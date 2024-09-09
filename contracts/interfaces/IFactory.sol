// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface IFactory {



    function feeReceiver() external view returns (address);

    function WETH() external view returns (address);

    function NONFUNGIBLE_POSITION_MANAGER() external view returns (address);

}
