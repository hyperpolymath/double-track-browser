<!--
SPDX-License-Identifier: MPL-2.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# Development Guide

This guide covers setting up and developing DoubleTrack Browser.

## Prerequisites

- **Node.js** (v18 or higher)
- **npm** or **yarn**
- **Rust** (latest stable)
- **wasm-pack** for compiling Rust to WebAssembly

### Installing Rust and wasm-pack

```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install wasm-pack
curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
```

## Project Structure

```
double-track-browser/
├── rust_core/              # Rust/WASM core logic
│   ├── src/
│   │   ├── lib.rs         # Main WASM bindings
│   │   ├── profile.rs     # Profile generation
│   │   ├── activity.rs    # Activity simulation
│   │   ├── interests.rs   # URL generation
│   │   └── schedule.rs    # Scheduling logic
│   └── Cargo.toml
├── src/                    # TypeScript extension
│   ├── background/         # Service worker
│   ├── popup/              # Popup UI
│   ├── options/            # Options page
│   ├── content/            # Content scripts
│   ├── types/              # Type definitions
│   ├── utils/              # Utility functions
│   └── manifest.json
├── dist/                   # Build output (gitignored)
├── icons/                  # Extension icons
└── package.json
```

## Initial Setup

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/double-track-browser.git
cd double-track-browser

# 2. Install Node dependencies
npm install

# 3. Build the Rust core
cd rust_core
wasm-pack build --target web
cd ..

# 4. Build the extension
npm run build
```

## Development Workflow

### Building

```bash
# Full build (Rust + TypeScript)
npm run build

# Build Rust core only
npm run build:rust

# Build extension only (assumes Rust already built)
npm run build:extension

# Development mode with watch
npm run dev
```

### Testing

```bash
# Run Rust tests
npm run test:rust

# Run TypeScript tests
npm run test:ts

# Run all tests
npm test

# Type checking
npm run type-check

# Linting
npm run lint
```

### Loading the Extension

#### Chrome/Chromium

1. Open `chrome://extensions/`
2. Enable "Developer mode" (top right)
3. Click "Load unpacked"
4. Select the `dist/` directory

#### Firefox

1. Open `about:debugging#/runtime/this-firefox`
2. Click "Load Temporary Add-on"
3. Select any file in the `dist/` directory (e.g., `manifest.json`)

## Development Tips

### Debugging

**Background Service Worker:**
- Chrome: `chrome://extensions/` → Click "service worker" link
- Firefox: `about:debugging` → Inspect extension

**Popup:**
- Right-click popup → "Inspect"

**Options Page:**
- Open options, right-click → "Inspect"

**Content Scripts:**
- Use browser DevTools console on any page
- Filter console by "DoubleTrack"

### Hot Reloading

The `npm run dev` command watches for file changes, but you'll need to:
1. Reload the extension in `chrome://extensions/`
2. Or use an auto-reload extension like "Extension Reloader"

### Rust Development

When modifying Rust code:

```bash
cd rust_core

# Check code without building
cargo check

# Run tests
cargo test

# Build and check wasm output
wasm-pack build --target web

# Optimize for size (production)
wasm-pack build --target web --release
```

### TypeScript Development

TypeScript files are in `src/`. Key files:

- `background/index.ts` - Main service worker logic
- `utils/storage.ts` - Data persistence
- `utils/wasm.ts` - Rust/WASM interface
- `types/index.ts` - Type definitions

### Working with WASM

The Rust core is compiled to WASM and loaded by TypeScript:

1. Rust exports functions via `#[wasm_bindgen]`
2. TypeScript imports via `utils/wasm.ts`
3. Data is serialized/deserialized with `serde-wasm-bindgen`

Currently using mock implementations in `wasm.ts` - replace with actual WASM calls once compiled.

## Common Issues

### WASM Module Not Found

**Problem:** Extension can't find WASM files

**Solution:**
- Ensure `npm run build:rust` completed successfully
- Check `dist/` contains `.wasm` files
- Verify webpack copied files correctly

### Service Worker Not Updating

**Problem:** Changes not reflected after reload

**Solution:**
- Chrome: Click "service worker" link to open DevTools
- Use "Update" button in extensions page
- Clear storage: DevTools → Application → Clear storage

### Type Errors

**Problem:** TypeScript errors in editor

**Solution:**
```bash
npm run type-check
npm install  # Ensure all types are installed
```

### Build Failures

**Problem:** Webpack or Rust build fails

**Solution:**
- Check Node.js version: `node --version` (should be v18+)
- Check Rust version: `rustc --version`
- Clear builds: `npm run clean && npm run build`
- Delete `node_modules` and reinstall: `rm -rf node_modules && npm install`

## Performance Optimization

### Rust

- Use `--release` flag for production builds
- Profile with `cargo flamegraph` (install with `cargo install flamegraph`)
- Minimize allocations in hot paths
- Use `SmallRng` instead of full RNG for speed

### TypeScript

- Lazy load WASM module
- Debounce frequent operations
- Use `chrome.alarms` instead of `setInterval`
- Batch storage operations

### Extension Size

Current optimizations:
- Rust compiled with `opt-level = "z"` (optimize for size)
- LTO enabled for smaller binaries
- Dead code elimination via tree-shaking

## Architecture Decisions

### Why Rust + TypeScript?

- **Rust**: Memory safety, performance, complex logic
- **TypeScript**: Browser API integration, UI, async operations
- **WASM**: Bridge between them

### Storage Design

- Uses `chrome.storage.local` for persistence
- Profile data stored separately from activity history
- Statistics updated incrementally
- Activity history capped at 1000 entries

### Activity Simulation

- Poisson distribution for realistic timing
- Profile-based URL generation
- Schedule-aware execution
- Configurable noise levels

## Contributing

See `CONTRIBUTING.md` for contribution guidelines.

### Code Style

**Rust:**
- Follow Rust standard style (`rustfmt`)
- Document public APIs
- Write tests for new features

**TypeScript:**
- Use ESLint configuration
- Prefer `async/await` over callbacks
- Type everything (no `any`)

## Release Process

1. Update version in `package.json` and `Cargo.toml`
2. Update `CHANGELOG.md`
3. Run full test suite
4. Build production version
5. Test loaded extension thoroughly
6. Create git tag
7. Build distribution package
8. Submit to Chrome Web Store / Firefox Add-ons

## Resources

- [Manifest V3 Documentation](https://developer.chrome.com/docs/extensions/mv3/)
- [WebAssembly Guide](https://rustwasm.github.io/docs/book/)
- [wasm-pack Documentation](https://rustwasm.github.io/wasm-pack/)
- [Rust WebExtensions Example](https://github.com/rustwasm/wasm-bindgen)

## Getting Help

- Check existing issues on GitHub
- Read CLAUDE.md for AI assistant context
- Review inline code comments
- Consult browser extension documentation
