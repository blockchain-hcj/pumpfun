// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./PumpFun.sol";
import "./Events.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PumpFunFactory is Ownable {
    Events public eventsContract;
    address[] public deployedPumpFuns;


    event CreatePumpFun(address indexed token);
    constructor() Ownable(msg.sender) {
        eventsContract = new Events();
    }

    function createPumpFun(string memory name, string memory symbol) public  {
        PumpFun newPumpFun = new PumpFun(name, symbol, address(eventsContract), owner());
        deployedPumpFuns.push(address(newPumpFun));
        eventsContract.setIsPumpToken(address(newPumpFun), true);
        emit CreatePumpFun(address(newPumpFun));
    }

    function getDeployedPumpFuns() public view returns (address[] memory) {
        return deployedPumpFuns;
    }
}
