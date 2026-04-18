# flow-state

一个基于**经验采样法（Experience Sampling Method）**的 Claude Code 插件，帮你找到真正让自己进入心流的活动和时机。该方法由心理学家 Mihaly Csikszentmihalyi 提出。

## 它能做什么

每周设置 40 次提醒（每天 5～6 次）。只需运行一次 `/flow-state:flow-setup`，之后 Mac 会**在设定的时间自动弹出对话框** —— 不需要打开 Claude Code，填完关掉，30 秒结束。坚持 1～2 周后，运行 `/flow-state:flow-review` 找到你的规律：

1. **哪些活动会触发心流** — 你在做什么、在哪里、和谁在一起
2. **你的高效时段** — 一天中哪些时刻最容易进入心流
3. **如何重新设计你的日程** — 基于真实数据的可操作建议

## 安装

```bash
claude plugin install https://github.com/Richology/flow-state
```

## 工作原理

`flow-setup` 会在系统 cron 里安装定时任务，到点自动运行 `remind.sh`，通过 macOS 的 AppleScript 弹出原生对话框 —— **提醒时无需任何 App、浏览器或 Claude Code**。

```
cron → remind.sh → AppleScript 对话框 → ~/.flow-data/logs.json
```

> **macOS 权限提示：** 如果弹框没有出现，请前往「系统设置 → 隐私与安全性 → 完全磁盘访问权限」，将 `/usr/sbin/cron` 添加进去。

## 三个 Skill

### `/flow-state:flow-setup`
第一次使用时运行。告诉它你的起床和睡觉时间，它会自动：
- 计算 6 个均匀分布的提醒时间点
- 将 `remind.sh` 复制到 `~/.flow-data/`
- 安装 cron 定时任务

### `/flow-state:flow-log`
通过 Claude Code 手动记录 —— 适合在计划外的时刻补录。约 30 秒完成，记录内容：
- 当前在做什么
- 在哪里、和谁在一起
- 专注程度（1～10）
- 情绪状态（1～10）
- 心流状态（是 / 部分 / 否）
- 可选备注

数据保存到 `~/.flow-data/logs.json`。

### `/flow-state:flow-review`
分析你积累的数据。建议至少收集 20 条记录后使用（40 条以上效果更佳）。

```bash
/flow-state:flow-review        # 分析全部数据
/flow-state:flow-review week   # 只分析最近 7 天
```

分析内容包括：
- 各活动的心流率排名
- 一天中的心流热力图
- 地点与陪伴者的影响分析
- 3 条个性化可操作建议

## 数据存储

所有记录保存在本地的 `~/.flow-data/logs.json` 文件中，不会上传或发送到任何外部服务。

```json
[
  {
    "timestamp": "2026-04-18T14:32:00",
    "activity": "写作",
    "location": "家里",
    "with_whom": "独自一人",
    "focus": 9,
    "mood": 8,
    "flow": "yes",
    "note": ""
  }
]
```

随时可以停止提醒：
```bash
crontab -l | grep -v remind.sh | crontab -
```

## 背后的科学原理

Csikszentmihalyi 的研究发现，人们对「什么让自己快乐或专注」的预测往往严重失准。经验采样法通过捕捉**实时快照**绕过了这个问题 —— 你记录的是当下真实的感受，而不是事后的回忆（记忆会美化或扭曲）。

每周 40 个样本，1～2 周内即可积累足够的数据，找到真正属于你的心流规律。

## 环境要求

- macOS（弹窗依赖 AppleScript）
- Python 3（macOS 已预装）
- Claude Code（仅 setup 和 review 时需要）

## 开始使用

```
/flow-state:flow-setup   ← 从这里开始
```

## License

MIT
