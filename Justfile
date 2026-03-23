# SPDX-License-Identifier: MIT OR Palimpsest-0.8
# justfile - Modern task runner for DoubleTrack Browser
# https://github.com/casey/just
#
# Install just: cargo install just
# List recipes: just --list
# Run a recipe: just <recipe-name>

# Default recipe (runs when you type `just`)
default:
    @just --list

# === BUILD RECIPES ===

# Build everything (Rust + ReScript + Extension)
build: build-rust build-rescript build-extension
    @echo "✅ Build complete! Load dist/ folder in chrome://extensions/"

# Build only Rust/WASM core
build-rust:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🦀 Building Rust core..."
    cd rust_core
    wasm-pack build --target web --release
    echo "✅ Rust core built"

# Build ReScript code
build-rescript:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📦 Building ReScript..."
    npx rescript build
    echo "✅ ReScript built"

# Build the extension bundle
build-extension:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📦 Building extension..."
    deno run --allow-read --allow-write scripts/build.ts
    echo "✅ Extension built"

# Clean build artifacts
clean:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🧹 Cleaning build artifacts..."
    rm -rf dist/
    rm -rf rust_core/pkg/
    rm -rf rust_core/target/
    rm -rf lib/
    rm -rf .cache/
    echo "✅ Clean complete"

# === INSTALL RECIPES ===

# Install all dependencies
install: check-deno check-rust
    @echo "✅ Dependencies checked"

# Check Deno is installed
check-deno:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🦕 Checking Deno..."
    if ! command -v deno &> /dev/null; then
        echo "❌ Deno not found. Install from https://deno.land/"
        exit 1
    fi
    echo "✅ Deno ready ($(deno --version | head -1))"

# Check Rust toolchain
check-rust:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🦀 Checking Rust toolchain..."
    if ! command -v cargo &> /dev/null; then
        echo "❌ Rust not found. Install from https://rustup.rs/"
        exit 1
    fi
    if ! command -v wasm-pack &> /dev/null; then
        echo "❌ wasm-pack not found. Install: cargo install wasm-pack"
        exit 1
    fi
    echo "✅ Rust toolchain ready ($(rustc --version))"

# === TEST RECIPES ===

# Run all tests
test: test-rust test-deno
    @echo "✅ All tests passed!"

# Run Rust tests
test-rust:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🦀 Running Rust tests..."
    cd rust_core
    cargo test --release
    echo "✅ Rust tests passed"

# Run Deno tests
test-deno:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🦕 Running Deno tests..."
    deno test
    echo "✅ Deno tests passed"

# === LINT & FORMAT RECIPES ===

# Run all linters
lint: lint-rust lint-deno lint-rescript
    @echo "✅ Linting complete"

# Lint Rust code
lint-rust:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🦀 Linting Rust..."
    cd rust_core
    cargo clippy -- -D warnings
    cargo fmt -- --check
    echo "✅ Rust linting passed"

# Lint with Deno
lint-deno:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🦕 Linting with Deno..."
    deno lint
    echo "✅ Deno linting passed"

# Check ReScript
lint-rescript:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📦 Checking ReScript..."
    npx rescript build 2>&1 | head -50
    echo "✅ ReScript check passed"

# Auto-fix formatting
fix: fix-rust fix-deno
    @echo "✅ Auto-fixes applied"

# Fix Rust formatting
fix-rust:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🦀 Formatting Rust..."
    cd rust_core
    cargo fmt
    echo "✅ Rust formatted"

# Fix Deno formatting
fix-deno:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🦕 Formatting with Deno..."
    deno fmt
    echo "✅ Deno formatted"

# === DEVELOPMENT RECIPES ===

# Start development mode (watch for changes)
dev:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🔄 Starting development mode..."
    echo "Press Ctrl+C to stop"
    npx rescript build -w

# Rebuild and reload (for quick iteration)
reload: build
    @echo "🔄 Extension rebuilt - reload in browser"

# === VALIDATION RECIPES ===

