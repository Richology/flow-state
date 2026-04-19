---
name: flow-setup
description: First-time setup for the flow state tracking system. Auto-detects macOS or Windows and installs automated reminders via cron (macOS) or Task Scheduler (Windows) so popups appear without needing Claude Code open.
user-invocable: true
allowed-tools: Bash Write Read
---

# Flow State Tracker — 初始化设置

你好！这个工具基于 Mihaly Csikszentmihalyi 的**经验采样法（Experience Sampling Method）**，帮你找到真正让自己进入心流的活动和时机。

## 工作方式

安装完成后，**不需要打开电脑或 Claude Code**，系统会在设定的时间自动弹出对话框，你直接填写即可，约 15 秒完成一次记录（3步）。

---

## 初始化步骤

### 第一步：检测操作系统

运行以下命令判断系统类型：

```bash
uname -s 2>/dev/null || echo "Windows"
```

- 输出包含 `Darwin` → macOS，走 **macOS 流程**
- 命令不存在或输出 `Windows` → Windows，走 **Windows 流程**

---

### 第二步：询问用户的作息时间

问用户两个问题：
1. 你通常几点起床？（默认 7:00）
2. 你通常几点睡觉？（默认 23:00）

### 第三步：计算 6 个提醒时间点

根据起床和睡觉时间，计算 6 个均匀分布的时间点：
- 第一个：起床后 1 小时
- 最后一个：睡觉前 1.5 小时
- 其余 4 个均匀分布在中间
- 每个时间点加 ±5～15 分钟随机偏移，避免整点

例如（7:00 起床，23:00 睡觉）：
```
08:12 / 10:43 / 13:07 / 15:28 / 17:51 / 20:19
```

---

## macOS 流程

### 复制提醒脚本

```bash
mkdir -p ~/.flow-data
cp "$(dirname "$0")/../../scripts/remind.sh" ~/.flow-data/remind.sh
chmod +x ~/.flow-data/remind.sh
```

如果复制失败，提示用户手动下载：
```
https://github.com/Richology/flow-state/raw/main/scripts/remind.sh
```
保存到 `~/.flow-data/remind.sh`，然后运行 `chmod +x ~/.flow-data/remind.sh`。

### 安装 cron 定时任务

```bash
(crontab -l 2>/dev/null | grep -v 'flow-data/remind.sh'; echo "分钟 小时 * * * ~/.flow-data/remind.sh") | crontab -
```

安装 6 条，每条对应一个时间点。

### 验证

```bash
crontab -l | grep remind.sh
```

### 权限提醒

⚠️ cron 在 macOS Catalina 及以上需要「完全磁盘访问权限」才能弹出窗口：
「系统设置 → 隐私与安全性 → 完全磁盘访问权限」→ 添加 `/usr/sbin/cron`

---

## Windows 流程

### 复制提醒脚本

将插件的 `scripts/remind.ps1` 复制到用户目录：

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.flow-data"
Copy-Item "remind.ps1" "$env:USERPROFILE\.flow-data\remind.ps1"
```

如果复制失败，提示用户手动下载：
```
https://github.com/Richology/flow-state/raw/main/scripts/remind.ps1
```
保存到 `%USERPROFILE%\.flow-data\remind.ps1`。

### 安装任务计划程序（Task Scheduler）

为每个时间点创建一个定时任务，使用 `schtasks` 命令：

```powershell
schtasks /create /tn "FlowState_08:12" /tr "powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File \"%USERPROFILE%\.flow-data\remind.ps1\"" /sc daily /st 08:12 /f
```

每个时间点执行一次，共创建 6 个任务，任务名格式为 `FlowState_HH:MM`。

### 验证

```powershell
schtasks /query /fo list | findstr "FlowState"
```

### 权限提醒

⚠️ PowerShell 脚本默认执行策略可能阻止运行。如弹框未出现，以管理员身份运行：
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

---

## 安装完成后的确认信息

显示如下内容：

```
✓ 已安装 6 个每日提醒
✓ 数据将保存到 ~/.flow-data/logs.json（macOS）
         或 %USERPROFILE%\.flow-data\logs.json（Windows）
✓ 首次提醒将在 [第一个时间点] 弹出

使用说明：
- 提醒弹出时直接填写，3步约15秒，无需打开任何软件
- 不在电脑旁时，手机随手记一句话，回来后用 /flow-state:flow-import 导入
- 积累记录后，运行 /flow-state:flow-review 分析心流规律
- 如需停止提醒，运行 /flow-state:flow-uninstall
```

---

## 数据说明

- 数据完全保存在本地，不联网，不上传
- macOS：`~/.flow-data/logs.json`
- Windows：`%USERPROFILE%\.flow-data\logs.json`
