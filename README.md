# HatchyTribes - Diamond-3-Hardhat Implementation

This is the source code of HatchyTribes, which is built on top of Diamond implementation by mudgen
[https://github.com/mudgen/diamond-3]

## test

```
yarn test
```

## deploy
```
npx hardhat deploy --tags DeployGameDiamond --network shimmer-testnet
```

### only update facet implementation
```
npx hardhat --network shimmer-testnet deployUpgrade --deploy-init false --facet CityManagerFacet --add-selectors "" --remove-selectors ""
```

### add single function from facet
```
npx hardhat --network shimmer-testnet deployUpgrade --deploy-init false --facet CityManagerFacet --remove-selectors "" --add-selectors "function buildingLevels(uint)"
```

### remove single function from facet
```
npx hardhat --network shimmer-testnet deployUpgrade --deploy-init false --facet CityManagerFacet --add-selectors "" --remove-selectors "function buildingLevels(uint)"
```

### add and remove single function from facet
```
npx hardhat --network shimmer-testnet deployUpgrade --deploy-init false --facet CityManagerFacet --add-selectors "function upgradeBuilding(uint, uint,  bool)" --remove-selectors "function buildingUpgradeCompletionTimes(uint)"
```

### add multiple function to a facet
```
npx hardhat --network shimmer-testnet deployUpgrade --deploy-init false --facet CityManagerFacet --add-selectors "function buildingLevels(uint)$$$function upgradeBuilding(uint, uint, bool)" --remove-selectors ""
```

### remove multiple functions from a facet
```
npx hardhat --network shimmer-testnet deployUpgrade --deploy-init false --facet CityManagerFacet --remove-selectors "function buildingLevels(uint)$$$function upgradeBuilding(uint, uint, bool)" --add-selectors ""
```
