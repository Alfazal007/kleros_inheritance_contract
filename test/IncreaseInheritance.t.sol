// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Test} from "forge-std/Test.sol";
import {Inheritance} from "../src/Inheritance.sol";

/*
    function increaseInheritance() public payable onlyOwner {
        inheritanceAmount += msg.value;
        lastInteractedAt = block.timestamp;
        emit InheritanceIncreased(msg.sender, msg.value, inheritanceAmount);
    }
*/

contract InheritanceIncreaseTest is Test {
    Inheritance public inheritance;
    address public firstHeir = 0x76eF1456aF7D8335dFf0888a5B08485eeF178f5a;

    function setUp() public {
        inheritance = new Inheritance{value: 10 ether}(firstHeir);
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
        inheritance.increaseInheritance{value: 2 ether}();
        vm.stopPrank();
    }

    function test_increasedBalanceAmount() public {
        assertEq(inheritance.inheritanceAmount(), 10 ether);
        vm.expectEmit(true, false, false, true);
        emit Inheritance.InheritanceIncreased(address(this), 3 ether, 13 ether);
        inheritance.increaseInheritance{value: 3 ether}();
        assertEq(inheritance.inheritanceAmount(), 13 ether);
        assertEq(inheritance.lastInteractedAt(), block.timestamp);
    }

    function test_blockTimeUpdates() public {
        uint256 remainingTimeToClaim = inheritance.getRemainingTimeUntilClaim();
        assertEq(remainingTimeToClaim, 30 days);
        uint256 start = block.timestamp;
        vm.warp(start + 15 days);
        remainingTimeToClaim = inheritance.getRemainingTimeUntilClaim();
        assertEq(remainingTimeToClaim, 15 days);
        inheritance.increaseInheritance{value: 3 ether}();
        remainingTimeToClaim = inheritance.getRemainingTimeUntilClaim();
        assertEq(remainingTimeToClaim, 30 days);
    }
}
