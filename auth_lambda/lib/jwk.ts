import {CloudFrontRequestCallback} from "aws-lambda";
import axios from "axios"

import {Config} from "./config";
import {internalServerError} from "./internalservererror";

let _jwks = null;

export async function getJSONWebKeys(config: Config, callback: CloudFrontRequestCallback): Promise<any> {
    if (_jwks === null) {
        try {
            console.log("Retrieving JSON Web Keys...");
            let response = await axios.get(`https://${config.okta_org_name}.okta-emea.com/oauth2/v1/keys`);
            _jwks = response.data;
            console.log("Updated JSON Web Keys: ", _jwks);
        } catch(error) {
            console.log("Internal server error: " + error.message);
            internalServerError(callback);
        }
    }

    return _jwks;
}
