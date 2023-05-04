module.exports = async function (taskArgs, hre) {
    const diamond = await ethers.getContract("Diamond")
    const cityManagerFacet = await ethers.getContractAt("CityManagerFacet", diamond.address)
    const { cityId, buildingId, autoClaim, givePremium } = taskArgs
    try {
        if (givePremium) {
            console.log('giving premium');
            await (await cityManagerFacet.setPremiumStatus(cityId, 1, 3)).wait(1)
            console.log('premium sent');
        }
        let tx = await (await cityManagerFacet.upgradeBuilding(cityId, buildingId, autoClaim)).wait(1)
        console.log('upgrading building')
        console.log(`tx: ${tx.transactionHash}`)
    } catch (e) {
        console.log(e);
    }
}