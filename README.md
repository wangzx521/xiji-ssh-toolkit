# xiji-ssh-toolkit

通用希冀教育云平台（educg.net）SSH 隧道连接工具。

适用于任何需要从本地电脑连接希冀平台实验虚拟机的场景，
包括 Hadoop、Spark、Flink、Kafka、Hive 等大数据实验环境。

> **Claude Code 用户**：本仓库即一个完整的 Claude Code Skill，
> 以 submodule 方式引入项目后 Claude Code 会自动加载，无需额外配置。

## 原理

希冀平台虚拟机分配的是 `100.64.x.x` 内网地址，本地无法直连。
通过 [bore](https://github.com/ekzhang/bore) 建立反向 TCP 隧道，
将虚拟机 SSH 端口穿透到公网，从而实现本地直接连接。

```
本地电脑（校园网）
    ↕ SSH
bore.pub:随机端口
    ↕ 反向隧道
希冀平台虚拟机（100.64.x.x）
    ↕ SSH
master / slave 节点
```

## 仓库结构

```
xiji-ssh-toolkit/              ← 仓库根目录 = Skill 目录
├── SKILL.md                   ← Claude Code 自动加载的 Skill 指令
├── README.md                  ← 本文件（人类阅读）
├── scripts/
│   ├── start.sh               ← 虚拟机一键启动脚本（需上传到虚拟机）
│   └── connect.ps1            ← 本地一键更新端口并启动 Claude Code
└── assets/
    └── ssh_config             ← SSH 连接配置模板
```

> `SKILL.md` 供 Claude Code 读取；`README.md` 供开发者阅读。两者职责分离。

## 在项目中引入（推荐方式）

```powershell
# 在你的项目根目录执行，挂载到 .claude/skills/hijix-ssh-tunnel
git submodule add https://github.com/wangzx521/xiji-ssh-toolkit.git .claude/skills/hijix-ssh-tunnel

# 复制 connect.ps1 到项目根目录使用
copy .claude\skills\hijix-ssh-tunnel\scripts\connect.ps1 .\connect.ps1
```

引入后项目结构：
```
你的项目/
├── connect.ps1                        ← 从 skill 复制过来
└── .claude/
    ├── settings.json                  ← 项目自有配置，不受影响
    ├── skills/
    │   ├── hijix-ssh-tunnel/          ← submodule，指向本仓库
    │   │   ├── SKILL.md
    │   │   ├── scripts/
    │   │   └── assets/
    │   └── 其他skill/                 ← 项目自有 skill，不受影响
    └── commands/                      ← 项目自有命令，不受影响
```

## 快速开始

### 首次初始化

**1. 本地生成 SSH 密钥**
```powershell
ssh-keygen -t rsa -b 4096 -f $HOME\.ssh\id_rsa
type $HOME\.ssh\id_rsa.pub   # 复制输出的公钥
```

**2. 编辑 `scripts/start.sh`，填入公钥**

将 `PUBLIC_KEY` 变量替换为上一步复制的公钥内容。

**3. 上传 start.sh 到虚拟机**

在希冀平台网页虚拟机终端里粘贴 `start.sh` 内容并保存，或通过已有连接上传：
```bash
scp -F .claude/skills/hijix-ssh-tunnel/assets/ssh_config \
    .claude/skills/hijix-ssh-tunnel/scripts/start.sh \
    hijix:~/Desktop/start.sh
```

### 日常使用

**虚拟机端（每次打开实验时）：**
```bash
cd ~/Desktop && ./start.sh
# 记下端口号，例如：bore.pub:39595
```

**本地端：**
```powershell
.\connect.ps1 39595
```

### 更新 Skill

```powershell
cd .claude/skills/hijix-ssh-tunnel
git pull
```

## 注意事项

- bore 隧道是临时的，虚拟机重启后需重新运行 `start.sh`
- 希冀平台实验环境重置后公钥丢失，重新运行 `start.sh` 即可自动恢复
- bore.pub 是免费公共服务，请勿传输敏感数据
- 本仓库所有文件均不含个人敏感信息，可放心公开
