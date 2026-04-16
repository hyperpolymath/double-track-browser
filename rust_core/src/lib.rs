#![forbid(unsafe_code)]
#![allow(dead_code, unexpected_cfgs)]
use rand::SeedableRng;
use wasm_bindgen::prelude::*;

mod activity;
mod form_data;
mod interests;
mod profile;
mod schedule;

pub use activity::{ActivitySimulator, ActivityType, BrowsingActivity};
pub use form_data::{FormData, FormDataGenerator};
pub use profile::{Demographics, InterestCategory, Profile, ProfileGenerator};
pub use schedule::{Schedule, TimePattern};

/// Initialize the WASM module
#[wasm_bindgen(start)]
pub fn init() {
    #[cfg(feature = "console_error_panic_hook")]
    console_error_panic_hook::set_once();
}

/// Generate a new random profile
#[wasm_bindgen]
pub fn generate_profile(seed: Option<u64>) -> JsValue {
    let mut generator = ProfileGenerator::new(seed);
    let profile = generator.generate();
    serde_wasm_bindgen::to_value(&profile).expect("TODO: handle error")
}

/// Generate browsing activities for a profile
#[wasm_bindgen]
pub fn generate_activities(profile_json: JsValue, duration_hours: u32) -> JsValue {
    let profile: Profile = serde_wasm_bindgen::from_value(profile_json).expect("TODO: handle error");
    let mut simulator = ActivitySimulator::new(profile);
    let activities = simulator.generate_activities(duration_hours);
    serde_wasm_bindgen::to_value(&activities).expect("TODO: handle error")
}

/// Validate that a profile is internally consistent
#[wasm_bindgen]
pub fn validate_profile(profile_json: JsValue) -> bool {
    if let Ok(profile) = serde_wasm_bindgen::from_value::<Profile>(profile_json) {
        profile.is_valid()
    } else {
        false
    }
}

/// Get recommended activity schedule for a profile
#[wasm_bindgen]
pub fn get_activity_schedule(profile_json: JsValue) -> JsValue {
    let profile: Profile = serde_wasm_bindgen::from_value(profile_json).expect("TODO: handle error");
    let schedule = Schedule::from_profile(&profile);
    serde_wasm_bindgen::to_value(&schedule).expect("TODO: handle error")
}

/// Generate plausible form fill data tied to a profile
#[wasm_bindgen]
pub fn generate_form_data(profile_json: JsValue) -> JsValue {
    let profile: Profile = serde_wasm_bindgen::from_value(profile_json).expect("TODO: handle error");
    let mut rng = rand::rngs::SmallRng::from_entropy();
    let form = FormDataGenerator::generate(&profile, &mut rng);
    serde_wasm_bindgen::to_value(&form).expect("TODO: handle error")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_profile_generation() {
        let mut generator = ProfileGenerator::new(Some(42));
        let profile = generator.generate();
        assert!(profile.is_valid());
        assert!(!profile.name.is_empty());
    }

    #[test]
    fn test_activity_generation() {
        let mut generator = ProfileGenerator::new(Some(42));
        let profile = generator.generate();
        let mut simulator = ActivitySimulator::new(profile);
        let activities = simulator.generate_activities(24);
        assert!(!activities.is_empty());
    }
}
