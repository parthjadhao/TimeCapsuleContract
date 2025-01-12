// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {TimeCapsule} from "../src/TimeCapsule.sol";

contract TimeCapsuleDeployScript is Script {
    function run() external returns (TimeCapsule) {
        vm.startBroadcast();
        TimeCapsule timeCapsule = new TimeCapsule();
        vm.stopBroadcast();
        return (timeCapsule);
    }
}
