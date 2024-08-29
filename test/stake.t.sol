pragma solidity >=0.8.0;
import "forge-std/Test.sol";
import "../contracts/FeeDistributor.sol";
import "../contracts/MPAA.sol";
import "../contracts/VotingEscrow.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "../contracts/interfaces/IVotingEscrow.sol";
import "../contracts/interfaces/IPumpFun.sol";


contract StakeTest is Test {




    function testSell() public{
      address owner = 0xB53a792e2045ED72CeD55C9720780Ee31aE23874;
      // test deposit token 
      vm.startPrank(owner);
      IPumpFun token = IPumpFun(0x3274D9890A5dB877Fd6bE2506F826301C465Ba67);
     uint256 balance = token.balanceOf(owner);
      token.sell(balance / 3, 10000);


    }
    

}
