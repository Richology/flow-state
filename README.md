# flow-state

[中文版](README.zh.md)

> This tool started as my own problem. And after nearly three years of career coaching, I've heard the same question more times than I can count: **"How do I find my flow?"**

---

## Why I Built This

I've been a career coach for almost three years. Most of my clients fall into two groups.

The first group are professionals at a crossroads — should I quit? Should I change careers? Should I start my own business? Underneath every one of those questions is usually the same thing: they rarely feel genuinely engaged in what they're doing.

The second group are young people, roughly 15 to 20 years old. They feel out of place in traditional education, but the AI era has given them a new outlet — they're turning their ideas into real things, even starting to think about building businesses. Their biggest question is: **What do I actually want to do? What am I capable of? What would let me create real value — and make a living doing it?**

There's a third group too, a smaller one: people who've just started their own ventures. Suddenly they have all the time in the world, but can't seem to focus. Can't get started on the things that actually matter.

**That last one describes me.**

When I was still working a regular job, I noticed I could only ever get into a real flow state late at night. Creative thinking, deep work — I couldn't do any of it during the day. Meetings, messages, constant interruptions. I'd stay up late to finish the things that mattered, sleep poorly, wake up drained, and repeat. A slow, exhausting cycle.

Last year I left that job and started my own business. I thought having freedom over my time would fix everything. It didn't.

Working alone at home or in an office, the distractions were somehow worse — my phone, my computer, messages from everywhere. I tried forcing myself into a fixed "work schedule," like I was still employed. I sat there looking productive. But I wasn't really present. The projects barely moved.

In coaching, I've noticed people get stuck in three specific places:

1. **They don't really understand what flow is, or why it matters** — they've heard the word, but it stays abstract
2. **They don't know how to find their own flow** — because flow is personal. What works for someone else won't necessarily work for you
3. **Even when they know the method, they can't stick with it** — this is the most common failure point, because most approaches are too vague to actually use

This tool is built around those three problems.

**It won't tell you what flow is. It will help you find yours — from your own real life, in your own words.**

Whether you're figuring out your next career move, pushing through an important project, or trying to find your rhythm as a new founder — the things worth doing require you to be genuinely present to do them well.

---

## What It Does

Set 40 reminders per week (5–6 per day). After running `/flow-state:flow-setup` once, your Mac will **automatically pop up a dialog at each scheduled time** — no need to open Claude Code. Fill it in, close it, done in 30 seconds. When you're away from your computer, jot a quick note on your phone and import it later with `/flow-state:flow-import`. After 1–2 weeks, run `/flow-state:flow-review` to discover:

1. **Which activities trigger your flow** — what you're doing, where, and with whom
2. **Your peak hours** — when in the day you're most likely to enter flow
3. **How to redesign your schedule** — actionable suggestions based on your actual data

**This works for everyone. Run it again every 3–6 months** — as your life changes, so does where your flow comes from.

---

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

## Two Ways to Log

This tool is designed around a simple truth: **you're not always at your computer.**

Flow can happen anywhere — in a conversation at a café, on a run, while cooking, while doing nothing in particular. If you only capture your state when you're at your desk, you'll miss some of the most important data points, and the analysis will have blind spots.

So there are two paths:

**On your computer (automatic)**
Cron fires at scheduled times, a dialog pops up, you fill it in and close it in 30 seconds.

**On your phone (freeform notes)**
When you're away from your computer, jot a quick note anywhere — Notes app, WeChat, wherever. Something like:
- "afternoon at café writing, really in the zone"
- "3pm meeting at office, so bored"
- "just finished a run, alone, head feels clear, haven't felt like this in a while"

When you're back at your computer, paste those notes into `/flow-state:flow-import`. Claude parses them into structured data and saves them alongside your other records.

**Building the habit gradually**

You don't need to write a lot at first. Even a single sentence about what you were doing and how it felt is enough to start. After each import, the tool gives you one specific tip for next time — just one thing, not a checklist. Over time, your notes naturally get more complete without it feeling like work.

Consistency matters more than completeness.

---

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

### `/flow-state:flow-import`
Paste freeform notes from your phone — one sentence, multiple entries at once, any format. Nothing will be rejected for being incomplete.

Claude extracts what it can: time, activity, location, company, focus level, mood, and flow state. Missing fields are left blank. It shows you the parsed result and only asks about the things it's genuinely unsure about.

After each import, you get one specific tip for next time, for example:
> "Next time, add roughly what time it was — like 'around 3pm at the café writing' — and I can start mapping which hours are your best."

One tip per session. That's it. The habit builds on its own.

### `/flow-state:flow-uninstall`
Remove all scheduled reminders installed by `flow-setup`. Will ask whether to keep or delete your log data.

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
/flow-state:flow-uninstall
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
