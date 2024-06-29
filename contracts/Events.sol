// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
// Uncomment this line to use console.log



contract Events {

    mapping (address => bool) public isPumpToken;
    address public factory;
    event PumpFunEvent(address indexed token, bool isBuy, uint256 ethAmount, uint256 tokenAmount);
    constructor(){
        factory = msg.sender;
    }

    function setIsPumpToken(address token, bool value) public {
        require(msg.sender == factory, "Only factory can set isPumpToken");
        isPumpToken[token] = value;
    }

    function emitPumpFunEvents(bool isBuy, uint256 ethAmount, uint256 tokenAmount) public {
        require(isPumpToken[msg.sender],"Only PumpFun tokens can emit events");
        emit PumpFunEvent(msg.sender, isBuy, ethAmount, tokenAmount);
    }


}
