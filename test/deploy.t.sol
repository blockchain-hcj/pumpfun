pragma solidity >=0.8.0;
import "forge-std/Test.sol";
import "../contracts/PumpFunFactory.sol";
import "../contracts/interfaces/IPumpFun.sol";
import "../contracts/interfaces/IUniswapV2Router.sol";

contract EmissionTest is Test {




    address public owner = 0x647EA6FB992Ffefd9c8aC686f94B9dDE06c943a6;
    address public user1 = 0x836f5473B40F6E9581ae18D4821Ec1892dEE5ccC;
    address public user2 = 0x911fCeE8553E9a5d6439CD4F1ae47Aa9A597Ec2a;
    PumpFunFactory public factory;

    function setUp() public{
        vm.deal(user1, 10000 ether);
        vm.startPrank(0x330BD48140Cf1796e3795A6b374a673D7a4461d0);
        factory = new PumpFunFactory();
    
        factory.createPumpFun("PumpFun", "PFP");

    }

    function testCreateToken() public{
        vm.startPrank(user1);
        factory.createPumpFun("PumpFun", "PFP");
        address[] memory tokens = factory.getDeployedPumpFuns();
         IPumpFun(tokens[0]).buy{value: 13 ether}();
        uint256 maxEthToBuy = IPumpFun(tokens[0]).getMaxEthToBuy();
           console.log(IPumpFun(tokens[0]).isPaused());
             IPumpFun(tokens[0]).buy{value: maxEthToBuy}();
              console.log(IPumpFun(tokens[0]).isPaused());
    }
       


}
