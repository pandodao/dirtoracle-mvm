import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-chai-matchers";
import '@nomiclabs/hardhat-ethers';
import '@typechain/hardhat';

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  etherscan: {
    apiKey: {
      mvm: "api"
    },
    customChains: [
      {
        network: "mvm",
        chainId: 73927,
        urls: {
          apiURL: "https://geth.mvm.dev/",
          browserURL: "https://scan.mvm.dev/"
        }
      }
    ]
  },
  solidity: {
    version: "0.8.9",
    settings: {
      evmVersion: "london",
      libraries: {
        "contracts/BLS.sol": {
          "BLS": "0xf183132d7bB57EB2568E836cE9730873651Ffa2D"
        }
      },
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    mvm: {
      url: "https://geth.mvm.dev",
      accounts: []
    }
  }
};
