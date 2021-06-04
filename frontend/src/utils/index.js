const testNetUrl = "https://testnet.confluxscan.io"
const mainNetUrl = "https://confluxscan.io"

const prefixMap = {
  1: testNetUrl,
  1029: mainNetUrl
}

// type: "transaction" or "address"
function getScanUrl(content, type, networkId) {
  return [prefixMap[parseInt(networkId)], type, content].join('/')
}

export {
  getScanUrl
};