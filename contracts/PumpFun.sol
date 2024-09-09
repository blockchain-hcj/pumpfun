// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
// Uncomment this line to use console.log

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import "./interfaces/IEvents.sol";
import "./interfaces/INonfungiblePositionManager.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/IWETH.sol";


contract PumpFun is ERC20, ReentrancyGuard, IERC721Receiver {

    address payable public owner;
    uint256 constant public MAX_SUPPLY = 1000000000 ether;
    IEvents public events;
    bool public isPaused;
    IFactory public factory;
    uint256 public constant MAX_ETH_AMOUNT = 15 ether;

    uint256 public tokensSold;
    uint256 public ethAmount;
    uint256 public constant FEE_PERCENTAGE = 1; // 1% fee
    event Withdrawal(uint amount, uint when);
    

    constructor(string memory name, string memory symbol, address _events, address creator) ERC20(name, symbol) payable{
         events = IEvents(_events);
        factory = IFactory(msg.sender);
        _mint(address(this), MAX_SUPPLY);
        if(msg.value > 0){
            _buy(creator, msg.value, 0);
        }
    }

    function buy(uint256 slippage) public payable nonReentrant{
        _buy(msg.sender, msg.value, slippage);
    }
    

    function _buy(address receiver, uint256 buyEthAmount, uint256 slippage) internal {

        require(!isPaused, "Bonding curve phase ended");

        uint256 fee = (buyEthAmount * FEE_PERCENTAGE) / 100;
        //Transfer fee to admin
        (bool success, ) = payable(factory.feeReceiver()).call{value: fee}("");
        require(success, "Fee transfer to feeReceiver failed");
        uint256 ethAfterFee = buyEthAmount - fee;
      
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

        _transfer(address(this), receiver, tokensToMint);
        tokensSold += tokensToMint;
        events.emitPumpFunEvents(receiver, true, ethAfterFee, tokensToMint, ethAmount, tokensSold, getCurrentTokenPrice());
        if(ethAmount >= MAX_ETH_AMOUNT){
            isPaused = true;
            _addLiquidity();
       }
    }


    

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        // Only accept NFTs from the Uniswap V3 position manager
       require(msg.sender == factory.NONFUNGIBLE_POSITION_MANAGER(), "Only Uniswap V3 NFTs allowed");
        return this.onERC721Received.selector;
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

 

    function getCoefficient() internal pure returns (uint256) {
        // Calculate the coefficient based on MAX_ETH_AMOUNT and MAX_SUPPLY
        // tokenAmount = co * ethAmount^2, where tokenAmount = 0.8 * MAX_SUPPLY and ethAmount = MAX_ETH_AMOUNT
        // Solving for co: co = (0.8 * MAX_SUPPLY) / MAX_ETH_AMOUNT^2
        return (206559139 * 10**9);
    }

    function calculateTokenAmount(uint256 buyEthAmount) public view returns (uint256) {
        uint256 tokenAmount = getCoefficient() * (Math.sqrt(buyEthAmount + ethAmount) - Math.sqrt(ethAmount));
        return tokenAmount;
    }
    // y = 206559139 * (10 ** 9 ) * sqrt(x)
    // x = (y / (206559139 * 10^9))^2
    function calculateEthAmount(uint256 tokenAmount) public view returns (uint256) {
        uint256 supply = tokensSold;
        uint256 newSupply = supply - tokenAmount;
        // Using the inverse of the formula: x = (y / (206559139 * 10^9))^2 - ethAmount
        uint256 currentEth = (supply * 1 ether  / getCoefficient()) **2 / 1 ether / 1 ether ;
        uint256 newEth = (newSupply * 1 ether  / getCoefficient()) **2  / 1 ether / 1 ether   ;
        
        return currentEth - newEth;
    }


    function _update(address from, address to, uint256 value) internal override {
        super._update(from, to, value);
        events.emitPumpFunTransfer(from, to, value);
    }
    


    function getCurrentTokenPrice() public view returns (uint256) {

        // We need to calculate this at the current ethAmount
        uint256 coefficient = getCoefficient();
        uint256 sqrtEthAmount = Math.sqrt(ethAmount);

        // To maintain precision, we'll multiply by 1e18 and then divide
        uint256 price =  (2 * sqrtEthAmount) * 1 ether/ coefficient ;
        
        // The price is in wei per token
        return price;
    }


    function _addLiquidity() internal {

            _approve(address(this), factory.NONFUNGIBLE_POSITION_MANAGER(), balanceOf(address(this)));
            address token0;
            address token1;
            if (address(this) < factory.WETH()) {
                token0 = address(this);
                token1 = factory.WETH();
            } else {
                token0 = factory.WETH();
                token1 = address(this);
            }

            
          INonfungiblePositionManager(factory.NONFUNGIBLE_POSITION_MANAGER()).createAndInitializePoolIfNecessary(
                    token0,
                    token1,
                    3000,
                    uint160(Math.sqrt(getCurrentTokenPrice()) * 2 ** 96)
            );

            uint256 wethBalance = address(this).balance;
            IWETH(factory.WETH()).deposit{value: wethBalance}();
            IWETH(factory.WETH()).approve(factory.NONFUNGIBLE_POSITION_MANAGER(), wethBalance);

            uint256 token0Amount = token0 == address(this) ? balanceOf(address(this)) : wethBalance;
            uint256 token1Amount = token1 == address(this) ? balanceOf(address(this)) : wethBalance;

            INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
                token0: token0,
                token1: token1,
                fee: 3000, // 0.3% fee tier
                tickLower: 0,
                tickUpper: 300000, 
                amount0Desired: token0Amount,
                amount1Desired: token1Amount,
                amount0Min: 0, 
                amount1Min: 0, 
                recipient: address(this),
                deadline: block.timestamp  // Allow 5 minutes to complete transaction
            });

            INonfungiblePositionManager(factory.NONFUNGIBLE_POSITION_MANAGER()).mint(params);
        
    }

}
