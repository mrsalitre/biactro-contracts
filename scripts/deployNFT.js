const main = async () => {
    const [deployer] = await hre.ethers.getSigners();

    console.log('Deploying contracts with account: ', deployer.address);

    const BiactroFoundersNFTFactory = await hre.ethers.getContractFactory('BiactroFoundersNFT');
    const BiactroFoundersNFTContract = await BiactroFoundersNFTFactory.deploy('ipfs://QmfLCLmb3TvFgnJccCBVVSVWsg6jaepsXoW5wxpFV14mhc/', deployer.address);

    await BiactroFoundersNFTContract.deployed();

    console.log('Contract address: ', BiactroFoundersNFTContract.address);
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