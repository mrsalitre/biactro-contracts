const main = async () => {

    const [owner, randomPerson] = await hre.ethers.getSigners();

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

    let addMemberTx = await biactroWhiteListContract.addMember(1);
    await addMemberTx.wait();

    
    let transferOwnership = await biactroWhiteListContract.transferOwnership(randomPerson.address);
    await transferOwnership.wait();
    
    let renounceOwnership = await biactroWhiteListContract.renounceOwnership();
    await renounceOwnership.wait();
    
    addMemberTx = await biactroWhiteListContract.connect(randomPerson).addMember(1);
    await addMemberTx.wait();


    let membersCount = await biactroWhiteListContract.getMemberCount();
    console.log(`Members count: ${membersCount}`);
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