use crate::profile::{InterestCategory, Profile};
use rand::seq::SliceRandom;
use rand::Rng;
use serde::{Deserialize, Serialize};

/// Plausible form fill data tied to a profile's persona
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FormData {
    pub email: String,
    pub display_name: String,
    pub preferences: Vec<String>,
    pub newsletter_topics: Vec<String>,
}

/// Generates fake form data that is consistent with a profile
pub struct FormDataGenerator;

impl FormDataGenerator {
    /// Generate form data that matches the profile's persona
    pub fn generate<R: Rng>(profile: &Profile, rng: &mut R) -> FormData {
        let email = Self::generate_email(&profile.name, rng);
        let display_name = Self::generate_display_name(&profile.name, rng);
        let preferences = Self::generate_preferences(&profile.interests, rng);
        let newsletter_topics = Self::generate_newsletter_topics(&profile.interests, rng);

        FormData {
            email,
            display_name,
            preferences,
            newsletter_topics,
        }
    }

    fn generate_email<R: Rng>(name: &str, rng: &mut R) -> String {
        let parts: Vec<&str> = name.split_whitespace().collect();
        let (first, last) = match parts.len() {
            0 => ("user", "name"),
            1 => (parts[0], "user"),
            _ => (parts[0], parts[parts.len() - 1]),
        };

        let first_lower = first.to_lowercase();
        let last_lower = last.to_lowercase();

        let domains = [
            "gmail.com",
            "outlook.com",
            "yahoo.com",
            "protonmail.com",
            "fastmail.com",
            "icloud.com",
            "hotmail.com",
        ];
        let domain = domains.choose(rng).unwrap();

        let separator = [".", "_", ""].choose(rng).unwrap();
        let number_suffix = if rng.gen_bool(0.6) {
            format!("{}", rng.gen_range(1..999))
        } else {
            String::new()
        };

        let local = match rng.gen_range(0..4) {
            0 => format!(
                "{}{}{}{}",
                first_lower, separator, last_lower, number_suffix
            ),
            1 => format!(
                "{}{}{}",
                first_lower.chars().next().unwrap(),
                last_lower,
                number_suffix
            ),
            2 => format!(
                "{}{}{}{}",
                last_lower, separator, first_lower, number_suffix
            ),
            _ => format!("{}{}", first_lower, number_suffix),
        };

        format!("{}@{}", local, domain)
    }

    fn generate_display_name<R: Rng>(name: &str, rng: &mut R) -> String {
        let parts: Vec<&str> = name.split_whitespace().collect();
        match rng.gen_range(0..4) {
            0 => name.to_string(),                                         // Full name
            1 => parts.first().map(|s| s.to_string()).unwrap_or_default(), // First name only
            2 => {
                // First initial + last name
                if parts.len() >= 2 {
                    format!(
                        "{}. {}",
                        parts[0].chars().next().unwrap(),
                        parts.last().unwrap()
                    )
                } else {
                    name.to_string()
                }
            }
            _ => {
                // Nickname-style
                let first = parts.first().map(|s| s.to_lowercase()).unwrap_or_default();
                format!("{}{}", first, rng.gen_range(10..99))
            }
        }
    }

    fn generate_preferences<R: Rng>(interests: &[InterestCategory], rng: &mut R) -> Vec<String> {
        let mut prefs = Vec::new();
        for interest in interests.iter().take(3) {
            let pref = match interest {
                InterestCategory::Technology => {
                    vec!["tech updates", "gadget reviews", "software tips"]
                }
                InterestCategory::Gaming => vec!["game releases", "esports news", "gaming deals"],
                InterestCategory::Sports => vec!["match results", "team updates", "player stats"],
                InterestCategory::Cooking => {
                    vec!["new recipes", "cooking tips", "ingredient guides"]
                }
                InterestCategory::Travel => {
                    vec!["flight deals", "destination guides", "travel tips"]
                }
                InterestCategory::Music => {
                    vec!["new releases", "concert alerts", "artist profiles"]
                }
                InterestCategory::Books => {
                    vec!["book recommendations", "author interviews", "reading lists"]
                }
                InterestCategory::Finance => {
                    vec!["market updates", "investment tips", "financial news"]
                }
                InterestCategory::Fitness => {
                    vec!["workout plans", "nutrition advice", "fitness challenges"]
                }
                InterestCategory::Photography => {
                    vec!["photo tips", "gear reviews", "editing tutorials"]
                }
                _ => vec!["general updates", "weekly digest", "featured content"],
            };
            if let Some(p) = pref.choose(rng) {
                prefs.push(p.to_string());
            }
        }
        prefs
    }

    fn generate_newsletter_topics<R: Rng>(
        interests: &[InterestCategory],
        rng: &mut R,
    ) -> Vec<String> {
        let mut topics = Vec::new();

        // Pick 1-3 topics aligned with interests
        let num_topics = rng.gen_range(1..=3.min(interests.len()));
        for interest in interests.choose_multiple(rng, num_topics) {
            let topic = match interest {
                InterestCategory::Technology => "Technology & Innovation",
                InterestCategory::Science => "Science & Discovery",
                InterestCategory::Programming => "Software Development",
                InterestCategory::Cooking => "Food & Recipes",
                InterestCategory::Travel => "Travel & Adventure",
                InterestCategory::Fitness => "Health & Wellness",
                InterestCategory::Finance => "Personal Finance",
                InterestCategory::Art => "Arts & Culture",
                InterestCategory::Music => "Music & Entertainment",
                InterestCategory::Books => "Literature & Reading",
                InterestCategory::Gaming => "Gaming",
                InterestCategory::Sports => "Sports",
                InterestCategory::Photography => "Photography",
                InterestCategory::DataScience => "Data & Analytics",
                _ => "General Interest",
            };
            topics.push(topic.to_string());
        }

        topics
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::profile::ProfileGenerator;
    use rand::rngs::SmallRng;
    use rand::SeedableRng;

    #[test]
    fn test_form_data_generation() {
        let mut gen = ProfileGenerator::new(Some(42));
        let profile = gen.generate();
        let mut rng = SmallRng::seed_from_u64(42);

        let form = FormDataGenerator::generate(&profile, &mut rng);

        assert!(form.email.contains('@'));
        assert!(!form.display_name.is_empty());
        assert!(!form.preferences.is_empty());
        assert!(!form.newsletter_topics.is_empty());
    }

    #[test]
    fn test_email_format() {
        let mut gen = ProfileGenerator::new(Some(99));
        let profile = gen.generate();
        let mut rng = SmallRng::seed_from_u64(99);

        for _ in 0..10 {
            let form = FormDataGenerator::generate(&profile, &mut rng);
            assert!(form.email.contains('@'));
            let parts: Vec<&str> = form.email.split('@').collect();
            assert_eq!(parts.len(), 2);
            assert!(!parts[0].is_empty());
            assert!(parts[1].contains('.'));
        }
    }

    #[test]
    fn test_preferences_match_interests() {
        let mut gen = ProfileGenerator::new(Some(77));
        let profile = gen.generate();
        let mut rng = SmallRng::seed_from_u64(77);

        let form = FormDataGenerator::generate(&profile, &mut rng);
        // Should have at most as many preferences as interests (capped at 3)
        assert!(form.preferences.len() <= 3);
        assert!(form.newsletter_topics.len() >= 1);
    }
}
