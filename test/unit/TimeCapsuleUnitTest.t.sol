// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// import {Test} from "";
import {Test, console} from "forge-std/Test.sol";
import {TimeCapsule} from "../../src/TimeCapsule.sol";
import {TimeCapsuleDeployScript} from "../../script/TimeCapsuleDeploy.s.sol";

contract TimeCapsuleUnitTest is Test {
    TimeCapsule timeCapsule;
    address SENDER = makeAddr("Sender");
    address RECIVER = makeAddr("Reciver");
    uint256 constant STARTINGBALANCE = 10 ether;
    uint256 constant VALUETOSEND = 5 ether;
    uint256 constant VALIDINTERVAL = 3 days;
    uint256 constant INVALIDINTERVAL = 1 days;
    string constant MESSAGE = "THIS IS MESSAGE";

    event CapsuleCreated(address indexed sender, address indexed receiver, uint256 amount, uint256 unlockTime);

    function setUp() external {
        TimeCapsuleDeployScript timeCapsuleDeploy = new TimeCapsuleDeployScript();
        timeCapsule = timeCapsuleDeploy.run();
        vm.deal(SENDER, STARTINGBALANCE);
    }

    // createCapsules Test
    function testMinimumIntervalCheckWorking() public {
        vm.prank(SENDER);
        vm.expectRevert(TimeCapsule.TimeCapsule__IntervalIsToShot.selector);
        timeCapsule.createCapsule{value: VALUETOSEND}(MESSAGE, INVALIDINTERVAL, RECIVER);
    }

    function testInvalidReciverAddressCheckWorking() public {
        vm.prank(SENDER);
        vm.expectRevert(TimeCapsule.TimeCapsule_InvalidReciverAddress.selector);
        timeCapsule.createCapsule{value: VALUETOSEND}(MESSAGE, VALIDINTERVAL, address(0));
    }

    function testNoAssetFoundCheckWorking() public {
        vm.prank(SENDER);
        vm.expectRevert(TimeCapsule.TimeCapsule_NoAssetFound.selector);
        timeCapsule.createCapsule{value: 0}(MESSAGE, VALIDINTERVAL, RECIVER);
    }

    function testEmitCapsuleCreateWorking() public {
        vm.prank(SENDER);
        vm.expectEmit(true, true, false, true);
        emit CapsuleCreated(SENDER, RECIVER, VALUETOSEND, block.timestamp + VALIDINTERVAL);
        timeCapsule.createCapsule{value: VALUETOSEND}(MESSAGE, VALIDINTERVAL, RECIVER);
    }

    // isCapsuleUnlocked Test
    function testIsCapsuleUnlocked() public {
        vm.startPrank(SENDER);
        timeCapsule.createCapsule{value: VALUETOSEND}(MESSAGE, VALIDINTERVAL, RECIVER);
        vm.stopPrank();
        vm.startPrank(RECIVER);
        assertFalse(timeCapsule.isCapsuleUnlocked(0));
        vm.warp(block.timestamp + VALIDINTERVAL + 1);
        assertTrue(timeCapsule.isCapsuleUnlocked(0));
        vm.stopPrank();
    }

    // withDrawFromCapsule Test
    function testNoCapsuleFoundCheckWorking() public {
        vm.prank(RECIVER);
        vm.expectRevert(TimeCapsule.TimeCapsule_NoCapsuleFound.selector);
        timeCapsule.withDrawFromCapsule(0);
    }

    function testTimeNotCompleteCheckWorking() public {
        vm.startPrank(SENDER);
        timeCapsule.createCapsule{value: VALUETOSEND}(MESSAGE, VALIDINTERVAL, RECIVER);
        vm.stopPrank();
        vm.prank(RECIVER);
        vm.expectRevert(TimeCapsule.TimeCapsule__TimeNotCompleted.selector);
        timeCapsule.withDrawFromCapsule(0);
    }

    // getCapsule test
    function testGetCapsules() public {
        // Create multiple capsules
        vm.startPrank(SENDER);
        timeCapsule.createCapsule{value: VALUETOSEND}(MESSAGE, VALIDINTERVAL, RECIVER);
        vm.stopPrank();

        // Get and verify capsules
        vm.startPrank(RECIVER);
        TimeCapsule.capsule[] memory capsules = timeCapsule.getCapsule();
        assertEq(capsules.length, 1);
        assertEq(capsules[0].amount, VALUETOSEND);
        assertEq(capsules[0].message, MESSAGE);
        vm.stopPrank();
    }
}
