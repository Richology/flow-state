# flow-state

[中文版](README.zh.md)

A Claude Code plugin for discovering your personal flow state patterns using the **Experience Sampling Method (ESM)** — developed by psychologist Mihaly Csikszentmihalyi.

## What It Does

Set 40 reminders per week (5–6 per day). After running `/flow-state:flow-setup` once, your Mac will **automatically pop up a dialog at each scheduled time** — no need to open Claude Code. Fill it in, close it, done in 30 seconds. After 1–2 weeks, run `/flow-state:flow-review` to discover:

1. **Which activities trigger your flow** — what you're doing, where, and with whom
2. **Your peak hours** — when in the day you're most likely to enter flow
3. **How to redesign your schedule** — actionable suggestions based on your actual data

## Installation

```bash
/plugin marketplace add Richology/flow-state
/plugin install flow-state@richology-flow-state
```

## How It Works

`flow-setup` installs a cron job that fires `remind.sh` at your chosen times. The script uses macOS AppleScript to show a native dialog — **no app, no browser, no Claude Code needed** at reminder time.

```
cron → remind.sh → AppleScript dialog → ~/.flow-data/logs.json
```

## ⚠️ Required: macOS Permission Setup

**This step is mandatory — skip it and reminders will silently not appear.**

On macOS Catalina and later, cron requires Full Disk Access permission to run scripts that show dialogs.

**How to grant it:**
1. Open **System Settings → Privacy & Security → Full Disk Access**
2. Click the `+` button
3. Press `Cmd+Shift+G`, type `/usr/sbin/cron`, press Enter
4. Select `cron` and click Open

Do this **before** your first scheduled reminder, otherwise nothing will pop up.

## Skills

### `/flow-state:flow-setup`
Run this first. Tell it your wake/sleep time and it will:
- Calculate 6 evenly distributed reminder times
- Copy `remind.sh` to `~/.flow-data/`
- Install cron jobs automatically

### `/flow-state:flow-log`
Manual logging via Claude Code — useful when you want to log outside of scheduled reminders. Takes ~30 seconds. Records:
- What you're doing
- Where you are and who you're with
- Focus level (1–10)
- Mood (1–10)
- Flow state (yes / partial / no)
- Optional notes

Data is saved to `~/.flow-data/logs.json`.

### `/flow-state:flow-review`
Analyze your accumulated data. Run after collecting 20+ entries (40+ recommended).

```bash
/flow-state:flow-review        # analyze all data
/flow-state:flow-review week   # analyze last 7 days only
```

Shows:
- Activity breakdown by flow rate
- Time-of-day heatmap
- Location and social context analysis
- 3 personalized, actionable recommendations

## Data Storage

All logs are stored locally in `~/.flow-data/logs.json`. Nothing is sent externally.

```json
[
  {
    "timestamp": "2026-04-18T14:32:00",
    "activity": "writing",
    "location": "home",
    "with_whom": "alone",
    "focus": 9,
    "mood": 8,
    "flow": "yes",
    "note": ""
  }
]
```

To stop reminders at any time:
```bash
crontab -l | grep -v remind.sh | crontab -
```

## The Science Behind It

Csikszentmihalyi found that people are notoriously bad at predicting what makes them happy or focused. ESM bypasses this by capturing real-time snapshots — you record how you actually feel in the moment, not how you think you feel in retrospect.

40 samples per week gives enough statistical signal to identify genuine patterns within 1–2 weeks.

## Requirements

- macOS (AppleScript-based popups)
- Python 3 (pre-installed on macOS)
- Claude Code (for setup and review only)

## License

MIT
