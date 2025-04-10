// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import { Modifier } from "../libraries/LibAppStorage.sol";
import { LibDna } from "../libraries/LibDna.sol";

contract DNAFacet is Modifier {
    function setRuleVersion(uint8 _ruleVersion) external onlyOwner {
        s.dnaRuleVersion = _ruleVersion;
        emit LibDna.SetRuleVersion(_ruleVersion);
    }
}