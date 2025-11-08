// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "../lib/forge-std/src/console.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Test} from "forge-std/Test.sol";
import {Inheritance} from "../src/Inheritance.sol";
import {RejectingContract} from "../src/RejectingContract.sol";

contract WithdrawAndResetTest is Test {
    Inheritance public inheritance;
    RejectingContract rejectingContract;
    address public firstHeir = 0x76eF1456aF7D8335dFf0888a5B08485eeF178f5a;
    address public secondHeir = 0x0BA0b7289DeD9E86D05E569Ba3d5056AaFE64070;

    function setUp() public {
        inheritance = new Inheritance{value: 10 ether}(firstHeir, 10 ether);
        vm.deal(firstHeir, 100 ether);
        rejectingContract = new RejectingContract();
        vm.deal(address(rejectingContract), 100 ether);
    }

    function test_callNonOwner() public {
        vm.startPrank(firstHeir);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                firstHeir
            )
        );
        inheritance.withdrawAndResetCounter(1 ether);
        vm.stopPrank();
    }

    function test_InsufficientAmountInInheritance() public {
        vm.expectRevert(Inheritance.InsufficientAmountInInheritance.selector);
        inheritance.withdrawAndResetCounter(11 ether);
    }

    function test_TransferFailed() public {
        address mainOwner = address(this);
        inheritance.transferOwnership(address(rejectingContract));
        vm.startPrank(address(rejectingContract));
        vm.expectRevert(Inheritance.WithdrawFailed.selector);
        inheritance.withdrawAndResetCounter(5 ether);
        inheritance.transferOwnership(mainOwner);
        vm.stopPrank();
    }

    function test_TestEventAndWithdrawal() public {
        uint256 prevBalance = address(this).balance;
        assertEq(inheritance.inheritanceAmount(), 10 ether);
        vm.expectEmit(true, false, false, true);
        emit Inheritance.WithdrawalMade(address(this), 10 ether, 5 ether);
        inheritance.withdrawAndResetCounter(5 ether);
        assertEq(inheritance.inheritanceAmount(), 5 ether);
        assertEq(address(inheritance).balance, 5 ether);
        assertEq(address(this).balance, prevBalance + 5 ether);
    }

    function test_blockTimeUpdates() public {
        uint256 remainingTimeToClaim = inheritance.getRemainingTimeUntilClaim();
        assertEq(remainingTimeToClaim, 30 days);
        uint256 start = block.timestamp;
        vm.warp(start + 15 days);
        remainingTimeToClaim = inheritance.getRemainingTimeUntilClaim();
        assertEq(remainingTimeToClaim, 15 days);
        inheritance.withdrawAndResetCounter(5 ether);
        remainingTimeToClaim = inheritance.getRemainingTimeUntilClaim();
        assertEq(remainingTimeToClaim, 30 days);
    }

    // this is required to receive the eth as this is a contract account and not an eoa
    receive() external payable {}
}

