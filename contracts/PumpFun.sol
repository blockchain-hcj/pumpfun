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
    address public admin;
    bool public isPaused;
    event Withdrawal(uint amount, uint when);
    

    constructor(string memory name, string memory symbol, address _events, address _admin) ERC20(name, symbol){
      _mint(address(this), MAX_SUPPLY);
      events = IEvents(_events);
      admin = _admin;
    }

    uint256 public constant MAX_ETH_AMOUNT = 15 ether;

    uint256 public tokensSold;
    uint256 public ethAmount;
    uint256 public constant FEE_PERCENTAGE = 5; // 5% fee

    function buy() public payable {
        require(!isPaused, "Bonding curve phase ended");
        require(ethAmount + msg.value <= MAX_ETH_AMOUNT, "Bonding curve phase ended");
        
        uint256 fee = (msg.value * FEE_PERCENTAGE) / 100;
        // Transfer fee to admin
        (bool success, ) = payable(admin).call{value: fee}("");
        require(success, "Fee transfer to admin failed");
        uint256 ethAfterFee = msg.value - fee;
        
        uint256 tokensToMint = calculateTokenAmount(ethAfterFee);
        ethAmount += ethAfterFee;
        require(tokensToMint > 0, "Not enough ETH sent");

        _transfer(address(this), msg.sender, tokensToMint);
        tokensSold += tokensToMint;

        events.emitPumpFunEvents(true, ethAfterFee, tokensToMint, ethAmount, tokensSold);
       if(ethAmount >= MAX_ETH_AMOUNT){
            isPaused = true;
            // add to uniswap
       }
    }


    
    function sell(uint256 amount) public {
        require(!isPaused, "Bonding curve phase ended");
        require(tokensSold > 0, "No tokens sold yet");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        uint256 ethToReturn = calculateEthAmount(amount);
        uint256 fee = (ethToReturn * FEE_PERCENTAGE) / 100;
        // Transfer fee to admin
        (bool success, ) = payable(admin).call{value: fee}("");
        require(success, "Fee transfer to admin failed");
        uint256 ethAfterFee = ethToReturn - fee > balanceOf(address(this)) ? balanceOf(address(this)) : ethToReturn - fee;
        
        _transfer(msg.sender, address(this), amount);
        tokensSold -= amount;
        (success, ) = payable(msg.sender).call{value: ethAfterFee}("");
        require(success, "ETH transfer failed");
        events.emitPumpFunEvents(false, ethAfterFee, amount, ethAmount, tokensSold);
    }

    function calculateTokenAmount(uint256 buyEthAmount) public view returns (uint256) {
        uint256 supply = tokensSold;
        uint256 tokenAmount = 206559139 * (10 ** 9 ) * (Math.sqrt(buyEthAmount + ethAmount) - Math.sqrt(ethAmount));
        return tokenAmount;
    }
    // y = 206559139 * (10 ** 9 ) * sqrt(x)
    // x = (y / (206559139 * 10^9))^2
    function calculateEthAmount(uint256 tokenAmount) public view returns (uint256) {
        uint256 supply = tokensSold;
        uint256 newSupply = supply - tokenAmount;
        // Using the inverse of the formula: x = (y / (206559139 * 10^9))^2 - ethAmount
        uint256 currentEth = (supply * 1 ether  / (206559139 * 10**9))**2 / 1 ether / 1 ether ;
        uint256 newEth = (newSupply * 1 ether  / (206559139 * 10**9))**2  / 1 ether / 1 ether   ;
        
        return currentEth - newEth;
    }

    function testEthAmount(uint256 tokenAmount) public view returns (uint256) {
        return (tokenAmount * 1 ether  / (206559139 * 10**9))**2 / 1 ether / 1 ether;
    }

   

}
