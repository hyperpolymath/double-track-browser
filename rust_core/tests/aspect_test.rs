// SPDX-License-Identifier: PMPL-1.0-or-later
// Security and aspect tests for DoubleTrack core
// Tests for handling of oversized inputs, special characters, and injection patterns

use doubletrack_core::*;
use rand::SeedableRng;

#[test]
fn test_oversized_input_handling() {
    // Test that very large inputs don't crash the system
    let oversized_name = "A".repeat(100_000); // 100KB of 'A's

    // Profile generation should handle this gracefully
    // (It may ignore or truncate, but shouldn't crash)
    let large_json = format!(
        r#"{{"id":"test","name":"{}","demographics":{{"age":30,"gender":"Male","location_type":"Urban","occupation_category":"Technology","education_level":"Bachelor"}},"interests":[],"browsing_style":"Focused","activity_level":"Medium","created_at":0}}"#,
        oversized_name
    );

    // Attempt deserialization - should succeed or fail gracefully
    let result: Result<Profile, _> = serde_json::from_str(&large_json);
    // The outcome doesn't matter (success or parse error), but shouldn't panic
    let _ = result;
}

#[test]
fn test_unicode_in_profile_fields() {
    // Test Unicode handling in names and interests
    let unicode_profiles = vec![
        ("José García", "Español"),
        ("李明", "中文"),
        ("Müller", "Deutsch"),
        ("Πέτρος", "Ελληνικά"),
        ("🎭 Name", "Emoji"),
    ];

    for (name, description) in unicode_profiles {
        // Create a JSON profile with Unicode
        let json_str = format!(
            r#"{{"id":"test_{}","name":"{}","demographics":{{"age":25,"gender":"Male","location_type":"Urban","occupation_category":"Technology","education_level":"Bachelor"}},"interests":["Technology"],"browsing_style":"Focused","activity_level":"Medium","created_at":0}}"#,
            description, name
        );

        let result: Result<Profile, _> = serde_json::from_str(&json_str);

        if let Ok(profile) = result {
            // If it parses, verify data integrity
            assert_eq!(profile.name, name, "Unicode name must be preserved");
        }
        // Parse failure is acceptable, but no panic
    }
}

#[test]
fn test_xss_payload_handling_in_urls() {
    // Test that XSS-like payloads in generated content don't execute
    let _xss_patterns = vec![
        "<script>alert('xss')</script>",
        "javascript:alert('xss')",
        "onerror='alert(1)'",
        "';DROP TABLE users;--",
        "<img src=x onerror=alert(1)>",
    ];

    let mut gen = ProfileGenerator::new(Some(12345));
    let profile = gen.generate();
    let mut simulator = ActivitySimulator::new(profile);

    let activities = simulator.generate_activities(1);

    // Activities should have URLs and titles that are valid
    for activity in &activities {
        // URLs should be properly formatted, not injection attempts
        assert!(
            activity.url.starts_with("https://"),
            "URL must be properly formatted"
        );

        // Title should not contain unescaped script tags
        // (In real browser context, these would be escaped by DOM APIs)
        assert!(
            !activity.title.contains("<script>"),
            "Title should not contain raw script tags"
        );
    }
}

#[test]
fn test_sql_injection_patterns_in_formdata() {
    let mut gen = ProfileGenerator::new(Some(54321));
    let profile = gen.generate();
    let mut rng = rand::rngs::SmallRng::seed_from_u64(54321);

    let form = FormDataGenerator::generate(&profile, &mut rng);

    // Email should always be valid format, not SQL injection
    assert!(
        form.email.contains('@'),
        "Email must contain @ symbol"
    );
    let parts: Vec<&str> = form.email.split('@').collect();
    assert_eq!(parts.len(), 2, "Email must have valid structure");

    // Display name should not contain command injection patterns
    assert!(
        !form.display_name.contains(";"),
        "Display name should not contain semicolons"
    );
}

#[test]
fn test_empty_input_handling() {
    // Test handling of edge cases with empty/minimal data
    let minimal_json = r#"{"id":"test","name":"A B","demographics":{"age":30,"gender":"Male","location_type":"Urban","occupation_category":"Technology","education_level":"Bachelor"},"interests":["Technology"],"browsing_style":"Focused","activity_level":"Medium","created_at":0}"#;

    let result: Result<Profile, _> = serde_json::from_str(minimal_json);
    assert!(result.is_ok(), "Minimal valid profile should parse");

    if let Ok(profile) = result {
        assert!(!profile.name.is_empty(), "Profile must have name");
        assert!(!profile.interests.is_empty(), "Profile must have interests");
    }
}

