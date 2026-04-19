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
    // Profile is a plain serde-derived struct of owned primitives/Vecs; serialization
    // to a JsValue cannot fail. WASM-export signature returns JsValue, not Result.
    serde_wasm_bindgen::to_value(&profile).expect("Profile serialization is infallible (plain owned data)")
}

/// Generate browsing activities for a profile
#[wasm_bindgen]
pub fn generate_activities(profile_json: JsValue, duration_hours: u32) -> JsValue {
    // Caller-supplied JsValue must deserialize as Profile; validated by JS shim.
    // WASM-export signature returns JsValue, not Result — callers should pre-validate.
    let profile: Profile = serde_wasm_bindgen::from_value(profile_json)
        .expect("profile_json must be a valid serialized Profile (validate via validate_profile first)");
    let mut simulator = ActivitySimulator::new(profile);
    let activities = simulator.generate_activities(duration_hours);
    // Vec<BrowsingActivity> is plain serde-derived owned data; serialization is infallible.
    serde_wasm_bindgen::to_value(&activities).expect("BrowsingActivity serialization is infallible (plain owned data)")
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
    // Caller-supplied JsValue must deserialize as Profile; validated by JS shim.
    let profile: Profile = serde_wasm_bindgen::from_value(profile_json)
        .expect("profile_json must be a valid serialized Profile (validate via validate_profile first)");
    let schedule = Schedule::from_profile(&profile);
    // Schedule is plain serde-derived owned data; serialization is infallible.
    serde_wasm_bindgen::to_value(&schedule).expect("Schedule serialization is infallible (plain owned data)")
}

/// Generate plausible form fill data tied to a profile
#[wasm_bindgen]
pub fn generate_form_data(profile_json: JsValue) -> JsValue {
    // Caller-supplied JsValue must deserialize as Profile; validated by JS shim.
    let profile: Profile = serde_wasm_bindgen::from_value(profile_json)
        .expect("profile_json must be a valid serialized Profile (validate via validate_profile first)");
    let mut rng = rand::rngs::SmallRng::from_os_rng();
    let form = FormDataGenerator::generate(&profile, &mut rng);
    // FormData is plain serde-derived owned data; serialization is infallible.
    serde_wasm_bindgen::to_value(&form).expect("FormData serialization is infallible (plain owned data)")
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
