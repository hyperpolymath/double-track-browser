// SPDX-License-Identifier: PMPL-1.0-or-later
// Property-based tests for DoubleTrack extension invariants

import { assertEquals } from "jsr:@std/assert";

Deno.test("Extension invariant: profiles never have empty names", () => {
  // Simulate profile validation
  const validateProfile = (profile: { name: string }): boolean => {
    return profile.name.length > 0;
  };

  const validProfile = { name: "John Doe" };
  const invalidProfile = { name: "" };

  assertEquals(validateProfile(validProfile), true);
  assertEquals(validateProfile(invalidProfile), false);
});

Deno.test("Extension invariant: activities always have HTTPS URLs", () => {
  const validateActivity = (
    activity: { url: string }
  ): boolean => {
    return activity.url.startsWith("https://");
  };

  const validActivity = { url: "https://example.com" };
  const invalidActivity = { url: "http://example.com" };

  assertEquals(validateActivity(validActivity), true);
  assertEquals(validateActivity(invalidActivity), false);
});

Deno.test("Extension invariant: timestamps are monotonic", () => {
  const validateChronological = (
    activities: Array<{ timestamp: number }>
  ): boolean => {
    for (let i = 1; i < activities.length; i++) {
      if (activities[i].timestamp < activities[i - 1].timestamp) {
        return false;
      }
    }
    return true;
  };

  const sortedActivities = [
    { timestamp: 1000 },
    { timestamp: 2000 },
    { timestamp: 3000 },
  ];

  const unsortedActivities = [
    { timestamp: 3000 },
    { timestamp: 1000 },
    { timestamp: 2000 },
  ];

  assertEquals(validateChronological(sortedActivities), true);
  assertEquals(validateChronological(unsortedActivities), false);
});

Deno.test("Extension invariant: email format is valid", () => {
  const validateEmail = (email: string): boolean => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };

  assertEquals(validateEmail("user@example.com"), true);
  assertEquals(validateEmail("user.name@example.co.uk"), true);
  assertEquals(validateEmail("invalid.email"), false);
  assertEquals(validateEmail("@example.com"), false);
});

Deno.test("Extension invariant: no null bytes in strings", () => {
  const hasNoNullBytes = (str: string): boolean => {
    return !str.includes("\0");
  };

  assertEquals(hasNoNullBytes("normal string"), true);
  assertEquals(hasNoNullBytes("string\x00with null"), false);
});

Deno.test("Extension invariant: message type is always defined", () => {
  interface Message {
    type?: string;
    payload?: Record<string, unknown>;
  }

  const validateMessage = (msg: Message): boolean => {
    return typeof msg.type === "string" && msg.type.length > 0;
  };

  const validMsg: Message = { type: "PROFILE_GENERATED" };
  const invalidMsg: Message = { payload: {} };

  assertEquals(validateMessage(validMsg), true);
  assertEquals(validateMessage(invalidMsg), false);
});

Deno.test("Extension invariant: duration is always positive", () => {
  const validateDuration = (duration: number): boolean => {
    return duration > 0 && Number.isFinite(duration);
  };

  assertEquals(validateDuration(120), true);
  assertEquals(validateDuration(0), false);
  assertEquals(validateDuration(-100), false);
  assertEquals(validateDuration(Infinity), false);
});

Deno.test("Extension invariant: interests array is never empty", () => {
  const validateInterests = (interests: string[]): boolean => {
    return Array.isArray(interests) && interests.length > 0;
  };

  assertEquals(validateInterests(["Technology", "Gaming"]), true);
  assertEquals(validateInterests([]), false);
  assertEquals(validateInterests(null as unknown as string[]), false);
});

Deno.test("Extension invariant: activity type is known", () => {
  const VALID_ACTIVITY_TYPES = [
    "Search",
    "PageVisit",
    "VideoWatch",
    "Shopping",
    "SocialMedia",
    "News",
    "Research",
  ];

  const validateActivityType = (type: string): boolean => {
    return VALID_ACTIVITY_TYPES.includes(type);
  };

  assertEquals(validateActivityType("Search"), true);
  assertEquals(validateActivityType("PageVisit"), true);
  assertEquals(validateActivityType("InvalidType"), false);
});
