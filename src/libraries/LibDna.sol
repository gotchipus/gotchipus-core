// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;


library LibDna {
    event SetRuleVersion(uint8 indexed ruleVersion);

    function getRandomGene(bytes32 seed) internal pure returns (uint256) {
        return uint256(seed);
    }
}