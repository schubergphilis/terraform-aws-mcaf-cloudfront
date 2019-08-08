import {Handler, Context, CloudFrontRequestEvent, CloudFrontRequestCallback} from "aws-lambda";

import {getConfig} from "./lib/config";
import {redirect} from "./lib/redirect";
import {handleCallback} from "./lib/callback";
import {getCookie} from "./lib/cookie";
import {verifyToken} from "./lib/verify";

export const handler: Handler = async (
    event: CloudFrontRequestEvent,
    context: Context,
    callback: CloudFrontRequestCallback
) => {
    console.log("Event: ", JSON.stringify(event));

    const cloudfrontRecord = event.Records[0].cf;
    const request = cloudfrontRecord.request;
    const config = await getConfig(cloudfrontRecord.config.distributionId);
    const cookie = getCookie(request.headers);

    if (request.uri.startsWith("/_callback")) {
        await handleCallback(config, request, callback);
    } else if ("TOKEN" in cookie) {
        verifyToken(cookie.TOKEN, config, request, callback);
    } else {
        console.log("No authentication session found. Redirecting to Okta...");
        redirect(config, request, callback);
    }
}
