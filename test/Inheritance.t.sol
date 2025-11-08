// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Inheritance} from "../src/Inheritance.sol";

contract InheritanceTest is Test {
    Inheritance public inheritance;
    address public firstHeir = 0x76eF1456aF7D8335dFf0888a5B08485eeF178f5a;
    address public secondHeir = 0x0BA0b7289DeD9E86D05E569Ba3d5056AaFE64070;

    function setUp() public {
        inheritance = new Inheritance{value: 32}(firstHeir, 32);
    }
}
