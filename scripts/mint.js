const main = async () => {

    const [owner] = await hre.ethers.getSigners();

    // Compile our contract
    const BiactroFoundersNFTFactory = await hre.ethers.getContractFactory("BiactroFoundersNFT");

    // Deploy our contract
    const BiactroFoundersNFTContract = await BiactroFoundersNFTFactory.deploy('ipfs://QmfLCLmb3TvFgnJccCBVVSVWsg6jaepsXoW5wxpFV14mhc/', '0xf57b2c51ded3a29e6891aba85459d600256cf317');

    // Wait for the minted process to finish
    await BiactroFoundersNFTContract.deployed();

    await BiactroFoundersNFTContract.mint([2,3,4,55,1056]);

    await BiactroFoundersNFTContract.mint([1]);

    console.log("total supply: " + await BiactroFoundersNFTContract.totalSupply());

    // Get the address of the contract
    const address = BiactroFoundersNFTContract.address;
    console.log(`Contract deployed to ${address}`);
    console.log("Contract deployed by:", owner.address);
}

// Run the main function
const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();