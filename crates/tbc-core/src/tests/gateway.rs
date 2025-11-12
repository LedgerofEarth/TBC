use tbc_core::gateway::{GatewayPolicy, SessionRequest};

#[test]
fn test_default_policy_allows_default_request() {
    let policy = GatewayPolicy::default();
    let request = SessionRequest::default();
    let result = policy.check(&request);
    assert!(result.is_ok()); // or adapt to your policy engine
}

#[test]
fn test_rejects_invalid_proof_type() {
    let mut request = SessionRequest::default();
    request.proof_type = "unsupported_proof".into();
    let result = GatewayPolicy::default().check(&request);
    assert!(result.is_err());
}