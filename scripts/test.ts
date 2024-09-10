import { ethers } from "hardhat";
import ContractAddresses from "../DeploymentOutput.json";
import fs from "fs";
import PumpFunFactoryABI from "../deployments-zk/zklink-sepolia/contracts/PumpFunFactory.sol/PumpFunFactory.json";

async function main() {
    const provider = new ethers.JsonRpcProvider(
        'https://sepolia.rpc.zklink.io',
      );
      const pumpFunFactory = new ethers.Contract(
        "0x089Fac5c9B202114f466bF1a23f366403D69BA4d",
        PumpFunFactoryABI.abi,
        provider,
      );
      const add = await pumpFunFactory.getCreate2Address(
        "name",
        "symbol",
        "0x089Fac5c9B202114f466bF1a23f366403D69BA4d",
        "stringSalt"
      );
      console.log(add);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
