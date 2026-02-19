use serde::{Deserialize, Serialize};
use rand::{Rng, SeedableRng};
use rand::rngs::SmallRng;
use rand::seq::SliceRandom;

/// A fictional browsing profile
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Profile {
    pub id: String,
    pub name: String,
    pub demographics: Demographics,
    pub interests: Vec<InterestCategory>,
    pub browsing_style: BrowsingStyle,
    pub activity_level: ActivityLevel,
    pub created_at: i64,
}

impl Profile {
    /// Check if the profile is internally consistent
    pub fn is_valid(&self) -> bool {
        !self.name.is_empty()
            && !self.interests.is_empty()
            && self.interests.len() <= 10
            && self.demographics.age >= 18
            && self.demographics.age <= 100
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Demographics {
    pub age: u8,
    pub gender: Gender,
    pub location_type: LocationType,
    pub occupation_category: OccupationCategory,
    pub education_level: EducationLevel,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum Gender {
    Male,
    Female,
    NonBinary,
    PreferNotToSay,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum LocationType {
    Urban,
    Suburban,
    Rural,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum OccupationCategory {
    Technology,
    Healthcare,
    Education,
    Finance,
    Creative,
    Service,
    Trades,
    Retired,
    Student,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum EducationLevel {
    HighSchool,
    SomeCollege,
    Bachelor,
    Master,
    Doctorate,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum InterestCategory {
    Technology,
    Gaming,
    Sports,
    Fitness,
    Cooking,
    Travel,
    Fashion,
    Music,
    Movies,
    Books,
    Art,
    Science,
    Politics,
    News,
    Finance,
    HomeImprovement,
    Gardening,
    Photography,
    Programming,
    DataScience,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum BrowsingStyle {
    Focused,      // Few tabs, deep reading
    Explorer,     // Many tabs, broad browsing
    Researcher,   // Lots of searches, academic
    Casual,       // Mix of everything
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ActivityLevel {
    Low,       // 10-30 activities per day
    Medium,    // 30-70 activities per day
    High,      // 70-150 activities per day
    VeryHigh,  // 150+ activities per day
}

pub struct ProfileGenerator {
    rng: SmallRng,
}

impl ProfileGenerator {
    pub fn new(seed: Option<u64>) -> Self {
        let rng = if let Some(s) = seed {
            SmallRng::seed_from_u64(s)
        } else {
            SmallRng::from_entropy()
        };

        Self { rng }
    }

    pub fn generate(&mut self) -> Profile {
        let demographics = self.generate_demographics();
        let interests = self.generate_interests(&demographics);
        let browsing_style = self.generate_browsing_style(&interests);
        let activity_level = self.generate_activity_level(&demographics);

        Profile {
            id: self.generate_id(),
            name: self.generate_name(&demographics),
            demographics,
            interests,
            browsing_style,
            activity_level,
            created_at: chrono::Utc::now().timestamp(),
        }
    }

    fn generate_id(&mut self) -> String {
        format!("profile_{:016x}", self.rng.gen::<u64>())
    }

    fn generate_name(&mut self, demographics: &Demographics) -> String {
        let first_names_male = vec![
            "James", "John", "Robert", "Michael", "William", "David", "Richard",
            "Joseph", "Thomas", "Christopher", "Daniel", "Matthew", "Anthony",
        ];

        let first_names_female = vec![
            "Mary", "Patricia", "Jennifer", "Linda", "Elizabeth", "Barbara",
            "Susan", "Jessica", "Sarah", "Karen", "Nancy", "Lisa", "Margaret",
        ];

        let first_names_neutral = vec![
            "Alex", "Jordan", "Taylor", "Casey", "Riley", "Morgan", "Avery",
            "Quinn", "Sam", "Charlie", "Jamie", "Drew",
        ];

        let last_names = vec![
            "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller",
            "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez",
            "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin",
        ];

        let first_name = match demographics.gender {
            Gender::Male => first_names_male.choose(&mut self.rng).unwrap(),
            Gender::Female => first_names_female.choose(&mut self.rng).unwrap(),
            Gender::NonBinary | Gender::PreferNotToSay => {
                first_names_neutral.choose(&mut self.rng).unwrap()
            }
        };

        let last_name = last_names.choose(&mut self.rng).unwrap();
        format!("{} {}", first_name, last_name)
    }

    fn generate_demographics(&mut self) -> Demographics {
        let age = self.rng.gen_range(18..=75);

        let gender = match self.rng.gen_range(0..=100) {
            0..=48 => Gender::Male,
            49..=97 => Gender::Female,
            98 => Gender::NonBinary,
            _ => Gender::PreferNotToSay,
        };

        let location_type = match self.rng.gen_range(0..=100) {
            0..=49 => LocationType::Urban,
            50..=84 => LocationType::Suburban,
            _ => LocationType::Rural,
        };

        let occupation_category = match age {
            18..=22 => OccupationCategory::Student,
            65.. => {
                if self.rng.gen_bool(0.7) {
                    OccupationCategory::Retired
                } else {
                    self.random_occupation()
                }
            }
            _ => self.random_occupation(),
        };

        let education_level = match age {
            18..=21 => {
                if self.rng.gen_bool(0.7) {
                    EducationLevel::HighSchool
                } else {
                    EducationLevel::SomeCollege
                }
            }
            22..=24 => {
                match self.rng.gen_range(0..=100) {
                    0..=30 => EducationLevel::SomeCollege,
                    31..=80 => EducationLevel::Bachelor,
                    _ => EducationLevel::Master,
                }
            }
            _ => {
                match self.rng.gen_range(0..=100) {
                    0..=20 => EducationLevel::HighSchool,
                    21..=40 => EducationLevel::SomeCollege,
                    41..=75 => EducationLevel::Bachelor,
                    76..=95 => EducationLevel::Master,
                    _ => EducationLevel::Doctorate,
                }
            }
        };

        Demographics {
            age,
            gender,
            location_type,
            occupation_category,
            education_level,
        }
    }

    fn random_occupation(&mut self) -> OccupationCategory {
        let occupations = vec![
            OccupationCategory::Technology,
            OccupationCategory::Healthcare,
            OccupationCategory::Education,
            OccupationCategory::Finance,
            OccupationCategory::Creative,
            OccupationCategory::Service,
            OccupationCategory::Trades,
        ];
        occupations.choose(&mut self.rng).unwrap().clone()
    }

    fn generate_interests(&mut self, demographics: &Demographics) -> Vec<InterestCategory> {
        let mut interests = Vec::new();

        // Base interests on occupation
        let occupation_interests = match demographics.occupation_category {
            OccupationCategory::Technology => {
                vec![InterestCategory::Technology, InterestCategory::Programming, InterestCategory::DataScience]
            }
            OccupationCategory::Healthcare => {
                vec![InterestCategory::Fitness, InterestCategory::Science]
            }
            OccupationCategory::Education => {
                vec![InterestCategory::Books, InterestCategory::Science]
            }
            OccupationCategory::Finance => {
                vec![InterestCategory::Finance, InterestCategory::News]
            }
            OccupationCategory::Creative => {
                vec![InterestCategory::Art, InterestCategory::Music, InterestCategory::Photography]
            }
            OccupationCategory::Student => {
                vec![InterestCategory::Gaming, InterestCategory::Movies, InterestCategory::Music]
            }
            OccupationCategory::Retired => {
                vec![InterestCategory::Gardening, InterestCategory::Travel, InterestCategory::Cooking]
            }
            _ => vec![InterestCategory::News],
        };

        // Add 1-2 occupation-related interests
        let num_occupation_interests = self.rng.gen_range(1..=2.min(occupation_interests.len()));
        interests.extend(
            occupation_interests
                .choose_multiple(&mut self.rng, num_occupation_interests)
                .cloned()
        );

        // Add random interests
        let all_interests = vec![
            InterestCategory::Technology, InterestCategory::Gaming, InterestCategory::Sports,
            InterestCategory::Fitness, InterestCategory::Cooking, InterestCategory::Travel,
            InterestCategory::Fashion, InterestCategory::Music, InterestCategory::Movies,
            InterestCategory::Books, InterestCategory::Art, InterestCategory::Science,
            InterestCategory::Politics, InterestCategory::News, InterestCategory::Finance,
            InterestCategory::HomeImprovement, InterestCategory::Gardening,
            InterestCategory::Photography, InterestCategory::Programming,
            InterestCategory::DataScience,
        ];

        let num_random_interests = self.rng.gen_range(2..=5);
        for interest in all_interests.choose_multiple(&mut self.rng, num_random_interests) {
            if !interests.contains(interest) {
                interests.push(interest.clone());
            }
        }

        interests
    }

    fn generate_browsing_style(&mut self, interests: &[InterestCategory]) -> BrowsingStyle {
        // Tech-savvy profiles tend to be explorers or researchers
        if interests.contains(&InterestCategory::Technology)
            || interests.contains(&InterestCategory::Programming) {
            if self.rng.gen_bool(0.6) {
                return BrowsingStyle::Explorer;
            } else {
                return BrowsingStyle::Researcher;
            }
        }

        // Science/academic interests lean towards researcher or focused
        if interests.contains(&InterestCategory::Science)
            || interests.contains(&InterestCategory::DataScience) {
            if self.rng.gen_bool(0.5) {
                return BrowsingStyle::Researcher;
            } else {
                return BrowsingStyle::Focused;
            }
        }

        // Default to weighted random
        match self.rng.gen_range(0..=100) {
            0..=25 => BrowsingStyle::Focused,
            26..=50 => BrowsingStyle::Explorer,
            51..=70 => BrowsingStyle::Researcher,
            _ => BrowsingStyle::Casual,
        }
    }

    fn generate_activity_level(&mut self, demographics: &Demographics) -> ActivityLevel {
        // Younger people tend to be more active online
        let age_factor = match demographics.age {
            18..=25 => 0.8,
            26..=35 => 0.7,
            36..=50 => 0.5,
            51..=65 => 0.3,
            _ => 0.2,
        };

        // Students and tech workers are more active
        let occupation_factor = match demographics.occupation_category {
            OccupationCategory::Technology | OccupationCategory::Student => 0.2,
            _ => 0.0,
        };

        let activity_score = self.rng.gen::<f32>() + age_factor + occupation_factor;

        match activity_score {
            x if x < 0.5 => ActivityLevel::Low,
            x if x < 1.0 => ActivityLevel::Medium,
            x if x < 1.5 => ActivityLevel::High,
            _ => ActivityLevel::VeryHigh,
        }
    }
}
