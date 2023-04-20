import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
import * as fs from 'fs'
import { BuildingsFacet, CityManagerFacet, CityNFTFacet, ResourcesFacet, TroopsManagerFacet, WorldFacet } from "../typechain-types";
import { deployDiamond } from "./deploy";
let cities: CityNFTFacet;
let gameWorld: WorldFacet;
let cityManager: CityManagerFacet;
let troops: TroopsManagerFacet;
let troopsManager: TroopsManagerFacet;
let buildings: BuildingsFacet;
let resources: ResourcesFacet;
const desiredCoords: any = { X: 1, Y: 1, }
let owner: any;
describe("CityMintTest",
    function () {
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

        it("Plot is empty", async function () {
            expect(await gameWorld.isPlotEmpty(desiredCoords)).to.equal(true);
        });

        it("Create city at [1, -1]", async function () {

            expect(await gameWorld.isPlotEmpty(desiredCoords)).to.equal(true);

            try {
                const tx = await gameWorld.createCity(
                    desiredCoords, // desired coords
                    true, // pick closest,
                    2,
                )
                await tx.wait(1);
            } catch (error) {
                // console.log(error);
                // console.log(error);
                // console.log(error);
            } finally {
                // console.log("called 'createCity' method");
            }

            expect(await cityManager.racePopulation(2)).to.be.equal(1);

            // console.log(coords.X.toString(), ",", coords.Y.toString(), '"""');

            expect(await gameWorld.isPlotEmpty(desiredCoords)).to.equal(false);
            // console.log('End of city 1 test.');

        });

        it("give premium", async () => {
            await cityManager.setPremiumStatus(1, 1, 1)
            const status = await cityManager.premiumStatus(1)
            console.log('City has premium tier: ', status._tier.toNumber());

            expect(status._tier.toNumber()).to.eq(1)
            expect(status._expirationDate.toNumber()).to.gt(0)
        })
        it("Shouldn't allow re-create city in same coords", async function () {

            let hasError = false
            expect(await gameWorld.isPlotEmpty(desiredCoords)).to.equal(false);
            try {
                const tx = await gameWorld.createCity(
                    desiredCoords, // desired coords
                    false, // pick closest
                    1
                )
                await tx.wait(1);
            } catch (error: any) {
                // console.log(error?.message || error?.data);
                hasError = true;
            } finally {
                // console.log("called 'createCity' method for second city");
            }

            expect(await gameWorld.isPlotEmpty(desiredCoords)).to.equal(false);
            expect(hasError).to.equal(true);
        });


        it("Create city at [2, 1] by typing 1,1 using closest method", async function () {


            try {
                const tx = await gameWorld.createCity(
                    desiredCoords, // desired coords
                    true, // pick closest
                    3
                )
                await tx.wait(1);
            } catch (error) {
                console.log(error);

                // console.log(error);
            } finally {
                // console.log("called 'createCity' method for third time");
            }
            const isEmpty = await gameWorld.isPlotEmpty({ X: 2, Y: 1, });
            const sup = await cities.totalSupply();

            expect(await cityManager.racePopulation(3)).to.be.equal(1);

            let coords = await gameWorld.cityCoords(2)
            // console.log(coords.X.toString(), ",", coords.Y.toString());
            expect(await gameWorld.isPlotEmpty({ X: coords.X, Y: coords.Y, })).to.equal(false);
        });


        it("Create city at [2, 2] by typing 1,1 using closest method", async function () {

            try {
                const tx = await gameWorld.createCity(
                    desiredCoords, // desired coords
                    true, // pick closest
                    3
                )
                await tx.wait(1);
            } catch (error) {
                // console.log(error);
            } finally {
                // console.log("called 'createCity' method for fourth time");
            }
            const isEmpty = await gameWorld.isPlotEmpty({ X: 2, Y: 2, });
            const sup = await cities.totalSupply();

            let coords = await gameWorld.cityCoords(3)
            // console.log(coords.X.toString(), ",", coords.Y.toString());
            expect(await cityManager.racePopulation(3)).to.be.equal(2);

            expect(await gameWorld.isPlotEmpty({ X: coords.X, Y: coords.Y, })).to.equal(false);
        });

        it("Create city at [3, 2] by typing 1,1 using closest method", async function () {

            try {
                const tx = await gameWorld.createCity(
                    desiredCoords, // desired coords
                    true, // pick closest
                    3
                )
                await tx.wait(1);
            } catch (error) {
                console.log(error);

                // console.log(error);
            } finally {
                // console.log("called 'createCity' method for fifth time");
            }
            const isEmpty = await gameWorld.isPlotEmpty({ X: 3, Y: 2, });
            const sup = await cities.totalSupply();

            let coords = await gameWorld.cityCoords(4)
            // console.log(coords.X.toString(), ",", coords.Y.toString());

            expect(await gameWorld.isPlotEmpty({ X: coords.X, Y: coords.Y, })).to.equal(false);
        });

        it("Create city at [3, 3] by typing 1,1 using closest method", async function () {

            try {
                const tx = await gameWorld.createCity(
                    desiredCoords, // desired coords
                    true, // pick closest
                    3
                )
                await tx.wait(1);
            } catch (error) {
                // console.log(error);
            } finally {
                // console.log("called 'createCity' method for sixth time");
            }
            const isEmpty = await gameWorld.isPlotEmpty({ X: 3, Y: 3, });
            const sup = await cities.totalSupply();

            let coords = await gameWorld.cityCoords(5)
            // console.log(coords.X.toString(), ",", coords.Y.toString());

            expect(await gameWorld.isPlotEmpty({ X: coords.X, Y: coords.Y, })).to.equal(false);
        });



        it("Create city at [6, 7] by typing 1,1 using closest method", async function () {

            try {
                const tx = await gameWorld.createCity(
                    { X: 6, Y: 7, }, // desired coords
                    true, // pick closest
                    3
                )
                await tx.wait(1);
            } catch (error) {
                // console.log(error);
            } finally {
                // console.log("called 'createCity' method for seventh time");
            }
            const isEmpty = await gameWorld.isPlotEmpty({ X: 6, Y: 7, });
            const sup = await cities.totalSupply();

            let coords = await gameWorld.cityCoords(6)
            // console.log(coords.X.toString(), ",", coords.Y.toString());

            expect(await gameWorld.isPlotEmpty({ X: coords.X, Y: coords.Y, })).to.equal(false);
        });

        it("Create city at [7, 7] by typing 6,7 using closest method", async function () {

            try {
                const tx = await gameWorld.createCity(
                    { X: 6, Y: 7, }, // desired coords
                    true, // pick closest
                    3
                )
                await tx.wait(1);
            } catch (error) {
                // console.log(error);
            } finally {
                // console.log("called 'createCity' method for seventh time");
            }
            const isEmpty = await gameWorld.isPlotEmpty({ X: 6, Y: 7, });
            const sup = await cities.totalSupply();

            let coords = await gameWorld.cityCoords(7)
            // console.log(coords.X.toString(), ",", coords.Y.toString());

            expect(await gameWorld.isPlotEmpty({ X: coords.X, Y: coords.Y, })).to.equal(false);
        });

        it("Cant mint city more far than 100 plots", async function () {
            let hasError;
            try {
                const tx = await gameWorld.createCity(
                    { X: 200, Y: 200, }, // desired coords
                    true, // pick closest
                    5
                )
                await tx.wait(1);
            } catch (error) {
                // console.log(error);
                hasError = true;
            } finally {
                // console.log("called 'createCity' method for eighth time");
            }

            expect(hasError).to.equal(true);
        });


        it("Scan and get city infos.", async function () {
            let result = await gameWorld.scanCitiesBetweenCoords(0, 10, 0, 10);
            let cities = result[0];
            // cities.forEach((city, idx) => {
            //     if (city.Alive) {
            //     }
            // })
            let cityIds = result[1].filter(a => a.gt(0));
            let cityIdxs = []
            cityIds.forEach(id => {
                cityIdxs.push(result[1].indexOf(id))
            })
            // console.log(cityIds.length);
            expect(cityIds.length).to.equal(7);
        });

        it("Scan and get free plots.", async function () {
            let result = await gameWorld.scanPlotsForEmptyPlace(0, 10, 0, 10);
            const isFree = await gameWorld.isPlotEmpty(result)
            expect(isFree).to.equal(true);
        });

        it("Get user balance.", async function () {
            const myCities = await cities.tokenIdsOfOwner(owner.address)

            expect(myCities.length).to.equal(7);
        });

        it("Buildings initiated.", async function () {
            let buildings = await cityManager.buildingLevels(2)
            for (let index = 0; index < 5; index++) {
                expect(buildings[index].Tier.eq(1)).to.equal(true);
            }
        });

        it("Should claim population.", async function () {

            console.log(await cityManager.calculateRecruitable(2));

            await cityManager.recruitPopulation(2,)
            console.log(await cityManager.calculateRecruitable(2));
            expect((await cityManager.city(2)).Population.toNumber()).to.equal(51);
        });

        it("Should not allow claim population.", async function () {
            let hasError
            try {
                await cityManager.recruitPopulation(2,)
            } catch (error) {
                // console.log(error);
                hasError = true
            }
            expect(hasError).to.be.true;
        });


    });