# Validate RSR compliance
validate-rsr:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📋 Checking RSR compliance..."
    echo ""
    echo "Documentation:"
    [[ -f README.adoc ]] && echo "  ✅ README.adoc" || echo "  ❌ README.adoc"
    [[ -f LICENSE.txt ]] && echo "  ✅ LICENSE.txt" || echo "  ❌ LICENSE.txt"
    [[ -f SECURITY.md ]] && echo "  ✅ SECURITY.md" || echo "  ❌ SECURITY.md"
    [[ -f CODE_OF_CONDUCT.md ]] && echo "  ✅ CODE_OF_CONDUCT.md" || echo "  ❌ CODE_OF_CONDUCT.md"
    [[ -f CONTRIBUTING.md ]] && echo "  ✅ CONTRIBUTING.md" || echo "  ❌ CONTRIBUTING.md"
    [[ -f MAINTAINERS.md ]] && echo "  ✅ MAINTAINERS.md" || echo "  ❌ MAINTAINERS.md"
    [[ -f CHANGELOG.md ]] && echo "  ✅ CHANGELOG.md" || echo "  ❌ CHANGELOG.md"
    echo ""
    echo "Build System:"
    [[ -f deno.json ]] && echo "  ✅ deno.json" || echo "  ❌ deno.json"
    [[ -f rescript.json ]] && echo "  ✅ rescript.json" || echo "  ❌ rescript.json"
    [[ -f justfile ]] && echo "  ✅ justfile" || echo "  ❌ justfile"
    [[ -f Mustfile.epx ]] && echo "  ✅ Mustfile.epx" || echo "  ❌ Mustfile.epx"
    echo ""
    echo "Policy Enforcement:"
    [[ ! -f package.json ]] && echo "  ✅ No package.json (Deno enforced)" || echo "  ❌ package.json exists"
    [[ ! -f tsconfig.json ]] && echo "  ✅ No tsconfig.json (ReScript enforced)" || echo "  ❌ tsconfig.json exists"
    echo ""
    echo "See RSR_COMPLIANCE_AUDIT.md for full audit"

# Check for security vulnerabilities
audit:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🔒 Auditing dependencies..."
    cd rust_core && cargo audit || true
    echo "✅ Audit complete"

# === RELEASE RECIPES ===

# Prepare for release (run all checks)
pre-release: clean install build test lint audit validate-rsr
    @echo "✅ Pre-release checks passed!"

# Build optimized production bundle
build-release:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🚀 Building production release..."
    just clean
    just build-rust
    just build-rescript
    just build-extension
    echo "✅ Production build complete"

# Package extension for distribution
package: build-release
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📦 Packaging extension..."
    cd dist
    zip -r ../doubletrack-browser.zip *
    cd ..
    echo "✅ Package created: doubletrack-browser.zip"

# === DOCUMENTATION RECIPES ===

# Generate documentation
docs:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📚 Generating documentation..."
    cd rust_core && cargo doc --no-deps --open
    echo "✅ Rust docs generated"

# === UTILITY RECIPES ===

# Show project statistics
stats:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📊 Project Statistics"
    echo ""
    echo "Lines of Code:"
    echo "  Rust:      $(find rust_core/src -name '*.rs' | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}' || echo '0')"
    echo "  ReScript:  $(find src -name '*.res' | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}' || echo '0')"
    echo ""
    echo "Files:"
    echo "  Total:     $(find . -type f ! -path './.git/*' ! -path './node_modules/*' ! -path './target/*' ! -path './dist/*' | wc -l)"
    echo "  Rust:      $(find rust_core/src -name '*.rs' 2>/dev/null | wc -l || echo '0')"
    echo "  ReScript:  $(find src -name '*.res' 2>/dev/null | wc -l || echo '0')"
    echo ""
    echo "Git:"
    echo "  Commits:   $(git rev-list --count HEAD 2>/dev/null || echo 'N/A')"
    echo "  Branch:    $(git branch --show-current 2>/dev/null || echo 'N/A')"

# === CI/CD RECIPES ===

# Run full CI pipeline locally
ci: install build test lint audit
    @echo "✅ CI pipeline complete!"

# Check if ready for commit
pre-commit: lint test
    @echo "✅ Ready to commit!"

# === HELP RECIPES ===

# Show detailed help
help:
    @echo "DoubleTrack Browser - Just Task Runner"
    @echo ""
    @echo "Common workflows:"
    @echo "  just install          # Check dependencies"
    @echo "  just build            # Build everything"
    @echo "  just test             # Run all tests"
    @echo "  just dev              # Start development mode"
    @echo "  just lint             # Run linters"
    @echo "  just pre-release      # Run all checks"
    @echo ""
    @echo "See 'just --list' for all recipes"

# Print version information
version:
    @echo "DoubleTrack Browser v0.1.0"
    @echo "Deno:      $(deno --version | head -1)"
    @echo "Rust:      $(rustc --version)"
    @echo "wasm-pack: $(wasm-pack --version)"
    @echo "Just:      $(just --version)"

# Run panic-attacker pre-commit scan
assail:
    @command -v panic-attack >/dev/null 2>&1 && panic-attack assail . || echo "panic-attack not found — install from https://github.com/hyperpolymath/panic-attacker"
