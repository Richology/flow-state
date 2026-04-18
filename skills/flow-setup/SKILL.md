---
name: flow-setup
description: First-time setup for the flow state tracking system. Installs automated macOS reminders via cron so popups appear without needing Claude Code open.
user-invocable: true
allowed-tools: Bash Write Read
---

# Flow State Tracker — 初始化设置

你好！这个工具基于 Mihaly Csikszentmihalyi 的**经验采样法（Experience Sampling Method）**，帮你找到真正让自己进入心流的活动和时机。

## 工作方式

安装完成后，**不需要打开电脑或 Claude Code**，系统会在设定的时间自动弹出对话框，你直接填写即可，约 30 秒完成一次记录。

---

## 初始化步骤

请按顺序执行：

### 第一步：询问用户的作息时间

问用户两个问题：
1. 你通常几点起床？（默认 7:00）
2. 你通常几点睡觉？（默认 23:00）

### 第二步：计算 6 个提醒时间点

根据用户填写的起床和睡觉时间，计算 6 个均匀分布的时间点。

规则：
- 第一个提醒在起床后 1 小时
- 最后一个提醒在睡觉前 1.5 小时
- 其余 4 个在中间均匀分布
- 每个时间点加上 ±5～15 分钟的随机偏移，避免整点

例如（7:00 起床，23:00 睡觉）：
```
08:12 / 10:43 / 13:07 / 15:28 / 17:51 / 20:19
```

### 第三步：复制提醒脚本

将插件自带的 `remind.sh` 脚本复制到 `~/.flow-data/remind.sh`，并赋予执行权限：

```bash
mkdir -p ~/.flow-data
# 从插件目录复制脚本（Claude 需要找到插件的实际安装路径）
cp "$(dirname "$0")/../../scripts/remind.sh" ~/.flow-data/remind.sh
chmod +x ~/.flow-data/remind.sh
```

如果复制失败，提示用户手动下载脚本：
```
https://github.com/Richology/flow-state/raw/main/scripts/remind.sh
```
保存到 `~/.flow-data/remind.sh`，然后运行 `chmod +x ~/.flow-data/remind.sh`。

### 第四步：安装 cron 定时任务

根据第二步计算的时间点，生成 cron 条目并安装。

**生成格式：**
```
分钟 小时 * * 1-7 ~/.flow-data/remind.sh
```

**安装方式（保留用户现有 cron）：**
```bash
(crontab -l 2>/dev/null | grep -v 'flow-data/remind.sh'; echo "<新的cron条目>") | crontab -
```

安装 6 条，对应 6 个时间点。

### 第五步：验证安装

运行以下命令确认 cron 条目已安装：
```bash
crontab -l | grep remind.sh
```

显示安装成功的确认信息，例如：
```
✓ 已安装 6 个每日提醒
✓ 数据将保存到 ~/.flow-data/logs.json
✓ 首次提醒将在明天 [第一个时间点] 弹出

使用说明：
- 每次弹框出现时，直接填写即可，无需打开电脑上的任何软件
- 积累 1～2 周后，运行 /flow-state:flow-review 分析你的心流规律
- 如需停止提醒，运行：crontab -l | grep -v remind.sh | crontab -
```

---

## 注意事项

- 此功能目前仅支持 **macOS**
- cron 在 macOS 上运行需要「完全磁盘访问权限」，如弹框未出现，请在「系统设置 → 隐私与安全性 → 完全磁盘访问权限」中添加 `/usr/sbin/cron`
- 数据保存在 `~/.flow-data/logs.json`，完全本地，不联网
