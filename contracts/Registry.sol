// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

abstract contract Registry {
    mapping(uint256 => address) public contracts;
}
