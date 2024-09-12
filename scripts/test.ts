import { ethers } from "hardhat";
import ContractAddresses from "../DeploymentOutput.json";
import fs from "fs";
import PumpFunFactoryABI from "../deployments-zk/zklink-sepolia/contracts/PumpFunFactory.sol/PumpFunFactory.json";

import { Secrets } from "../secrets";
async function main() {
    const provider = new ethers.JsonRpcProvider(network.config.url);



      const signer = new ethers.Wallet(Secrets.DEPLOYER_PRIVATEKEY, provider);

      const tx = {
        to: "0x7f19656b47F3878c176e2A18cfF962c35240c5BD",
        value: ethers.parseEther("0.000000000001"),
        data: "0x4b25fa3b000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000000046e616d6500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000673796d626f6c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a737472696e6753616c7400000000000000000000000000000000000000000000",
      };

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
