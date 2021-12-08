const main = async () => {

    const [owner] = await hre.ethers.getSigners();

    // Compile our contract
    const BiactroFoundersNFTFactory = await hre.ethers.getContractFactory("BiactroFoundersNFT");

    // Deploy our contract
    const BiactroFoundersNFTContract = await BiactroFoundersNFTFactory.deploy('ipfs://QmfLCLmb3TvFgnJccCBVVSVWsg6jaepsXoW5wxpFV14mhc/', owner.address);

    // Wait for the minted process to finish
    await BiactroFoundersNFTContract.deployed();

    const mint = await BiactroFoundersNFTContract.mint(1, { value: ethers.utils.parseUnits('80000000', 'gwei') });
    mint.wait();

    const metadata = await BiactroFoundersNFTContract.tokenURI(1);
    console.log('Metadata: ', metadata);

    // Get the address of the contract
    const address = BiactroFoundersNFTContract.address;
    console.log(`Contract deployed to ${address}`);
    console.log("Contract deployed by:", owner.address);

    addMemberTx = await BiactroFoundersNFTContract.mint(1);
    await addMemberTx.wait();
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