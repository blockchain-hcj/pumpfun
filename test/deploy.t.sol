pragma solidity >=0.8.0;
import "forge-std/Test.sol";
import "../contracts/PumpFunFactory.sol";
import "../contracts/interfaces/IPumpFun.sol";


contract EmissionTest is Test {




    address public owner = 0x647EA6FB992Ffefd9c8aC686f94B9dDE06c943a6;
    address public user1 = 0x836f5473B40F6E9581ae18D4821Ec1892dEE5ccC;
    address public user2 = 0x911fCeE8553E9a5d6439CD4F1ae47Aa9A597Ec2a;
    PumpFunFactory public factory;

    function setUp() public{

      factory = new PumpFunFactory();
      vm.deal(user1, 10000 ether);
    

    }

    function testCreateToken() public{
        vm.startPrank(user1);
        factory.createPumpFun("PumpFun", "PFP");
        address[] memory tokens = factory.getDeployedPumpFuns();
        IPumpFun(tokens[0]).buy{value: 16 ether}();
      
    }


}
