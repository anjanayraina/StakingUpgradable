require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  networks:{
    sepolia:{
      url:process.env.ALCHEMY_TESTNET_RPC_URL,
      accounts:[process.env.TESTNET_PRIVATE_KEY],
    },
  },
};
