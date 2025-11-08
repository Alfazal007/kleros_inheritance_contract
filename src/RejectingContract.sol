// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract RejectingContract {
    receive() external payable {
        revert();
    }
}
