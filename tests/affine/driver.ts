// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Deno test driver for the AffineScript tests in tests/affine/.
//
// Run with:
//   deno test --allow-read --allow-run --allow-env tests/affine/driver.ts
//
// This driver delegates to @hyperpolymath/affinescript-deno-test (sibling
// component in developer-ecosystem/affinescript-ecosystem/). The harness
// discovers every `*_test.affine` under tests/affine/, compiles each via
// `affinescript compile`, loads the WASM through @hyperpolymath/affine-js,
// and wraps every `pub fn test_*() -> Bool` as a Deno.test() case.

import { runAll } from "@hyperpolymath/affinescript-deno-test";

await runAll(new URL("./", import.meta.url).pathname);
