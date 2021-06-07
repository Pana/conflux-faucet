import { default as faucet } from "../../../build/contracts/Faucet.json";

// 水龙头合约地址
// 要求为 CIP-37 格式的测试网地址
// 1000 cfx each claim, 3600s interval
const faucetAddress = "cfxtest:acdr3ygpy4v46udjy6649czu2cutr226e2zhus1uf1";

/** 
 * faucetContractConfig[netId] = { abi, bytecode, address }
 * */ 
const faucetContractConfig = {
  1: { abi: faucet.abi, bytecode: faucet.bytecode, address: faucetAddress },
  "1": { abi: faucet.abi, bytecode: faucet.bytecode, address: faucetAddress },
  // 1029: { abi: faucet.abi, bytecode: faucet.bytecode, address: faucetAddress }
};

export default faucetContractConfig;
