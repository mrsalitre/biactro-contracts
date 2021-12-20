require("@nomiclabs/hardhat-waffle");
require('dotenv').config();

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  networks: {
    rinkeby: {
      url: process.env.ALCHEMY_RINKEBY_API_KEY,
      accounts: [process.env.PRIVATE_ACCOUNT_KEY],
    },
    matic: {
      url: "https://rpc-mumbai.maticvigil.com",
      accounts: [process.env.PRIVATE_ACCOUNT_KEY]
    },
    testmatic: {
      url: process.env.ALCHEMY_POLYGON_MUMBAI_API_KEY,
      accounts: [process.env.PRIVATE_ACCOUNT_KEY]
    }
  },
};
