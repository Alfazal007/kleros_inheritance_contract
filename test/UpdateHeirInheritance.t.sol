// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Test} from "forge-std/Test.sol";
import {Inheritance} from "../src/Inheritance.sol";

contract UpdateHeirInheritanceTest is Test {
    Inheritance public inheritance;
    address public firstHeir = 0x76eF1456aF7D8335dFf0888a5B08485eeF178f5a;
    address public secondHeir = 0x0BA0b7289DeD9E86D05E569Ba3d5056AaFE64070;

    function setUp() public {
        inheritance = new Inheritance{value: 32}(firstHeir);
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
        inheritance.updateHeir(firstHeir);
        vm.stopPrank();
    }

    function test_emptyHeir() public {
        vm.expectRevert(Inheritance.EmptyHeir.selector);
        inheritance.updateHeir(address(0));
    }

    function test_sameHeir() public {
        vm.expectRevert(Inheritance.SameHeir.selector);
        inheritance.updateHeir(firstHeir);
    }

    function test_ownerCannotBeHeir() public {
        vm.expectRevert(Inheritance.CannotBeOwnHeir.selector);
        inheritance.updateHeir(address(this));
    }

    function test_updateHeirAndEmit() public {
        assertEq(inheritance.owner(), address(this));
        assertEq(inheritance.heir(), firstHeir);
        vm.expectEmit(true, true, true, false);
        emit Inheritance.HeirUpdated(address(this), firstHeir, secondHeir);
        inheritance.updateHeir(secondHeir);
        assertEq(inheritance.owner(), address(this));
        assertEq(inheritance.heir(), secondHeir);
    }

    function test_blockTimeUpdates() public {
        uint256 remainingTimeToClaim = inheritance.getRemainingTimeUntilClaim();
        assertEq(remainingTimeToClaim, 30 days);
        uint256 start = block.timestamp;
        vm.warp(start + 15 days);
        remainingTimeToClaim = inheritance.getRemainingTimeUntilClaim();
        assertEq(remainingTimeToClaim, 15 days);
        inheritance.updateHeir(0x0b86C19D7a8bd6277FDC563270eF999E84dd85e3);
        remainingTimeToClaim = inheritance.getRemainingTimeUntilClaim();
        assertEq(remainingTimeToClaim, 30 days);
    }
}

