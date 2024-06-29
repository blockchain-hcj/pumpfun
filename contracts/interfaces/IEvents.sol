// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface IEvents {
    event PumpFunEvent(address indexed token, bool isBuy, uint256 ethAmount, uint256 tokenAmount);



    function emitPumpFunEvents(bool isBuy, uint256 ethChangeAmount, uint256 tokenChangeAmount, uint256 currentEthAmount, uint256 currentTokenSold) external;
}
