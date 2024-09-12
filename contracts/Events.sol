// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;


import "./interfaces/IFactory.sol";


contract Events {

    mapping (address => bool) public isPumpToken;
    IFactory public factory;
    event PumpFunEvent(address indexed token,address account, bool isBuy, uint256 userETHChangeAmount, uint256 tokenChangeAmount, uint256 currentEthAmount, uint256 currentTokenAmount, uint256 currentTokenPrice);
    event PumpFunTransfer(address indexed token, address indexed from, address indexed to, uint256 amount);
    constructor(){
        factory = IFactory(msg.sender);
    }

    
    function emitPumpFunEvents(address account, bool isBuy, uint256 ethChangeAmount, uint256 tokenChangeAmount, uint256 currentEthAmount, uint256 currentTokenSold, uint256 currentTokenPrice) public {
        require(factory.isPumpFun(msg.sender),"Only PumpFun tokens can emit events");
        emit PumpFunEvent(msg.sender, account, isBuy, ethChangeAmount, tokenChangeAmount, currentEthAmount, currentTokenSold, currentTokenPrice);
    }


     function emitPumpFunTransfer(address from, address to, uint256 amount) public {
       require(factory.isPumpFun(msg.sender), "Only PumpFun tokens can emit transfer events");
        emit PumpFunTransfer(msg.sender, from, to, amount);
    }


}