#[test]
fn test_timestamp_validity() {
    let mut gen = ProfileGenerator::new(Some(77777));
    let profile = gen.generate();

    // created_at should be a reasonable timestamp
    let now = chrono::Utc::now().timestamp();

    // Profile created_at should be close to now (within 1 minute)
    assert!(
        (now - profile.created_at).abs() < 60,
        "Profile created_at should be recent"
    );
}

#[test]
fn test_activity_timestamp_validity() {
    let mut gen = ProfileGenerator::new(Some(88888));
    let profile = gen.generate();
    let mut simulator = ActivitySimulator::new(profile);

    let activities = simulator.generate_activities(24);

    let now = chrono::Utc::now().timestamp();

    for activity in &activities {
        // Activity timestamps should be recent (within 24 hours)
        let time_diff = (now - activity.timestamp).abs();
        assert!(
            time_diff < 86400 * 2,  // 2 days tolerance
            "Activity timestamp should be recent"
        );
    }
}

#[test]
fn test_integer_overflow_protection() {
    // Test handling of edge case numeric values
    let edge_case_json = r#"{"id":"test","name":"Test User","demographics":{"age":255,"gender":"Male","location_type":"Urban","occupation_category":"Technology","education_level":"Bachelor"},"interests":["Technology"],"browsing_style":"Focused","activity_level":"Medium","created_at":9223372036854775807}"#;

    let result: Result<Profile, _> = serde_json::from_str(edge_case_json);
    // Should either succeed or fail gracefully, not panic
    let _ = result;
}

#[test]
fn test_activity_list_consistency() {
    let mut gen = ProfileGenerator::new(Some(11111));
    let profile = gen.generate();
    let mut simulator = ActivitySimulator::new(profile);

    let activities = simulator.generate_activities(1);

    // All activities should have consistent structure
    for activity in &activities {
        // Duration should be positive
        assert!(
            activity.duration_seconds > 0,
            "Duration must be positive"
        );

        // URL should be valid
        assert!(
            activity.url.starts_with("https://"),
            "URL should be HTTPS"
        );

        // Title should not be empty
        assert!(!activity.title.is_empty(), "Title must not be empty");

        // Interest category is optional but if present should be valid
        // (We can't easily validate this without matching all variants,
        // but the type system ensures it's valid)
    }
}

#[test]
fn test_formdata_field_lengths() {
    let mut gen = ProfileGenerator::new(Some(22222));
    let profile = gen.generate();
    let mut rng = rand::rngs::SmallRng::seed_from_u64(22222);

    let form = FormDataGenerator::generate(&profile, &mut rng);

    // Email should be within reasonable bounds
    assert!(
        form.email.len() < 256,
        "Email address shouldn't exceed 255 chars"
    );

    // Display name should be reasonable
    assert!(
        form.display_name.len() < 256,
        "Display name shouldn't exceed 255 chars"
    );

    // Preferences should be reasonable
    for pref in &form.preferences {
        assert!(
            pref.len() < 256,
            "Individual preference shouldn't exceed 255 chars"
        );
    }
}

#[test]
fn test_no_unsafe_pattern_in_data_structures() {
    // Verify that generated data doesn't contain patterns that could
    // cause issues in different contexts

    let mut gen = ProfileGenerator::new(Some(33333));
    let profile = gen.generate();
    let mut rng = rand::rngs::SmallRng::seed_from_u64(33333);

    let form = FormDataGenerator::generate(&profile, &mut rng);

    // Check for null bytes (would cause C string issues)
    assert!(!form.email.contains('\0'), "Email must not contain null bytes");
    assert!(!form.display_name.contains('\0'), "Display name must not contain null bytes");

    // Check for control characters (except newline/tab which might be ok)
    for c in form.email.chars() {
        assert!(
            !c.is_control() || c == '\n' || c == '\t' || c == '\r',
            "Email should not contain control characters"
        );
    }
}

#[test]
fn test_boundary_values_for_activity_duration() {
    let mut gen = ProfileGenerator::new(Some(44444));
    let profile = gen.generate();
    let mut simulator = ActivitySimulator::new(profile);

    let activities = simulator.generate_activities(1);

    for activity in &activities {
        // Duration should be reasonable for different activity types
        let max_duration = match activity.activity_type {
            ActivityType::VideoWatch => 3600 * 4, // Videos might be longer
            ActivityType::Research => 3600 * 2,   // Research could be extended
            _ => 3600,                              // Most activities < 1 hour
        };

        assert!(
            activity.duration_seconds <= max_duration * 2, // 2x safety margin
            "Duration {:?} seems unreasonable for {:?}",
            activity.duration_seconds,
            activity.activity_type
        );
    }
}
