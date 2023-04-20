import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
import { time } from "@nomicfoundation/hardhat-network-helpers";
import "hardhat-gas-reporter"
import { BuildingsFacet, CalculatorFacet, CityManagerFacet, CityNFTFacet, ResourcesFacet, TroopCommandsFacet, TroopsManagerFacet, WorldFacet } from "../typechain-types";
import { deployDiamond } from "./deploy";
import { TroopMovementsFacet } from "../typechain-types/contracts/Game/facets/TroopMovementsFacet.sol";
let cities: CityNFTFacet;
let gameWorld: WorldFacet;
let cityManager: CityManagerFacet;
let troops: TroopsManagerFacet;
let troopsManager: TroopsManagerFacet;
let troopsMovement: TroopMovementsFacet;
let troopCommands: TroopCommandsFacet;
let buildings: BuildingsFacet;
let resources: ResourcesFacet;
let calculator: CalculatorFacet;
const desiredCoords: any = { X: 1, Y: 1, }
let owner: any;
describe("FieldBattle", function () {

    const cityId = 1;
    const barracksId = 6;

    const cityCoords = {
        X: 1,
        Y: 1
    }

    async function deployAll() {
        // console.log('Deploying contracts...');
        const [owner$] = await ethers.getSigners();
        owner = owner$;
        const diamond = await deployDiamond()
        cities = await ethers.getContractAt("CityNFTFacet", diamond) as any
        gameWorld = await ethers.getContractAt("WorldFacet", diamond) as any
        cityManager = await ethers.getContractAt("CityManagerFacet", diamond) as any
        troops = await ethers.getContractAt("TroopsManagerFacet", diamond) as any
        troopsManager = await ethers.getContractAt("TroopsManagerFacet", diamond) as any
        troopsMovement = await ethers.getContractAt("TroopMovementsFacet", diamond) as any
        buildings = await ethers.getContractAt("BuildingsFacet", diamond) as any
        resources = await ethers.getContractAt("ResourcesFacet", diamond) as any
        calculator = await ethers.getContractAt("CalculatorFacet", diamond) as any
        troopCommands = await ethers.getContractAt("TroopCommandsFacet", diamond) as any
    }

    before(async function () {
        await deployAll()
    });



    it("Mint 10000 resources.", async function () {
        const [owner] = await ethers.getSigners();
        await gameWorld.createCity(cityCoords, true, 1)
        // await resources.setGameManager(owner.address, true)
        for (let i = 0; i < 5; i++) {
            await resources.addResource(cityId, i, 50000)
        }
        for (let i = 0; i < 4; i++) {
            expect((await resources.cityResources(cityId, i)).eq(50000)).to.be.true
        }
        console.log(await cities.ownerOf(0));
        console.log(await cities.ownerOf(1));
        console.log(await cities.ownerOf(2));
        console.log(await cities.ownerOf(3));
        console.log(await cities.ownerOf(4));

    });

    it("Upgrade barracks", async function () {
        console.log('1');
        console.log("City  Blaances before upgrade: ");
        for (let index = 0; index < 5; index++) {
            console.log(
                await resources.cityResources(cityId, index)
            );
        }
        await cityManager.upgradeBuilding(cityId, barracksId)
        console.log('2');
        console.log("City Blaances after upgrade: ");
        for (let index = 0; index < 5; index++) {
            console.log(
                await resources.cityResources(cityId, index)
            );
        }
        let hasError
        try {
            await cityManager.upgradeBuilding(cityId, barracksId)
        } catch (error) {
            hasError = true
        }
        expect(hasError).to.be.true
        await time.increase(await (await buildings.buildingInfo(barracksId)).UpgradeTime[0].add(1).toNumber());
        const barracksLvL = await cityManager.buildingLevel(cityId, barracksId)
        expect(barracksLvL.eq(1)).to.be.true
    })

    it("Upgrade barracks again", async function () {
        console.log('1');
        console.log("City  Blaances before upgrade2: ");
        for (let index = 0; index < 5; index++) {
            console.log(
                await resources.cityResources(cityId, index)
            );
        }
        await cityManager.upgradeBuilding(cityId, barracksId)
        console.log('2');
        console.log("City Blaances after upgrade2: ");
        for (let index = 0; index < 5; index++) {
            console.log(
                await resources.cityResources(cityId, index)
            );
        }
        let hasError
        try {
            await cityManager.upgradeBuilding(cityId, barracksId)
        } catch (error) {
            hasError = true
        }
        expect(hasError).to.be.true
        await time.increase(await (await buildings.buildingInfo(barracksId)).UpgradeTime[1].add(1).toNumber());
        const barracksLvL = await cityManager.buildingLevel(cityId, barracksId)
        expect(barracksLvL.eq(2)).to.be.true
    })

    it("Upgrade barracks again again", async function () {
        console.log('1');
        console.log("City  Blaances before upgrade2: ");
        for (let index = 0; index < 5; index++) {
            console.log(
                await resources.cityResources(cityId, index)
            );
        }
        await cityManager.upgradeBuilding(cityId, barracksId)
        console.log('2');
        console.log("City Blaances after upgrade2: ");
        for (let index = 0; index < 5; index++) {
            console.log(
                await resources.cityResources(cityId, index)
            );
        }
        let hasError
        try {
            await cityManager.upgradeBuilding(cityId, barracksId)
        } catch (error) {
            hasError = true
        }
        expect(hasError).to.be.true
        await time.increase(await (await buildings.buildingInfo(barracksId)).UpgradeTime[2].add(1).toNumber());
        const barracksLvL = await cityManager.buildingLevel(cityId, barracksId)
        expect(barracksLvL.eq(3)).to.be.true
    })
    it("Mint 100 soldier", async function () {
        const [owner] = await ethers.getSigners();
        await troopsManager.recruitTroops(cityId, [0], [40])
        expect((await troopsManager.cityTroops(cityId, 0)).toNumber()).to.eq(40)
    });

    it("Send squad to coords", async function () {
        const coordsToSend = { X: 1, Y: 2 }
        const foodId = 4;
        let resourceBalance = await resources.cityResources(cityId, foodId)
        const troopToSend = 20
        await troopsMovement.sendSquadTo(cityId, coordsToSend, [0], [troopToSend], 2)

        let resourceAfter = await resources.cityResources(cityId, foodId)

        let squad = await troopsManager.squadsById(0)
        const activeSquadsOfCity = await troopsManager.cityActiveSquads(cityId)
        const squadsInPosition = await troopsManager.squadsIdOnWorld(coordsToSend)

        expect((await troopsManager.cityTroops(cityId, 0)).toNumber()).to.eq(40 - troopToSend, "soldier sent")
        expect(squad.Active).to.be.false
        expect(activeSquadsOfCity.length).to.equal(1)
        expect(squadsInPosition.length).to.equal(1)
        expect(squadsInPosition[0].eq(0)).to.be.true;
        const distance = await calculator.timeBetweenTwoPoints(cityCoords, coordsToSend)
        // console.log("Distance in seconds: ", distance.toNumber());
        expect(resourceBalance.sub(resourceAfter).eq(distance.mul(5)))
        resourceBalance = await resources.cityResources(cityId, foodId)
        expect(squad.Position.X.eq(coordsToSend.X)).to.be.true
        expect(squad.Position.Y.eq(coordsToSend.Y)).to.be.true
        await time.increase(distance.toNumber() + 1)
        squad = await troopsManager.squadsById(0)
        expect(squad.Active).to.be.true
        expect((await troopsManager.cityTroops(cityId, 0)).toNumber()).to.eq(40 - troopToSend)
    });


    it("Send squad 2 to coords", async function () {
        const coordsToSend = { X: 1, Y: 3 }
        const foodId = 4;
        let resourceBalance = await resources.cityResources(cityId, foodId)
        await troopsMovement.sendSquadTo(cityId, coordsToSend, [0], [20], 0)
        let resourceAfter = await resources.cityResources(cityId, foodId)
        let squad = await troopsManager.squadsById(1)
        const activeSquadsOfCity = await troopsManager.cityActiveSquads(cityId)
        const squadsInPosition = await troopsManager.squadsIdOnWorld(coordsToSend)
        console.log(activeSquadsOfCity);
        expect(squad.Active).to.be.false
        console.log(2);
        expect(activeSquadsOfCity.length).to.equal(2)
        console.log(1);

        expect(squadsInPosition.length).to.equal(1)

        expect(squadsInPosition[0].eq(1)).to.be.true;
        const distance = await calculator.timeBetweenTwoPoints(cityCoords, coordsToSend)
        // console.log("Distance in seconds: ", distance.toNumber());
        expect(resourceBalance.sub(resourceAfter).eq(distance.mul(5)))
        resourceBalance = await resources.cityResources(cityId, foodId)
        expect(squad.Position.X.eq(coordsToSend.X)).to.be.true
        expect(squad.Position.Y.eq(coordsToSend.Y)).to.be.true
        await time.increase(distance.toNumber() + 111)
        squad = await troopsManager.squadsById(1)
        expect(squad.Active).to.be.true
    });

    it("Attack to squad 2 with squad 1", async function () {
        let squad1 = await troopsManager.squadsById(0)
        let squad2 = await troopsManager.squadsById(1)
        const coordsOfMySquad = { X: 1, Y: 2 }
        const coordsToAttack = { X: 1, Y: 3 }

        for (let index = 0; index < squad1.TroopIds.length; index++) {
            console.log(`squad1 has troop ${index}: ${squad1.TroopAmounts[index].toNumber()}`);
        }
        for (let index = 0; index < squad2.TroopIds.length; index++) {
            console.log(`squad2 has troop ${index}: ${squad2.TroopAmounts[index].toNumber()}`);
        }

        let tx = await troopCommands.attack(0, 0, 1)
        await tx.wait(1)
        // const txReceipt = await (cities.provider).getTransactionReceipt(tx.hash);
        // console.log(tx.hash);
        // let txGasUsed = txReceipt.cumulativeGasUsed
        // const gasCostEth = ethers.utils.formatEther(txReceipt.effectiveGasPrice.mul(txReceipt.gasUsed).toNumber());
        // console.log({
        //     txGasUsed, gasUsed: txReceipt.gasUsed, gasPrice: txReceipt.effectiveGasPrice,
        //     total: txReceipt.effectiveGasPrice.mul(txReceipt.gasUsed).toNumber(),
        //     gasCostEth
        // });

        squad1 = await troopsManager.squadsById(0)
        squad2 = await troopsManager.squadsById(1)
        for (let index = 0; index < squad1.TroopIds.length; index++) {
            console.log(`end of fight squad1 has troop ${index}: ${squad1.TroopAmounts[index].toNumber()}`);
        }
        for (let index = 0; index < squad2.TroopIds.length; index++) {
            console.log(`end of fight squad2 has troop ${index}: ${squad2.TroopAmounts[index].toNumber()}`);
        }




        console.log(
            "squad of atk",
            await troopsManager.squadsIdOnWorld(coordsOfMySquad)
        );
        console.log(
            "squad of def",
            await troopsManager.squadsIdOnWorld(coordsToAttack)
        );

        await time.increase(1000);
        console.log("squad id 0 troop left", await (await troopsManager.squadsById(0)).TroopAmounts);
        console.log("squad id 1 troop left", await (await troopsManager.squadsById(1)).TroopAmounts);
        // console.log("squad of my cities", await troopsManager.cityActiveSquads(cityId));

    })


});