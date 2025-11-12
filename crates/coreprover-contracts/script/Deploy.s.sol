// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/CoreProverEscrow.sol";
import "../src/ReceiptVault.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        CoreProverEscrow escrow = new CoreProverEscrow();
        ReceiptVault vault = new ReceiptVault();

        console.log("CoreProverEscrow deployed at:", address(escrow));
        console.log("ReceiptVault deployed at:", address(vault));

        vm.stopBroadcast();
    }
}
