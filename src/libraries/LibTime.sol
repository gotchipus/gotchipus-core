// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;


library LibTime {
    function getCurrentHour(uint32 _worldTime, uint8 _createTimeHour) internal view returns (uint8) {
        uint256 elapsedTime = block.timestamp - uint256(_worldTime);
        uint256 secondsInDay = elapsedTime % 1 days;
        uint256 hoursFromMidnight = secondsInDay / 1 hours;
        uint256 currentHour = (_createTimeHour + hoursFromMidnight) % 24;

        return uint8(currentHour);
    }
}