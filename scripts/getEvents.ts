import { ethers } from "hardhat";
import ContractAddresses from "../DeploymentOutput.json";

async function main() {
    // Get the Events contract instance
    const eventsContract = await ethers.getContractAt("Events", ContractAddresses.Events.address);

    // Get all events
    const filter = eventsContract.filters.PumpFunEvent();
    const events = await eventsContract.queryFilter(filter);
    console.log("All PumpFunEvent events:");
    events.forEach((event, index) => {
        console.log(`Event ${index + 1}:`);
        if (event.args) {
            console.log(`  Token Address: ${event.args[0] || 'N/A'}`);
            console.log(`  is buy: ${event.args[1] || 'N/A'}`);
            console.log(`  eth change amount: ${event.args[2] || 'N/A'}`);
            console.log(`  token change amount: ${event.args[3] || 'N/A'}`);

        } else {
            console.log("  Event arguments not available");
        }
        console.log(`  Block Number: ${event.blockNumber}`);
        console.log(`  Transaction Hash: ${event.transactionHash}`);
        console.log("--------------------");
    });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
