# CLAUDE.md - Development Guide for DoubleTrack Browser

This document provides context for AI assistants working on the DoubleTrack Browser project.

## Project Overview

DoubleTrack Browser is an experimental browser extension that creates a fictional digital presence alongside a user's real browsing patterns. Instead of hiding data, it generates believable but fictional browsing behavior to obscure real patterns from tracking systems.

**Core Philosophy**: Visibility as camouflage in the age of surveillance capitalism.

## Architecture

### Technology Stack

- **Rust Core** (`rust_core/`): Profile generation and activity simulation engine
  - Compiled to WebAssembly for browser integration
  - Provides memory-safe handling of sensitive data
  - Implements the core logic for identity generation and behavior simulation

- **ReScript** (`src/`): Browser API integration and UI
  - Type-safe functional language that compiles to JavaScript
  - Handles WebExtensions API interactions
  - Manages background processes and user interface

- **Deno**: Runtime and build tooling
  - Modern JavaScript/TypeScript runtime
  - Used for build scripts and development tooling
  - No npm/node_modules required

- **WebAssembly**: Bridge between Rust and ReScript
  - Compiled using `wasm-pack`
  - Enables high-performance Rust code to run in the browser

### Key Components

1. **Profile Generator**: Creates consistent, believable alternative browsing personas
2. **Activity Simulator**: Generates background browsing behavior
3. **Browser Integration**: Hooks into WebExtensions API for seamless operation
4. **Configuration System**: Allows users to adjust noise levels and behavior patterns

## Project Structure

```
double-track-browser/
├── rust_core/           # Rust/WASM core logic
│   └── (build with wasm-pack)
├── src/                 # ReScript source
│   ├── background/      # Background service worker
│   ├── bindings/        # Chrome/DOM bindings
│   ├── content/         # Content script
│   ├── dashboard/       # Analytics dashboard
│   ├── options/         # Options page
│   ├── popup/           # Extension popup
│   ├── types/           # Type definitions
│   └── utils/           # Storage and WASM utilities
├── scripts/             # Deno build scripts
├── dist/                # Built extension (gitignored)
├── rescript.json        # ReScript configuration
├── deno.json            # Deno configuration
├── justfile             # Task runner recipes
├── Mustfile.epx         # Deployment manifest
└── CLAUDE.md            # This file
```

## Development Setup

### Prerequisites

- Deno (v2.0+)
- Rust toolchain
- `wasm-pack` for building Rust to WebAssembly
- `just` task runner (optional but recommended)

### Initial Setup

```bash
# Check dependencies
just install

# Build everything
just build

# Or without just:
deno task build
```

### Loading the Extension

Load from the `dist/` directory into your browser's extension developer mode.

## Key Considerations

### Language Policy (Hyperpolymath Standard)

This project follows the Hyperpolymath language policy. See `.claude/CLAUDE.md` for the complete policy.

**Key rules:**
- Use **ReScript** instead of TypeScript
- Use **Deno** instead of npm/node
- Use **Rust** for performance-critical code
- Use **justfile** instead of Makefile

### Privacy and Security

- This project deals with sensitive browsing data
- The Rust core is designed to maintain separation between real and fictional identities
- All real user data must remain protected and never mixed with simulated data
- Code changes should maintain memory safety guarantees

### Behavior Simulation

- Generated profiles must be consistent and believable
- Simulated browsing should not interfere with real user activity
- Background processes should be resource-efficient

### Browser Compatibility

- Target modern browsers supporting WebExtensions API
- Consider Firefox and Chrome/Chromium differences
- Ensure WASM compatibility across target browsers

## Common Development Tasks

### Building the Project

```bash
# Full build
just build

# Development mode (watch)
just dev

# Build components individually
just build-rust
just build-rescript
just build-extension
```

### Testing

```bash
# All tests
just test

# Rust tests only
just test-rust

# Deno tests only
just test-deno
```

### Linting and Formatting

```bash
# Run all linters
just lint

# Auto-fix formatting
just fix
```

### Adding Features

1. **Profile Generation**: Modify Rust core in `rust_core/`
2. **UI Components**: Update ReScript in `src/`
3. **Browser Integration**: Work with Chrome bindings in `src/bindings/`
4. **Configuration**: Update both UI and core logic for new parameters

## Code Quality

### Rust Code
- Follow Rust idioms and ownership patterns
- Maintain memory safety
- Document public APIs
- Write tests for core logic

### ReScript Code
- Use proper type annotations
- Leverage pattern matching
- Handle async operations with proper error handling
- Document complex interactions

## Important Notes

### Experimental Nature

This is experimental software exploring unconventional privacy approaches. Code changes should:
- Consider potential unintended consequences
- Maintain security boundaries
- Be well-documented for review
- Include warnings for risky operations

### Performance

- Background activity must be lightweight
- WASM calls should be optimized
- Avoid blocking main thread operations
- Monitor memory usage

### Ethics and Responsibility

- This tool is designed for personal privacy protection
- Code should not enable malicious uses
- Features should respect website terms of service
- Document any potentially concerning capabilities

## Useful Commands

```bash
# Check dependencies
just install

# Build everything
just build

# Run tests
just test

# Lint code
just lint

# Clean build artifacts
just clean

# Package for distribution
just package

# View all available commands
just --list
```

## Contributing Guidelines

See `CONTRIBUTING.md` for detailed contribution guidelines.

When making changes:
1. Test thoroughly with the extension loaded
2. Verify no real user data leakage
3. Check resource usage impact
4. Document new configuration options
5. Update this file if architecture changes

## License

MIT License OR Palimpsest-0.8 - See LICENSE files

## Getting Help

- Review README.adoc for user-facing documentation
- Check inline code comments for implementation details
- Refer to Rust and WebExtensions documentation for platform-specific questions

---

*Last updated: 2025-12-26*
