import { ethers } from "hardhat";
import ConrtactAddresses from "../../DeploymentOutput.json"
import fs from "fs";

async function main() {

const [signer] = await ethers.getSigners();

    const VotingEscrow = await ethers.getContractAt("VotingEscrow", ConrtactAddresses.VotingEscrow.address);
    // Get the current timestamp
    const currentTimestamp = Math.floor(Date.now() / 1000);
    console.log(`Current timestamp: ${currentTimestamp}`);
    console.log(await VotingEscrow.MINTIME());
    const mpaa = await ethers.getContractAt("MPAA", ConrtactAddresses.mpaa.address);
    // console.log(await VotingEscrow.balanceOf(signer.address));
    // const approve = await mpaa.approve(ConrtactAddresses.VotingEscrow.address, ethers.parseEther('1000'));
    // await approve.wait();
    // let weekTime = 86400 * 7;
    //  const lock = await VotingEscrow.create_lock(ethers.parseEther('1000'), currentTimestamp + 8 * weekTime);
    //  await lock.wait()
    //  console.log(lock.hash);
    //  console.log(await VotingEscrow.balanceOf(signer.address));

    console.log(await VotingEscrow.locked(signer.address))


    

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
