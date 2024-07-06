import { ethers } from "hardhat";

import fs from "fs";

async function main() {


    let deploymentStateJSON = fs.readFileSync("./DeploymentOutput.json", "utf-8");
    let deploymentState = JSON.parse(deploymentStateJSON);
    const currentTimestamp = Math.floor(Date.now() / 1000);
    console.log(currentTimestamp);
    // Deploy MPAA contract
    const feeDistributor = await ethers.deployContract("FeeDistributor",[deploymentState.VotingEscrow.address, currentTimestamp + 86400 * 7]);
    await feeDistributor.waitForDeployment();
      deploymentState["FeeDistributor"] = {
    address: await feeDistributor.getAddress(),
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
