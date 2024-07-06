import { ethers } from "hardhat";

import fs from "fs";

async function main() {



    let deploymentStateJSON = fs.readFileSync("./DeploymentOutput.json", "utf-8");
    let deploymentState = JSON.parse(deploymentStateJSON);

      // Deploy MPAA contract
    const mpaa = await ethers.deployContract("MPAA",[]);
    await mpaa.waitForDeployment();

     deploymentState["mpaa"] = {
    address: await mpaa.getAddress(),
    }

    const VotingEscrow = await ethers.deployContract("VotingEscrow", [await mpaa.getAddress(), 1000]);
    await VotingEscrow.waitForDeployment();
    
    deploymentState["VotingEscrow"] = {
        address: await VotingEscrow.getAddress(),
    }
    deploymentStateJSON = JSON.stringify(deploymentState, null, 2);

    fs.writeFileSync("./DeploymentOutput.json", deploymentStateJSON);

    

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
