import { default as ERC20 } from "../../../build/contracts/IERC20.json";
import { default as faucet } from "../../../build/contracts/Faucet.json";

const options = [
  {
    contractName: "GLD",
    label: "测试Token GLD",
    address: "cfxtest:ace0ea1x6st1spm1jwfces43tder2yewz2vtx8hxrt"
  },
  {
    contractName: "DMD",
    label: "测试Token DMD",
    address: "cfxtest:type.contract:acg4kb024uwn2cr9682s5ar0yk7zx2vuja20bwrx46",
    disabled: false
  },
  {
    contractName: "BIGGLD",
    label: "测试Token BIG GLD",
    address: "cfxtest:type.contract:acd29kfdf8wyz41dczw1sj9jua9523047681m9rjfs",
    disabled: false
  }
];

// 1 cfx each claim, 120s interval
const faucetAddress = "cfxtest:acc31bu3vaeabm8zkkrd3uhdugnesk148aaxhdewfg";

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
