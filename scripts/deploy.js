const main = async () => {
  const [deployer] = await hre.ethers.getSigners();
    
  console.log('Deploying contracts with account: ', deployer.address);
  
  const biactroWhiteListFactory = await hre.ethers.getContractFactory('BiactroWhiteList');
  const biactroWhiteListContract = await biactroWhiteListFactory.deploy();
  
  await biactroWhiteListContract.deployed();
  console.log('Contract address: ', biactroWhiteListContract.address);
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.error(error);
        process.exit(1);
    }
};

runMain();