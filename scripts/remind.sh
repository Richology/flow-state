#!/bin/bash

# Flow State Reminder — macOS popup logger
# Runs via cron, no Claude Code needed

TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")
DATA_DIR="$HOME/.flow-data"
LOG_FILE="$DATA_DIR/logs.json"

mkdir -p "$DATA_DIR"
[ ! -f "$LOG_FILE" ] && echo "[]" > "$LOG_FILE"

# Question 1: Activity
ACTIVITY=$(osascript \
  -e 'display dialog "心流打卡 ⏰\n\n你现在在做什么？" default answer "" with title "心流状态记录" buttons {"跳过", "继续"} default button "继续"' \
  -e 'text returned of result' 2>/dev/null)
[ $? -ne 0 ] || [ -z "$ACTIVITY" ] && exit 0

# Question 2: Location & company
LOCATION=$(osascript \
  -e 'display dialog "你在哪里？和谁在一起？\n（例如：家里 / 独自一人）" default answer "" with title "心流状态记录" buttons {"返回", "继续"} default button "继续"' \
  -e 'text returned of result' 2>/dev/null)
[ $? -ne 0 ] && exit 0

# Question 3: Focus level
FOCUS=$(osascript \
  -e 'display dialog "专注程度？（输入 1-10）\n\n1-3  心不在焉\n4-6  勉强投入\n7-8  比较专注\n9-10 完全沉浸" default answer "7" with title "心流状态记录" buttons {"返回", "继续"} default button "继续"' \
  -e 'text returned of result' 2>/dev/null)
[ $? -ne 0 ] && exit 0
# Validate number range
if ! [[ "$FOCUS" =~ ^[0-9]+$ ]] || [ "$FOCUS" -lt 1 ] || [ "$FOCUS" -gt 10 ]; then
  FOCUS=5
fi

# Question 4: Mood
MOOD=$(osascript \
  -e 'display dialog "情绪状态？（输入 1-10）\n\n1-3  烦躁/焦虑/疲惫\n4-6  平淡一般\n7-8  愉悦/平静\n9-10 兴奋/充实" default answer "7" with title "心流状态记录" buttons {"返回", "继续"} default button "继续"' \
  -e 'text returned of result' 2>/dev/null)
[ $? -ne 0 ] && exit 0
if ! [[ "$MOOD" =~ ^[0-9]+$ ]] || [ "$MOOD" -lt 1 ] || [ "$MOOD" -gt 10 ]; then
  MOOD=5
fi

# Question 5: Flow state (button choice)
FLOW_RAW=$(osascript \
  -e 'display dialog "此刻处于心流状态吗？\n\n「是」— 时间飞逝，完全忘我\n「部分」— 有点投入但未完全进入\n「否」— 心不在焉，被迫在做" with title "心流状态记录" buttons {"否", "部分", "是"} default button "部分"' 2>/dev/null)
[ $? -ne 0 ] && exit 0
FLOW_BUTTON=$(echo "$FLOW_RAW" | sed 's/button returned://' | xargs)
case "$FLOW_BUTTON" in
  "是")   FLOW="yes"     ;;
  "部分") FLOW="partial" ;;
  *)      FLOW="no"      ;;
esac

# Question 6: Optional note
NOTE=$(osascript \
  -e 'display dialog "还有什么想备注的吗？（可直接点完成）" default answer "" with title "心流状态记录" buttons {"跳过", "完成"} default button "完成"' \
  -e 'text returned of result' 2>/dev/null)

# Escape special characters for JSON
escape_json() {
  echo "$1" | python3 -c "import json,sys; print(json.dumps(sys.stdin.read().strip()))"
}

ACT_JSON=$(escape_json "$ACTIVITY")
LOC_JSON=$(escape_json "$LOCATION")
NOTE_JSON=$(escape_json "$NOTE")

# Append entry to log file
COUNT=$(python3 - <<EOF
import json

entry = {
    "timestamp": "$TIMESTAMP",
    "activity": $ACT_JSON,
    "location": $LOC_JSON,
    "with_whom": "",
    "focus": $FOCUS,
    "mood": $MOOD,
    "flow": "$FLOW",
    "note": $NOTE_JSON
}

with open("$LOG_FILE", "r") as f:
    logs = json.load(f)

logs.append(entry)

with open("$LOG_FILE", "w") as f:
    json.dump(logs, f, ensure_ascii=False, indent=2)

print(len(logs))
EOF
)

# Success notification
osascript -e "display notification \"$ACTIVITY — 心流：$FLOW_BUTTON　已记录第 $COUNT 条\" with title \"心流打卡完成 ✓\""
