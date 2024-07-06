import { ethers } from "hardhat";
import ConrtactAddresses from "../../DeploymentOutput.json"
import fs from "fs";

async function main() {

const [signer] = await ethers.getSigners();

    const feeDistributor = await ethers.getContractAt("FeeDistributor", ConrtactAddresses.FeeDistributor.address);
    const mpaa = await ethers.getContractAt("MPAA", ConrtactAddresses.mpaa.address);
    const approve = await mpaa.approve(ConrtactAddresses.FeeDistributor.address, ethers.MaxUint256);
    await approve.wait();

    const enableToken = await feeDistributor.enableTokenClaiming(ConrtactAddresses.mpaa.address, true);
    await enableToken.wait();
    const deposit = await feeDistributor.depositToken(ConrtactAddresses.mpaa.address, ethers.parseEther('11'));
    await deposit.wait();

    console.log(deposit.hash);
    


    

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
