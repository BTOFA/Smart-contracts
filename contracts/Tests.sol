// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Tests {

    address acc;

    function beforeAll() public {
        acc = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    }

    function get() external view returns(address) {
        return acc;
    }

}