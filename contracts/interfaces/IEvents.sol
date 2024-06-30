// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface IEvents {
    event PumpFunEvent(address indexed token, bool isBuy, uint256 ethAmount, uint256 tokenAmount);


    function emitPumpFunTransfer(address from, address to, uint256 amount) external;

    function emitPumpFunEvents(address account, bool isBuy, uint256 ethChangeAmount, uint256 tokenChangeAmount, uint256 currentEthAmount, uint256 currentTokenSold, uint256 currentTokenPrice) external;
}
