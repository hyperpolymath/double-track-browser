# Quick Start Guide

Get up and running with DoubleTrack Browser in 5 minutes.

## Installation

### Step 1: Install Prerequisites

You need:
- **Deno** (v2.0+): [Download here](https://deno.land/)
- **Rust**: Run `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
- **wasm-pack**: Run `cargo install wasm-pack`
- **just** (optional): Run `cargo install just`

### Step 2: Build the Extension

```bash
# Clone the repository
git clone https://github.com/hyperpolymath/double-track-browser.git
cd double-track-browser

# Check dependencies
just install

# Build everything (Rust + ReScript + Extension)
just build

# Or without just:
deno task build
```

### Step 3: Load in Browser

**Chrome/Chromium/Edge:**
1. Open `chrome://extensions/`
2. Enable "Developer mode" (toggle in top-right)
3. Click "Load unpacked"
4. Select the `dist/` folder

**Firefox:**
1. Open `about:debugging#/runtime/this-firefox`
2. Click "Load Temporary Add-on"
3. Navigate to `dist/` and select `manifest.json`

## First-Time Setup

### 1. Generate Your Profile

After installing:
1. Click the DoubleTrack icon in your toolbar
2. Click **"Generate New Profile"**
3. Review your fictional persona details

Your profile includes:
- A fictional name and demographics
- Interest categories
- Browsing style and activity level
- Realistic schedule based on occupation

### 2. Configure Settings

Click the **gear icon** or "Advanced Settings":

- **Noise Level**: How active your fictional persona is (start with 50%)
- **Respect Schedule**: Follow realistic activity times (recommended: ON)
- **Privacy Mode**: Choose between Full, Moderate, Minimal, or Disabled

### 3. Enable DoubleTrack

Back in the popup, click the **"Enable"** button.

✅ You're now generating fictional browsing activity!

## Understanding Your Dashboard

Open Settings → **"View Analytics Dashboard"** to see:

- **Activity Timeline**: 7-day history of simulated activities
- **Type Distribution**: Breakdown by activity category (searches, videos, shopping, etc.)
- **Hourly Pattern**: When your profile is most active
- **Interest Bars**: Which topics get the most attention
- **Heatmap**: Day × hour activity density visualization
- **Recent Activities**: Latest simulated browsing

## How It Works

1. **Profile Generation**: Creates a consistent fictional persona
2. **Activity Simulation**: Generates realistic browsing patterns based on your profile
3. **Scheduled Execution**: Activities occur during appropriate hours
4. **Privacy Separation**: Fictional data is completely separate from your real browsing

## Privacy & Safety

⚠️ **Important Notes:**

- **Experimental**: This is experimental privacy software
- **Local Only**: All data stays on your device
- **No Real Data Mixed**: Your actual browsing is never affected
- **Resource Usage**: Background simulation uses CPU/memory
- **Disable Anytime**: Simply toggle off in the popup

## Customization

### Adjusting Activity Level

- **Low** (10-30/day): Minimal noise, light resource usage
- **Medium** (30-70/day): Balanced approach (recommended)
- **High** (70-150/day): Heavy noise, more resource usage
- **Very High** (150+/day): Maximum obfuscation

### Noise Level Slider

Controls the frequency of simulated activities within your profile's base level:
- **0%**: Minimum activity
- **50%**: Standard (recommended)
- **100%**: Maximum activity

### Schedule Adherence

When **ON**: Activities only during realistic hours for your profile
When **OFF**: Activities can occur 24/7

## Common Questions

**Q: Will this open actual browser tabs?**
A: By default, NO. Activity is only logged. You can modify the background worker to actually open tabs, but this is disabled for safety.

**Q: How much data does it store?**
A: Up to 1,000 recent activities. Older ones are automatically removed.

**Q: Can I have multiple profiles?**
A: Currently, one profile at a time. Generate a new one to replace the current.

**Q: Does this send data anywhere?**
A: NO. Everything stays local on your device.

**Q: Will this slow down my browser?**
A: Minimal impact at default settings. Reduce noise level if you notice slowdown.

## Next Steps

- Review the [full README](README.adoc) for detailed information
- Check [DEVELOPMENT.md](DEVELOPMENT.md) if you want to contribute
- Read [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
- Explore the Analytics Dashboard to understand your profile's patterns

## Troubleshooting

**Extension not loading?**
- Ensure all build steps completed without errors
- Check that `dist/` folder exists and contains files
- Try rebuilding: `just clean && just build`

**No activities generating?**
- Ensure extension is enabled (check popup)
- Verify a profile exists
- Check browser console for errors

**Want to start fresh?**
- Settings → "Clear All History"
- Generate a new profile
- Re-enable the extension

## Support

- **Issues**: [GitHub Issues](https://github.com/hyperpolymath/double-track-browser/issues)
- **Documentation**: See docs/ folder
- **Community**: [Discussions](https://github.com/hyperpolymath/double-track-browser/discussions)

---

**Welcome to DoubleTrack Browser!** 🎭

*Privacy through deliberate visibility in the age of surveillance capitalism.*
