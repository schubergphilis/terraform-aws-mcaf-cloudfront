import {SSM} from "aws-sdk";

let _config: Config | null = null;

export interface Config {
    client_id: string;
    client_secret: string;
    private_key: string;
    public_key: string;
    scope: string;
    grant_type: string;
    response_type: string;
    redirect_uri: string;
    okta_org_name: string;
    session_duration: number;
}

export async function getConfig(distributionId: string): Promise<Config | null> {
    if (_config === null) {
        console.log("No config found. Retrieving from SSM...");

        _config = {
            client_id: "",
            client_secret: "",
            private_key: "",
            public_key: "",
            okta_org_name: "",
            redirect_uri: "",
            scope: "openid email",
            grant_type:  "authorization_code",
            response_type:  "code",
            session_duration: 43200,
        };

        const ssm = new SSM({region: "us-east-1"});
        const prefix = `/cloudfront-config/${distributionId}`;
        const result = ssm.getParameters({
            Names: [
                `${prefix}/client_id`,
                `${prefix}/client_secret`,
                `${prefix}/private_key`,
                `${prefix}/public_key`,
                `${prefix}/okta_org_name`,
                `${prefix}/redirect_uri`,
                `${prefix}/scope`,
                `${prefix}/grant_type`,
                `${prefix}/response_type`,
                `${prefix}/session_duration`,
            ],
            WithDecryption: true
        });

        const resp = await result.promise();
        for (let param of resp.Parameters) {
            _config[param.Name.replace(`${prefix}/`, "")] = param.Value;
        }
    }

    for (let [key, value] of Object.entries(_config)) {
        if (value === "") {
            _config = null;
            throw new Error(`Required configuration not set in the environment: ${key.toUpperCase()}`)
        }
    }

    return _config;
}
