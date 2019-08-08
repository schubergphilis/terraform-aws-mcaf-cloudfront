import {randomBytes, createHmac} from "crypto"

export function getNonce() {
    const nonce = randomBytes(32)
        .toString("hex");
    const hash = createHmac("sha256", nonce)
        .digest("hex");
    return [nonce, hash];
}

export function validateNonce(nonce, hash) {
    const other = createHmac("sha256", nonce)
        .digest("hex");
    return (other == hash);
}
