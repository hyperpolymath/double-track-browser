// SPDX-License-Identifier: MIT OR Palimpsest-0.8
// Build script for DoubleTrack Browser extension
// Uses Deno for file operations

import { copy, ensureDir } from "https://deno.land/std@0.220.1/fs/mod.ts";
import { join } from "https://deno.land/std@0.220.1/path/mod.ts";

const SRC_DIR = "src";
const DIST_DIR = "dist";
const RUST_PKG_DIR = "rust_core/pkg";

async function build() {
  console.log("📦 Building DoubleTrack Browser extension...");

  // Create dist directory
  await ensureDir(DIST_DIR);

  // Copy manifest
  await Deno.copyFile(
    join(SRC_DIR, "manifest.json"),
    join(DIST_DIR, "manifest.json"),
  );
  console.log("  ✓ Copied manifest.json");

  // Copy HTML files
  const htmlFiles = [
    { src: "popup/popup.html", dest: "popup.html" },
    { src: "options/options.html", dest: "options.html" },
    { src: "dashboard/dashboard.html", dest: "dashboard.html" },
  ];

  for (const file of htmlFiles) {
    await Deno.copyFile(
      join(SRC_DIR, file.src),
      join(DIST_DIR, file.dest),
    );
    console.log(`  ✓ Copied ${file.dest}`);
  }

  // Copy CSS files
  const cssFiles = [
    { src: "popup/popup.css", dest: "popup.css" },
    { src: "options/options.css", dest: "options.css" },
    { src: "dashboard/dashboard.css", dest: "dashboard.css" },
  ];

  for (const file of cssFiles) {
    await Deno.copyFile(
      join(SRC_DIR, file.src),
      join(DIST_DIR, file.dest),
    );
    console.log(`  ✓ Copied ${file.dest}`);
  }

  // Copy compiled ReScript JS files
  const jsFiles = [
    { src: "background/Background.res.js", dest: "background.js" },
    { src: "content/Content.res.js", dest: "content.js" },
    { src: "popup/Popup.res.js", dest: "popup.js" },
    { src: "options/Options.res.js", dest: "options.js" },
    { src: "dashboard/Dashboard.res.js", dest: "dashboard.js" },
  ];

  for (const file of jsFiles) {
    try {
      await Deno.copyFile(
        join(SRC_DIR, file.src),
        join(DIST_DIR, file.dest),
      );
      console.log(`  ✓ Copied ${file.dest}`);
    } catch {
      console.log(`  ⚠ ${file.src} not found (build ReScript first)`);
    }
  }

  // Copy WASM if it exists
  try {
    await copy(RUST_PKG_DIR, join(DIST_DIR, "wasm"), { overwrite: true });
    console.log("  ✓ Copied WASM package");
  } catch {
    console.log("  ⚠ WASM package not found (build Rust first)");
  }

  // Copy icons
  await ensureDir(join(DIST_DIR, "icons"));
  try {
    await copy("icons", join(DIST_DIR, "icons"), { overwrite: true });
    console.log("  ✓ Copied icons");
  } catch {
    console.log("  ⚠ Icons directory not found");
  }

  console.log("✅ Build complete! Load dist/ folder in chrome://extensions/");
}

if (import.meta.main) {
  await build();
}
