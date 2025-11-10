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
        inheritance = new Inheritance{value: 10 ether}(firstHeir, 10 ether);
        vm.deal(firstHeir, 100 ether);
        vm.deal(secondHeir, 100 ether);
    }

    function testNonHeirCalling() public {
        vm.expectRevert(Inheritance.CallerCanOnlyBeHeir.selector);
        inheritance.takeOverAfterAMonth(secondHeir);
        vm.startPrank(secondHeir);
        vm.expectRevert(Inheritance.CallerCanOnlyBeHeir.selector);
        inheritance.takeOverAfterAMonth(secondHeir);
        vm.stopPrank();
    }

    function testEmptyHeir() public {
        vm.startPrank(firstHeir);
        vm.expectRevert(Inheritance.EmptyHeir.selector);
        inheritance.takeOverAfterAMonth(address(0));
        vm.stopPrank();
    }

    function testOwnHeir() public {
        vm.startPrank(firstHeir);
        vm.expectRevert(Inheritance.CannotBeOwnHeir.selector);
        inheritance.takeOverAfterAMonth(firstHeir);
        vm.stopPrank();
    }

    function testCallBeforeMonthElapse() public {
        vm.startPrank(firstHeir);
        vm.expectRevert(Inheritance.MonthTimeNotElapsedYet.selector);
        inheritance.takeOverAfterAMonth(secondHeir);
        vm.warp(15 days);
        vm.expectRevert(Inheritance.MonthTimeNotElapsedYet.selector);
        inheritance.takeOverAfterAMonth(secondHeir);
        vm.stopPrank();
    }

    function testValidEmitEvents() public {
        address prevOwner = address(this);
        vm.startPrank(firstHeir);
        vm.warp(31 days);
        vm.expectEmit(true, true, true, false);
        emit Inheritance.TakeOverAfterAMonth(prevOwner, firstHeir, secondHeir);
        inheritance.takeOverAfterAMonth(secondHeir);
        vm.stopPrank();
    }

    function testStateBeforeAndAfterTakeOver() public {
        address prevOwner = inheritance.owner();
        address prevHeir = inheritance.heir();
        assertEq(prevOwner, address(this));
        assertEq(prevHeir, firstHeir);
        vm.startPrank(firstHeir);
        vm.warp(31 days);
        inheritance.takeOverAfterAMonth(secondHeir);
        vm.stopPrank();
        address newOwner = inheritance.owner();
        address newHeir = inheritance.heir();
        assertEq(newOwner, firstHeir);
        assertEq(newHeir, secondHeir);
        vm.warp(block.timestamp + 2 days);
        uint256 timeLatest = inheritance.getRemainingTimeUntilClaim();
        assertEq(timeLatest, 28 days);
    }
}

