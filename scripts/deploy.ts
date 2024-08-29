import { ethers } from "hardhat";

import fs from "fs";

async function main() {


    const [signer] = await ethers.getSigners();
    console.log(signer.address)
    let deploymentState: any = {}

    const Factory = await ethers.deployContract("PumpFunFactory", []);
    await Factory.waitForDeployment();
    
    deploymentState["Factory"] = {
        address: await Factory.getAddress(),
    }

    deploymentState["Events"] = {
        address: await Factory.eventsContract()
    }
    console.log(deploymentState)
    const deploymentStateJSON = JSON.stringify(deploymentState, null, 2);
    fs.writeFileSync("./DeploymentOutput.json", deploymentStateJSON);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
