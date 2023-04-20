import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
import { time } from "@nomicfoundation/hardhat-network-helpers";

import * as fs from 'fs'
import { BuildingsFacet, CityManagerFacet, CityNFTFacet, WorldFacet, ResourcesFacet, TroopsManagerFacet, ResearchsFacet } from "../typechain-types";
import { deployDiamond } from "./deploy";
import { ResearchManagerFacet } from "../typechain-types/contracts/Game/facets";
let cities: CityNFTFacet;
let gameWorld: WorldFacet;
let cityManager: CityManagerFacet;
let troops: TroopsManagerFacet;
let troopsManager: TroopsManagerFacet;
let buildings: BuildingsFacet;
let resources: ResourcesFacet;
let researchManager: ResearchManagerFacet;
let researchInfo: ResearchsFacet;
const desiredCoords: any = { X: 1, Y: 1, }
let owner: any;
let cityId: any = 1;
let researchCenterId: any = 9;
describe("Test1",
    function () {

        let city1 = 2;
        let city2 = 3;
        // simulation
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
            buildings = await ethers.getContractAt("BuildingsFacet", diamond) as any
            resources = await ethers.getContractAt("ResourcesFacet", diamond) as any
            researchManager = await ethers.getContractAt("ResearchManagerFacet", diamond) as any
            researchInfo = await ethers.getContractAt("ResearchsFacet", diamond) as any
        }


        before(async function () {
            await deployAll()
        });

        it("should mint resources", async () => {
            await gameWorld.createCity(desiredCoords, true, 1)
            // await resources.setGameManager(owner.address, true)
            for (let i = 0; i < 5; i++) {
                await resources.addResource(cityId, i, 250000)
            }
            for (let i = 0; i < 5; i++) {
                expect((await resources.cityResources(cityId, i)).eq(250000)).to.be.true
            }
        })

        it("should upgrade research center 1", async () => {
            await cityManager.upgradeBuilding(cityId, researchCenterId)
            await time.increase(await (await buildings.buildingInfo(researchCenterId)).UpgradeTime[0].add(1).toNumber());
            const researchCenter = await cityManager.buildingLevel(cityId, researchCenterId)
            expect(researchCenter.eq(1)).to.be.true
        })

        it("should upgrade research center 2", async () => {
            await cityManager.upgradeBuilding(cityId, researchCenterId)
            await time.increase(await (await buildings.buildingInfo(researchCenterId)).UpgradeTime[1].add(1).toNumber());
            const researchCenter = await cityManager.buildingLevel(cityId, researchCenterId)
            expect(researchCenter.eq(2)).to.be.true
        })
        it("should research housing", async () => {
            const housing = 1;
            await researchManager.beginResearch(cityId, housing)
            await time.increase(await (await researchInfo.researchInfo(housing)).TimeRequired.add(1).toNumber());
            const researched = await researchManager.isResearched(cityId, housing)
            expect(researched).to.be.true
        })

        it("should research pulley", async () => {
            const pulley = 21;
            await researchManager.beginResearch(cityId, pulley)
            await time.increase(await (await researchInfo.researchInfo(pulley)).TimeRequired.add(1).toNumber());
            const researched = await researchManager.isResearched(cityId, pulley)
            expect(researched).to.be.true
        })


        it("should log current production", async () => {
            const bonus = await resources.resourceResearchBonus(cityId);
            console.log("bonus");
            console.log(bonus.toNumber());
            expect(bonus).to.eq(0)
            console.log(
                (await resources.resourcesPerTick(cityId)).map(a => a.toNumber())
            );

        })

        it("should research Advanced Tools I", async () => {
            const advLogi1 = 22;
            await researchManager.beginResearch(cityId, advLogi1)
            let t = (await researchInfo.researchInfo(advLogi1)).TimeRequired.add(1).toNumber()
            await time.increase(t);
            const researched = await researchManager.isResearched(cityId, advLogi1)
            expect(researched).to.be.true
        })

        it("production amount must be increased", async () => {
            const bonus = await resources.resourceResearchBonus(cityId);
            console.log("bonus");
            console.log(bonus.toNumber());
            expect(bonus).to.eq(5)
            console.log(
                (await resources.resourcesPerTick(cityId)).map(a => a.toNumber())
            );
        })
    });
