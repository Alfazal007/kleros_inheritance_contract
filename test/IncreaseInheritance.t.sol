// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Test} from "forge-std/Test.sol";
import {Inheritance} from "../src/Inheritance.sol";

contract InheritanceIncreaseTest is Test {
    Inheritance public inheritance;
    address public firstHeir = 0x76eF1456aF7D8335dFf0888a5B08485eeF178f5a;
    address public secondHeir = 0x0BA0b7289DeD9E86D05E569Ba3d5056AaFE64070;

    function setUp() public {
        inheritance = new Inheritance{value: 10 ether}(firstHeir, 10 ether);
        vm.deal(firstHeir, 100 ether);
    }

    function test_callNonOwner() public {
        vm.startPrank(firstHeir);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                firstHeir
            )
        );
        inheritance.increaseInheritance{value: 2 ether}(2 ether);
        vm.stopPrank();
    }

    function test_increaseAmountByZero() public {
       vm.expectRevert(Inheritance.ZeroAmountNotAllowed.selector);
       inheritance.increaseInheritance(0);
       vm.expectRevert(Inheritance.ZeroAmountNotAllowed.selector);
       inheritance.increaseInheritance{value: 0}(0);
    }

    function test_amountMismatch() public {
       vm.expectRevert(Inheritance.MismatchAmount.selector);
       inheritance.increaseInheritance{value: 2 ether}(3 ether);
    }

    function test_increasedBalanceAmount() public {
        assertEq(inheritance.inheritanceAmount(), 10 ether);
        vm.expectEmit(true, false, false, true);
        emit Inheritance.InheritanceIncreased(address(this), 3 ether, 13 ether);
        inheritance.increaseInheritance{value: 3 ether}(3 ether);
        assertEq(inheritance.inheritanceAmount(), 13 ether);
    }
}
