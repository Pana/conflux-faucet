// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.8.0;

import "./SponsorWhitelistControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Faucet {
    // lastTokenClaimRecord[tokenContractAddress][msg.sender] = lastClaimTimestamp
    // 特殊地，0地址视为CFX的地址
    mapping(address => mapping(address => uint256)) lastTokenClaimRecord;

    struct ClaimSetting {
        uint256 amount;
        uint256 interval;
    }

    // 每类代币的interval和amount可以单独设置
    // 特殊地，0地址视为CFX的地址
    mapping(address => ClaimSetting) tokenClaimSettings;

    // 两次领取的默认最小间隔 与 默认领取token的数量
    // 当 tokenClaimSetting 中对应值为 0 时（即未设置） 会调用默认值
    uint256 public defaultInterval = 3600 seconds;
    uint256 public defaultAmount = 1000 * 1e18;

    address internal _manager;

    constructor() public {
        _manager = msg.sender;
        SponsorWhitelistControl cpc =
            SponsorWhitelistControl(0x0888000000000000000000000000000000000001);
        address[] memory a = new address[](1);
        a[0] = address(0);
        cpc.addPrivilege(a);
    }

    modifier onlyManager {
        require(msg.sender == _manager, "Sender is not manager");
        _;
    }

    function changeManager(address newManager) public onlyManager {
        _manager = newManager;
    }

    function getClaimInterval(address tokenContractAddress) public view returns (uint256) {
        uint256 claimInterval = tokenClaimSettings[tokenContractAddress].interval;
        if (claimInterval != 0) {
            return claimInterval;
        }
        return defaultInterval;
    }

    function getClaimAmount(address tokenContractAddress) public view returns (uint256) {
        uint256 claimAmount = tokenClaimSettings[tokenContractAddress].amount;
        if (claimAmount != 0) {
            return claimAmount;
        }
        return defaultAmount;
    }

    function setDefaultIntervalSeconds(uint256 intervalSeconds) public onlyManager {
        defaultInterval = intervalSeconds;
    }

    function setDefaultAmount(uint256 cfxAmount) public onlyManager {
        defaultAmount = cfxAmount * 1e18;
    }

    /**
    @param tokenContractAddress 代币地址。如果传入0地址代表设置的是CFX
    @param interval 领取的间隔 单位为秒
    @param amountForDecimals 设置每次领取Token的整数部分，与decimals 一起使用，领取额度为 amountForDecimals * (10^decimals)
    @param decimals 设置每次领取 Token 的数位，与 amountForDecimals 一起使用，领取额度为 amountForDecimals * (10^decimals)
     */
    function setClaimSetting(address tokenContractAddress, uint256 interval, uint256 amountForDecimals, uint256 decimals) public onlyManager {
        tokenClaimSettings[tokenContractAddress].interval = interval;
        tokenClaimSettings[tokenContractAddress].amount = amountForDecimals * (10**decimals);
    }

    function nextCfxClaim() public view returns (uint256) {
        return nextTokenClaim(address(0));
    }

    function nextTokenClaim(address tokenContractAddress)
        public
        view
        returns (uint256)
    {
        uint256 lastTs = lastTokenClaimRecord[tokenContractAddress][msg.sender];
        uint256 interval = getClaimInterval(tokenContractAddress);
        if (lastTs == 0 || block.timestamp - lastTs < interval) {
            return 0;
        } else {
            return block.timestamp - lastTs - interval;
        }
    }

    function claimToken(address tokenContractAddress) public {
        uint256 lastTs = lastTokenClaimRecord[tokenContractAddress][msg.sender];
        uint256 interval = getClaimInterval(tokenContractAddress);
        uint256 amount = getClaimAmount(tokenContractAddress);

        require(
            block.timestamp - lastTs > interval,
            "Claim Interval too short"
        );

        lastTokenClaimRecord[tokenContractAddress][msg.sender] = block.timestamp;
        if (tokenContractAddress == address(0)) {
            require(
                address(this).balance >= amount,
                "There is no enough CFX in the faucet. Please notify the faucet admin"
            );
            msg.sender.transfer(amount);
            return;
        }
        require(
            IERC20(tokenContractAddress).balanceOf(address(this)) >= amount,
            "There is no enough token in the faucet. Please notify the faucet admin"
        );
        IERC20(tokenContractAddress).transfer(msg.sender, amount);
    }

    // 这个接口依然保留
    function claimCfx() public {
        return claimToken(address(0));
    }

    function claimTokenRegardingSenderBalance(address tokenContractAddress) public {
        uint256 amount = getClaimAmount(tokenContractAddress);

        if (tokenContractAddress == address(0)) {
            require(
                msg.sender.balance < amount,
                "There is enoungh CFX in sender's wallet"
            );
            lastTokenClaimRecord[tokenContractAddress][msg.sender] = block.timestamp;

            // will revert if there is no enough cfx balance
            require(
                address(this).balance >= amount,
                "No enough CFX in token pool. Please notify the faucet admin"
            );
            msg.sender.transfer(amount - msg.sender.balance);
        } else {
            uint256 balance = IERC20(tokenContractAddress).balanceOf(msg.sender);
            require(
                balance < amount,
                "There is enoungh token balance in sender's wallet"
            );

            uint256 faucetBalance = IERC20(tokenContractAddress).balanceOf(address(this));
            require(
                faucetBalance >= amount,
                "No enough token in token pool. Please notify the faucet admin"
            );
            IERC20(tokenContractAddress).transfer(msg.sender, amount - balance);
        }

        lastTokenClaimRecord[tokenContractAddress][msg.sender] = block.timestamp;
    }

    // 接口仍然保留
    function claimCfxRegardingSenderBalance() public {
        return claimTokenRegardingSenderBalance(address(0));
    }

    // 接受CFX转账时触发
    receive() external payable {}
}
