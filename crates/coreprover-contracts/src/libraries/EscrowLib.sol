// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title EscrowLib
/// @notice Utility library for escrow operations
library EscrowLib {
    /// @notice Calculate fee for a given amount
    /// @param amount Transaction amount
    /// @return fee Fee amount (1%)
    function calculateFee(uint256 amount) internal pure returns (uint256) {
        return amount / 100;
    }

    /// @notice Check if deadline has passed
    /// @param deadline Deadline timestamp
    /// @return bool Whether deadline has passed
    function isExpired(uint256 deadline) internal view returns (bool) {
        return block.timestamp > deadline;
    }

    /// @notice Generate order ID from parameters
    /// @param buyer Buyer address
    /// @param seller Seller address
    /// @param nonce Unique nonce
    /// @return bytes32 Order ID
    function generateOrderId(address buyer, address seller, uint256 nonce)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(buyer, seller, nonce));
    }
}
```

### `crates/coreprover-contracts/src/libraries/SignatureVerifier.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SignatureVerifier
/// @notice Library for verifying legal signatures
library SignatureVerifier {
    /// @notice Verify ECDSA signature
    /// @param hash Message hash
    /// @param signature Signature bytes
    /// @param signer Expected signer address
    /// @return bool Whether signature is valid
    function verify(bytes32 hash, bytes memory signature, address signer)
        internal
        pure
        returns (bool)
    {
        require(signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid signature v value");

        address recovered = ecrecover(hash, v, r, s);
        return recovered == signer;
    }

    /// @notice Create Ethereum signed message hash
    /// @param messageHash Original message hash
    /// @return bytes32 Ethereum signed message hash
    function toEthSignedMessageHash(bytes32 messageHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
    }
}