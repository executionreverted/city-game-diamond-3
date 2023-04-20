import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
import { time } from "@nomicfoundation/hardhat-network-helpers";

import * as fs from 'fs'
import { BuildingsFacet, CityManagerFacet, CityNFTFacet, WorldFacet, ResourcesFacet, TroopsManagerFacet, ResearchsFacet, ResearchManagerFacet } from "../typechain-types";
import { deployDiamond } from "./deploy";
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
describe("Research Tree test",
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
                await resources.addResource(cityId, i, 999999999)
            }
            for (let i = 0; i < 5; i++) {
                expect((await resources.cityResources(cityId, i)).eq(999999999)).to.be.true
            }
        })

        it("give premium", async () => {
            await gameWorld.createCity(desiredCoords, true, 1)
            await cityManager.setPremiumStatus(1, 1, 1)
            const status = await cityManager.premiumStatus(1)
            console.log('City has premium tier: ', status._tier.toNumber());

            expect(status._tier.toNumber()).to.eq(1)
            expect(status._expirationDate.toNumber()).to.gt(0)
        })

        it("should upgrade research center 1", async () => {
            await cityManager.upgradeBuilding(cityId, researchCenterId, true)
            await time.increase(await (await buildings.buildingInfo(researchCenterId)).UpgradeTime[0].add(1).toNumber());
            const researchCenter = await cityManager.buildingLevel(cityId, researchCenterId)
            expect(researchCenter.eq(1)).to.be.true
        })

        it("should upgrade research center 2", async () => {
            await cityManager.upgradeBuilding(cityId, researchCenterId, true)
            await time.increase(await (await buildings.buildingInfo(researchCenterId)).UpgradeTime[1].add(1).toNumber());
            const researchCenter = await cityManager.buildingLevel(cityId, researchCenterId)
            expect(researchCenter.eq(2)).to.be.true
        })

        it("should upgrade research center 3", async () => {
            await cityManager.upgradeBuilding(cityId, researchCenterId, true)
            await time.increase(await (await buildings.buildingInfo(researchCenterId)).UpgradeTime[2].add(1).toNumber());
            const researchCenter = await cityManager.buildingLevel(cityId, researchCenterId)
            expect(researchCenter.eq(3)).to.be.true
        })

        it("should upgrade research center 4", async () => {
            await cityManager.upgradeBuilding(cityId, researchCenterId, true)
            await time.increase(await (await buildings.buildingInfo(researchCenterId)).UpgradeTime[3].add(1).toNumber());
            const researchCenter = await cityManager.buildingLevel(cityId, researchCenterId)
            expect(researchCenter.eq(4)).to.be.true
        })

        it("should research housing", async () => {
            const housing = 1;
            await researchManager.beginResearch(cityId, housing, true)
            await time.increase(await (await researchInfo.researchInfo(housing)).TimeRequired.add(4).toNumber());
            const researched = await researchManager.isResearched(cityId, housing)
            expect(researched).to.be.true
        })

        it("should research pulley", async () => {
            const pulley = 21;
            await researchManager.beginResearch(cityId, pulley, true)
            await time.increase(await (await researchInfo.researchInfo(pulley)).TimeRequired.add(1).toNumber());
            const researched = await researchManager.isResearched(cityId, pulley)
            expect(researched).to.be.true
        })


        it("should log current production", async () => {
            const bonus = await resources.resourceResearchBonus(cityId);
            console.log("bonus");
            console.log(bonus.resourceBoostAmount.toNumber());
            expect(bonus.resourceBoostAmount.toNumber()).to.eq(0)
            console.log(
                (await resources.resourcesPerTick(cityId)).map(a => a.toNumber())
            );

        })

        it("should research Advanced Tools I", async () => {
            const advLogi1 = 22;
            await researchManager.beginResearch(cityId, advLogi1, false)
            let t = (await researchInfo.researchInfo(advLogi1)).TimeRequired.add(1).toNumber()
            await time.increase(t);
            const researched = await researchManager.isResearched(cityId, advLogi1)
            expect(researched).to.be.true
        })

        it("production amount must be increased", async () => {
            const bonus = await resources.resourceResearchBonus(cityId);
            console.log("bonus");
            console.log(bonus.resourceBoostAmount.toNumber());
            expect(bonus.resourceBoostAmount.toNumber()).to.eq(5)
            console.log(
                (await resources.resourcesPerTick(cityId)).map(a => a.toNumber())
            );
        })

        it("should research Savings 101", async () => {
            const Savings = 2;
            await researchManager.beginResearch(cityId, Savings, false)
            let t = (await researchInfo.researchInfo(Savings)).TimeRequired.add(1).toNumber()
            await time.increase(t);
            const researched = await researchManager.isResearched(cityId, Savings)
            expect(researched).to.be.true
        })

        it("should research VAT (Value Added Tax)", async () => {
            const Savings = 3;
            await researchManager.beginResearch(cityId, Savings, false)
            let t = (await researchInfo.researchInfo(Savings)).TimeRequired.add(1).toNumber()
            await time.increase(t);
            const researched = await researchManager.isResearched(cityId, Savings)
            expect(researched).to.be.true
        })

        it("gold reward amount must be increased", async () => {
            const day = 86400;
            await time.increase(day)
            const bonus = await resources.resourceResearchBonus(cityId);
            console.log("bonus");
            console.log(bonus.goldBoostAmount.toNumber());
            expect(bonus.goldBoostAmount.toNumber()).to.eq(2)
            console.log(
                (await resources.claimableGold(cityId, true)).toNumber()
            );
        })



        it("should research Beyond Our Realm", async () => {
            const Bor = 23;
            await researchManager.beginResearch(cityId, Bor, false)
            let t = (await researchInfo.researchInfo(Bor)).TimeRequired.add(1).toNumber()
            await time.increase(t);
            const researched = await researchManager.isResearched(cityId, Bor)
            expect(researched).to.be.true
        })


        it("should research Architecture", async () => {
            const Architecture = 24;
            await researchManager.beginResearch(cityId, Architecture, false)
            let t = (await researchInfo.researchInfo(Architecture)).TimeRequired.add(1).toNumber()
            await time.increase(t);
            const researched = await researchManager.isResearched(cityId, Architecture)
            expect(researched).to.be.true
        })

        it("building time and cost reduce works", async () => {
            const building = await buildings.buildingInfo(0)

            console.log("wood cost: ");
            console.log(building.Cost[1][1]);
            console.log("base time: ");
            console.log(building.UpgradeTime[1].toNumber());
            const bal1 = await resources.cityResources(1, 1)
            console.log("pre wood bal:");
            console.log(bal1.toNumber());

            await cityManager.upgradeBuilding(cityId, 0, false)
            const completions = (await cityManager.buildingUpgradeCompletionTimes(cityId)).map(a => a.toNumber())
            console.log(
                { completion: completions[0] }
            );
            const timeStamp = (await ethers.provider.getBlock("latest")).timestamp
            console.log({ timeStamp });
            const timeReq = completions[0] - timeStamp
            console.log({ timeReq });
            const bal2 = await resources.cityResources(1, 1)
            console.log("post wood bal:");
            console.log(bal2.toNumber())
            console.log("diff");
            console.log(bal1.sub(bal2).toNumber());
        })

        it("should research Ink", async () => {
            const Ink = 25;
            await researchManager.beginResearch(cityId, Ink, false)
            let t = (await researchInfo.researchInfo(Ink)).TimeRequired.add(1).toNumber()
            await time.increase(t);
            const researched = await researchManager.isResearched(cityId, Ink)
            expect(researched).to.be.true
        })

        it("should research Science Budget ", async () => {
            const ScienceBudget = 4;
            await researchManager.beginResearch(cityId, ScienceBudget, false)
            let t = (await researchInfo.researchInfo(ScienceBudget)).TimeRequired.add(1).toNumber()
            await time.increase(t);
            const researched = await researchManager.isResearched(cityId, ScienceBudget)
            expect(researched).to.be.true
        })

        it("should decrease research time and cost", async () => {
            const nextResarch = 5;
            const research = await researchInfo.researchInfo(5)
            console.log("Base TimeRequired");
            console.log(research.TimeRequired);
            console.log("Base Wood cost");
            console.log(research.Cost[1]);

            const bal1 = await resources.cityResources(1, 1)
            console.log("pre wood bal:");
            console.log(bal1.toNumber())
            console.log("diff");
            
            await researchManager.beginResearch(cityId, nextResarch, false)

            const completionTime = await researchManager.researchTime(cityId, nextResarch)
            const timeStamp = (await ethers.provider.getBlock("latest")).timestamp;
            console.log('completed at: ');
            console.log(completionTime.toNumber());
            console.log('now: ');
            console.log(timeStamp);
            console.log('diff');
            console.log(completionTime.sub(timeStamp).toNumber());
            const bal2 = await resources.cityResources(1, 1)
            console.log("post wood bal:");
            console.log(bal2.toNumber())
            console.log("diff");

            console.log(bal1.sub(bal2).toNumber());


        })
    });
