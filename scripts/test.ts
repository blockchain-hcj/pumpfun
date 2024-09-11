import { ethers } from "hardhat";
import ContractAddresses from "../DeploymentOutput.json";
import fs from "fs";
import PumpFunFactoryABI from "../deployments-zk/zklink-sepolia/contracts/PumpFunFactory.sol/PumpFunFactory.json";
import { Secrets } from "../secrets";
async function main() {
    const provider = new ethers.JsonRpcProvider(
        'https://arb-sepolia.g.alchemy.com/v2/I-ZVEdUQy4Mk3rwbsNAIp_MVql6coseO',
      );

      const signer = new ethers.Wallet(Secrets.DEPLOYER_PRIVATEKEY, provider);

      const tx = {
        to: "0xa7d6942093b2d93Fef2E342B0A740ed54C9784E0",
        value: ethers.parseEther("0.001"),
        data: "0x4b25fa3b000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000000046e616d6500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000673796d626f6c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a737472696e6753616c7400000000000000000000000000000000000000000000",

      };
      const signedTx = await signer.signTransaction(tx);
      const txResponse = await signer.sendTransaction(tx);
      await txResponse.wait();
      console.log("Transaction hash:", txResponse.hash);

      
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
