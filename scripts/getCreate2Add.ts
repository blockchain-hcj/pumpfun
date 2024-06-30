import { ethers } from "hardhat";

import { MPAA } from "../typechain-types";

async function main() {
    const [owner, user1] = await ethers.getSigners();

    // Deploy MPAA contract
    const mpaa = await ethers.deployContract("MPAA",[]);
    await mpaa.waitForDeployment();



    console.log("MPAA deployed to:", await mpaa.getAddress());

    // Test ERC20 Permit
    const amount = ethers.parseEther("100");
    const deadline = Math.floor(Date.now() / 1000) + 3600; // 1 hour from now

    // Get the current nonce for user1
    const nonce = await mpaa.nonces(user1.address);

    // Create the EIP712 signature
    const domain = {
        name: await mpaa.name(),
        version: '1',
        chainId: (await ethers.provider.getNetwork()).chainId,
        verifyingContract: await mpaa.getAddress(),
    };

    const types = {
        Permit: [
            { name: 'owner', type: 'address' },
            { name: 'spender', type: 'address' },
            { name: 'value', type: 'uint256' },
            { name: 'nonce', type: 'uint256' },
            { name: 'deadline', type: 'uint256' },
        ],
    };

    const values = {
        owner: owner.address,
        spender: user1.address,
        value: amount,
        nonce: nonce,
        deadline: deadline,
    };
    const signature = await owner.signTypedData(domain, types, values);
    const { v, r, s } = ethers.Signature.from(signature);

    // Execute the permit
    await mpaa.connect(user1).permit(owner.address, user1.address, amount, deadline, v, r, s);

    console.log("Permit executed successfully");

    // Verify the allowance
    const allowance = await mpaa.allowance(owner.address, user1.address);
    console.log("Allowance after permit:", ethers.formatEther(allowance));

    // Test a transfer using the permit

    await mpaa.connect(user1).transferFrom(owner.address, user1.address, amount);

    console.log("Transfer using permit executed successfully");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
