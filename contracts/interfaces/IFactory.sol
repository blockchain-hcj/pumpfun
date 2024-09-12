// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IFactory {



    function feeReceiver() external view returns (address);

    function WETH() external view returns (address);

    function NONFUNGIBLE_POSITION_MANAGER() external view returns (address);

    function isPumpFun(address token) external view returns (bool);

    function feePercent() external view returns (uint256);
}
