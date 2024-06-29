// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
// Uncomment this line to use console.log



contract Events {

    mapping (address => bool) public isPumpToken;
    address public factory;
    event PumpFunEvent(address indexed token, bool isBuy, uint256 ethChangeAmount, uint256 tokenChangeAmount, uint256 currentEthAmount, uint256 currentTokenAmount);
    constructor(){
        factory = msg.sender;
    }

    function setIsPumpToken(address token, bool value) public {
        require(msg.sender == factory, "Only factory can set isPumpToken");
        isPumpToken[token] = value;
    }

    function emitPumpFunEvents(bool isBuy, uint256 ethChangeAmount, uint256 tokenChangeAmount, uint256 currentEthAmount, uint256 currentTokenSold) public {
        require(isPumpToken[msg.sender],"Only PumpFun tokens can emit events");
        emit PumpFunEvent(msg.sender, isBuy, ethChangeAmount, tokenChangeAmount, currentEthAmount, currentTokenSold);
    }


}
