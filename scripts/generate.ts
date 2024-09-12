import { ethers, network } from "hardhat";
import ContractAddresses from "../DeploymentOutput.json";
import fs from "fs";


import PumpFunABI from "../artifacts-zk/contracts/PumpFun.sol/PumpFun.json";
import PumpFunFactoryABI from "../artifacts-zk/contracts/PumpFunFactory.sol/PumpFunFactory.json";

import { Secrets } from "../secrets";
import { PumpFunFactory } from "../typechain-types";
import { Address, BytesLike } from "ethers";
async function main() {

    const provider = new ethers.JsonRpcProvider(network.config.url);

    const signer = new ethers.Wallet(Secrets.DEPLOYER_PRIVATEKEY, provider);
      const pumpFunFactory = new ethers.Contract(
        "0x7f19656b47F3878c176e2A18cfF962c35240c5BD",
        PumpFunFactoryABI.abi,
        provider,
      )as unknown as PumpFunFactory;

      const pumpFun = await pumpFunFactory.createPumpFun.populateTransaction("name", "symbol", "stringSalt");

      console.log(pumpFun);
      console.log(await pumpFunFactory.getCreate2Address("name", "symbol", signer.address, "stringSalt"));

      

    //   const token = new ethers.Contract(
    //     tokenAdd,
    //     PumpFunABI.abi,
    //     provider
    //   );
    //   console.log(await token.balanceOf(signer.address));


      
}

export function create2Address(sender: Address, bytecodeHash: BytesLike, salt: BytesLike, input: BytesLike) {
    const prefix = ethers.keccak256(ethers.toUtf8Bytes("zksyncCreate2"));
    const inputHash = ethers.keccak256(input);
    const addressBytes = ethers.keccak256(ethers.concat([prefix, ethers.zeroPadValue(sender, 32), salt, bytecodeHash, inputHash])).slice(26);
    return ethers.getAddress(addressBytes);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
