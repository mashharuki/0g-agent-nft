import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";

dotenv.config();

const ZG_TESTNET_PRIVATE_KEY = process.env.ZG_TESTNET_PRIVATE_KEY;
const ZG_AGENT_NFT_CREATOR_PRIVATE_KEY = process.env.ZG_AGENT_NFT_CREATOR_PRIVATE_KEY;
const ZG_AGENT_NFT_ALICE_PRIVATE_KEY = process.env.ZG_AGENT_NFT_ALICE_PRIVATE_KEY;
const ZG_AGENT_NFT_BOB_PRIVATE_KEY = process.env.ZG_AGENT_NFT_BOB_PRIVATE_KEY;

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
      allowBlocksWithSameTimestamp: true,
      blockGasLimit: 100000000,
      gas: 100000000,
      accounts: [
          {
              privateKey: ZG_AGENT_NFT_CREATOR_PRIVATE_KEY || "",
              balance: "1000000000000000000000",
          },
          {
              privateKey: ZG_AGENT_NFT_ALICE_PRIVATE_KEY || "",
              balance: "1000000000000000000000",
          },
          {
              privateKey: ZG_AGENT_NFT_BOB_PRIVATE_KEY || "",
              balance: "1000000000000000000000",
          }
      ],
    },
    zgTestnet: {
      url: "https://evmrpc-testnet.0g.ai",
      accounts: [ZG_TESTNET_PRIVATE_KEY || ""],
      chainId: 16600,
  },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

export default config;