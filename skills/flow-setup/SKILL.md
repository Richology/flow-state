---
name: flow-setup
description: First-time setup for the flow state tracking system. Explains the method, creates the data directory, and helps the user plan their reminder schedule.
user-invocable: true
allowed-tools: Bash Write Read
---

# Flow State Tracker — 初始化设置

你好！这个工具基于 Mihaly Csikszentmihalyi 的**经验采样法（Experience Sampling Method）**，帮你找到真正让自己进入心流的活动和时机。

## 方法说明

每周设置 **40 次随机提醒**（平均每天 5～6 次），铃响时立刻用 `/flow-state:flow-log` 记录当下状态。坚持 1～2 周后，用 `/flow-state:flow-review` 分析规律。

**关键原则：**
- 提醒要**随机**，避免只在特定时段记录
- 铃响后**立刻**记录，不要事后补写（记忆会失真）
- 不评判自己的状态，如实记录即可

---

## 设置提醒的建议

假设你每天 7:00 起床、23:00 睡觉（共 16 小时），每天需要 5～6 次提醒：

**推荐时间段分布（示例）：**
```
08:15 / 10:30 / 12:45 / 15:00 / 17:20 / 20:10
```

**iOS 快速设置：**「嘿 Siri，在 [时间] 提醒我记录心流状态」逐一设置

**Android：**使用 Google 日历或第三方 App（如 Randomly RemindMe）设置随机提醒

**建议：** 把提醒文本设为「现在感觉如何？」或「心流打卡」，这样响铃时你会立刻知道要做什么。

---

## 初始化数据目录

我现在会在你的当前目录下创建 `.flow-data/` 文件夹，用于存储你的记录。

请先告诉我：
1. 你通常几点起床、几点睡觉？
2. 你想从哪天开始追踪？

我会根据你的情况生成个性化的提醒时间表，并完成初始化。

---

初始化后，你就可以开始使用：
- `/flow-state:flow-log` — 每次铃响时记录
- `/flow-state:flow-review` — 每周回顾分析
