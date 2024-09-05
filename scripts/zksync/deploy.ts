import { Deployer } from "@matterlabs/hardhat-zksync-deploy";
import { Wallet, Provider } from "zksync-ethers";
import { ethers } from "ethers";

import {Secrets } from "../../secrets";

import * as hre from "hardhat";


async function main() {
  // Get the private key from the environment variable
  const privateKey = Secrets.DEPLOYER_PRIVATEKEY;
  if (!privateKey) {
    throw new Error("WALLET_PRIVATE_KEY is not set in the environment variables");
  }
  // Initialize the wallet with the zkSync provider
  const zkSyncProvider = new Provider("https://sepolia.rpc.zklink.io");
  const wallet = new Wallet(privateKey, zkSyncProvider);

  // Create deployer object
  const deployer = new Deployer(hre, wallet);

  // Load the artifact of the contract you want to deploy
  const artifact = await deployer.loadArtifact("PumpFunFactory");


  const PumpFunFactory = await deployer.deploy(artifact, []);

  // Wait for the deployment transaction to be confirmed
  
  await PumpFunFactory.waitForDeployment();
  console.log(`PumpFunFactory deployed to ${ await PumpFunFactory.getAddress()}`);

  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
