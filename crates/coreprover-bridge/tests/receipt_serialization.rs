use coreprover_bridge::types::Receipt;
use ethers::types::Address;
use serde_json;

#[test]
fn test_receipt_serialization_roundtrip() {
    let receipt = Receipt {
        buyer: "0x0000000000000000000000000000000000000001".parse::<Address>().unwrap(),
        seller: "0x0000000000000000000000000000000000000002".parse::<Address>().unwrap(),
        policy_hash: [0u8; 32],
    };

    let json = serde_json::to_string(&receipt).unwrap();
    let decoded: Receipt = serde_json::from_str(&json).unwrap();

    assert_eq!(decoded.buyer, receipt.buyer);
    assert_eq!(decoded.seller, receipt.seller);
    assert_eq!(decoded.policy_hash, receipt.policy_hash);
}