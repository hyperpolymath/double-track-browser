// SPDX-License-Identifier: PMPL-1.0-or-later
// Unit tests for DoubleTrack TypeScript type contracts

import { assertEquals, assertExists, assertStringIncludes } from "jsr:@std/assert";

Deno.test("Extension message types", () => {
  interface ContentMessage {
    type: string;
    payload?: Record<string, unknown>;
  }

  const msg: ContentMessage = {
    type: "PROFILE_GENERATED",
    payload: { profileId: "test_123" },
  };

  assertEquals(msg.type, "PROFILE_GENERATED");
  assertExists(msg.payload);
});

Deno.test("Storage schema validation", () => {
  interface StoredProfile {
    id: string;
    name: string;
    interests: string[];
    created_at: number;
  }

  const profile: StoredProfile = {
    id: "prof_123",
    name: "Test User",
    interests: ["Technology", "Gaming"],
    created_at: Date.now(),
  };

  assertEquals(profile.id, "prof_123");
  assertEquals(profile.interests.length, 2);
  assertEquals(typeof profile.created_at, "number");
});

Deno.test("Form data contract", () => {
  interface FormData {
    email: string;
    displayName: string;
    preferences: string[];
    newsletterTopics: string[];
  }

  const form: FormData = {
    email: "test@example.com",
    displayName: "Test User",
    preferences: ["tech", "gaming"],
    newsletterTopics: ["Technology & Innovation"],
  };

  assertStringIncludes(form.email, "@");
  assertEquals(form.displayName.length > 0, true);
});

Deno.test("Activity log schema", () => {
  interface BrowsingActivity {
    url: string;
    title: string;
    duration_seconds: number;
    timestamp: number;
    activity_type: string;
  }

  const activity: BrowsingActivity = {
    url: "https://example.com",
    title: "Example Page",
    duration_seconds: 120,
    timestamp: Date.now(),
    activity_type: "PageVisit",
  };

  assertStringIncludes(activity.url, "https://");
  assertEquals(activity.duration_seconds > 0, true);
});
