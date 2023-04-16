// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {City, Race} from "../shared/CityStructs.sol";
import {Coords} from "../shared/WorldStructs.sol";
import {IERC20} from "../../shared/interfaces/IERC20.sol";
import {LibCityManager} from "./LibCityManager.sol";
import {LibAppStorage, AppStorage} from "./LibAppStorage.sol";
import {LibERC20} from "../../shared/libraries/LibERC20.sol";
import {LibMeta} from "../../shared/libraries/LibMeta.sol";
import {IERC721} from "../../shared/interfaces/IERC721.sol";
import {LibERC721} from "../../shared/libraries/LibERC721.sol";

library LibCities {
    function getCity(uint256 _tokenId) internal view returns (City memory cityInfo) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        cityInfo = s.CityList[_tokenId];
    }

    function mint(address to, Coords memory _coords, Race _race) internal returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        uint tokenId = s.tokenIds.length + 1;
        mintCity(to, tokenId, _coords, _race);
        return tokenId;
    }

    function mintCity(address to, uint tokenId, Coords memory _coords, Race _race) internal returns (uint) {
        AppStorage storage s = LibAppStorage.diamondStorage();
        City memory minted = s.CityList[tokenId];
        require(to != address(0), "ERC721: mint to the zero address");
        require(minted.Explorer == address(0), "ERC721: token already minted");
        s.tokenIdIndexes[tokenId] = s.tokenIds.length;
        s.tokenIds.push(uint32(tokenId));
        s.ownerTokenIdIndexes[to][tokenId] = s.ownerTokenIds[to].length;
        s.ownerTokenIds[to].push(uint32(tokenId));
        emit LibERC721.Transfer(address(0), to, tokenId);
        // _afterTokenTransfer(address(0), to, tokenId, 1);
        LibCityManager.setCity(
            tokenId,
            City({Coords: _coords, Explorer: to, Race: _race, Alive: true, Operator: to, CreationDate: block.timestamp, Population: 50})
        );
        return tokenId;
    }

    function transfer(address _from, address _to, uint256 _tokenId) internal {
        AppStorage storage s = LibAppStorage.diamondStorage();

        // remove
        uint256 index = s.ownerTokenIdIndexes[_from][_tokenId];
        uint256 lastIndex = s.ownerTokenIds[_from].length - 1;
        if (index != lastIndex) {
            uint32 lastTokenId = s.ownerTokenIds[_from][lastIndex];
            s.ownerTokenIds[_from][index] = lastTokenId;
            s.ownerTokenIdIndexes[_from][lastTokenId] = index;
        }
        s.ownerTokenIds[_from].pop();
        delete s.ownerTokenIdIndexes[_from][_tokenId];
        if (s.approved[_tokenId] != address(0)) {
            delete s.approved[_tokenId];
            emit LibERC721.Approval(_from, address(0), _tokenId);
        }
        // add
        s.CityList[_tokenId].Operator = _to;
        s.ownerTokenIdIndexes[_to][_tokenId] = s.ownerTokenIds[_to].length;
        s.ownerTokenIds[_to].push(uint32(_tokenId));
        emit LibERC721.Transfer(_from, _to, _tokenId);
    }
}
