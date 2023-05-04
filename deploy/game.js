// @ts-nocheck

const FacetNames = [
    'GameInit',
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

module.exports = async function main({ getNamedAccounts, deployments }) {
    const { diamond } = deployments;
    const { deployer } = await getNamedAccounts();
    console.log(deployer);
    let diamond$ = await diamond.deploy('Diamond', {
        diamondArtifact: "Diamond",
        deterministicDeployment: false,
        from: deployer,
        owner: deployer,
        facets: FacetNames,
        log: true,
        waitConfirmations: 1,
        execute: {
            contract: 'GameInit',
            methodName: 'init',
            args: []
        },
    });
    console.log('Completed diamond cut', diamond$?.address)
};

module.exports.tags = ["Game"]