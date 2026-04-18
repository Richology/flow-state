---
name: flow-uninstall
description: Remove all scheduled flow state reminders installed by flow-setup. Cleans up cron jobs. Optionally keeps or deletes log data.
user-invocable: true
allowed-tools: Bash Read
---

# 取消心流提醒

我会帮你移除之前 `flow-setup` 安装的所有定时提醒。

## 第一步：确认当前已安装的提醒

运行以下命令，列出当前所有心流提醒的 cron 条目：

```bash
crontab -l 2>/dev/null | grep remind.sh
```

如果没有任何输出，说明当前没有安装提醒，告知用户并退出。

如果有输出，将所有条目展示给用户，例如：
```
已找到以下提醒任务：
  12 8  * * * ~/.flow-data/remind.sh
  43 10 * * * ~/.flow-data/remind.sh
  ...（共 X 条）
```

## 第二步：询问用户是否确认删除

问用户：「确认移除以上全部提醒吗？」
- 用户确认后继续
- 用户取消则退出，不做任何操作

## 第三步：移除 cron 条目

执行以下命令，删除所有包含 `remind.sh` 的 cron 条目：

```bash
crontab -l 2>/dev/null | grep -v 'remind.sh' | crontab -
```

完成后验证：

```bash
crontab -l 2>/dev/null | grep remind.sh
```

如果无输出，说明删除成功。

## 第四步：询问是否保留历史数据

问用户：「是否保留你的心流记录数据（~/.flow-data/）？」

- **保留**（默认）：不做任何操作，数据仍可用于 `/flow-state:flow-review` 分析
- **删除**：运行 `rm -rf ~/.flow-data/`，并告知用户数据已不可恢复

## 完成提示

显示操作结果，例如：

```
✓ 已移除全部 X 个定时提醒
✓ 历史数据已保留在 ~/.flow-data/logs.json

如需重新开始追踪，随时运行 /flow-state:flow-setup
```
