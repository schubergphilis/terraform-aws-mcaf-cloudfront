import {CloudFrontRequest, CloudFrontRequestCallback} from "aws-lambda";
import {parse, stringify} from "querystring";
import axios from "axios";
import jwt from "jsonwebtoken"
import jwkToPem from "jwk-to-pem"

import {Config} from "./config";
import {unauthorized} from "./unauthorized";
import {internalServerError} from "./internalservererror";
import {getJSONWebKeys} from "./jwk";
import {redirect} from "./redirect";
import {serialize} from "cookie";
import {validateNonce} from "./nonce";
import {getCookie} from "./cookie";

const KNOWN_ERRORS = {
    "invalid_request": "Invalid Request",
    "unauthorized_client": "Unauthorized Client",
    "access_denied": "Access Denied",
    "unsupported_response_type": "Unsupported Response Type",
    "invalid_scope": "Invalid Scope",
    "server_error": "Server Error",
    "temporarily_unavailable": "Temporarily Unavailable"
};

export async function handleCallback(config: Config, request: CloudFrontRequest, callback: CloudFrontRequestCallback) {
    console.log("Callback from Okta received");

    const queryDict = parse(request.querystring);

    // Check for error response (https://tools.ietf.org/html/rfc6749#section-4.2.2.1)
    if (queryDict.error) {
        console.log("Received error in callback");

        let error = KNOWN_ERRORS[<string>queryDict.error] || queryDict.error;
        let error_description = queryDict.error_description || "";
        let error_uri = queryDict.error_uri || "";

        unauthorized(error, error_description, error_uri, callback);
    }
    // Verify code is in querystring
    else if (!queryDict.code) {
        unauthorized("No Code Found", "", "", callback);
    }
    else {
        // Exchange code for authorization token
        console.log("Requesting access token.");
        try {
            let response = await axios.post(`https://${config.okta_org_name}.okta-emea.com/oauth2/v1/token`, stringify({
                code: queryDict.code,
                client_id: config.client_id,
                client_secret: config.client_secret,
                redirect_uri: config.redirect_uri,
                grant_type: config.grant_type,
            }));

            let decodedData = jwt.decode(response.data.id_token, {complete: true});
            console.log("Succesfully retrieved and decoded access token", decodedData);

            // Search for correct JWK and create PEM
            let pem = "";
            let jwks = await getJSONWebKeys(config, callback);
            for (let i = 0; i < jwks.keys.length; i++) {
                if (decodedData.header.kid === jwks.keys[i].kid) {
                    pem = jwkToPem(jwks.keys[i]);
                }
            }

            console.log("Verifying JWT...");
            jwt.verify(response.data.id_token, pem, { algorithms: ['RS256'] }, (err, decoded) => {
                if (err) {
                    switch (err.name) {
                        case 'TokenExpiredError':
                            console.log("Token expired, redirecting to OIDC provider.");
                            redirect(config, request, callback);
                            break;
                        case 'JsonWebTokenError':
                            console.log("JWT error, unauthorized.");
                            unauthorized('Json Web Token Error', err.message, '', callback);
                            break;
                        default:
                            console.log("Unknown JWT error, unauthorized.");
                            unauthorized('Unknown JWT', 'User ' + decodedData.payload.email + ' is not permitted.', '', callback);
                    }
                }
                else {
                    // Validate nonce
                    const cookie = getCookie(request.headers);
                    if ("NONCE" in cookie && validateNonce(decoded.nonce, cookie.NONCE)) {
                        console.log("Setting cookie and redirecting.");

                        // Once verified, create new JWT for this server
                        const response = {
                            "status": "302",
                            "statusDescription": "Found",
                            "body": "ID token retrieved.",
                            "headers": {
                                "location" : [
                                    {
                                        "key": "Location",
                                        "value": <string>queryDict.state
                                    }
                                ],
                                "set-cookie" : [
                                    {
                                        "key": "Set-Cookie",
                                        "value" : serialize('TOKEN', jwt.sign(
                                            { },
                                            config.private_key.trim(),
                                            {
                                                "audience": request.headers.host[0].value,
                                                "subject": decodedData.payload.email,
                                                "expiresIn": config.session_duration,
                                                "algorithm": "RS256"
                                            } // Options
                                        ), {
                                            path: '/',
                                            maxAge: config.session_duration
                                        })
                                    },
                                    {
                                        "key": "Set-Cookie",
                                        "value" : serialize('NONCE', '', {
                                            path: '/',
                                            expires: new Date(1970, 1, 1, 0, 0, 0, 0)
                                        })
                                    }
                                ],
                            },
                        };

                        callback(null, response);
                    }
                    else {
                        unauthorized('Nonce Verification Failed', '', '', callback);
                    }
                }
            });
        }
        catch (error) {
            console.log("Internal server error: " + error.message);
            internalServerError(callback);
        }
    }
}
