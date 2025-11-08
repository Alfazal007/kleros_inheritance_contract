// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Inheritance} from "../src/Inheritance.sol";

contract InheritanceConstructorTest is Test {
    address public firstHeir = 0x76eF1456aF7D8335dFf0888a5B08485eeF178f5a;
    address public secondHeir = 0x0BA0b7289DeD9E86D05E569Ba3d5056AaFE64070;

    function test_zeroAmountRevert() public {
        vm.expectRevert(Inheritance.ZeroAmountNotAllowed.selector);
        new Inheritance(firstHeir, 0);
    }

    function test_zeroAddressRevert() public {
        vm.expectRevert(Inheritance.ZeroAddressNotAllowedForHeir.selector);
        new Inheritance(address(0), 1 ether);
    }

    function test_ownHeirRevert() public {
        vm.expectRevert(Inheritance.CannotBeOwnHeir.selector);
        new Inheritance(address(this), 1 ether);
    }

    function test_mismatchAmountRevert() public {
        vm.expectRevert(Inheritance.MismatchAmount.selector);
        new Inheritance{value: 32}(firstHeir, 10 ether);
    }

    function test_successfulDeployment() public {
        vm.expectEmit(true, true, false, true);
        emit Inheritance.InheritanceCreated(address(this), firstHeir, 10 ether);
        Inheritance inheritance = new Inheritance{value: 10 ether}(firstHeir, 10 ether);
        assertEq(10 ether, inheritance.inheritanceAmount());
        assertEq(firstHeir, inheritance.heir());
        assertEq(block.timestamp, inheritance.lastInteractedAt());
    }
}
