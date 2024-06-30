// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./PumpFun.sol";
import "./Events.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PumpFunFactory is Ownable {
    Events public eventsContract;
    address[] public deployedPumpFuns;
    address public feeReceiver;

    mapping(address => address[]) public userCreatedTokens;
    event CreatePumpFun(address indexed token);
    constructor() Ownable(msg.sender) {
        eventsContract = new Events();
        feeReceiver = msg.sender;
    }

    function setFeeReceiver(address newFeeReceiver) public onlyOwner {
        feeReceiver = newFeeReceiver;
    }

    
    function createPumpFun(string memory name, string memory symbol, uint _salt) public payable  {
        PumpFun newPumpFun = new PumpFun{value: msg.value, salt: bytes32(_salt)}(name, symbol, address(eventsContract), msg.sender);
        deployedPumpFuns.push(address(newPumpFun));
        eventsContract.setIsPumpToken(address(newPumpFun), true);
        userCreatedTokens[msg.sender].push(address(newPumpFun));
        emit CreatePumpFun(address(newPumpFun));
    }

    function getUserCreatedTokens(address user) public view returns (address[] memory) {
        return userCreatedTokens[user];
    }

    function getDeployedPumpFuns() public view returns (address[] memory) {
        return deployedPumpFuns;
    }
}
