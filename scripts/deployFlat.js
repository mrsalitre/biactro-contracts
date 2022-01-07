const main = async () => {
    const [deployer] = await hre.ethers.getSigners();

    console.log('Deploying contracts with account: ', deployer.address);

    const BiactroFoundersNFTFactory = await hre.ethers.getContractFactory('BiactroFoundersNFTFlat');
    const BiactroFoundersNFTContract = await BiactroFoundersNFTFactory.deploy('ipfs://Qmchfs5uv1Bh6v6CNYxH92cv77nrddUPabZF7HSkKJdJ29/', '0x7ea1Bb15c6D91827a37697c75b2Eeee930c0C188');

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