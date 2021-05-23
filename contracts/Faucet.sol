// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Faucet {
    // lastTokenClaimRecord[tokenContractAddress][msg.sender] = lastClaimTimestamp
    mapping(address => mapping(address => uint256)) lastTokenClaimRecord;
    
    mapping(address => uint256) lastCfxClaimRecord;

    // 两次领取的间隔
    uint256 public interval = 120 seconds;

    // 更改默认Claim token的数量
    uint256 public defaultAmount = 1e18;

    address internal _manager;


    // constructor(uint _interval, uint256 _defaultAmount) public {
    constructor() public {
        // interval = _interval;
        // defaultAmount = _defaultAmount;
        _manager = msg.sender;
    }

    modifier onlyManager {
        require(msg.sender == _manager, "Sender is not manager");
        _;
    }

    function changeManager(address newManager) public onlyManager {
        _manager = newManager;
    }

    //
    function changeIntervalSeconds(uint256 intervalSeconds) public onlyManager {
        interval = intervalSeconds;
    }

    function changeDefaultAmount(uint256 cfxAmount) public onlyManager {
        defaultAmount = cfxAmount * 1e18;
    }

    function nextCfxClaim()
        public
        view
        returns (uint256)
    {
        uint256 lastTs = lastCfxClaimRecord[msg.sender];
        if (lastTs == 0 || block.timestamp - lastTs < interval) {
            return 0;
        } else {
            return block.timestamp - lastTs - interval;
        }
    }
    function nextTokenClaim(address tokenContractAddress)
        public
        view
        returns (uint256)
    {
        uint256 lastTs = lastTokenClaimRecord[tokenContractAddress][msg.sender];
        if (lastTs == 0 || block.timestamp - lastTs < interval) {
            return 0;
        } else {
            return block.timestamp - lastTs - interval;
        }
    }

    function claimToken(address tokenContractAddress) public {
        uint256 lastTs = lastTokenClaimRecord[tokenContractAddress][msg.sender];
        require(
            block.timestamp - lastTs > interval,
            "Claim interval too short"
        );
        lastTokenClaimRecord[tokenContractAddress][msg.sender] = block
            .timestamp;
        IERC20(tokenContractAddress).transfer(msg.sender, defaultAmount);
    }

    function claimCfx() public payable {
        uint256 lastTs = lastCfxClaimRecord[msg.sender];
        require(
            block.timestamp - lastTs > interval,
            "Claim interval too short"
        );
        lastCfxClaimRecord[msg.sender] = block.timestamp;
        // will revert if there is no enough cfx balance
        msg.sender.transfer(defaultAmount);
    }

    // 接受CFX转账时触发
    receive() external payable {}
}
