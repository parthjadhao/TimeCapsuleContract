// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract TimeCapsule {
    // error
    error TimeCapsule__TimeNotCompleted();
    error TimeCapsule__IntervalIsToShot();
    error TimeCapsule_InvalidReciverAddress();
    error TimeCapsule_NoAssetFound();
    error TimeCapsule__WithdrawlFailed();
    error TimeCapsule_NoCapsuleFound();

    // events
    event CapsuleCreated(address indexed sender, address indexed receiver, uint256 amount, uint256 unlockTime);
    event CapsuleWithdrawn(address indexed sender, uint256 amount);

    struct capsule {
        uint256 amount;
        string message;
        uint256 unlockTime;
        address sender;
        bool withDraw;
    }

    // state variables
    mapping(address => capsule[]) private s_receiverToCapsules;
    uint256 private constant MINIMUM_INTERVAL = 2 days;

    function createCapsule(string memory _message, uint256 interval, address reciverAddress) external payable {
        if (interval < MINIMUM_INTERVAL) revert TimeCapsule__IntervalIsToShot();
        if (reciverAddress == address(0)) revert TimeCapsule_InvalidReciverAddress();
        if (msg.value == 0) revert TimeCapsule_NoAssetFound();
        uint256 unlockTime = block.timestamp + interval;
        capsule memory newCapsule =
            capsule({amount: msg.value, message: _message, unlockTime: unlockTime, sender: msg.sender, withDraw: false});
        s_receiverToCapsules[reciverAddress].push(newCapsule);
        emit CapsuleCreated(msg.sender, reciverAddress, msg.value, unlockTime);
    }

    function isCapsuleUnlocked(uint256 capsuleIndex) public view returns (bool) {
        capsule[] storage capsules = s_receiverToCapsules[msg.sender];
        if (capsules.length == 0 || capsuleIndex >= capsules.length) {
            return false;
        }
        return block.timestamp >= capsules[capsuleIndex].unlockTime && !capsules[capsuleIndex].withDraw;
    }

    function withDrawFromCapsule(uint256 capsuleIndex) external {
        capsule[] storage capsules = s_receiverToCapsules[msg.sender];
        if (capsules.length == 0 || capsuleIndex >= capsules.length) {
            revert TimeCapsule_NoCapsuleFound();
        }
        capsule storage storingCapsule = capsules[capsuleIndex];
        if (!isCapsuleUnlocked(capsuleIndex)) {
            revert TimeCapsule__TimeNotCompleted();
        }
        uint256 amount = storingCapsule.amount;
        storingCapsule.withDraw = true;

        (bool success,) = payable(msg.sender).call{value: amount}("");
        if (!success) revert TimeCapsule__WithdrawlFailed();

        emit CapsuleWithdrawn(msg.sender, amount);
    }

    // getter function
    function getCapsule() external view returns (capsule[] memory) {
        return s_receiverToCapsules[msg.sender];
    }
}
