// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
// Uncomment this line to use console.log

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "./interfaces/IEvents.sol";
import "./interfaces/IUniswapV2Router.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapPair.sol";
import "./interfaces/IFactory.sol";

contract PumpFun is ERC20 {

    address payable public owner;
    uint256 constant public MAX_SUPPLY = 1000000000 ether;
    address constant public UNISWAP_V2_ROUTER = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;
    address constant public UNISWAP_V2_FACTORY = 0x8909Dc15e40173Ff4699343b6eB8132c65e18eC6;
    IEvents public events;
    bool public isPaused;
    bool public initialized;
    IFactory public factory;
    uint256 public constant MAX_ETH_AMOUNT = 15 ether;

    uint256 public tokensSold;
    uint256 public ethAmount;
    uint256 public constant FEE_PERCENTAGE = 1; // 1% fee
    event Withdrawal(uint amount, uint when);
    

    constructor(string memory name, string memory symbol, address _events, address creator) ERC20(name, symbol) payable{
      _mint(address(this), MAX_SUPPLY);
      events = IEvents(_events);
      factory = IFactory(msg.sender);
      buy_internal(creator, msg.value);
    }

  

    function buy() public payable {

      
        require(!isPaused, "Bonding curve phase ended");

        uint256 fee = (msg.value * FEE_PERCENTAGE) / 100;
        // Transfer fee to admin
        (bool success, ) = payable(factory.feeReceiver()).call{value: fee}("");
        require(success, "Fee transfer to feeReceiver failed");
        uint256 ethAfterFee = msg.value - fee;
        
        uint256 tokensToMint = calculateTokenAmount(ethAfterFee);
        ethAmount += ethAfterFee;
        require(tokensToMint > 0, "Not enough ETH sent");

        _transfer(address(this), msg.sender, tokensToMint);
        tokensSold += tokensToMint;

        events.emitPumpFunEvents(msg.sender, true, ethAfterFee, tokensToMint, ethAmount, tokensSold);
       if(ethAmount >= MAX_ETH_AMOUNT){
            isPaused = true;
            // add to uniswap
        _approve(address(this), UNISWAP_V2_ROUTER, balanceOf(address (this)));

        IUniswapV2Router(UNISWAP_V2_ROUTER).addLiquidityETH{value: address(this).balance}(
            address(this), balanceOf(address(this)), 0, 0, address(0), block.timestamp
        );
            
       }
    }

    function buy_internal(address receiver, uint256 buyEthAmount) public  {
        require(!initialized, "PumpFun already initialized");
       
        require(!isPaused, "Bonding curve phase ended");

        uint256 fee = (buyEthAmount * FEE_PERCENTAGE) / 100;
        // Transfer fee to admin
        (bool success, ) = payable(factory.feeReceiver()).call{value: fee}("");
        require(success, "Fee transfer to feeReceiver failed");
        uint256 ethAfterFee = buyEthAmount - fee;
        
        uint256 tokensToMint = calculateTokenAmount(ethAfterFee);
        ethAmount += ethAfterFee;
        require(tokensToMint > 0, "Not enough ETH sent");

        _transfer(address(this),receiver, tokensToMint);
        tokensSold += tokensToMint;

        events.emitPumpFunEvents(receiver, true, ethAfterFee, tokensToMint, ethAmount, tokensSold);
       if(ethAmount >= MAX_ETH_AMOUNT){
            isPaused = true;
            // add to uniswap
        _approve(address(this), UNISWAP_V2_ROUTER, balanceOf(address (this)));

        IUniswapV2Router(UNISWAP_V2_ROUTER).addLiquidityETH{value: address(this).balance}(
            address(this), balanceOf(address(this)), 0, 0, address(0), block.timestamp
        );
            
       }
          initialized = true;
    }



    
    function sell(uint256 amount) public {
        require(!isPaused, "Bonding curve phase ended");
        require(tokensSold > 0, "No tokens sold yet");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        uint256 ethToReturn = calculateEthAmount(amount);
        uint256 fee = (ethToReturn * FEE_PERCENTAGE) / 100;

        (bool success, ) = payable(factory.feeReceiver()).call{value: fee}("");
        require(success, "Fee transfer to feeReceiver failed");
        uint256 ethAfterFee = ethToReturn - fee > balanceOf(address(this)) ? balanceOf(address(this)) : ethToReturn - fee;
        
        _transfer(msg.sender, address(this), amount);
        tokensSold -= amount;
        (success, ) = payable(msg.sender).call{value: ethAfterFee}("");
        require(success, "ETH transfer failed");
        events.emitPumpFunEvents(msg.sender, false, ethAfterFee, amount, ethAmount, tokensSold);
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


    function _update(address from, address to, uint256 value) internal override {
        super._update(from, to, value);
        events.emitPumpFunTransfer(from, to, value);
    }

}
