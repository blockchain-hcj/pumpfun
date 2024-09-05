pragma solidity >=0.8.0;
import "forge-std/Test.sol";
import "../contracts/PumpFunFactory.sol";
import "../contracts/interfaces/IPumpFun.sol";
import "../contracts/interfaces/IUniswapV2Router.sol";

contract EmissionTest is Test {




    address public owner = 0x2DEF756A20cf2a87d02f2d7C9f8ba70385C736c1;
    address public user1 = 0x836f5473B40F6E9581ae18D4821Ec1892dEE5ccC;

    PumpFunFactory public factory;

    function setUp() public{
        vm.deal(user1, 10000 ether);

        vm.startPrank(user1);
        factory = PumpFunFactory(0xcB8327E07D377F55cb251F60108bC9163d72Cca4);
    


    }

    function testCreateToken() public{

        factory.createPumpFun("PumpFun", "PFP");

        address[] memory tokens = factory.getDeployedPumpFuns();
            IPumpFun(tokens[0]).buy{value: 1 ether}(10000);

            IPumpFun(tokens[0]).buy{value: 0.1 ether}(500);

            // assertEq(balance1 < balance2, true, "Balance 1 is not less than balance 2");
            // assertEq(balance1 > 0, true, "Balance 1 is not greater than 0");    
            // assertEq(balance2 > 0, true, "Balance 2 is not greater than 0");
            uint256 maxEthToBuy = IPumpFun(tokens[0]).getMaxEthToBuy();
            uint256 contractBalance = address(tokens[0]).balance;
            IPumpFun(tokens[0]).buy{value: maxEthToBuy}(1 ether);
            uint256 contractBalance2 = address(tokens[0]).balance;
            console.log(contractBalance);
            console.log(contractBalance2);

            // uint256 balance = IERC20(tokens[0]).balanceOf(user2);
            // console.log(1 ether * 1 ether / balance);
            // uint256 maxEthToBuy = IPumpFun(tokens[0]).getMaxEthToBuy();
            // console.log(IPumpFun(tokens[0]).isPaused());
            // console.log(IPumpFun(tokens[0]).getCurrentTokenPrice());
            // IPumpFun(tokens[0]).buy{value: maxEthToBuy}();
            // console.log(IPumpFun(tokens[0]).isPaused());
            // console.log(IPumpFun(tokens[0]).getCurrentTokenPrice());

        IUniswapV2Factory uniswapFactory = IUniswapV2Factory(0x31a78894a2B5dE2C4244cD41595CD0050a906Db3);
        address pair = uniswapFactory.getPair(address(tokens[0]), 0x0Dc808adcE2099A9F62AA87D9670745AbA741746);
        console.log(pair);
    }
    

}
