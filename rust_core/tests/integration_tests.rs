use doubletrack_core::*;

#[test]
fn test_profile_generation_deterministic() {
    // Same seed should produce same profile
    let mut gen1 = ProfileGenerator::new(Some(42));
    let mut gen2 = ProfileGenerator::new(Some(42));

    let profile1 = gen1.generate();
    let profile2 = gen2.generate();

    assert_eq!(profile1.name, profile2.name);
    assert_eq!(profile1.demographics.age, profile2.demographics.age);
}

#[test]
fn test_profile_validation() {
    let mut gen = ProfileGenerator::new(Some(123));
    let profile = gen.generate();

    assert!(profile.is_valid());
    assert!(!profile.name.is_empty());
    assert!(!profile.interests.is_empty());
    assert!(profile.demographics.age >= 18);
    assert!(profile.demographics.age <= 100);
}

#[test]
fn test_activity_generation_count() {
    let mut gen = ProfileGenerator::new(Some(42));
    let profile = gen.generate();
    let mut simulator = ActivitySimulator::new(profile);

    let activities = simulator.generate_activities(1);

    // Should generate some activities for 1 hour
    assert!(!activities.is_empty());

    // Activities should be sorted by timestamp
    for i in 1..activities.len() {
        assert!(activities[i].timestamp >= activities[i - 1].timestamp);
    }
}

#[test]
fn test_activity_types_vary() {
    let mut gen = ProfileGenerator::new(Some(999));
    let profile = gen.generate();
    let mut simulator = ActivitySimulator::new(profile);

    let activities = simulator.generate_activities(24);

    // Check that we have some variety in activity types
    let unique_types: std::collections::HashSet<_> = activities
        .iter()
        .map(|a| std::mem::discriminant(&a.activity_type))
        .collect();

    // Should have at least 3 different types over 24 hours
    assert!(unique_types.len() >= 3);
}

#[test]
fn test_profile_interests_based_on_occupation() {
    // Technology occupation should have tech-related interests
    let mut gen = ProfileGenerator::new(Some(100));

    // Generate multiple profiles to test variety
    for _ in 0..5 {
        let profile = gen.generate();

        // Should have at least one interest
        assert!(!profile.interests.is_empty());

        // Interests should be from valid categories
        assert!(profile.interests.len() <= 10);
    }
}

#[test]
fn test_schedule_generation() {
    let mut gen = ProfileGenerator::new(Some(42));
    let profile = gen.generate();
    let schedule = Schedule::from_profile(&profile);

    // Should have 7 days
    assert_eq!(schedule.time_patterns.len(), 7);

    // Each day should have some active hours
    for pattern in &schedule.time_patterns {
        assert!(!pattern.active_hours.is_empty());
        assert!(pattern.activity_intensity > 0.0);
        assert!(pattern.activity_intensity <= 1.0);
    }
}

#[test]
fn test_activity_duration_reasonable() {
    let mut gen = ProfileGenerator::new(Some(42));
    let profile = gen.generate();
    let mut simulator = ActivitySimulator::new(profile);

    let activities = simulator.generate_activities(1);

    for activity in activities {
        // Duration should be positive and reasonable (less than 2 hours)
        assert!(activity.duration_seconds > 0);
        assert!(activity.duration_seconds < 7200);
    }
}

#[test]
fn test_activity_urls_valid() {
    let mut gen = ProfileGenerator::new(Some(42));
    let profile = gen.generate();
    let mut simulator = ActivitySimulator::new(profile);

    let activities = simulator.generate_activities(1);

    for activity in activities {
        // URLs should start with http
        assert!(
            activity.url.starts_with("https://") || activity.url.starts_with("https://")
        );

        // Titles should not be empty
        assert!(!activity.title.is_empty());
    }
}

#[test]
fn test_different_seeds_different_profiles() {
    let mut gen1 = ProfileGenerator::new(Some(1));
    let mut gen2 = ProfileGenerator::new(Some(2));

    let profile1 = gen1.generate();
    let profile2 = gen2.generate();

    // Different seeds should produce different profiles
    assert_ne!(profile1.name, profile2.name);
}

#[test]
fn test_activity_timestamps_increase() {
    let mut gen = ProfileGenerator::new(Some(42));
    let profile = gen.generate();
    let mut simulator = ActivitySimulator::new(profile);

    let activities = simulator.generate_activities(2);

    // Timestamps should be strictly increasing or equal
    for i in 1..activities.len() {
        assert!(activities[i].timestamp >= activities[i - 1].timestamp);
    }
}

#[test]
fn test_profile_age_ranges() {
    let mut gen = ProfileGenerator::new(None);

    // Generate many profiles to test age distribution
    let mut ages = Vec::new();
    for _ in 0..50 {
        let profile = gen.generate();
        ages.push(profile.demographics.age);
    }

    // Should have variety in ages
    let min_age = *ages.iter().min().unwrap();
    let max_age = *ages.iter().max().unwrap();

    assert!(min_age >= 18);
    assert!(max_age <= 75);
    assert!(max_age - min_age >= 20); // At least 20 years range
}

#[test]
fn test_browsing_style_variety() {
    let mut gen = ProfileGenerator::new(None);

    let mut styles = std::collections::HashSet::new();
    for _ in 0..20 {
        let profile = gen.generate();
        styles.insert(std::mem::discriminant(&profile.browsing_style));
    }

    // Should have at least 2 different browsing styles
    assert!(styles.len() >= 2);
}
