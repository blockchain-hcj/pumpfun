// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./PumpFun.sol";
import "./Events.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PumpFunFactory is Ownable {
    Events public eventsContract;
    address[] public deployedPumpFuns;
    address public feeReceiver;


    event CreatePumpFun(address indexed token);
    constructor() Ownable(msg.sender) {
        eventsContract = new Events();
        feeReceiver = msg.sender;
    }

    function setFeeReceiver(address newFeeReceiver) public onlyOwner {
        feeReceiver = newFeeReceiver;
    }

    
    function createPumpFun(string memory name, string memory symbol) public payable  {
        PumpFun newPumpFun = new PumpFun{value: msg.value}(name, symbol, address(eventsContract), msg.sender);
        deployedPumpFuns.push(address(newPumpFun));
        eventsContract.setIsPumpToken(address(newPumpFun), true);
        emit CreatePumpFun(address(newPumpFun));
    }

    function getDeployedPumpFuns() public view returns (address[] memory) {
        return deployedPumpFuns;
    }
}
