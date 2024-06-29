// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;


interface IPumpFun {


    function buy() external payable;
    function sell(uint256 amount) external;
    function calculateTokenAmount(uint256 buyEthAmount) external view returns (uint256);
    function calculateEthAmount(uint256 tokenAmount) external view returns (uint256);

    function testEthAmount(uint256 tokenAmount) external view returns (uint256);
}
