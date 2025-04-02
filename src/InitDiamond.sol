// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { AppStorage } from "./libraries/LibAppStorage.sol";
import { LibDiamond } from "./libraries/LibDiamond.sol";
import { IDiamondCut } from "./interfaces/IDiamondCut.sol";
import { IDiamondLoupe } from  "./interfaces/IDiamondLoupe.sol";
import { IERC173 } from "./interfaces/IERC173.sol";
import { IERC165} from "./interfaces/IERC165.sol";


contract InitDiamond {
    AppStorage internal s;

    struct Args {
        string name;
        string symbol;
        string baseUri;
    }


    function init(Args calldata _args) external {
        s.name = _args.name;
        s.symbol = _args.symbol;
        s.baseUri = _args.baseUri;

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        // erc165
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;
        // erc1155
        ds.supportedInterfaces[0xd9b67a26] = true;

    }
}