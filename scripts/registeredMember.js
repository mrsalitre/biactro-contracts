const main = async () => {

    const [owner] = await hre.ethers.getSigners();

    // Compile our contract
    const biactroWhiteListFactory = await hre.ethers.getContractFactory("BiactroWhiteList");

    // Deploy our contract
    const biactroWhiteListContract = await biactroWhiteListFactory.deploy();

    // Wait for the minted process to finish
    await biactroWhiteListContract.deployed();

    // Get the address of the contract
    const address = biactroWhiteListContract.address;
    console.log(`Contract deployed to ${address}`);
    console.log("Contract deployed by:", owner.address);
    
    let addMemberLimitTx = await biactroWhiteListContract.setMaxMembers(1);
    await addMemberLimitTx.wait();

    let addMemberTx = await biactroWhiteListContract.addMember();
    await addMemberTx.wait();
    
    let getMemberTx = await biactroWhiteListContract.isMember(owner.address);
    console.log(getMemberTx);

    let membersCount = await biactroWhiteListContract.getMemberCount();
    console.log(`Members count: ${membersCount}`);

    await biactroWhiteListContract.addMember();

    let allMembers = await biactroWhiteListContract.getMembers();
    console.log(allMembers);
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