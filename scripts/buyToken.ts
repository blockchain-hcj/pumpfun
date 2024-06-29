import { ethers } from "hardhat";
import ContractAddresses from "../DeploymentOutput.json";
import fs from "fs";

async function main() {

    const token = await ethers.getContractAt("PumpFun", "0x59a3Ba39197f4063BEbd9c23F05cC0bDD3090258");
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
