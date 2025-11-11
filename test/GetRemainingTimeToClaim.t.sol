// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Test} from "forge-std/Test.sol";
import {Inheritance} from "../src/Inheritance.sol";
import {console} from "../lib/forge-std/src/console.sol";

contract InheritanceIncreaseTest is Test {
    Inheritance public inheritance;
    address public firstHeir = 0x76eF1456aF7D8335dFf0888a5B08485eeF178f5a;
    address public secondHeir = 0x0BA0b7289DeD9E86D05E569Ba3d5056AaFE64070;

    function setUp() public {
        inheritance = new Inheritance{value: 10 ether}(firstHeir);
        vm.deal(firstHeir, 100 ether);
    }

    function testInitTimeToClaim() public {
        uint256 initTTC = inheritance.getRemainingTimeUntilClaim();
        assertEq(initTTC, 2592000);
        vm.warp(15 days);
        initTTC = inheritance.getRemainingTimeUntilClaim();
        assertEq(initTTC, 1296001);
    }

    function test30Days() public {
        uint256 initTTC = inheritance.getRemainingTimeUntilClaim();
        assertEq(initTTC, 2592000);
        vm.warp(30 days);
        initTTC = inheritance.getRemainingTimeUntilClaim();
        assertEq(initTTC, 1);
    }

    function testAfter30Days() public {
        uint256 initTTC = inheritance.getRemainingTimeUntilClaim();
        assertEq(initTTC, 2592000);
        vm.warp(32 days);
        initTTC = inheritance.getRemainingTimeUntilClaim();
        assertEq(initTTC, 0);
    }
}

