import {CloudFrontHeaders} from "aws-lambda";
import {parse} from "cookie";

export function getCookie(headers: CloudFrontHeaders): { [key: string]: string } {
    return "cookie" in headers ? parse(headers["cookie"][0].value) : {};
}
