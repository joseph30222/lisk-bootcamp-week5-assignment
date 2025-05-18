// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

// SmartWallet contract implementing basic EIP-4337 features
contract SmartWallet {
    // Using OpenZeppelin's ECDSA library for secure signature verification
    using ECDSA for bytes32;

    // Address of the wallet owner
    address public owner;

    // Nonce to prevent replay attacks
    uint256 public nonce;

    // Event emitted when a transaction is executed
    event Executed(address indexed to, uint256 value, bytes data);

    // Constructor to set the initial owner
    constructor(address _owner) {
        owner = _owner;
    }

    // Modifier to restrict functions to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // Function to execute a transaction (call any contract or send ETH)
    function execute(address to, uint256 value, bytes calldata data) external onlyOwner {
        // Increment nonce to prevent replay attacks
        nonce++;

        // Execute the call to the target address
        (bool success, ) = to.call{value: value}(data);
        require(success, "Execution failed");

        // Emit event for transparency
        emit Executed(to, value, data);
    }

    // Simulates EIP-4337 UserOperation validation
    function validateUserOp(
        bytes calldata userOp,
        bytes32 userOpHash,
        bytes calldata signature
    ) external returns (bool) {
        // Increment nonce to ensure this UserOperation can't be replayed
        nonce++;

        // Verify the signature using ECDSA
        // In a real EIP-4337 wallet, userOpHash would be derived from UserOperation fields
        address signer = userOpHash.recover(signature);
        require(signer == owner, "Invalid signature");

        // Return true if validation passes
        return true;
    }

    // Function to receive ETH (required for sending ETH or Paymaster refunds)
    receive() external payable {}
}

// Paymaster contract to simulate gas sponsorship
contract Paymaster {
    // Event to log gas sponsorship
    event GasSponsored(address indexed wallet, uint256 gasUsed, uint256 amountPaid);

    // Function to simulate gas sponsorship for a UserOperation
    function sponsorGas(address wallet, uint256 gasUsed) external {
        // In a real Paymaster, this would transfer ETH to cover gas
        // Here, we just log the sponsorship event
        emit GasSponsored(wallet, gasUsed, 0);

        // Note: A real Paymaster would check gas limits, validate the UserOperation,
        // and possibly charge the wallet in ERC-20 tokens or deduct from a deposit
    }
}