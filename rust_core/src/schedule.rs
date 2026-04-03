use crate::profile::{ActivityLevel, OccupationCategory, Profile};
use serde::{Deserialize, Serialize};

/// Represents a schedule for when activities should occur
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Schedule {
    pub time_patterns: Vec<TimePattern>,
    pub timezone_offset: i32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TimePattern {
    pub day_of_week: DayOfWeek,
    pub active_hours: Vec<HourRange>,
    pub activity_intensity: f32, // 0.0 to 1.0
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HourRange {
    pub start_hour: u8,
    pub end_hour: u8,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub enum DayOfWeek {
    Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday,
    Sunday,
}

impl Schedule {
    /// Generate a schedule from a profile
    pub fn from_profile(profile: &Profile) -> Self {
        let mut patterns = Vec::new();

        // Different patterns for weekdays vs weekends
        for day in 0..7 {
            let day_of_week = match day {
                0 => DayOfWeek::Monday,
                1 => DayOfWeek::Tuesday,
                2 => DayOfWeek::Wednesday,
                3 => DayOfWeek::Thursday,
                4 => DayOfWeek::Friday,
                5 => DayOfWeek::Saturday,
                6 => DayOfWeek::Sunday,
                _ => unreachable!(),
            };

            let is_weekend = day >= 5;
            let pattern = Self::generate_day_pattern(profile, day_of_week, is_weekend);
            patterns.push(pattern);
        }

        Schedule {
            time_patterns: patterns,
            timezone_offset: 0, // UTC by default
        }
    }

    fn generate_day_pattern(
        profile: &Profile,
        day_of_week: DayOfWeek,
        is_weekend: bool,
    ) -> TimePattern {
        let active_hours = match &profile.demographics.occupation_category {
            OccupationCategory::Student => {
                if is_weekend {
                    vec![
                        HourRange {
                            start_hour: 10,
                            end_hour: 14,
                        },
                        HourRange {
                            start_hour: 18,
                            end_hour: 2,
                        },
                    ]
                } else {
                    vec![
                        HourRange {
                            start_hour: 8,
                            end_hour: 10,
                        },
                        HourRange {
                            start_hour: 15,
                            end_hour: 23,
                        },
                    ]
                }
            }
            OccupationCategory::Technology => {
                if is_weekend {
                    vec![
                        HourRange {
                            start_hour: 9,
                            end_hour: 12,
                        },
                        HourRange {
                            start_hour: 14,
                            end_hour: 22,
                        },
                    ]
                } else {
                    vec![
                        HourRange {
                            start_hour: 7,
                            end_hour: 9,
                        },
                        HourRange {
                            start_hour: 12,
                            end_hour: 13,
                        },
                        HourRange {
                            start_hour: 17,
                            end_hour: 23,
                        },
                    ]
                }
            }
            OccupationCategory::Retired => {
                vec![
                    HourRange {
                        start_hour: 7,
                        end_hour: 11,
                    },
                    HourRange {
                        start_hour: 14,
                        end_hour: 17,
                    },
                    HourRange {
                        start_hour: 19,
                        end_hour: 21,
                    },
                ]
            }
            _ => {
                if is_weekend {
                    vec![
                        HourRange {
                            start_hour: 9,
                            end_hour: 13,
                        },
                        HourRange {
                            start_hour: 16,
                            end_hour: 22,
                        },
                    ]
                } else {
                    vec![
                        HourRange {
                            start_hour: 7,
                            end_hour: 9,
                        },
                        HourRange {
                            start_hour: 12,
                            end_hour: 13,
                        },
                        HourRange {
                            start_hour: 18,
                            end_hour: 22,
                        },
                    ]
                }
            }
        };

        let activity_intensity = match profile.activity_level {
            ActivityLevel::Low => 0.3,
            ActivityLevel::Medium => 0.6,
            ActivityLevel::High => 0.85,
            ActivityLevel::VeryHigh => 1.0,
        };

        TimePattern {
            day_of_week,
            active_hours,
            activity_intensity,
        }
    }

    /// Check if the given hour is within an active period
    pub fn is_active_hour(&self, day: DayOfWeek, hour: u8) -> bool {
        for pattern in &self.time_patterns {
            if matches_day(pattern.day_of_week, day) {
                for range in &pattern.active_hours {
                    if Self::hour_in_range(hour, range) {
                        return true;
                    }
                }
            }
        }
        false
    }

    fn hour_in_range(hour: u8, range: &HourRange) -> bool {
        if range.start_hour <= range.end_hour {
            hour >= range.start_hour && hour < range.end_hour
        } else {
            // Wraps around midnight
            hour >= range.start_hour || hour < range.end_hour
        }
    }
}

fn matches_day(pattern_day: DayOfWeek, target_day: DayOfWeek) -> bool {
    matches!(
        (pattern_day, target_day),
        (DayOfWeek::Monday, DayOfWeek::Monday)
            | (DayOfWeek::Tuesday, DayOfWeek::Tuesday)
            | (DayOfWeek::Wednesday, DayOfWeek::Wednesday)
            | (DayOfWeek::Thursday, DayOfWeek::Thursday)
            | (DayOfWeek::Friday, DayOfWeek::Friday)
            | (DayOfWeek::Saturday, DayOfWeek::Saturday)
            | (DayOfWeek::Sunday, DayOfWeek::Sunday)
    )
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::profile::ProfileGenerator;

    #[test]
    fn test_schedule_generation() {
        let mut gen = ProfileGenerator::new(Some(42));
        let profile = gen.generate();
        let schedule = Schedule::from_profile(&profile);

        assert_eq!(schedule.time_patterns.len(), 7);
    }

    #[test]
    fn test_hour_in_range() {
        let range = HourRange {
            start_hour: 9,
            end_hour: 17,
        };
        assert!(Schedule::hour_in_range(10, &range));
        assert!(!Schedule::hour_in_range(18, &range));

        // Test wrap-around
        let night_range = HourRange {
            start_hour: 22,
            end_hour: 2,
        };
        assert!(Schedule::hour_in_range(23, &night_range));
        assert!(Schedule::hour_in_range(1, &night_range));
        assert!(!Schedule::hour_in_range(12, &night_range));
    }
}
