import {Config} from "./config";
import {getNonce} from "./nonce";
import {serialize} from "cookie";
import {stringify} from "querystring";

export function redirect(config: Config, request, callback) {
    const n = getNonce();

    // Redirect to Authorization Server
    let querystring = stringify({
        client_id: config.client_id,
        response_type: config.response_type,
        scope: config.scope,
        redirect_uri: config.redirect_uri,
        nonce: n[0],
        state: request.uri,
    });

    const response = {
        "status": "302",
        "statusDescription": "Found",
        "body": "Redirecting to OIDC provider",
        "headers": {
            "location" : [{
                "key": "Location",
                "value": `https://${config.okta_org_name}.okta-emea.com/oauth2/v1/authorize?${querystring}`
            }],
            "set-cookie" : [
                {
                    "key": "Set-Cookie",
                    "value" : serialize("TOKEN", "", {
                        path: "/",
                        expires: new Date(1970, 1, 1, 0, 0, 0, 0),
                        secure: true
                    })
                },
                {
                    "key": "Set-Cookie",
                    "value" : serialize("NONCE", n[1], {
                        path: "/",
                        httpOnly: true,
                        secure: true
                    })
                }
            ],
        },
    };

    callback(null, response);
}
