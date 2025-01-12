# TimeCapsule Smart Contract

## Description
TimeCapsule is a decentralized application for creating and managing locked Ether capsules that can be withdrawn only after a specified time interval. 

## Features
- Create time-locked Ether capsules.
- Withdraw funds after the specified interval.
- Automatic Withdrawl [Not Implemeted].

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo.git

## Usage

### Deployment
Deploy the contract using Foundry:
```bash
forge script script/TimeCapsuleDeploy.s.sol:TimeCapsuleDeployScript --fork-url <RPC_URL> --private-key <PRIVATE_KEY>
