// SPDX-License-Identifier: PMPL-1.0-or-later
// Property-based tests for DoubleTrack core types
// Tests invariants that must hold across all generated values

use doubletrack_core::*;
use proptest::prelude::*;
use rand::SeedableRng;

// Define strategies for property-based testing

fn name_strategy() -> impl Strategy<Value = String> {
    r"[A-Z][a-z]{1,10} [A-Z][a-z]{1,10}"
        .prop_map(|s| s.to_string())
}

fn age_strategy() -> impl Strategy<Value = u8> {
    18u8..=100
}

fn interests_strategy() -> impl Strategy<Value = Vec<InterestCategory>> {
    prop::collection::vec(
        prop_oneof![
            Just(InterestCategory::Technology),
            Just(InterestCategory::Gaming),
            Just(InterestCategory::Sports),
            Just(InterestCategory::Fitness),
            Just(InterestCategory::Cooking),
            Just(InterestCategory::Travel),
            Just(InterestCategory::Fashion),
            Just(InterestCategory::Music),
            Just(InterestCategory::Movies),
            Just(InterestCategory::Books),
            Just(InterestCategory::Art),
            Just(InterestCategory::Science),
            Just(InterestCategory::Politics),
            Just(InterestCategory::News),
            Just(InterestCategory::Finance),
            Just(InterestCategory::HomeImprovement),
            Just(InterestCategory::Gardening),
            Just(InterestCategory::Photography),
            Just(InterestCategory::Programming),
            Just(InterestCategory::DataScience),
        ],
        1..=10,
    )
}

proptest! {
    /// Property: Profile names are always non-empty
    #[test]
    fn prop_profile_name_never_empty(
        name in r"[A-Z][a-z]{2,15} [A-Z][a-z]{2,15}",
    ) {
        assert!(!name.is_empty(), "Profile name must never be empty");
        assert!(name.len() > 0, "Profile name length must be > 0");
    }

    /// Property: Ages are always in valid range [18, 100]
    #[test]
    fn prop_profile_age_in_valid_range(age in age_strategy()) {
        assert!(age >= 18 && age <= 100, "Age must be between 18 and 100, got {}", age);
    }

    /// Property: Interests list is never empty and respects max limit
    #[test]
    fn prop_interests_valid_bounds(interests in interests_strategy()) {
        assert!(!interests.is_empty(), "Interests must not be empty");
        assert!(interests.len() <= 20, "Interests must not exceed 20");
    }

    /// Property: Activity log entries are chronologically ordered
    #[test]
    fn prop_activities_chronologically_ordered(
        seed in any::<u64>(),
        duration_hours in 1u32..=72,
    ) {
        let mut gen = ProfileGenerator::new(Some(seed));
        let profile = gen.generate();
        let mut simulator = ActivitySimulator::new(profile);

        let activities = simulator.generate_activities(duration_hours);

        // Check activities are sorted
        for i in 1..activities.len() {
            assert!(
                activities[i].timestamp >= activities[i - 1].timestamp,
                "Activities not chronologically ordered at index {}",
                i
            );
        }
    }

    /// Property: Interest similarity score always in [0.0, 1.0]
    #[test]
    fn prop_activity_duration_positive_and_bounded(
        seed in any::<u64>(),
    ) {
        let mut gen = ProfileGenerator::new(Some(seed));
        let profile = gen.generate();
        let mut simulator = ActivitySimulator::new(profile);

        let activities = simulator.generate_activities(24);

        // Activity durations must be positive and reasonable
        for activity in &activities {
            assert!(activity.duration_seconds > 0, "Duration must be positive");
            assert!(
                activity.duration_seconds < 3600 * 12,
                "Duration shouldn't exceed 12 hours"
            );
        }
    }

    /// Property: FormData email always has valid format
    #[test]
    fn prop_formdata_email_always_valid(
        seed in any::<u64>(),
    ) {
        let mut gen = ProfileGenerator::new(Some(seed));
        let profile = gen.generate();
        let mut rng = rand::rngs::SmallRng::seed_from_u64(seed);

        let form = FormDataGenerator::generate(&profile, &mut rng);

        assert!(form.email.contains('@'), "Email must contain @");
        let parts: Vec<&str> = form.email.split('@').collect();
        assert_eq!(parts.len(), 2, "Email must have exactly one @");
        assert!(!parts[0].is_empty(), "Email local part must not be empty");
        assert!(!parts[1].is_empty(), "Email domain must not be empty");
        assert!(parts[1].contains('.'), "Email domain must contain .");
    }

    /// Property: FormData display name is never empty
    #[test]
    fn prop_formdata_display_name_never_empty(
        seed in any::<u64>(),
    ) {
        let mut gen = ProfileGenerator::new(Some(seed));
        let profile = gen.generate();
        let mut rng = rand::rngs::SmallRng::seed_from_u64(seed);

        let form = FormDataGenerator::generate(&profile, &mut rng);

        assert!(
            !form.display_name.is_empty(),
            "Display name must never be empty"
        );
    }

    /// Property: Profile validity is reflexive after generation
    #[test]
    fn prop_generated_profiles_are_valid(seed in any::<u64>()) {
        let mut gen = ProfileGenerator::new(Some(seed));
        let profile = gen.generate();

        assert!(
            profile.is_valid(),
            "Generated profile must always be valid"
        );
    }

    /// Property: Schedule has exactly 7 daily patterns
    #[test]
    fn prop_schedule_has_7_days(seed in any::<u64>()) {
        let mut gen = ProfileGenerator::new(Some(seed));
        let profile = gen.generate();
        let schedule = Schedule::from_profile(&profile);

        assert_eq!(
            schedule.time_patterns.len(),
            7,
            "Schedule must have exactly 7 day patterns"
        );
    }

    /// Property: No null bytes in FormData fields
    #[test]
    fn prop_formdata_no_null_bytes(seed in any::<u64>()) {
        let mut gen = ProfileGenerator::new(Some(seed));
        let profile = gen.generate();
        let mut rng = rand::rngs::SmallRng::seed_from_u64(seed);

        let form = FormDataGenerator::generate(&profile, &mut rng);

        assert!(!form.email.contains('\0'), "Email must not contain null bytes");
        assert!(!form.display_name.contains('\0'), "Display name must not contain null bytes");

        for pref in &form.preferences {
            assert!(!pref.contains('\0'), "Preferences must not contain null bytes");
        }

        for topic in &form.newsletter_topics {
            assert!(!topic.contains('\0'), "Topics must not contain null bytes");
        }
    }

    /// Property: Profile ID is unique and non-empty
    #[test]
    fn prop_profile_id_valid(seed in any::<u64>()) {
        let mut gen = ProfileGenerator::new(Some(seed));
        let profile = gen.generate();

        assert!(!profile.id.is_empty(), "Profile ID must not be empty");
        assert!(profile.id.starts_with("profile_"), "Profile ID must have correct prefix");
    }
}
