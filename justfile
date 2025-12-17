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

# Build everything (Rust + TypeScript)
build: build-rust build-extension
    @echo "✅ Build complete! Load dist/ folder in chrome://extensions/"

# Build only Rust/WASM core
build-rust:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🦀 Building Rust core..."
    cd rust_core
    wasm-pack build --target web --release
    echo "✅ Rust core built"

# Build only TypeScript extension
build-extension:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📦 Building TypeScript extension..."
    npm run build:extension
    echo "✅ Extension built"

# Clean build artifacts
clean:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🧹 Cleaning build artifacts..."
    rm -rf dist/
    rm -rf rust_core/pkg/
    rm -rf rust_core/target/
    rm -rf node_modules/.cache/
    echo "✅ Clean complete"

# Clean everything including node_modules
clean-all: clean
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🧹 Deep cleaning..."
    rm -rf node_modules/
    echo "✅ Deep clean complete - run 'just install' to rebuild"

# === INSTALL RECIPES ===

# Install all dependencies
install: install-node check-rust
    @echo "✅ Dependencies installed"

# Install Node.js dependencies
install-node:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📦 Installing npm dependencies..."
    npm install
    echo "✅ npm dependencies installed"

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
test: test-rust test-ts
    @echo "✅ All tests passed!"

# Run Rust tests
test-rust:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🦀 Running Rust tests..."
    cd rust_core
    cargo test --release
    echo "✅ Rust tests passed"

# Run TypeScript tests
test-ts:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📦 Running TypeScript tests..."
    npm test
    echo "✅ TypeScript tests passed"

# Run tests with coverage
test-coverage:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📊 Running tests with coverage..."
    cd rust_core && cargo tarpaulin --out Html
    npm run test -- --coverage
    echo "✅ Coverage reports generated"

# === LINT & FORMAT RECIPES ===

# Run all linters
lint: lint-rust lint-ts
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

# Lint TypeScript code
lint-ts:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📦 Linting TypeScript..."
    npm run lint
    npm run type-check
    echo "✅ TypeScript linting passed"

# Auto-fix linting issues
fix: fix-rust fix-ts
    @echo "✅ Auto-fixes applied"

# Fix Rust formatting
fix-rust:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🦀 Formatting Rust..."
    cd rust_core
    cargo fmt
    cargo fix --allow-dirty --allow-staged
    echo "✅ Rust formatted"

# Fix TypeScript formatting
fix-ts:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📦 Formatting TypeScript..."
    npm run lint -- --fix
    echo "✅ TypeScript formatted"

# === DEVELOPMENT RECIPES ===

# Start development mode (watch for changes)
dev:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🔄 Starting development mode..."
    echo "Press Ctrl+C to stop"
    npm run dev

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
    [[ -f README.adoc || -f README.md ]] && echo "  ✅ README" || echo "  ❌ README"
    [[ -f LICENSE.txt || -f LICENSE ]] && echo "  ✅ LICENSE" || echo "  ❌ LICENSE"
    [[ -f SECURITY.md ]] && echo "  ✅ SECURITY.md" || echo "  ❌ SECURITY.md"
    [[ -f CODE_OF_CONDUCT.md ]] && echo "  ✅ CODE_OF_CONDUCT.md" || echo "  ❌ CODE_OF_CONDUCT.md"
    [[ -f CONTRIBUTING.md ]] && echo "  ✅ CONTRIBUTING.md" || echo "  ❌ CONTRIBUTING.md"
    [[ -f MAINTAINERS.md ]] && echo "  ✅ MAINTAINERS.md" || echo "  ❌ MAINTAINERS.md"
    [[ -f CHANGELOG.md ]] && echo "  ✅ CHANGELOG.md" || echo "  ❌ CHANGELOG.md"
    echo ""
    echo ".well-known:"
    [[ -f .well-known/security.txt ]] && echo "  ✅ security.txt" || echo "  ❌ security.txt"
    [[ -f .well-known/ai.txt ]] && echo "  ✅ ai.txt" || echo "  ❌ ai.txt"
    [[ -f .well-known/humans.txt ]] && echo "  ✅ humans.txt" || echo "  ❌ humans.txt"
    echo ""
    echo "Build System:"
    [[ -f package.json ]] && echo "  ✅ package.json" || echo "  ❌ package.json"
    [[ -f justfile ]] && echo "  ✅ justfile" || echo "  ❌ justfile"
    echo ""
    echo "See RSR_COMPLIANCE_AUDIT.md for full audit"

# Check for security vulnerabilities
audit:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🔒 Auditing dependencies..."
    cd rust_core && cargo audit || true
    npm audit
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
    NODE_ENV=production npm run build
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

# Serve documentation locally
docs-serve:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📚 Serving documentation..."
    cd rust_core/target/doc && python3 -m http.server 8000

# === UTILITY RECIPES ===

# Show project statistics
stats:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "📊 Project Statistics"
    echo ""
    echo "Lines of Code:"
    echo "  Rust:       $(find rust_core/src -name '*.rs' | xargs wc -l | tail -1 | awk '{print $1}')"
    echo "  TypeScript: $(find src -name '*.ts' | xargs wc -l | tail -1 | awk '{print $1}')"
    echo "  Tests:      $(find rust_core/tests src -name '*.test.ts' -o -name '*.rs' | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}' || echo '0')"
    echo ""
    echo "Files:"
    echo "  Total:      $(find . -type f ! -path './node_modules/*' ! -path './target/*' ! -path './dist/*' | wc -l)"
    echo "  Rust:       $(find rust_core/src -name '*.rs' | wc -l)"
    echo "  TypeScript: $(find src -name '*.ts' | wc -l)"
    echo ""
    echo "Git:"
    echo "  Commits:    $(git rev-list --count HEAD 2>/dev/null || echo 'N/A')"
    echo "  Branch:     $(git branch --show-current 2>/dev/null || echo 'N/A')"

# Open repository in browser
open:
    #!/usr/bin/env bash
    set -euo pipefail
    URL=$(git remote get-url origin | sed 's/\.git$//' | sed 's/^git@github.com:/https:\/\/github.com\//')
    echo "🌐 Opening ${URL}"
    open "${URL}" 2>/dev/null || xdg-open "${URL}" 2>/dev/null || echo "Could not open browser"

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
    @echo "  just install          # Install dependencies"
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
    @echo "Node:       $(node --version)"
    @echo "Rust:       $(rustc --version)"
    @echo "wasm-pack:  $(wasm-pack --version)"
    @echo "Just:       $(just --version)"
