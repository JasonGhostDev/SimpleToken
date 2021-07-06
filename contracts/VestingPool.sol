// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./interfaces/ISimpleToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract VestingPool is Ownable, ReentrancyGuard {
    struct InvestorInfo {
        uint256 investedTime;         
        uint256 endTime;   
        uint256 cliffPeriod;
        uint256 tokenAmount;
    }
    // Address of the ERC20 Token contract.
    ISimpleToken public erc20;
    // Info of each Investors.
    mapping (address => InvestorInfo) public investorsInfo;
    constructor(ISimpleToken _erc20) {
        erc20 = _erc20;  
    }

    function addInvestor(address _investorAddress, uint256 _endTime, uint256 _clif, uint256 _amount) external onlyOwner {
        investorsInfo[_investorAddress] = InvestorInfo({
            investedTime:block.timestamp,
            endTime: _endTime,
            cliffPeriod: _clif, 
            tokenAmount: _amount
        });
    }
    function removeInvestor(address _investorAddress) external onlyOwner {
        delete(investorsInfo[_investorAddress]);
    }
    function claimReard() external {
       uint256 rewardAmount = calculateReward(msg.sender);
       require(rewardAmount < erc20.balanceOf(address(this)), "less fund");
       if(rewardAmount > 0)
       {
           erc20.Transfer(msg.sender, rewardAmount);
       }
    }
    function calculateReward(address _investorAddr) external view returns (uint256) {
        uint256 time = block.timestamp;
        InvestorInfo storage investor = investorsInfo[_investorAddr];
        if (time < investor.cliff) {
         return 0;
        }
        if (time >= investor.endTime) {
         return investor.amount;
        }
        return investor.amount.mul(time.sub(investor.investedTime)).div(investor.endTime.sub(investor.investedTime));
    }

}