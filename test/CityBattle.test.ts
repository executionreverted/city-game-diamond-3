import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
import { time } from "@nomicfoundation/hardhat-network-helpers";
import "hardhat-gas-reporter"
import { BuildingsFacet, CalculatorFacet, CityManagerFacet, CityNFTFacet, ResourcesFacet, TroopCommandsFacet, TroopMovementsFacet, TroopsManagerFacet, WorldFacet } from "../typechain-types";
import { deployDiamond } from "./deploy";
let cities: CityNFTFacet;
let gameWorld: WorldFacet;
let gameWorld2: WorldFacet;
let cityManager: CityManagerFacet;
let troops: TroopsManagerFacet;
let troopsManager: TroopsManagerFacet;
let troopsManager2: TroopsManagerFacet;
let troopCommands: TroopCommandsFacet;
let troopsMovement: TroopMovementsFacet;
let troopsMovement2: TroopMovementsFacet;
let buildings: BuildingsFacet;
let resources: ResourcesFacet;
let calculator: CalculatorFacet;
const desiredCoords: any = { X: 1, Y: 1, }
let owner: any;
let owner2: any;
describe("CityBattle", function () {

    const cityId = 1;
    const barracksId = 6;

    const cityCoords = {
        X: 1,
        Y: 1
    }
    const atkCityCoords = {
        X: 1,
        Y: 2
    }

    async function deployAll() {
        // console.log('Deploying contracts...');
        const [owner$, owner$2] = await ethers.getSigners();
        owner = owner$;
        owner2 = owner$2;
        const diamond = await deployDiamond()
        cities = await ethers.getContractAt("CityNFTFacet", diamond) as any
        gameWorld = await ethers.getContractAt("WorldFacet", diamond) as any
        gameWorld2 = await ethers.getContractAt("WorldFacet", diamond, owner2) as any
        cityManager = await ethers.getContractAt("CityManagerFacet", diamond) as any
        troops = await ethers.getContractAt("TroopsManagerFacet", diamond) as any
        troopsManager = await ethers.getContractAt("TroopsManagerFacet", diamond) as any
        troopsMovement = await ethers.getContractAt("TroopMovementsFacet", diamond) as any
        troopsManager2 = await ethers.getContractAt("TroopsManagerFacet", diamond, owner2) as any
        troopsMovement2 = await ethers.getContractAt("TroopMovementsFacet", diamond, owner2) as any
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
        await gameWorld2.createCity(atkCityCoords, true, 1)
        // await resources.setGameManager(owner.address, true)
        for (let i = 0; i < 5; i++) {
            await resources.addResource(cityId, i, 50000)
            await resources.addResource(cityId + 1, i, 1000)
        }
        for (let i = 0; i < 5; i++) {
            expect((await resources.cityResources(cityId, i)).eq(50000)).to.be.true
            expect((await resources.cityResources(cityId + 1, i)).eq(1000)).to.be.true
        }
        await resources.addResource(cityId + 1, 4, 1000)
        console.log(await cities.ownerOf(0));
        console.log(await cities.ownerOf(1));
        console.log(await cities.ownerOf(2));
        console.log(await cities.ownerOf(3));
        console.log(await cities.ownerOf(4));
    });

    it("give premium", async () => {
        await gameWorld.createCity(desiredCoords, true, 1)
        await cityManager.setPremiumStatus(1, 1, 1)
        await cityManager.setPremiumStatus(2, 1, 1)
        const status = await cityManager.premiumStatus(1)
        console.log('City has premium tier: ', status._tier.toNumber());

        expect(status._tier.toNumber()).to.eq(1)
        expect(status._expirationDate.toNumber()).to.gt(0)
    })
    it("Upgrade barracks", async function () {
        console.log('1');
        console.log("City  Blaances before upgrade: ");
        for (let index = 0; index < 5; index++) {
            console.log(
                await resources.cityResources(cityId, index)
            );
        }
        await cityManager.upgradeBuilding(cityId, barracksId, true)
        console.log('2');
        console.log("City Blaances after upgrade: ");
        for (let index = 0; index < 5; index++) {
            console.log(
                await resources.cityResources(cityId, index)
            );
        }
        let hasError
        try {
            await cityManager.upgradeBuilding(cityId, barracksId, true)
        } catch (error) {
            hasError = true
        }
        expect(hasError).to.be.true
        await time.increase(await (await buildings.buildingInfo(barracksId)).UpgradeTime[0].add(1).toNumber());
        const barracksLvL = await cityManager.buildingLevel(cityId, barracksId)
        expect(barracksLvL.eq(1)).to.be.true
    })

    it("Mint 100 soldier", async function () {
        const [owner] = await ethers.getSigners();
        await troopsManager.recruitTroops(cityId, [0], [1000], true)
        const trn = await troopsManager.cityActiveTrainings(cityId)
        expect(trn.length).to.eq(1)
        const timeStamp = (await ethers.provider.getBlock("latest")).timestamp
        await time.increase(trn[0].EndTime.sub(timeStamp).add(1))
        await troopsManager.finalizeTraining(cityId, 0);

        await troopsManager2.recruitTroops(cityId + 1, [0], [5], true)
        const trn2 = await troopsManager2.cityActiveTrainings(cityId)
        expect(trn.length).to.eq(1)
        const timeStamp2 = (await ethers.provider.getBlock("latest")).timestamp
        await time.increase(trn[0].EndTime.sub(timeStamp2).add(1))
        await troopsManager2.finalizeTraining(cityId, 1);

        expect((await troopsManager.cityTroops(cityId, 0)).toNumber()).to.eq(1000)
        expect((await troopsManager.cityTroops(cityId + 1, 0)).toNumber()).to.eq(5)
    });

    it("Send squad to enemy city", async function () {
        const foodId = 4;
        const troopToSend = 100
        await troopsMovement.sendSquadTo(cityId, atkCityCoords, [0], [troopToSend], 2)
        expect((await troopsManager.cityTroops(cityId, 0)).toNumber()).to.eq(1000 - troopToSend, "soldier sent")
        expect((await troopsManager.cityTroops(cityId + 1, 0)).toNumber()).to.eq(5, "soldier waits in city")
    });

    it("squad arrived", async function () {
        const distance = await calculator.timeBetweenTwoPoints(cityCoords, atkCityCoords)
        await time.increase(distance.toNumber() + 1)
        expect((await troopsManager.squadsById(0)).Active).to.be.true
    });

    it("squad arrived", async function () {
        console.log(
            'before'
        );

        console.log((await troopsManager.squadsById(0)).TroopAmounts[0], 'soldier in squad left');
        console.log((await troopsManager.cityTroops(cityId + 1, 0)).toNumber(), 'soldier in city left');
        let pre = []
        let pre2 = []
        for (let i = 0; i < 5; i++) {
            let a = await resources.cityResources(cityId, i);
            let b = await resources.cityResources(cityId + 1, i);
            pre.push(a)
            pre2.push(b)
            console.log("atk ", (a), " ", i)
            console.log("def ", (b), " ", i)
        }
        console.log('____________________');

        let tx = await troopCommands.attack(0, 1, 0);
        console.log(
            'after'
        );
        for (let i = 0; i < 5; i++) {
            console.log("atk ", (await resources.cityResources(cityId, i)), " ", i)
            console.log("def ", (await resources.cityResources(cityId + 1, i)), " ", i)
        }
        for (let i = 0; i < 5; i++) {
            console.log("diff ", ((await resources.cityResources(cityId, i)).sub(pre[i]).toNumber()), " ", i)
            console.log("diff 2 ", ((await resources.cityResources(cityId + 1, i)).sub(pre2[i]).toNumber()), " ", i)
        }

        console.log((await troopsManager.squadsById(0)).TroopAmounts[0], 'soldier in squad left');
        console.log((await troopsManager.cityTroops(cityId + 1, 0)).toNumber(), 'soldier in city left');
    });

});