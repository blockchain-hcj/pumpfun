import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import { Secrets } from "./secrets";
import "@nomicfoundation/hardhat-foundry";
import "@matterlabs/hardhat-zksync-solc";
import "@matterlabs/hardhat-zksync-deploy";

const config: HardhatUserConfig = {
  zksolc: {
    version: "latest",
    settings: {
      optimizer: {
        enabled: true,
      },
    },
  },
  solidity: {
    compilers: [
      {
        version: '0.8.24',
        settings: {
          optimizer: {
            enabled: true,
            runs: 10,
          },
        },
      },]
    },
  networks: {
    "zklink-sepolia": {
      url: "https://sepolia.rpc.zklink.io",
      ethNetwork: "sepolia",
      zksync: true,
      accounts: [Secrets.DEPLOYER_PRIVATEKEY],
      verifyURL: "https://sepolia.explorer.zklink.io/contract_verification"
    },
    arbSepolia: {
      url: "https://arb-sepolia.g.alchemy.com/v2/I-ZVEdUQy4Mk3rwbsNAIp_MVql6coseO",
      accounts: [Secrets.DEPLOYER_PRIVATEKEY],
    },
    baseSepolia:{
      url: "https://base-sepolia.g.alchemy.com/v2/0cNsvrP9a82KWY24wOyUVpgKf8T7WJKQ",
      accounts: [Secrets.DEPLOYER_PRIVATEKEY],
    },
    base:{
      url: "https://base-mainnet.g.alchemy.com/v2/Xh0nbBjvLDgQQ5HhFPi0NRU7_Rv_c6is",
      accounts: [Secrets.DEPLOYER_PRIVATEKEY],
    },
    manta:{
      url: "https://pacific-rpc.manta.network/http",
      accounts: [Secrets.DEPLOYER_PRIVATEKEY],
    },
    
  },
  defaultNetwork: "baseSepolia",

};

export default config;
