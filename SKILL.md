---
name: hijix-ssh-tunnel
description: "连接希冀教育云平台（educg.net）实验虚拟机时使用此 skill。当用户提到希冀平台、educg、实验环境连接、bore 隧道、SSH 连接虚拟机，或需要在远程 Hadoop/Spark/Flink/Kafka/Hive 集群上执行实验时自动加载。包含：bore 隧道启动、SSH 免密登录配置、一键连接脚本使用方式、故障排查全流程。"
allowed-tools: [Bash, Read, Write]
---

# 希冀平台 SSH 隧道连接 Skill

## 网络结构

```
本地电脑（校园网，无法直连内网）
        ↕ SSH（经由 bore 公网隧道）
  bore.pub:随机端口
        ↕ 反向隧道
希冀平台虚拟机（100.64.x.x 内网）
        ↕ SSH
  master / slave 各节点
```

## 日常连接流程

### Step 1：虚拟机端启动隧道

在希冀平台网页虚拟机终端里执行：

```bash
cd ~/Desktop && ./start.sh
```

记下输出的端口号（每次不同），例如：
```
INFO bore_cli::client: listening at bore.pub:39595
```

### Step 2：本地端更新端口并连接

```powershell
.\connect.ps1 39595    # 替换为实际端口
```

脚本会自动更新 `assets/ssh_config` 里的端口并启动 Claude Code。

### Step 3：Claude Code 连接虚拟机执行命令

```bash
ssh -F .claude/skills/hijix-ssh-tunnel/assets/ssh_config hijix
```

---

## 辅助脚本说明

### scripts/start.sh（上传到虚拟机 ~/Desktop/）

功能：启动SSH服务 → 写入公钥 → 启动bore隧道

```bash
# 上传命令（在已连接状态下执行）
scp -F .claude/skills/hijix-ssh-tunnel/assets/ssh_config \
    .claude/skills/hijix-ssh-tunnel/scripts/start.sh \
    hijix:~/Desktop/start.sh
ssh -F .claude/skills/hijix-ssh-tunnel/assets/ssh_config \
    hijix "chmod +x ~/Desktop/start.sh"
```

### scripts/connect.ps1（放在项目根目录使用）

功能：更新端口 → 测试连接 → 启动 Claude Code

```powershell
# 从 skill 目录复制到项目根目录使用
copy .claude\skills\hijix-ssh-tunnel\scripts\connect.ps1 .\connect.ps1
```

---

## 首次初始化步骤

### 1. 本地生成 SSH 密钥

```powershell
ssh-keygen -t rsa -b 4096 -f $HOME\.ssh\id_rsa
type $HOME\.ssh\id_rsa.pub    # 复制输出的公钥
```

### 2. 编辑 start.sh，填入公钥

打开 `scripts/start.sh`，将 `PUBLIC_KEY` 变量替换为步骤 1 的公钥内容。

### 3. 上传 start.sh 到虚拟机

参考上方"辅助脚本说明"中的上传命令。

### 4. 复制 connect.ps1 到项目根目录

```powershell
copy .claude\skills\hijix-ssh-tunnel\scripts\connect.ps1 .\connect.ps1
```

---

## 故障排查

| 现象 | 原因 | 解决 |
|------|------|------|
| `Connection refused` | SSH 服务未启动或 bore 未运行 | 虚拟机执行 `service ssh start`，重跑 `start.sh` |
| `Connection closed` | 端口不匹配 | 确认 `assets/ssh_config` 的 Port 与 bore 输出一致 |
| `Permission denied` | 公钥未写入 | 重新运行 `start.sh`（已内置公钥写入逻辑） |
| bore 端口变了 | 每次重启随机分配 | 执行 `.\connect.ps1 新端口` |
| 公钥丢失 | 希冀平台重置了实验环境 | 重新运行 `start.sh` 即可 |

---

## 注意事项

- bore 隧道是**临时的**，虚拟机重启后需重新运行 `start.sh`
- bore.pub 是免费公共穿透服务，请勿传输敏感数据
- 本 skill 目录所有文件均不含个人敏感信息，可安全提交 Git
