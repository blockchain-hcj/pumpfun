// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
// Uncomment this line to use console.log

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./interfaces/IEvents.sol";

contract PumpFun is ERC20 {

    address payable public owner;
    uint256 constant public MAX_SUPPLY = 1000000000 ether;
    IEvents public events;
    event Withdrawal(uint amount, uint when);
    

    constructor(string memory name, string memory symbol, address _events) ERC20(name, symbol){
      _mint(address(this), MAX_SUPPLY);
      events = IEvents(_events);

    }

    uint256 public constant MAX_ETH_AMOUNT = 15 ether;

    uint256 public tokensSold;
    uint256 public ethAmount;

    function buy() public payable {
        require(ethAmount + msg.value <= MAX_ETH_AMOUNT, "Bonding curve phase ended");
        
        uint256 tokensToMint = calculateTokenAmount(msg.value);
        ethAmount += msg.value;
        require(tokensToMint > 0, "Not enough ETH sent");

        _transfer(address(this), msg.sender, tokensToMint);
        tokensSold += tokensToMint;


        events.emitPumpFunEvents(true, msg.value, tokensToMint);
        // if (tokensSold == BONDING_CURVE_SUPPLY) {
        //     // Transfer remaining tokens to Uniswap when bonding curve phase ends
        //     _transfer(address(this), address(this), UNISWAP_SUPPLY);
        //     // TODO: Implement Uniswap listing logic here
        // }
    }

    function sell(uint256 amount) public {
        require(tokensSold > 0, "No tokens sold yet");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        uint256 ethToReturn = calculateEthAmount(amount);
        require(address(this).balance >= ethToReturn, "Insufficient contract balance");

        _transfer(msg.sender, address(this), amount);
        tokensSold -= amount;
        (bool success, ) = payable(msg.sender).call{value: ethToReturn}("");
        require(success, "ETH transfer failed");
        events.emitPumpFunEvents(false, ethToReturn, amount);

    }

    function calculateTokenAmount(uint256 buyEthAmount) public view returns (uint256) {
        uint256 supply = tokensSold;
        uint256 tokenAmount =  ((ethAmount + buyEthAmount) ** 2) / 225 ether * (800000000 ether ) / 1 ether;
        return tokenAmount;
    }
    

    function calculateEthAmount(uint256 tokenAmount) public view returns (uint256) {
        uint256 supply = tokensSold;
        uint256 newSupply = supply - tokenAmount;
        
        // Using the inverse of the formula: x = sqrt((225 * y) / 800,000,000)
        uint256 currentEth = Math.sqrt((225 ether * supply * 1 ether) / (800000000 ether));
        uint256 newEth = Math.sqrt((225 ether * newSupply * 1 ether) / (800000000 ether));
        
        return currentEth - newEth;
    }

   

}
