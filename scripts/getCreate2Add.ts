import { Deployer } from "@matterlabs/hardhat-zksync-deploy";
import { Wallet, Provider  } from "zksync-ethers";
import  {utils } from "zksync-web3";
import { ethers } from "ethers";

import PumpFunABI from "../artifacts-zk/contracts/PumpFun.sol/PumpFun.json";


import * as hre from "hardhat";


async function main() {
    const [signer] = await hre.ethers.getSigners();
    const salt = "0x4e9e69678b8923e075d494128d2e34d91af668f5eddf441bb15a44e6f18563c1"
    const input = ethers.AbiCoder.defaultAbiCoder().encode(
        ['string', 'string', 'address', 'address'],
        ['name', 'symbol', '0xdE1614049EFA45b96f302894541c81dc57Bb461a', signer.address]
    );
    console.log(ethers.hexlify(utils.hashBytecode(PumpFunABI.bytecode)));


    const add = utils.create2Address(
        "0xBE692936366DD23EDd63204EfDAeEc34d6a02370",
         utils.hashBytecode(PumpFunABI.bytecode),
          salt,
           input)
  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
