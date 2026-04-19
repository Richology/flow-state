# Flow State Reminder — Windows popup logger (3-step, ~15 seconds)
# Run via Task Scheduler, no Claude Code needed
# Usage: powershell -ExecutionPolicy Bypass -File remind.ps1

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
$dataDir = "$env:USERPROFILE\.flow-data"
$logFile = "$dataDir\logs.json"

# Ensure data directory and log file exist
if (-not (Test-Path $dataDir)) { New-Item -ItemType Directory -Path $dataDir | Out-Null }
if (-not (Test-Path $logFile)) { Set-Content -Path $logFile -Value "[]" -Encoding UTF8 }

function Show-FlowDialog {
    param([string]$Title, [string]$Message, [string]$Default = "", [string[]]$Buttons = @("跳过","继续"))

    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Title
    $form.Size = New-Object System.Drawing.Size(420, 220)
    $form.StartPosition = "CenterScreen"
    $form.TopMost = $true
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Message
    $label.Location = New-Object System.Drawing.Point(20, 20)
    $label.Size = New-Object System.Drawing.Size(370, 80)
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Text = $Default
    $textBox.Location = New-Object System.Drawing.Point(20, 110)
    $textBox.Size = New-Object System.Drawing.Size(370, 25)
    $form.Controls.Add($textBox)

    $btnY = 150
    $btnWidth = 100
    $spacing = 20
    $totalWidth = ($Buttons.Count * $btnWidth) + (($Buttons.Count - 1) * $spacing)
    $startX = (420 - $totalWidth) / 2
    $result = $Buttons[0]

    for ($i = 0; $i -lt $Buttons.Count; $i++) {
        $btn = New-Object System.Windows.Forms.Button
        $btn.Text = $Buttons[$i]
        $btn.Location = New-Object System.Drawing.Point(($startX + $i * ($btnWidth + $spacing)), $btnY)
        $btn.Size = New-Object System.Drawing.Size($btnWidth, 30)
        $btnText = $Buttons[$i]
        $btn.Add_Click({
            $script:result = $btnText
            $form.Close()
        }.GetNewClosure())
        $form.Controls.Add($btn)
    }

    $form.AcceptButton = $form.Controls | Where-Object { $_ -is [System.Windows.Forms.Button] } | Select-Object -Last 1
    $form.ShowDialog() | Out-Null
    return @{ Text = $textBox.Text; Button = $script:result }
}

function Show-FlowButtonDialog {
    param([string]$Title, [string]$Message, [string[]]$Buttons)

    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Title
    $form.Size = New-Object System.Drawing.Size(420, 200)
    $form.StartPosition = "CenterScreen"
    $form.TopMost = $true
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Message
    $label.Location = New-Object System.Drawing.Point(20, 20)
    $label.Size = New-Object System.Drawing.Size(370, 100)
    $form.Controls.Add($label)

    $btnY = 130
    $btnWidth = 100
    $spacing = 20
    $totalWidth = ($Buttons.Count * $btnWidth) + (($Buttons.Count - 1) * $spacing)
    $startX = (420 - $totalWidth) / 2
    $script:chosen = $Buttons[0]

    foreach ($btnText in $Buttons) {
        $btn = New-Object System.Windows.Forms.Button
        $btn.Text = $btnText
        $btn.Location = New-Object System.Drawing.Point($startX, $btnY)
        $btn.Size = New-Object System.Drawing.Size($btnWidth, 30)
        $startX += $btnWidth + $spacing
        $capturedText = $btnText
        $btn.Add_Click({
            $script:chosen = $capturedText
            $form.Close()
        }.GetNewClosure())
        $form.Controls.Add($btn)
    }

    $form.ShowDialog() | Out-Null
    return $script:chosen
}

# Step 1: Activity + Location
$step1 = Show-FlowDialog `
    -Title "心流状态记录" `
    -Message "心流打卡 ⏰`n`n在做什么 · 在哪/和谁`n（例如：写方案，咖啡馆独自）" `
    -Buttons @("跳过", "继续")

if ($step1.Button -eq "跳过" -or $step1.Text -eq "") { exit }

$parts = $step1.Text -split '[，,、]', 2
$activity = $parts[0].Trim()
$location = if ($parts.Count -gt 1) { $parts[1].Trim() } else { "" }

# Step 2: Flow state — button only
$flowButton = Show-FlowButtonDialog `
    -Title "心流状态记录" `
    -Message "此刻的心流状态？`n`n是  — 完全忘我，时间飞逝`n部分 — 有点投入但未完全进入`n否  — 心不在焉" `
    -Buttons @("否", "部分", "是")

$flowValue = switch ($flowButton) {
    "是"   { "yes" }
    "部分" { "partial" }
    default { "no" }
}

# Step 3: Focus + Mood
$step3 = Show-FlowDialog `
    -Title "心流状态记录" `
    -Message "专注 · 情绪（各 1-10，空格隔开）`n例如：8 7" `
    -Default "7 7" `
    -Buttons @("跳过", "完成")

$scores = $step3.Text -split '\s+', 2
$focus = if ($scores[0] -match '^\d+$' -and [int]$scores[0] -ge 1 -and [int]$scores[0] -le 10) { $scores[0] } else { "null" }
$mood  = if ($scores.Count -gt 1 -and $scores[1] -match '^\d+$' -and [int]$scores[1] -ge 1 -and [int]$scores[1] -le 10) { $scores[1] } else { "null" }

# Append to JSON using Python
$activityEscaped = $activity -replace '"', '\"'
$locationEscaped = $location -replace '"', '\"'

$pyScript = @"
import json

entry = {
    "timestamp": "$timestamp",
    "activity":  "$activityEscaped",
    "location":  "$locationEscaped",
    "with_whom": "",
    "focus":     $focus,
    "mood":      $mood,
    "flow":      "$flowValue",
    "note":      "",
    "source":    "reminder"
}

with open(r"$logFile", "r", encoding="utf-8") as f:
    logs = json.load(f)
logs.append(entry)
with open(r"$logFile", "w", encoding="utf-8") as f:
    json.dump(logs, f, ensure_ascii=False, indent=2)
print(len(logs))
"@

$count = python $pyScript 2>$null
if (-not $count) { $count = "?" }

# Toast notification
[System.Windows.Forms.MessageBox]::Show(
    "$activity — $flowButton  第 $count 条",
    "心流打卡 ✓",
    [System.Windows.Forms.MessageBoxButtons]::OK,
    [System.Windows.Forms.MessageBoxIcon]::Information
) | Out-Null
