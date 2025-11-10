// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Test} from "forge-std/Test.sol";
import {Inheritance} from "../src/Inheritance.sol";
import {RejectingContract} from "../src/RejectingContract.sol";

contract RejectUnknownPaymentTest is Test {
    RejectingContract public rejectPaymentContract;

    function setUp() public {
        rejectPaymentContract = new RejectingContract();
    }

    function testReceiveFunctionRevertsDirectTransfersForRejectContract() public {
        (bool success, ) = payable(address(rejectPaymentContract)).call{
            value: 1 ether
        }("");
        assertFalse(success, "Call should have failed");
    }
}
