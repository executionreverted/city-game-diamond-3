import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@typechain/hardhat";
import "hardhat-gas-reporter"
import "solidity-coverage";
import "hardhat-contract-sizer";
import "hardhat-abi-exporter";
import * as dotenv from "dotenv";
import "@openzeppelin/hardhat-upgrades";
import "hardhat-interface-generator";
import "arb-shared-dependencies"

dotenv.config();
// @ts-ignore
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task('accounts', 'Prints the list of accounts', async () => {
  const accounts = await ethers.getSigners()
  for (const account of accounts) {
    console.log(account.address)
  }
})

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: '0.8.18',
  settings: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  },
  gasReporter: {
    currency: 'USD',
    gasPrice: 30,
    enabled: true,
    outputFile: "./gas-reporter.txt"
  },
  abiExporter: {
    path: "./abi",
    runOnCompile: true
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
  },
  networks: {
    hardhat: {
      gasPrice: 875000000,
      chainId: 1337,
      accounts: {
        accountsBalance: '1000000000000000000000000',
        count: 5
      },
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
}
