use crate::interests::InterestUrlGenerator;
use crate::profile::{ActivityLevel, BrowsingStyle, InterestCategory, Profile};
use rand::rngs::SmallRng;
use rand::seq::SliceRandom;
use rand::{Rng, SeedableRng};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BrowsingActivity {
    pub activity_type: ActivityType,
    pub url: String,
    pub title: String,
    pub duration_seconds: u32,
    pub timestamp: i64,
    pub interest_category: Option<InterestCategory>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ActivityType {
    Search,
    PageVisit,
    VideoWatch,
    Shopping,
    SocialMedia,
    News,
    Research,
}

pub struct ActivitySimulator {
    profile: Profile,
    rng: SmallRng,
    url_generator: InterestUrlGenerator,
}

impl ActivitySimulator {
    pub fn new(profile: Profile) -> Self {
        Self {
            profile: profile.clone(),
            rng: SmallRng::from_entropy(),
            url_generator: InterestUrlGenerator::new(),
        }
    }

    /// Generate activities for a given duration in hours
    pub fn generate_activities(&mut self, duration_hours: u32) -> Vec<BrowsingActivity> {
        let base_time = chrono::Utc::now().timestamp();
        let mut activities = Vec::new();

        // Calculate activities per hour based on activity level
        let activities_per_hour = self.get_activities_per_hour();

        let total_activities = (duration_hours as f64 * activities_per_hour) as usize;

        for i in 0..total_activities {
            // Distribute activities across the time period with realistic clustering
            let hour_offset = (i as f64 / activities_per_hour) as i64 * 3600;
            let minute_jitter = self.rng.gen_range(0..3600);
            let timestamp = base_time + hour_offset + minute_jitter;

            let activity = self.generate_single_activity(timestamp);
            activities.push(activity);
        }

        // Sort by timestamp
        activities.sort_by_key(|a| a.timestamp);

        activities
    }

    fn get_activities_per_hour(&self) -> f64 {
        match self.profile.activity_level {
            ActivityLevel::Low => 1.5,
            ActivityLevel::Medium => 4.0,
            ActivityLevel::High => 8.0,
            ActivityLevel::VeryHigh => 15.0,
        }
    }

    fn generate_single_activity(&mut self, timestamp: i64) -> BrowsingActivity {
        // Pick an interest category
        let interest = self.profile.interests.choose(&mut self.rng).cloned();

        // Determine activity type based on browsing style and interest
        let activity_type = self.choose_activity_type(&interest);

        // Generate URL and title
        let (url, title) =
            self.url_generator
                .generate_url(&activity_type, &interest, &mut self.rng);

        // Generate realistic duration
        let duration_seconds = self.generate_duration(&activity_type);

        BrowsingActivity {
            activity_type,
            url,
            title,
            duration_seconds,
            timestamp,
            interest_category: interest,
        }
    }

    fn choose_activity_type(&mut self, _interest: &Option<InterestCategory>) -> ActivityType {
        match &self.profile.browsing_style {
            BrowsingStyle::Researcher => {
                // Researchers do more searches and research
                match self.rng.gen_range(0..=100) {
                    0..=40 => ActivityType::Search,
                    41..=75 => ActivityType::Research,
                    76..=85 => ActivityType::PageVisit,
                    86..=92 => ActivityType::News,
                    _ => ActivityType::VideoWatch,
                }
            }
            BrowsingStyle::Focused => {
                // Focused users spend more time on fewer pages
                match self.rng.gen_range(0..=100) {
                    0..=60 => ActivityType::PageVisit,
                    61..=75 => ActivityType::Research,
                    76..=85 => ActivityType::Search,
                    _ => ActivityType::News,
                }
            }
            BrowsingStyle::Explorer => {
                // Explorers hit many different types
                match self.rng.gen_range(0..=100) {
                    0..=30 => ActivityType::PageVisit,
                    31..=45 => ActivityType::Search,
                    46..=60 => ActivityType::VideoWatch,
                    61..=75 => ActivityType::SocialMedia,
                    76..=85 => ActivityType::Shopping,
                    _ => ActivityType::News,
                }
            }
            BrowsingStyle::Casual => {
                // Casual browsers have balanced activity
                match self.rng.gen_range(0..=100) {
                    0..=25 => ActivityType::SocialMedia,
                    26..=45 => ActivityType::VideoWatch,
                    46..=60 => ActivityType::PageVisit,
                    61..=75 => ActivityType::News,
                    76..=85 => ActivityType::Shopping,
                    _ => ActivityType::Search,
                }
            }
        }
    }

    fn generate_duration(&mut self, activity_type: &ActivityType) -> u32 {
        // Mean durations in seconds for different activity types
        let mean = match activity_type {
            ActivityType::Search => 10.0,
            ActivityType::PageVisit => 120.0,
            ActivityType::VideoWatch => 480.0,
            ActivityType::Shopping => 180.0,
            ActivityType::SocialMedia => 240.0,
            ActivityType::News => 90.0,
            ActivityType::Research => 300.0,
        };

        // Add some randomness
        let duration = mean * (0.5 + self.rng.gen::<f64>() * 1.5);
        duration as u32
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::profile::ProfileGenerator;

    #[test]
    fn test_activity_generation() {
        let mut gen = ProfileGenerator::new(Some(42));
        let profile = gen.generate();
        let mut simulator = ActivitySimulator::new(profile);

        let activities = simulator.generate_activities(1);
        assert!(!activities.is_empty());

        // Check activities are sorted by time
        for i in 1..activities.len() {
            assert!(activities[i].timestamp >= activities[i - 1].timestamp);
        }
    }

    #[test]
    fn test_duration_generation() {
        let mut gen = ProfileGenerator::new(Some(42));
        let profile = gen.generate();
        let mut simulator = ActivitySimulator::new(profile);

        let duration = simulator.generate_duration(&ActivityType::VideoWatch);
        assert!(duration > 0);
        assert!(duration < 3600); // Less than an hour is reasonable
    }
}
