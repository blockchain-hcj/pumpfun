import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import { Secrets } from "./secrets";
import "@nomicfoundation/hardhat-foundry";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    arbSepolia: {
      url: "https://arb-sepolia.g.alchemy.com/v2/I-ZVEdUQy4Mk3rwbsNAIp_MVql6coseO",
      accounts: [Secrets.DEPLOYER_PRIVATEKEY, Secrets.TEST1],
    },
    baseSepolia:{
      url: "https://base-mainnet.g.alchemy.com/v2/0cNsvrP9a82KWY24wOyUVpgKf8T7WJKQ",
      accounts: [Secrets.DEPLOYER_PRIVATEKEY, Secrets.TEST1],
    }
  },
  defaultNetwork: "baseSepolia",

};

export default config;
