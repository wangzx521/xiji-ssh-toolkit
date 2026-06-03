#!/bin/bash
# ============================================================
# 希冀平台虚拟机一键启动脚本
# 来源：xiji-ssh-toolkit/scripts/start.sh
# 上传到虚拟机：~/Desktop/start.sh
#
# 首次使用：将 PUBLIC_KEY 替换为你的本地公钥
# 获取公钥（本地 PowerShell）：type $HOME\.ssh\id_rsa.pub
# ============================================================

set -e

# ⚠️ 在此填入你的本地 SSH 公钥（ssh-rsa AAAA... 开头的一整行）
PUBLIC_KEY="在此粘贴你的ssh-rsa公钥"

# ────────────────────────────────────────────
# 1. 启动 SSH 服务
# ────────────────────────────────────────────
echo "▶ [1/3] 启动 SSH 服务..."
service ssh start 2>/dev/null || true
sleep 1

if ps aux | grep -q '[s]shd'; then
    echo "✅ SSH 服务运行中"
else
    echo "❌ SSH 服务启动失败，请手动执行：service ssh start"
    exit 1
fi

# ────────────────────────────────────────────
# 2. 写入公钥
# ────────────────────────────────────────────
echo "▶ [2/3] 配置公钥..."

if [ "$PUBLIC_KEY" = "在此粘贴你的ssh-rsa公钥" ]; then
    echo "⚠️  PUBLIC_KEY 未设置，跳过公钥写入"
    echo "   请编辑 start.sh 的 PUBLIC_KEY 变量后重新运行"
else
    mkdir -p /root/.ssh
    echo "$PUBLIC_KEY" > /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
    chmod 600 /root/.ssh/authorized_keys
    echo "✅ 公钥写入完成"
fi

# ────────────────────────────────────────────
# 3. 检查并启动 bore
# ────────────────────────────────────────────
echo "▶ [3/3] 启动 bore 隧道..."

BORE_PATH="$HOME/Desktop/bore"

if [ ! -f "$BORE_PATH" ]; then
    echo "   未找到 bore，正在下载..."
    curl -sL https://github.com/ekzhang/bore/releases/download/v0.5.0/bore-v0.5.0-x86_64-unknown-linux-musl.tar.gz \
        | tar xz -C "$HOME/Desktop/"
    chmod +x "$BORE_PATH"
    echo "   bore 下载完成"
fi

echo ""
echo "─────────────────────────────────────────"
echo "  隧道启动中，请记下下方的端口号"
echo "  然后在本地执行：.\\connect.ps1 端口号"
echo "─────────────────────────────────────────"

cd "$HOME/Desktop"
./bore local 22 --to bore.pub
