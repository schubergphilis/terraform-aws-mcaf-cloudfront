import {CloudFrontRequest, CloudFrontRequestCallback} from "aws-lambda";
import jwt from "jsonwebtoken";

import {Config} from "./config";
import {redirect} from "./redirect";
import {unauthorized} from "./unauthorized";

export function verifyToken(token: string, config: Config, request: CloudFrontRequest, callback: CloudFrontRequestCallback) {
    console.log("Request received with TOKEN cookie. Validating.");
    // Verify the JWT, the payload email, and that the email ends with configured hosted domain
    jwt.verify(token, config.public_key.trim(), {algorithms: ["RS256"]}, (err, decoded) => {
        if (err) {
            switch (err.name) {
                case "TokenExpiredError":
                    console.log("Token expired, redirecting to OIDC provider.");
                    redirect(config, request, callback)
                    break;
                case "JsonWebTokenError":
                    console.log("JWT error, unauthorized.");
                    unauthorized("Json Web Token Error", err.message, "", callback);
                    break;
                default:
                    console.log("Unknown JWT error, unauthorized.");
                    unauthorized("Unauthorized.", "User " + decoded.sub + " is not permitted.", "", callback);
            }
        } else {
            console.log("Authorizing user.");
            callback(null, request);
        }
    });
}
