# sing-box 一键安装脚本 (GitHub 版)

基于 [233boy/sing-box](https://github.com/233boy/sing-box) 修改。

自动检测公网 IP，一键生成 7 种协议代理链接，安装即用。

## 功能特性

- 一键安装，零交互，装完即用
- 自动检测公网 IP（本地网卡 → 云平台 metadata → 外部服务）
- 支持 `-i` 参数手动添加额外公网 IP（适用于 NAT 云主机多 IP 场景）
- 安装时自动生成 7 种协议（VLESS-REALITY / Trojan / Hysteria2 / VMess / VLESS / SS / SOCKS5）
- 多 IP 时自动为每个 IP 生成完整链接（含 VMess base64 正确替换）
- 自签 TLS 证书（Trojan / Hysteria2 自动生成）
- BBR 加速一键启用
- 支持 x86_64 和 ARM64 架构
- 支持 Ubuntu / Debian / CentOS / SUSE / Alpine

## 一键安装

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/qq48674431/sing-box/main/install.sh)
```

### 指定额外公网 IP

如果 VPS 有多个公网 IP 但脚本只检测到一个（常见于 NAT 云主机），用 `-i` 指定：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/qq48674431/sing-box/main/install.sh) -i 1.2.3.4
```

多个 IP 用逗号分隔：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/qq48674431/sing-box/main/install.sh) -i 1.2.3.4,5.6.7.8
```

### 其他安装参数

```bash
-f <路径>       # 使用本地 sing-box 核心文件
-l              # 本地安装（使用当前目录的脚本）
-p <地址>       # 使用代理下载，如 -p http://127.0.0.1:2333
-v <版本>       # 指定 sing-box 版本，如 -v v1.8.13
-i <IP列表>     # 添加额外公网 IP，如 -i 1.2.3.4,5.6.7.8
-h              # 显示帮助
```

## 自动生成的协议

安装完成后自动生成以下 7 种协议配置：

| # | 协议 | 传输 | 加密 | 说明 |
|---|------|------|------|------|
| 1 | VLESS-REALITY | TCP | REALITY | 伪装 TLS 握手，随机 SNI |
| 2 | Trojan | TCP | 自签 TLS | 自动生成 TLS 证书 |
| 3 | Hysteria2 | UDP (QUIC) | 自签 TLS | 基于 QUIC，低延迟高速 |
| 4 | VMess-TCP | TCP | 无 | 经典 VMess 协议 |
| 5 | VLESS-TCP | TCP | 无 | 轻量 VLESS |
| 6 | Shadowsocks | TCP | chacha20-ietf-poly1305 | 传统加密代理 |
| 7 | SOCKS5 | TCP | 无 | 通用 SOCKS 代理 |

### 手动添加更多协议

```bash
sing-box add reality          # VLESS-REALITY
sing-box add trojan           # Trojan
sing-box add hy2              # Hysteria2
sing-box add tcp              # VMess-TCP
sing-box add vtcp             # VLESS-TCP
sing-box add ss               # Shadowsocks
sing-box add socks            # SOCKS5
sing-box add tuic             # TUIC
sing-box add anytls           # AnyTLS
sing-box add vmess-ws-tls     # VMess-WS-TLS
sing-box add vless-ws-tls     # VLESS-WS-TLS
sing-box add trojan-ws-tls    # Trojan-WS-TLS
```

## DNS 配置

默认 DNS: `1.1.1.1` (Cloudflare)

| 命令 | DNS | 说明 |
|------|-----|------|
| `sing-box dns 11` | `1.1.1.1` | Cloudflare |
| `sing-box dns 88` | `8.8.8.8` | Google |
| `sing-box dns google` | `h3://dns.google/dns-query` | Google DoH3 |
| `sing-box dns cloudflare` | `h3://cloudflare-dns.com/dns-query` | Cloudflare DoH3 |
| `sing-box dns set <地址>` | 自定义 | 任意 DNS |
| `sing-box dns none` | 关闭 | 不使用 DNS |

## 管理命令

```bash
sing-box info          # 查看配置信息
sing-box url           # 查看所有节点链接
sing-box add <协议>    # 添加协议
sing-box del <名称>    # 删除配置
sing-box change        # 修改配置
sing-box dns           # 切换 DNS
sing-box start         # 启动
sing-box stop          # 停止
sing-box restart       # 重启
sing-box status        # 运行状态
sing-box log           # 查看日志
sing-box update        # 更新内核
sing-box update.sh     # 更新脚本
sing-box reinstall     # 重新安装
sing-box uninstall     # 卸载
sing-box bbr           # 启用 BBR
sing-box help          # 帮助
```

快捷命令: `sb`（等同于 `sing-box`）

## IP 检测顺序

脚本安装时自动按以下顺序检测公网 IP：

1. **本地网卡** — `ip addr` 获取 IPv4 / IPv6（过滤内网地址）
2. **云平台 metadata** — 华为云 / AWS / 腾讯云 / 阿里云 metadata API
3. **外部服务 (curl)** — cloudflare / ifconfig.me / ipify / ip.sb
4. **外部服务 (wget)** — ifconfig.me / ip.sb 兜底
5. **`-i` 参数** — 手动指定额外 IP

## 下载源

| 资源 | 来源 |
|------|------|
| 安装脚本 | `github.com/qq48674431/sing-box` |
| 脚本包 (code.tar.gz) | `github.com/qq48674431/sing-box/releases` |
| sing-box 核心 | `github.com/qq48674431/sing-box/releases` |
| jq | `github.com/qq48674431/sing-box/releases` |

## 致谢

- [233boy/sing-box](https://github.com/233boy/sing-box) — 原版脚本
- [SagerNet/sing-box](https://github.com/SagerNet/sing-box) — sing-box 核心
