const { FacetCutAction, getSelectors } = require('./helpers')

const FacetNames = [
    'DelegationFacet',
    'BuildingsFacet',
    'CalculatorFacet',
    'CityManagerFacet',
    'CityNFTFacet',
    'PerlinNoiseFacet',
    'ResearchManagerFacet',
    'ResearchsFacet',
    'ResourcesFacet',
    'TrigonometryFacet',
    'TroopCommandsFacet',
    'TroopMovementsFacet',
    'TroopsManagerFacet',
    'WorldFacet',
]

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()
    console.log(`>>> your address: ${deployer}`)
    const DiamondCutFacet = await deploy("DiamondCutFacet", {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: 1,
    })
    console.log('DiamondCutFacet deployed:', DiamondCutFacet.address)

    // deploy Diamond
    const Diamond = await deploy("Diamond", {
        from: deployer,
        args: [deployer, DiamondCutFacet.address],
        log: true,
        waitConfirmations: 1,
    })
    console.log('Diamond deployed:', Diamond.address)

    // deploy DiamondInit
    // DiamondInit provides a function that is called when the diamond is upgraded to initialize state variables
    // Read about how the diamondCut function works here: https://eips.ethereum.org/EIPS/eip-2535#addingreplacingremoving-functions
    const DiamondInit = await deploy("GameInit", {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: 1,
    })
    console.log('DiamondInit deployed:', DiamondInit.address)


    const cut = []
    for (const FacetName of FacetNames) {
        const facet = await ethers.getContract(FacetName)
        console.log(`${FacetName} deployed: ${facet.address}`)
        cut.push({
            facetAddress: facet.address,
            action: FacetCutAction.Add,
            functionSelectors: getSelectors(facet)
        })
    }

    console.log('')
    console.log('Diamond Cut:', cut)
    const diamondCut = await ethers.getContractAt('IDiamondCut', Diamond.address)
    let tx
    let receipt
    // call to init function
    let diamondInit = await ethers.getContractAt("GameInit", DiamondInit.address)
    let functionCall = diamondInit.interface.encodeFunctionData('init')
    tx = await diamondCut.diamondCut(cut, diamondInit.address, functionCall)
    // tx = await diamondCut.diamondCut([], diamondInit.address, functionCall)
    console.log('Diamond cut tx: ', tx.hash)
    receipt = await tx.wait()
    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    console.log('Completed diamond cut')
    console.log(Diamond.address);
    return Diamond.address
}

module.exports.tags = ["DeployGameDiamond"]
module.exports.dependencies = ["BuildingsFacet", "CalculatorFacet", "CityManagerFacet", "CityNFTFacet", "DelegationFacet", "PerlinNoiseFacet", "ResearchManagerFacet", "ResearchsFacet", "ResourcesFacet", "TrigonometryFacet", "TroopCommandsFacet", "TroopMovementsFacet", "TroopsManagerFacet", "WorldFacet"]
