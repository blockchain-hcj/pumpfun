import { ethers } from "hardhat";
import ContractAddresses from "../DeploymentOutput.json";
import fs from "fs";

async function main() {

    const token = await ethers.getContractAt("PumpFun", "0x3C4Ff0a42456288D8d26dab7f38D606f34b0e9AD");
    const buy = await token.buy({value: ethers.parseEther('0.001')});
    await buy.wait();
    console.log(buy.hash);

    
   

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
