// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./PumpFun.sol";
import "./Events.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PumpFunFactory is Ownable {
    Events public eventsContract;
    address[] public deployedPumpFuns;
    address public feeReceiver;

    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant NONFUNGIBLE_POSITION_MANAGER = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    
    mapping(address => address[]) public userCreatedTokens;
    event CreatePumpFun(address indexed token);
    constructor() Ownable(msg.sender) {
        eventsContract = new Events();
        feeReceiver = msg.sender;
    }

    function setFeeReceiver(address newFeeReceiver) public onlyOwner {
        feeReceiver = newFeeReceiver;
    }

    
    function createPumpFun(string memory name, string memory symbol) public payable  {
        bytes32 salt = getSalt(msg.sender);
        address create2Address = getCreate2Address(name, symbol, msg.sender);
        eventsContract.setIsPumpToken(create2Address, true);
        PumpFun newPumpFun = new PumpFun{value: msg.value, salt: salt}(name, symbol, address(eventsContract), msg.sender);
        deployedPumpFuns.push(address(newPumpFun));
        userCreatedTokens[msg.sender].push(address(newPumpFun));
        emit CreatePumpFun(address(newPumpFun));
    }

    function getUserCreatedTokens(address user) public view returns (address[] memory) {
        return userCreatedTokens[user];
    }

    function getSalt(address sender) public view returns (bytes32) {
        uint256 nonce = userCreatedTokens[sender].length;
        return keccak256(abi.encodePacked(sender, nonce));
    }


    function getCreate2Address(string memory name, string memory symbol, address sender) public view returns (address) {
        bytes32 salt = getSalt(sender);
        bytes memory bytecode = abi.encodePacked(
            type(PumpFun).creationCode,
            abi.encode(name, symbol, address(eventsContract), sender)
        );
        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(bytecode))
        );
        return address(uint160(uint(hash)));
    }


    function getDeployedPumpFuns() public view returns (address[] memory) {
        return deployedPumpFuns;
    }
}
