# Lisk Africa Developer’s Bootcamp Week 5 Assignment

This repository contains my Week 5 submission for the Lisk Africa Developer’s Bootcamp, implementing an EIP-4337 smart wallet and Paymaster.

## Part 2: Technical Task – Smart Wallet Skeleton

### SmartWallet.sol
Located in `contracts/SmartWallet.sol`, this implements the required EIP-4337 features:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

// SmartWallet contract implementing basic EIP-4337 features
contract SmartWallet {
    using ECDSA for bytes32;

    address public owner;
    uint256 public nonce;

    event Executed(address indexed to, uint256 value, bytes data);

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function execute(address to, uint256 value, bytes calldata data) external onlyOwner {
        nonce++;
        (bool success, ) = to.call{value: value}(data);
        require(success, "Execution failed");
        emit Executed(to, value, data);
    }

    function validateUserOp(
        bytes calldata userOp,
        bytes32 userOpHash,
        bytes calldata signature
    ) external returns (bool) {
        nonce++;
        address signer = userOpHash.recover(signature);
        require(signer == owner, "Invalid signature");
        return true;
    }

    receive() external payable {}
}

// Paymaster contract to simulate gas sponsorship
contract Paymaster {
    event GasSponsored(address indexed wallet, uint256 gasUsed, uint256 amountPaid);

    function sponsorGas(address wallet, uint256 gasUsed) external {
        emit GasSponsored(wallet, gasUsed, 0);
    }
}
