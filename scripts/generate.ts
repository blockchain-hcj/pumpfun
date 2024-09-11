import { ethers } from "hardhat";
import ContractAddresses from "../DeploymentOutput.json";
import fs from "fs";
import PumpFunFactoryABI from "../deployments-zk/zklink-sepolia/contracts/PumpFunFactory.sol/PumpFunFactory.json";
import PumpFunABI from "../artifacts/contracts/PumpFun.sol/PumpFun.json";
import { Secrets } from "../secrets";
import { PumpFunFactory } from "../typechain-types";
async function main() {
    const provider = new ethers.JsonRpcProvider(
        'https://arb-sepolia.g.alchemy.com/v2/I-ZVEdUQy4Mk3rwbsNAIp_MVql6coseO',
      );

        const signer = new ethers.Wallet(Secrets.DEPLOYER_PRIVATEKEY, provider);
      const pumpFunFactory = new ethers.Contract(
        "0xa7d6942093b2d93Fef2E342B0A740ed54C9784E0",
        PumpFunFactoryABI.abi,
        provider,
      )as unknown as PumpFunFactory;

      const pumpFun = await pumpFunFactory.createPumpFun.populateTransaction("name", "symbol", "stringSalt");
      console.log(pumpFun);
      const tokenAdd = await pumpFunFactory.getCreate2Address("name", "symbol", signer.address, "stringSalt")
      console.log(tokenAdd);
    //   const token = new ethers.Contract(
    //     tokenAdd,
    //     PumpFunABI.abi,
    //     provider
    //   );
    //   console.log(await token.balanceOf(signer.address));


      
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
