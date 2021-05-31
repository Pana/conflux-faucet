import { default as ERC20 } from "../../../build/contracts/IERC20.json";
import { default as faucet } from "../../../build/contracts/Faucet.json";

/*
 options 数组中为支持的代币
 需要新增代币时只需要向 options 数组中增加新的对象即可
*/
const options = [
  {
    address: "cfxtest:achkx35n7vngfxgrm7akemk3ftzy47t61yk5nn270s",
    label: "FansCoin",
    contractName: "FC-testnet",
  },
  {
    address: "cfxtest:acab179g4xj369s16ufuaaku2bh6n52wwju2845cda",
    label: "conflux USDT",
    contractName: "cUSDT-testnet",
  },
  {
    contractName: "GLD", // 唯一标识符，数组内元素该字段不可重复
    label: "GLD - testnet token", // 前端页面会显示此名称
    address: "cfxtest:ace0ea1x6st1spm1jwfces43tder2yewz2vtx8hxrt" // 要求为 CIP-37 格式的测试网地址
  },
];

// 水龙头合约地址
// 要求为 CIP-37 格式的测试网地址
// 1 cfx each claim, 120s interval
const faucetAddress = "cfxtest:acdj471zng0njskpx3cuu7x3hyjnt3cbt66anu0bem";

let config = {};
options.forEach(option => {
  config[option.contractName] = {
    abi: ERC20.abi,
    bytecode: ERC20.bytecode,
    address: option.address,
    label: option.label,
    disabled: option.disabled
  };
});

// faucetContractConfig[netId]
const faucetContractConfig = {
  1: { abi: faucet.abi, bytecode: faucet.bytecode, address: faucetAddress },
  // 1029: { abi: faucet.abi, bytecode: faucet.bytecode, address: faucetAddress }
};

export { config, faucetContractConfig };
