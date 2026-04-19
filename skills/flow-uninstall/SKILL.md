---
name: flow-uninstall
description: Remove all scheduled flow state reminders installed by flow-setup. Auto-detects macOS (cron) or Windows (Task Scheduler). Optionally keeps or deletes log data.
user-invocable: true
allowed-tools: Bash Read
---

# 取消心流提醒

我会帮你移除之前 `flow-setup` 安装的所有定时提醒。

## 第一步：检测操作系统

```bash
uname -s 2>/dev/null || echo "Windows"
```

- 输出包含 `Darwin` → macOS 流程
- 否则 → Windows 流程

---

## macOS 流程

### 确认已安装的提醒

```bash
crontab -l 2>/dev/null | grep remind.sh
```

如果没有输出，告知用户当前没有安装提醒，退出。

如果有输出，展示所有条目：
```
已找到以下提醒任务：
  12 8  * * * ~/.flow-data/remind.sh
  43 10 * * * ~/.flow-data/remind.sh
  ...（共 X 条）
```

### 确认后移除

```bash
crontab -l 2>/dev/null | grep -v 'remind.sh' | crontab -
```

验证：
```bash
crontab -l 2>/dev/null | grep remind.sh
```

无输出即删除成功。

---

## Windows 流程

### 确认已安装的提醒

```powershell
schtasks /query /fo list | findstr "FlowState"
```

如果没有输出，告知用户当前没有安装提醒，退出。

如果有输出，展示任务列表：
```
已找到以下提醒任务：
  FlowState_08:12
  FlowState_10:43
  ...（共 X 条）
```

### 确认后移除

逐一删除所有 `FlowState_` 开头的任务：

```powershell
schtasks /query /fo csv | ConvertFrom-Csv | Where-Object { $_.TaskName -like "*FlowState*" } | ForEach-Object { schtasks /delete /tn $_.TaskName /f }
```

验证：
```powershell
schtasks /query /fo list | findstr "FlowState"
```

无输出即删除成功。

---

## 询问是否保留历史数据

问用户：「是否保留你的心流记录数据？」

- **保留**（默认）：不做任何操作，数据仍可用于 `/flow-state:flow-review` 分析
- **删除**：
  - macOS：`rm -rf ~/.flow-data/`
  - Windows：`Remove-Item -Recurse -Force "$env:USERPROFILE\.flow-data"`
  - 告知用户数据已不可恢复

## 完成提示

```
✓ 已移除全部 X 个定时提醒
✓ 历史数据已保留

如需重新开始追踪，随时运行 /flow-state:flow-setup
```
