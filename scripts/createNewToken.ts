import { ethers } from "hardhat";
import ContractAddresses from "../DeploymentOutput.json";
import fs from "fs";

async function main() {

    const factory = await ethers.getContractAt("PumpFunFactory", ContractAddresses.Factory.address);


    const createToken = await factory.createPumpFun("Test", "TST");


    const receipt = await createToken.wait();

    // Find the CreatePumpFun event in the logs
    if (receipt) {
        const createPumpFunEvent = receipt.logs.find(
            log => log.topics[0] === factory.interface.getEvent('CreatePumpFun').topicHash
        );

        if (createPumpFunEvent) {
            const decodedAddress = ethers.AbiCoder.defaultAbiCoder().decode(['address'], createPumpFunEvent.topics[1]);
            console.log('token address:', decodedAddress[0]);
        } else {
            console.log('CreatePumpFun event not found in the logs');
        }
    } else {
        console.log('Receipt is null, transaction may have failed');
    }
  
   

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
