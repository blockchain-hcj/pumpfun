// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./PumpFun.sol";
import "./Events.sol";


contract PumpFunFactory is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private deployedPumpFunsSet;


    Events public eventsContract;

    address public feeReceiver;

    uint256 public feePercent;
    address public immutable WETH;
    address public immutable NONFUNGIBLE_POSITION_MANAGER;
    bytes32 public immutable PUMPFUN_BYTECODE_HASH;

    

    mapping(address => address[]) public userCreatedTokens;
    event CreatePumpFun(address indexed token);
    constructor(address _weth, address _nonfungiblePositionManager, bytes32 _pumpFunBytecodeHash) Ownable(msg.sender) {
        eventsContract = new Events();
        feeReceiver = msg.sender;
        WETH = _weth;
        NONFUNGIBLE_POSITION_MANAGER = _nonfungiblePositionManager;
        PUMPFUN_BYTECODE_HASH = _pumpFunBytecodeHash;
    }

    function setFeePercent(uint256 newFeePercent) public onlyOwner {
        feePercent = newFeePercent;
    }

    function setFeeReceiver(address newFeeReceiver) public onlyOwner {
        feeReceiver = newFeeReceiver;
    }
    
    
    function createPumpFun(string memory name, string memory symbol, string memory stringSalt) public payable  {
        bytes32 salt = keccak256(abi.encodePacked(stringSalt));
        address create2Address = getCreate2Address(name, symbol, msg.sender, stringSalt);
        deployedPumpFunsSet.add(create2Address);
        PumpFun newPumpFun = new PumpFun{value: msg.value, salt: salt}(name, symbol, address(eventsContract), msg.sender);
        userCreatedTokens[msg.sender].push(address(newPumpFun));
        emit CreatePumpFun(address(newPumpFun));
    }

    

    function getUserCreatedTokens(address user) public view returns (address[] memory) {
        return userCreatedTokens[user];
    }

   
      function getCreate2Address(string memory name, string memory symbol, address sender, string memory stringSalt) public view returns (address) {
        bytes32 salt = keccak256(abi.encodePacked(stringSalt));

        bytes memory input = abi.encode(name, symbol, address(eventsContract), sender);
        bytes32 inputHash = keccak256(input);

        bytes32 zksync_create2_prefix = keccak256("zksyncCreate2");
        bytes32 address_hash = keccak256(
            bytes.concat(
                zksync_create2_prefix,
                bytes32(uint256(uint160(address(this)))),
                salt,
                PUMPFUN_BYTECODE_HASH,
                inputHash
            )
        );
        return address(uint160(uint256(address_hash)));
    }  

    function isPumpFun(address token) public view returns (bool) {
        return deployedPumpFunsSet.contains(token);
    }

    function getDeployedPumpFuns() public view returns (address[] memory) {
        return deployedPumpFunsSet.values();
    }
}
