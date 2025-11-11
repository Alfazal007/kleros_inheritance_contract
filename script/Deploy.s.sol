// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Inheritance.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        Inheritance inheritanceContract = new Inheritance{value: 100000000000000}(0x0BA0b7289DeD9E86D05E569Ba3d5056AaFE64070);
        vm.stopBroadcast();
        console.log("Deployed at:", address(inheritanceContract));
    }
}

