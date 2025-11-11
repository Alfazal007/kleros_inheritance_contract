// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Test} from "forge-std/Test.sol";
import {Inheritance} from "../src/Inheritance.sol";
import {RejectingContract} from "../src/RejectingContract.sol";

contract RejectUnknownPaymentTest is Test {
    Inheritance public inheritance;
    address public firstHeir = 0x76eF1456aF7D8335dFf0888a5B08485eeF178f5a;

    function setUp() public {
        inheritance = new Inheritance{value: 10 ether}(firstHeir);
        vm.deal(firstHeir, 100 ether);
    }

    function testReceiveFunctionRevertsDirectTransfers() public {
        vm.expectRevert(Inheritance.RejectUnknownExternalPayment.selector);
        payable(address(inheritance)).transfer(1 ether);
    }
}
