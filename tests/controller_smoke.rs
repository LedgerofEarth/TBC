// File: src/controller/tests/controller_smoke.rs
use controller::config::ControllerConfig;
use controller::controller::Controller;

#[tokio::test]
async fn controller_initializes_and_runs() {
    let cfg = ControllerConfig::default();
    let ctrl = Controller::new(cfg);
    assert!(ctrl.is_ok(), "Controller failed to initialize");
}