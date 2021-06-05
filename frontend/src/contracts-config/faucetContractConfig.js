import { default as faucet } from "../../../build/contracts/Faucet.json";

// 水龙头合约地址
// 要求为 CIP-37 格式的测试网地址
// 1000 cfx each claim, 3600s interval
const faucetAddress = "cfxtest:ace1huspbywtn2fvcs5zkjdvf909r0j576yfbgm0vx";

/** 
 * faucetContractConfig[netId] = { abi, bytecode, address }
 * */ 
const faucetContractConfig = {
  1: { abi: faucet.abi, bytecode: faucet.bytecode, address: faucetAddress },
  "1": { abi: faucet.abi, bytecode: faucet.bytecode, address: faucetAddress },
  // 1029: { abi: faucet.abi, bytecode: faucet.bytecode, address: faucetAddress }
};

export default faucetContractConfig;
