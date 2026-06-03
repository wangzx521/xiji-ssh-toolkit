# ============================================================
# 希冀平台本地一键连接脚本
# 来源：xiji-ssh-toolkit/scripts/connect.ps1
# 使用前复制到项目根目录：
#   copy .claude\skills\hijix-ssh-tunnel\scripts\connect.ps1 .\connect.ps1
#
# 用法：.\connect.ps1 <bore端口号>
# 示例：.\connect.ps1 39595
# ============================================================

param(
    [Parameter(Mandatory=$true, HelpMessage="bore 输出的端口号")]
    [int]$Port
)

# 定位 ssh_config（相对于项目根目录）
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SshConfig = Join-Path $ScriptDir ".claude\skills\hijix-ssh-tunnel\assets\ssh_config"

# ────────────────────────────────────────────
# 1. 检查 ssh_config
# ────────────────────────────────────────────
if (-not (Test-Path $SshConfig)) {
    Write-Host "❌ 未找到 ssh_config：$SshConfig" -ForegroundColor Red
    Write-Host "   请确认已执行：git submodule add ... .claude/skills/hijix-ssh-tunnel" -ForegroundColor Gray
    exit 1
}

# ────────────────────────────────────────────
# 2. 更新端口号
# ────────────────────────────────────────────
$content = Get-Content $SshConfig -Raw
$updated = $content -replace 'Port \d+', "Port $Port"
Set-Content $SshConfig $updated -NoNewline
Write-Host "✅ 端口已更新为 $Port" -ForegroundColor Green

# ────────────────────────────────────────────
# 3. 测试 SSH 连接
# ────────────────────────────────────────────
Write-Host "▶ 测试 SSH 连接（5秒超时）..." -ForegroundColor Cyan
$test = ssh -F $SshConfig -o ConnectTimeout=5 -o BatchMode=yes hijix "echo ok" 2>&1

if ($test -match "ok") {
    Write-Host "✅ SSH 连接成功" -ForegroundColor Green
} else {
    Write-Host "⚠️  连接测试未通过，请确认虚拟机端 start.sh 正在运行" -ForegroundColor Yellow
    Write-Host "   详情：$test" -ForegroundColor Gray
    $continue = Read-Host "是否仍要继续？(y/n)"
    if ($continue -ne 'y') { exit 1 }
}

# ────────────────────────────────────────────
# 4. 启动 Claude Code
# ────────────────────────────────────────────
Write-Host "🚀 启动 Claude Code..." -ForegroundColor Cyan
claude
