module.exports = async function (taskArgs, hre) {
    const diamond = await ethers.getContract("Diamond")
    const resourcesFacet = await ethers.getContractAt("ResourcesFacet", diamond.address)
    const { cityId, amount } = taskArgs

    for (let i = 0; i < 5; i++) {
        let tx = await (await resourcesFacet.addResource(cityId, i, amount)).wait(1)
        console.log('Sent material ', i);
        console.log(`tx: ${tx.transactionHash}`)
    }
}