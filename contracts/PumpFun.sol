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
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";



contract PumpFun is ERC20, ReentrancyGuard {

    address payable public owner;
    uint256 constant public MAX_SUPPLY = 1000000000 ether;
    address constant public UNISWAP_V2_ROUTER = 0xA3C957B20779Abf06661E25eE361Be1430ef1038;
    address constant public UNISWAP_V2_FACTORY = 0x31a78894a2B5dE2C4244cD41595CD0050a906Db3;
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
         events = IEvents(_events);
        _mint(address(this), MAX_SUPPLY);
        factory = IFactory(msg.sender);
        if(msg.value > 0){
            buy_internal(creator, msg.value);
        }
    }

  

    function buy(uint256 slippage) public payable nonReentrant{

        require(!isPaused, "Bonding curve phase ended");

        uint256 fee = (msg.value * FEE_PERCENTAGE) / 100;
        //Transfer fee to admin
       (bool success, ) = payable(factory.feeReceiver()).call{value: fee}("");
        require(success, "Fee transfer to feeReceiver failed");
        uint256 ethAfterFee = msg.value - fee;
      
        uint256 tokensToMint = calculateTokenAmount(ethAfterFee);
        
        //Check if the actual price is within the allowed slippage
        uint256 actualPrice = (ethAfterFee * 1e18) / tokensToMint;
        uint256 expectedPrice = getCurrentTokenPrice();
        uint256 maxAcceptablePrice = expectedPrice * (10000 + slippage) / 10000;
        if(ethAmount != 0 ){
        require(actualPrice <= maxAcceptablePrice, "Price exceeds allowed slippage");
        }
        ethAmount += ethAfterFee;
        require(ethAmount <= MAX_ETH_AMOUNT, "Max ETH amount reached");
        require(tokensToMint > 0, "Not enough ETH sent");

        _transfer(address(this), msg.sender, tokensToMint);
        tokensSold += tokensToMint;
        events.emitPumpFunEvents(msg.sender, true, ethAfterFee, tokensToMint, ethAmount, tokensSold, getCurrentTokenPrice());
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

        events.emitPumpFunEvents(receiver, true, ethAfterFee, tokensToMint, ethAmount, tokensSold, getCurrentTokenPrice());
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

    function getMaxEthToBuy() public view returns (uint256) {
        if (isPaused) {
            return 0; // Bonding curve phase has ended
        }
        
        uint256 remainingEth = MAX_ETH_AMOUNT - ethAmount;
        
        // Consider the fee when calculating the max ETH to buy
        // We need to solve: remainingEth = buyAmount - (buyAmount * FEE_PERCENTAGE / 100)
        // Rearranging: remainingEth = buyAmount * (1 - FEE_PERCENTAGE / 100)
        // buyAmount = remainingEth / (1 - FEE_PERCENTAGE / 100)
        
        uint256 maxEthToBuy = remainingEth * 100 / (100 - FEE_PERCENTAGE);
        
        return maxEthToBuy;
    }

    function sell(uint256 amount, uint256 slippage) public nonReentrant {
        require(!isPaused, "Bonding curve phase ended");
        require(tokensSold > 0, "No tokens sold yet");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        uint256 ethToReturn = calculateEthAmount(amount);

        // Check if the actual price is within the allowed slippage
        uint256 actualPrice = (ethToReturn  * 1e18) / amount;
        uint256 expectedPrice = getCurrentTokenPrice();
        uint256 minAcceptablePrice = expectedPrice * (10000 - slippage) / 10000;
        require(actualPrice >= minAcceptablePrice, "Price below allowed slippage");
        uint256 fee = (ethToReturn * FEE_PERCENTAGE) / 100;

        (bool success, ) = payable(factory.feeReceiver()).call{value: fee}("");
        require(success, "Fee transfer to feeReceiver failed");
        uint256 ethAfterFee = ethToReturn - fee > balanceOf(address(this)) ? balanceOf(address(this)) : ethToReturn - fee;
        
        _transfer(msg.sender, address(this), amount);
        tokensSold -= amount;
        (success, ) = payable(msg.sender).call{value: ethAfterFee}("");
        require(success, "ETH transfer failed");

        ethAmount -= ethToReturn;
      
        events.emitPumpFunEvents(msg.sender, false, ethAfterFee, amount, ethAmount, tokensSold, getCurrentTokenPrice());
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


    function getCurrentTokenPrice() public view returns (uint256) {

        // We need to calculate this at the current ethAmount
        uint256 coefficient = 206559139 * (10 ** 9);
        uint256 sqrtEthAmount = Math.sqrt(ethAmount);

        // To maintain precision, we'll multiply by 1e18 and then divide
        uint256 price =  (2 * sqrtEthAmount) * 1 ether/ coefficient ;
        
        // The price is in wei per token
        return price;
    }

}
