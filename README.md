# Conflux 测试网水龙头

开发者或用户可以使用 Conflux 测试网水龙头获取 Conflux 测试网 CFX 或 CRC20 代币。
- [Conflux 测试网水龙头](#conflux-测试网水龙头)
  - [项目主体结构](#项目主体结构)
  - [环境配置](#环境配置)
  - [前端命令说明](#前端命令说明)
    - [启动前端开发环境](#启动前端开发环境)
    - [生成前端静态文件](#生成前端静态文件)
    - [部署静态文件](#部署静态文件)
  - [前端配置说明](#前端配置说明)
  - [编译合约（可选）](#编译合约可选)
  - [修改水龙头合约配置](#修改水龙头合约配置)
  - [TODOS](#todos)
## 项目主体结构

项目大体分为 `solidity` 合约与 `vue` 前端两部分。

- `/contracts` 与 `/build/contracts` 为合约部分。其中 `/contracts` 中为 `solidity` 合约源码，`/build/contracts` 为编译后得到的 `JSON` 文件。
- `/frontend` 中为 `vue` 前端的源码。

## 环境配置

安装依赖

```bash
npm install
```

本项目中合约已经编译完毕(于`/build/contracts`)，未修改合约前不必再次编译。  
如果需要编译合约，需要安装 `truffle` 或 `cfxtruffle`。
> 其余 `solidity` 编译工具理论上也可以使用，但是没有进行过测试

```bash
npm install -g conflux-truffle
```

此外，本项目前端依赖于浏览器扩展 [Conflux Portal](https://portal.confluxnetwork.org/)

## 前端命令说明

前端基于 `vue-cli` 搭建，下面进行简单说明

### 启动前端开发环境

开发环境下允许热重载

```bash
cd ./frontend
npm run serve
```

### 生成前端静态文件

```bash
npm run build
```

需要说明的是，如果生成的静态文件将用于部署在二级域名下，则需要修改 `/frontend/vue.config.js` 文件。

```javascript
// vue.config.js
module.exports = {
    configureWebpack: {
        devtool: 'source-map',
    },
    publicPath: './', // 将publicPath变量修改为对应的二级目录路径
}
```

### 部署静态文件

```
npm run deploy
```

该命令会执行 `/frontend/deploy.sh` 脚本，将 `/frontend/dist` 文件中内容推送至远程对应的仓库与分支。如果提前部署了 github pages 类似的服务（或提前设置了远端仓库的钩子函数）可以实现部署的效果。

## 前端配置说明

水龙头合约地址与水龙头支持的代币种类通过读取前端的合约配置文件 `/frontend/src/contracts-config/index.js` 获取。下面简单介绍如何修改

```javascript
/*
 options 数组中为支持的代币
 需要新增代币时只需要向 options 数组中增加新的对象即可
*/
const options = [
  {
    contractName: "GLD", // 唯一标识符，数组内元素该字段不可重复
    label: "GLD - testnet token", // 前端页面会显示此名称
    address: "cfxtest:ace0ea1x6st1spm1jwfces43tder2yewz2vtx8hxrt" // 要求为 CIP-37 格式的测试网地址
  },
  // ....
];

// 水龙头合约地址
// 要求为 CIP-37 格式的测试网地址
const faucetAddress = "cfxtest:.........";
```

**此外，如果部署了新的合约或在配置列表中增加了新 Token，请向合约中转入足量的 Token，否则水龙头功能会因 CFX 余额不足或代币不足而缺失相应的功能。**

## 编译合约（可选）

之后使用 `cfxtruffle` 编译

```bash
cfxtruffle compile
```

## 修改水龙头合约配置

水龙头合约有两个初始配置参数分别为 `defaultAmount` 与 `interval`，分别代表用户每次领取的代币数量与用户两次领取之间的最小时间间隔(秒)。合约的管理者可以通过调用合约的下面两个接口进行修改。

``` solidity
function setIntervalSeconds(uint256 intervalSeconds) public onlyManager {
    interval = intervalSeconds;
}

function setDefaultAmount(uint256 cfxAmount) public onlyManager {
    defaultAmount = cfxAmount * 1e18;
}
```

## TODOS

- [ ] 用户自行添加合约
- [x] ui优化