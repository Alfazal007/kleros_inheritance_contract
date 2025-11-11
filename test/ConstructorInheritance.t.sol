// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Inheritance} from "../src/Inheritance.sol";

contract InheritanceConstructorTest is Test {
    address public firstHeir = 0x76eF1456aF7D8335dFf0888a5B08485eeF178f5a;

    function test_zeroAddressRevert() public {
        vm.expectRevert(Inheritance.ZeroAddressNotAllowedForHeir.selector);
        new Inheritance(address(0));
    }

    function test_ownHeirRevert() public {
        vm.expectRevert(Inheritance.CannotBeOwnHeir.selector);
        new Inheritance(address(this));
    }

    function test_successfulDeployment() public {
        vm.expectEmit(true, true, false, true);
        emit Inheritance.InheritanceCreated(address(this), firstHeir, 10 ether);
        Inheritance inheritance = new Inheritance{value: 10 ether}(firstHeir);
        assertEq(10 ether, inheritance.inheritanceAmount());
        assertEq(firstHeir, inheritance.heir());
        assertEq(block.timestamp, inheritance.lastInteractedAt());
        assertEq(inheritance.getRemainingTimeUntilClaim(), 30 days);
    }

    function test_validZeroAmountDeployment() public {
        vm.expectEmit(true, true, false, true);
        emit Inheritance.InheritanceCreated(address(this), firstHeir, 0);
        new Inheritance(firstHeir);
    }
}
