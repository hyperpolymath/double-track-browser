// SPDX-License-Identifier: MIT OR Palimpsest-0.8
// Type definitions for DoubleTrack Browser

type gender =
  | Male
  | Female
  | NonBinary
  | PreferNotToSay

type locationType =
  | Urban
  | Suburban
  | Rural

type occupationCategory =
  | Technology
  | Healthcare
  | Education
  | Finance
  | Creative
  | Service
  | Trades
  | Retired
  | Student

type educationLevel =
  | HighSchool
  | SomeCollege
  | Bachelor
  | Master
  | Doctorate

type interestCategory =
  | Technology
  | Gaming
  | Sports
  | Fitness
  | Cooking
  | Travel
  | Fashion
  | Music
  | Movies
  | Books
  | Art
  | Science
  | Politics
  | News
  | FinanceInterest
  | HomeImprovement
  | Gardening
  | Photography
  | Programming
  | DataScience

type browsingStyle =
  | Focused
  | Explorer
  | Researcher
  | Casual

type activityLevel =
  | Low
  | Medium
  | High
  | VeryHigh

type activityType =
  | Search
  | PageVisit
  | VideoWatch
  | Shopping
  | SocialMedia
  | News
  | Research

type privacyMode =
  | Full
  | Moderate
  | Minimal
  | Disabled

type dayOfWeek =
  | Monday
  | Tuesday
  | Wednesday
  | Thursday
  | Friday
  | Saturday
  | Sunday

type demographics = {
  age: int,
  gender: gender,
  locationType: locationType,
  occupationCategory: occupationCategory,
  educationLevel: educationLevel,
}

type profile = {
  id: string,
  name: string,
  demographics: demographics,
  interests: array<interestCategory>,
  browsingStyle: browsingStyle,
  activityLevel: activityLevel,
  createdAt: float,
}

type browsingActivity = {
  activityType: activityType,
  url: string,
  title: string,
  durationSeconds: int,
  timestamp: float,
  interestCategory: option<interestCategory>,
}

type hourRange = {
  startHour: int,
  endHour: int,
}

type timePattern = {
  dayOfWeek: dayOfWeek,
  activeHours: array<hourRange>,
  activityIntensity: float,
}

type schedule = {
  timePatterns: array<timePattern>,
  timezoneOffset: int,
}

type extensionConfig = {
  enabled: bool,
  currentProfile: option<profile>,
  noiseLevel: float,
  respectSchedule: bool,
  privacyMode: privacyMode,
}

type statistics = {
  mutable totalActivities: int,
  mutable activitiesToday: int,
  mutable profileAgeDays: int,
  mutable lastActivity: option<float>,
  mutable activityByType: Js.Dict.t<int>,
}

type messageType =
  | GetConfig
  | UpdateConfig
  | GenerateProfile
  | GetStatistics
  | GetCurrentProfile
  | SimulateActivity
  | ClearHistory
  | Ping
  | GetPageInfo

type message = {
  @as("type") messageType: string,
  payload: option<Js.Json.t>,
}

module StorageKey = {
  let config = "doubletrack_config"
  let profile = "doubletrack_profile"
  let statistics = "doubletrack_statistics"
  let activityHistory = "doubletrack_activity_history"
}

// Serialization helpers
let genderToString = (g: gender): string =>
  switch g {
  | Male => "Male"
  | Female => "Female"
  | NonBinary => "NonBinary"
  | PreferNotToSay => "PreferNotToSay"
  }

let activityTypeToString = (a: activityType): string =>
  switch a {
  | Search => "Search"
  | PageVisit => "PageVisit"
  | VideoWatch => "VideoWatch"
  | Shopping => "Shopping"
  | SocialMedia => "SocialMedia"
  | News => "News"
  | Research => "Research"
  }

let privacyModeToString = (p: privacyMode): string =>
  switch p {
  | Full => "Full"
  | Moderate => "Moderate"
  | Minimal => "Minimal"
  | Disabled => "Disabled"
  }

let browsingStyleToString = (b: browsingStyle): string =>
  switch b {
  | Focused => "Focused"
  | Explorer => "Explorer"
  | Researcher => "Researcher"
  | Casual => "Casual"
  }

let activityLevelToString = (a: activityLevel): string =>
  switch a {
  | Low => "Low"
  | Medium => "Medium"
  | High => "High"
  | VeryHigh => "VeryHigh"
  }

let interestCategoryToString = (i: interestCategory): string =>
  switch i {
  | Technology => "Technology"
  | Gaming => "Gaming"
  | Sports => "Sports"
  | Fitness => "Fitness"
  | Cooking => "Cooking"
  | Travel => "Travel"
  | Fashion => "Fashion"
  | Music => "Music"
  | Movies => "Movies"
  | Books => "Books"
  | Art => "Art"
  | Science => "Science"
  | Politics => "Politics"
  | News => "News"
  | FinanceInterest => "Finance"
  | HomeImprovement => "HomeImprovement"
  | Gardening => "Gardening"
  | Photography => "Photography"
  | Programming => "Programming"
  | DataScience => "DataScience"
  }
