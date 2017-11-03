export function fromAscii(str, padding) {
    let result = web3.fromAscii(str, padding);
    //web3.fromAscii(str, padding); - incorrect work and not add padding;
    return result + "0".repeat(padding * 2 - result.length + 2);
}

export function toAscii(str) {
    return web3.toAscii(str).replace(/\0/g, '');
}
