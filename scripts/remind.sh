#!/bin/bash

# Flow State Reminder — macOS popup logger (3-step, ~15 seconds)
# Runs via cron, no Claude Code needed

TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")
DATA_DIR="$HOME/.flow-data"
LOG_FILE="$DATA_DIR/logs.json"

mkdir -p "$DATA_DIR"
[ ! -f "$LOG_FILE" ] && echo "[]" > "$LOG_FILE"

# Step 1: Activity + Location in one box
STEP1=$(osascript \
  -e 'display dialog "心流打卡 ⏰\n\n在做什么 · 在哪/和谁\n（例如：写方案，咖啡馆独自）" default answer "" with title "心流状态记录" buttons {"跳过", "继续"} default button "继续"' \
  -e 'text returned of result' 2>/dev/null)
[ $? -ne 0 ] || [ -z "$STEP1" ] && exit 0

# Parse activity and location from single input (split on Chinese comma, comma, or slash)
ACTIVITY=$(echo "$STEP1" | sed 's/[，,、].*//' | xargs)
LOCATION=$(echo "$STEP1" | sed 's/^[^，,、]*//' | sed 's/^[，,、]*//' | xargs)
[ -z "$LOCATION" ] && LOCATION=""

# Step 2: Flow state — one button click, zero typing
FLOW_RAW=$(osascript \
  -e 'display dialog "此刻的心流状态？\n\n是 — 完全忘我，时间飞逝\n部分 — 有点投入但未完全进入\n否 — 心不在焉" with title "心流状态记录" buttons {"否", "部分", "是"} default button "部分"' 2>/dev/null)
[ $? -ne 0 ] && exit 0
FLOW_BUTTON=$(echo "$FLOW_RAW" | sed 's/button returned://' | xargs)
case "$FLOW_BUTTON" in
  "是")   FLOW="yes"     ;;
  "部分") FLOW="partial" ;;
  *)      FLOW="no"      ;;
esac

# Step 3: Focus + Mood as "X X" in one box
SCORES=$(osascript \
  -e 'display dialog "专注 · 情绪（各 1-10，空格隔开）\n例如：8 7" default answer "7 7" with title "心流状态记录" buttons {"跳过", "完成"} default button "完成"' \
  -e 'text returned of result' 2>/dev/null)
FOCUS=$(echo "$SCORES" | awk '{print $1}')
MOOD=$(echo "$SCORES"  | awk '{print $2}')
# Validate
[[ "$FOCUS" =~ ^[0-9]+$ ]] && [ "$FOCUS" -ge 1 ] && [ "$FOCUS" -le 10 ] || FOCUS=null
[[ "$MOOD"  =~ ^[0-9]+$ ]] && [ "$MOOD"  -ge 1 ] && [ "$MOOD"  -le 10 ] || MOOD=null

# Escape for JSON
escape_json() {
  echo "$1" | python3 -c "import json,sys; print(json.dumps(sys.stdin.read().strip()))"
}
ACT_JSON=$(escape_json "$ACTIVITY")
LOC_JSON=$(escape_json "$LOCATION")

# Append entry
COUNT=$(python3 - <<EOF
import json

entry = {
    "timestamp": "$TIMESTAMP",
    "activity":  $ACT_JSON,
    "location":  $LOC_JSON,
    "with_whom": "",
    "focus":     $FOCUS,
    "mood":      $MOOD,
    "flow":      "$FLOW",
    "note":      "",
    "source":    "reminder"
}

with open("$LOG_FILE", "r") as f:
    logs = json.load(f)
logs.append(entry)
with open("$LOG_FILE", "w") as f:
    json.dump(logs, f, ensure_ascii=False, indent=2)
print(len(logs))
EOF
)

osascript -e "display notification \"$ACTIVITY — $FLOW_BUTTON　第 $COUNT 条\" with title \"心流打卡 ✓\""
