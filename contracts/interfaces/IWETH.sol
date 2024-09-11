// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IWETH {
    function deposit() external payable;
    function withdraw(uint wad) external;
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}
