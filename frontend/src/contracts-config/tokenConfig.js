import { abi } from "../../../build/contracts/IERC20.json";

/*
 options 数组中为支持的代币
 需要新增代币时只需要向 options 数组中增加新的对象即可
 数组内元素的顺序与前端显示的顺序一致
*/
const options = [
  {
    /*
    这个地址是测试网的零地址，特殊地，在 Faucet.sol 中该地址会被视为CFX的地址
    使用零地址时往往要小心，零地址作为部分交易的 to 参数时，意味着代币的销毁
    但在水龙头Dapp中，Token合约的地址只被用作水龙头合约部分 claim 的参数

    最坏的情况是该合约被视为ERC20合约，被调用了 ERC20 的相应接口，这最多只会产生抛出一个在开发阶段就容易解决的错误
    */
    address: "cfxtest:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa6f0vrcsw",
    label: "CFX",
    symbol: "CFX"
  },
  {
    address: "cfxtest:achkx35n7vngfxgrm7akemk3ftzy47t61yk5nn270s",
    label: "FansCoin",
    symbol: "FC",
  },
  {
    address: "cfxtest:acepe88unk7fvs18436178up33hb4zkuf62a9dk1gv",
    label: "conflux USDT",
    symbol: "cUSDT",
  },
];

/**
  tokenConfig[symbol] = {
    abi,
    // bytecode,
    address,
    label
  }
*/
let tokenConfig = {};
options.forEach(option => {
  tokenConfig[option.symbol] = {
    abi,
    // bytecode: ERC20.bytecode,
    address: option.address,
    label: option.label,
  };
});

export default tokenConfig;
