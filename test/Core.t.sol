// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "src/Core.sol";

contract TestPredicCore is Test {
    PredicCore c;

    function setUp() public {
        c = new PredicCore();
    }
}
