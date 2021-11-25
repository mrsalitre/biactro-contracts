const main = async () => {
  const biactroWhiteListFactory = await hre.ethers.getContractFactory('SayHi');
  const biactroWhiteListContract = await biactroWhiteListFactory.deploy();
  
  await biactroWhiteListContract.deployed();
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