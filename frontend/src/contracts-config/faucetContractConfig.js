import { abi } from "../../../build/contracts/Faucet.json";

// 水龙头合约地址
// 要求为 CIP-37 格式的测试网地址
// 1000 cfx each claim, 3600s interval
const faucetAddress = "NET8888:TYPE.CONTRACT:ACDKDB5RYVBV7VKUU9JEWRAFJ2HAHF2YHJVX118BMA";

/** 
 * faucetContractConfig[netId] = { abi, address }
 * */ 
const faucetContractConfig = {
  // 1: { abi, address: faucetAddress },
  8888: { abi, address: faucetAddress },
  // 1029: { abi: abi, address: faucetAddress }
};

export default faucetContractConfig;
