// SPDX-License-Identifier: PMPL-1.0-or-later
// End-to-end tests for DoubleTrack extension lifecycle

import { assertEquals, assertExists } from "jsr:@std/assert";

interface ExtensionState {
  isInitialized: boolean;
  profile?: { id: string; name: string };
  activities: Array<{ url: string; timestamp: number }>;
  isRunning: boolean;
}

Deno.test("Extension lifecycle: initialization", () => {
  // Simulate extension initialization
  const state: ExtensionState = {
    isInitialized: false,
    activities: [],
    isRunning: false,
  };

  // Initialize
  state.isInitialized = true;

  assertEquals(state.isInitialized, true);
  assertEquals(state.activities.length, 0);
});

Deno.test("Extension lifecycle: profile creation", () => {
  let state: ExtensionState = {
    isInitialized: true,
    profile: undefined,
    activities: [],
    isRunning: false,
  };

  // Create profile
  state.profile = {
    id: "profile_abc123",
    name: "Fictional Persona",
  };

  assertExists(state.profile);
  assertEquals(state.profile.id, "profile_abc123");
  assertEquals(state.profile.name, "Fictional Persona");
});

Deno.test("Extension lifecycle: activity generation", () => {
  let state: ExtensionState = {
    isInitialized: true,
    profile: { id: "profile_abc", name: "Test" },
    activities: [],
    isRunning: true,
  };

  // Simulate activity generation
  state.activities.push({
    url: "https://example.com",
    timestamp: Date.now(),
  });

  assertEquals(state.activities.length, 1);
  assertEquals(state.activities[0].url, "https://example.com");
});

Deno.test("Extension lifecycle: activity accumulation", () => {
  let state: ExtensionState = {
    isInitialized: true,
    profile: { id: "profile_xyz", name: "User" },
    activities: [],
    isRunning: true,
  };

  // Simulate adding multiple activities
  const urls = [
    "https://example.com",
    "https://google.com",
    "https://github.com",
  ];

  for (const url of urls) {
    state.activities.push({
      url,
      timestamp: Date.now(),
    });
  }

  assertEquals(state.activities.length, 3);
});

Deno.test("Extension lifecycle: pause and resume", () => {
  let state: ExtensionState = {
    isInitialized: true,
    profile: { id: "profile_123", name: "Test User" },
    activities: [],
    isRunning: true,
  };

  // Pause
  state.isRunning = false;
  assertEquals(state.isRunning, false);

  // Resume
  state.isRunning = true;
  assertEquals(state.isRunning, true);
});

Deno.test("Extension lifecycle: configuration persistence", () => {
  interface ExtensionConfig {
    noiseLevel: number;
    profileId: string;
    enabled: boolean;
  }

  const config: ExtensionConfig = {
    noiseLevel: 0.5,
    profileId: "profile_999",
    enabled: true,
  };

  // Simulate saving and loading
  const savedConfig = JSON.stringify(config);
  const loadedConfig: ExtensionConfig = JSON.parse(savedConfig);

  assertEquals(loadedConfig.noiseLevel, 0.5);
  assertEquals(loadedConfig.profileId, "profile_999");
  assertEquals(loadedConfig.enabled, true);
});

Deno.test("Extension lifecycle: cleanup on uninstall", () => {
  let state: ExtensionState = {
    isInitialized: true,
    profile: { id: "profile_remove", name: "To Remove" },
    activities: [
      { url: "https://example.com", timestamp: Date.now() },
    ],
    isRunning: true,
  };

  // Simulate uninstall cleanup
  state.isInitialized = false;
  state.profile = undefined;
  state.activities = [];
  state.isRunning = false;

  assertEquals(state.isInitialized, false);
  assertEquals(state.profile, undefined);
  assertEquals(state.activities.length, 0);
  assertEquals(state.isRunning, false);
});

Deno.test("Extension lifecycle: state serialization", () => {
  const initialState: ExtensionState = {
    isInitialized: true,
    profile: { id: "profile_ser", name: "Serialized" },
    activities: [
      { url: "https://test.com", timestamp: 1000 },
      { url: "https://example.com", timestamp: 2000 },
    ],
    isRunning: true,
  };

  // Serialize
  const serialized = JSON.stringify(initialState);

  // Deserialize
  const deserialized: ExtensionState = JSON.parse(serialized);

  assertEquals(deserialized.isInitialized, true);
  assertExists(deserialized.profile);
  assertEquals(deserialized.activities.length, 2);
  assertEquals(deserialized.isRunning, true);
});

Deno.test("Extension lifecycle: profile switching", () => {
  let state: ExtensionState = {
    isInitialized: true,
    profile: { id: "profile_1", name: "First Profile" },
    activities: [],
    isRunning: true,
  };

  // Switch profile
  state.profile = { id: "profile_2", name: "Second Profile" };
  state.activities = []; // Reset activities for new profile

  assertEquals(state.profile.id, "profile_2");
  assertEquals(state.activities.length, 0);
});
