import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { MPAA } from "../typechain-types";

async function main() {
    const [owner, user1, user2] = await ethers.getSigners();

    // Deploy MPAA contract
    const MPAAFactory = await ethers.getContractFactory("MPAA");
    const mpaa: MPAA = await MPAAFactory.deploy();
    await mpaa.deployed();
    console.log("MPAA deployed to:", mpaa.address);

    // Test ERC20 Permit
    const amount = ethers.utils.parseEther("100");
    const deadline = Math.floor(Date.now() / 1000) + 3600; // 1 hour from now

    // Get the current nonce for user1
    const nonce = await mpaa.nonces(user1.address);

    // Create the EIP712 signature
    const domain = {
        name: await mpaa.name(),
        version: '1',
        chainId: (await ethers.provider.getNetwork()).chainId,
        verifyingContract: mpaa.address,
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
        owner: user1.address,
        spender: user2.address,
        value: amount,
        nonce: nonce,
        deadline: deadline,
    };

    const signature = await user1._signTypedData(domain, types, values);
    const { v, r, s } = ethers.utils.splitSignature(signature);

    // Execute the permit
    await mpaa.connect(user2).permit(user1.address, user2.address, amount, deadline, v, r, s);

    console.log("Permit executed successfully");

    // Verify the allowance
    const allowance = await mpaa.allowance(user1.address, user2.address);
    console.log("Allowance after permit:", ethers.utils.formatEther(allowance));

    // Test a transfer using the permit
    await mpaa.connect(owner).transfer(user1.address, amount);
    await mpaa.connect(user2).transferFrom(user1.address, user2.address, amount);

    console.log("Transfer using permit executed successfully");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
