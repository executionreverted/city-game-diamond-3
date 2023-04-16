import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
import { deployDiamond } from "../scripts/deploy";
import * as fs from 'fs'
import { BuildingsFacet, CityManagerFacet, CityNFTFacet, WorldFacet, ResourcesFacet, TroopsManagerFacet } from "../typechain-types";
let cities: CityNFTFacet;
let gameWorld: WorldFacet;
let cityManager: CityManagerFacet;
let troops: TroopsManagerFacet;
let troopsManager: TroopsManagerFacet;
let buildings: BuildingsFacet;
let resources: ResourcesFacet;
const desiredCoords: any = { X: 1, Y: 1, }
let owner: any;
describe("Test1",
    function () {

        let city1 = 2;
        let city2 = 3;
        // simulation
        const atkArmyPower = [1000, 1500, 2000, 3500, 4000, 4000, 50000, 3234, 6800];
        const defArmyPower = [500, 1000, 2000, 5000, 6000, 400, 1233, 64353, 400];
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
        }


        before(async function () {
            await deployAll()
        });

        it("should deploy", () => {
            expect(true).to.be.true;
        })


    });
