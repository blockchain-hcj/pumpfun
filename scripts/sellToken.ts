import { ethers } from "hardhat";
import ContractAddresses from "../DeploymentOutput.json";
import fs from "fs";

async function main() {
    const [signer] = await ethers.getSigners();
    const token = await ethers.getContractAt("PumpFun", "0x66170fc5142e809ee919e92d927BfD7Cfc8fA97a");
    console.log(await token.balanceOf(signer.address));
    const sell = await token.sell(ethers.parseEther('2637123'));
    await sell.wait();
    console.log(sell.hash);

    
   

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
