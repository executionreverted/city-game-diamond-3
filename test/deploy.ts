import { ethers } from "hardhat"
import { getSelectors, FacetCutAction } from '../scripts/libraries/diamond'

export async function deployDiamond() {
    const accounts = await ethers.getSigners()
    const contractOwner = accounts[0]

    // deploy DiamondCutFacet
    const DiamondCutFacet = await ethers.getContractFactory('DiamondCutFacet')
    const diamondCutFacet = await DiamondCutFacet.deploy()
    await diamondCutFacet.deployed()
    console.log('DiamondCutFacet deployed:', diamondCutFacet.address)

    // deploy Diamond
    const Diamond = await ethers.getContractFactory('Diamond')
    const diamond = await Diamond.deploy(contractOwner.address, diamondCutFacet.address)
    await diamond.deployed()
    console.log('Diamond deployed:', diamond.address)

    // deploy DiamondInit
    // DiamondInit provides a function that is called when the diamond is upgraded to initialize state variables
    // Read about how the diamondCut function works here: https://eips.ethereum.org/EIPS/eip-2535#addingreplacingremoving-functions
    const DiamondInit = await ethers.getContractFactory('GameInit')
    const diamondInit = await DiamondInit.deploy()
    await diamondInit.deployed()
    console.log('DiamondInit deployed:', diamondInit.address)

    // deploy facets
    console.log('')
    console.log('Deploying facets')
    const FacetNames = [
        'BuildingsFacet',
        'CityManagerFacet',
        'CityNFTFacet',
        'ResourcesFacet',
        'TroopCommandsFacet',
        'TroopsManagerFacet',
        'WorldFacet',
        'ResearchsFacet',
        'ResearchManagerFacet',
        'CalculatorFacet',
        // 'Test1Facet'
    ]

    // const UpgradedFacets = [
    //   'Test1FacetV2'
    // ]
    const cut = []
    for (const FacetName of FacetNames) {
        const Facet = await ethers.getContractFactory(FacetName)
        const facet = await Facet.deploy()
        await facet.deployed()
        console.log(`${FacetName} deployed: ${facet.address}`)
        cut.push({
            facetAddress: facet.address,
            action: FacetCutAction.Add,
            functionSelectors: getSelectors(facet)
        })
    }

    // upgrade diamond with facets
    console.log('')
    console.log('Diamond Cut:', cut)
    const diamondCut = await ethers.getContractAt('IDiamondCut', diamond.address)
    let tx
    let receipt
    // call to init function
    let functionCall = diamondInit.interface.encodeFunctionData('init')
    tx = await diamondCut.diamondCut(cut, diamondInit.address, functionCall)
    console.log('Diamond cut tx: ', tx.hash)
    receipt = await tx.wait()
    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    console.log('Completed diamond cut')

    // let facetInstance: Test1Facet = await ethers.getContractAt("Test1Facet", diamond.address) as any
    // console.log('V1 Facet calls:');
    // console.log(await facetInstance.test1Func2());
    // await facetInstance.test1Func1()
    // console.log(' call  await facetInstance.test1Func1() ');
    // console.log(await facetInstance.test1Func2());


    // const facets: FacetsAndAddSelectors[] = [
    //   {
    //     facetName: "Test1FacetV2",
    //     addSelectors: [
    //       'function test1Func3(uint value) external',
    //       'function test1Func4() external view'],
    //     removeSelectors: [
    //       'function test1Func1() external',
    //       'function test1Func2() external view'
    //     ],
    //   },
    // ];

    // const joined = convertFacetAndSelectorsToString(facets);

    // const args: DeployUpgradeTaskArgs = {
    //   diamondUpgrader: diamond.address,
    //   diamondAddress: diamond.address,
    //   facetsAndAddSelectors: joined,
    //   useLedger: false,
    //   useMultisig: false,
    // };

    // await run("deployUpgrade", args);

    // let facetInstanceV2: Test1FacetV2 = await ethers.getContractAt("Test1FacetV2", diamond.address) as any
    // try {
    //   // @ts-ignore
    //   console.log(await facetInstance.test1Func2());
    // } catch (error) {
    //   console.log('error');
    //   console.log(error);
    // }

    // console.log('V2 Facet calls:');
    // console.log(
    //   await facetInstanceV2.test1Func4()
    // );

    // await facetInstanceV2.test1Func3(42069420)
    // console.log(' call  await facetInstance.test1Func4(42069420) ');
    // console.log(await facetInstanceV2.test1Func4());


    // let ownershipFacetInstance: OwnershipFacet = await ethers.getContractAt("OwnershipFacet", diamond.address) as any
    // console.log(await ownershipFacetInstance.owner());

    return diamond.address
}