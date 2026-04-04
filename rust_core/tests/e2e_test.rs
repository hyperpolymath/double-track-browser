// SPDX-License-Identifier: PMPL-1.0-or-later
// End-to-end integration tests for DoubleTrack core workflow

use doubletrack_core::*;
use rand::SeedableRng;

#[test]
fn test_full_profile_lifecycle() {
    // Create a profile
    let mut gen = ProfileGenerator::new(Some(12345));
    let profile = gen.generate();

    // Validate it
    assert!(profile.is_valid(), "Generated profile must be valid");
    assert!(!profile.name.is_empty(), "Profile must have a name");
    assert!(!profile.interests.is_empty(), "Profile must have interests");

    // Serialize to JSON
    let json_str = serde_json::to_string(&profile).expect("Serialization failed");
    assert!(!json_str.is_empty(), "Serialized JSON must not be empty");

    // Deserialize back
    let deserialized: Profile =
        serde_json::from_str(&json_str).expect("Deserialization failed");

    // Verify data integrity
    assert_eq!(
        profile.id, deserialized.id,
        "Profile ID must match after round-trip"
    );
    assert_eq!(
        profile.name, deserialized.name,
        "Profile name must match after round-trip"
    );
    assert_eq!(
        profile.interests, deserialized.interests,
        "Interests must match after round-trip"
    );
}

#[test]
fn test_profile_to_activities_to_formdata_pipeline() {
    let mut gen = ProfileGenerator::new(Some(54321));
    let profile = gen.generate();

    // Generate activities for the profile
    let mut simulator = ActivitySimulator::new(profile.clone());
    let activities = simulator.generate_activities(24);

    assert!(!activities.is_empty(), "Should generate some activities");

    // Verify activities are consistent with profile interests
    let has_matching_interests = activities.iter().any(|activity| {
        if let Some(cat) = &activity.interest_category {
            profile.interests.contains(cat)
        } else {
            true // Activities without specific interest are ok
        }
    });

    assert!(
        has_matching_interests || activities.is_empty(),
        "Activities should relate to profile interests"
    );

    // Generate form data for the profile
    let mut rng = rand::rngs::SmallRng::seed_from_u64(54321);
    let form = FormDataGenerator::generate(&profile, &mut rng);

    // Verify form data consistency
    assert!(!form.email.is_empty(), "Form must have email");
    assert!(!form.display_name.is_empty(), "Form must have display name");
    assert!(!form.newsletter_topics.is_empty(), "Form must have topics");

    // Verify preferences match interests
    assert!(
        form.preferences.len() <= 3,
        "Preferences should be capped at 3"
    );
}

#[test]
fn test_profile_schedule_consistency() {
    let mut gen = ProfileGenerator::new(Some(99999));
    let profile = gen.generate();

    // Generate schedule from profile
    let schedule = Schedule::from_profile(&profile);

    // Verify schedule structure
    assert_eq!(
        schedule.time_patterns.len(),
        7,
        "Schedule must have 7 day patterns"
    );

    // Verify each day has active hours
    for pattern in &schedule.time_patterns {
        assert!(
            !pattern.active_hours.is_empty(),
            "Day pattern must have at least one active hour range"
        );

        // Verify activity intensity is in valid range
        assert!(
            pattern.activity_intensity >= 0.0 && pattern.activity_intensity <= 1.0,
            "Activity intensity must be in [0.0, 1.0]"
        );

        // Verify hour ranges are valid
        for range in &pattern.active_hours {
            assert!(
                range.start_hour < 24 && range.end_hour < 24,
                "Hour values must be valid (0-23)"
            );
        }
    }
}

#[test]
fn test_activity_stream_properties() {
    let mut gen = ProfileGenerator::new(Some(77777));
    let profile = gen.generate();
    let mut simulator = ActivitySimulator::new(profile);

    let activities = simulator.generate_activities(72); // 3 days

    // All activities should have valid URLs
    for activity in &activities {
        assert!(
            activity.url.starts_with("https://"),
            "Activity URL must be HTTPS: {}",
            activity.url
        );
        assert!(!activity.title.is_empty(), "Activity must have a title");
        assert!(activity.duration_seconds > 0, "Duration must be positive");
    }

    // Activities should span the requested duration
    if activities.len() > 1 {
        let first_ts = activities.first().unwrap().timestamp;
        let last_ts = activities.last().unwrap().timestamp;
        let span_hours = (last_ts - first_ts) / 3600;

        // Should be roughly 3 days (within 4 hours tolerance)
        assert!(
            span_hours >= 71 && span_hours <= 73,
            "Activity span should be ~72 hours, got {}",
            span_hours
        );
    }
}

#[test]
fn test_formdata_email_uniqueness_across_profiles() {
    let mut gen1 = ProfileGenerator::new(Some(111));
    let mut gen2 = ProfileGenerator::new(Some(222));

    let profile1 = gen1.generate();
    let profile2 = gen2.generate();

    let mut rng1 = rand::rngs::SmallRng::seed_from_u64(111);
    let mut rng2 = rand::rngs::SmallRng::seed_from_u64(222);

    let form1 = FormDataGenerator::generate(&profile1, &mut rng1);
    let form2 = FormDataGenerator::generate(&profile2, &mut rng2);

    // Emails should be different (with very high probability)
    // Note: Could theoretically collide, but probability is negligible
    assert_ne!(
        form1.email, form2.email,
        "Different profiles should generate different emails"
    );
}

#[test]
fn test_formdata_serialization_roundtrip() {
    let mut gen = ProfileGenerator::new(Some(33333));
    let profile = gen.generate();
    let mut rng = rand::rngs::SmallRng::seed_from_u64(33333);

    let form_original = FormDataGenerator::generate(&profile, &mut rng);

    // Serialize
    let json_str =
        serde_json::to_string(&form_original).expect("FormData serialization failed");

    // Deserialize
    let form_deserialized: FormData =
        serde_json::from_str(&json_str).expect("FormData deserialization failed");

    // Verify integrity
    assert_eq!(
        form_original.email, form_deserialized.email,
        "Email must match after round-trip"
    );
    assert_eq!(
        form_original.display_name, form_deserialized.display_name,
        "Display name must match after round-trip"
    );
    assert_eq!(
        form_original.preferences, form_deserialized.preferences,
        "Preferences must match after round-trip"
    );
}

#[test]
fn test_activity_types_distributed() {
    let mut gen = ProfileGenerator::new(Some(55555));
    let profile = gen.generate();
    let mut simulator = ActivitySimulator::new(profile);

    let activities = simulator.generate_activities(168); // 1 week

    // Count activity types
    let mut type_counts: std::collections::HashMap<String, usize> =
        std::collections::HashMap::new();

    for activity in &activities {
        let type_name = format!("{:?}", activity.activity_type);
        *type_counts.entry(type_name).or_insert(0) += 1;
    }

    // We should see multiple activity types
    assert!(
        type_counts.len() > 1,
        "Should see diverse activity types, got {}",
        type_counts.len()
    );
}

#[test]
fn test_large_activity_generation() {
    let mut gen = ProfileGenerator::new(Some(88888));
    let profile = gen.generate();
    let mut simulator = ActivitySimulator::new(profile);

    // Generate activities for a week
    let activities = simulator.generate_activities(168);

    // Should generate significant number of activities
    assert!(
        activities.len() > 100,
        "Should generate many activities over a week, got {}",
        activities.len()
    );

    // All should be valid
    for activity in &activities {
        assert!(activity.url.starts_with("https://"));
        assert!(activity.duration_seconds > 0);
    }
}
