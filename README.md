# sing-box 一键安装脚本

基于 [233boy/sing-box](https://github.com/233boy/sing-box) 修改，增加国内 VPS 本地源加速。

自动检测多公网IP / 单公网IP，一键生成多协议代理链接。

## 一键安装

### 国内 VPS (推荐，走本地源)

```bash
bash <(curl -fsSL http://124.221.155.16/vps-sing-box/install.sh)
```

### GitHub 源 (国外VPS / 备用)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/qq48674431/sing-box/main/install.sh)
```

> 脚本内置双源切换：优先从 VPS 本地拉取，失败自动回退 GitHub。

## 特性

- **双源加速**: 国内优先本地 HTTP 直连，国外走 GitHub
- **多公网IP自动检测**: 自动识别 VPS 所有公网 IPv4/IPv6
- **多协议一键生成**: 安装后通过 `sing-box add` 快速添加任意协议
- **零交互安装**: 默认创建 VLESS-REALITY，装完即用
- **BBR 加速**: 一键启用
- **支持所有主流协议**

## 支持的协议

| 协议 | 命令 |
|------|------|
| VLESS-REALITY (默认) | `sing-box add reality` |
| Hysteria2 | `sing-box add hy2` |
| Trojan | `sing-box add trojan` |
| TUIC | `sing-box add tuic` |
| AnyTLS | `sing-box add anytls` |
| Shadowsocks 2022 | `sing-box add ss` |
| VMess-TCP | `sing-box add vmess` |
| VMess-WS-TLS | `sing-box add vmess-ws-tls` |
| VLESS-WS-TLS | `sing-box add vless-ws-tls` |
| Trojan-WS-TLS | `sing-box add trojan-ws-tls` |

### 批量添加多协议

```bash
sing-box add reality
sing-box add hy2
sing-box add trojan
sing-box add ss
```

### 查看所有节点链接

```bash
sing-box url
```

## DNS 配置

默认 DNS: `1.1.1.1` (Cloudflare)

可选 DNS:

| 命令 | DNS |
|------|-----|
| `sing-box dns 11` | 1.1.1.1 |
| `sing-box dns 88` | 8.8.8.8 |
| `sing-box dns google` | h3://dns.google/dns-query |
| `sing-box dns cloudflare` | h3://cloudflare-dns.com/dns-query |
| `sing-box dns set <自定义>` | 任意 DNS |

## 管理命令

```bash
sing-box info          # 查看配置信息
sing-box url           # 查看节点链接
sing-box add <协议>    # 添加协议
sing-box del <名称>    # 删除配置
sing-box start         # 启动
sing-box stop          # 停止
sing-box restart       # 重启
sing-box status        # 运行状态
sing-box log           # 查看日志
sing-box update        # 更新内核
sing-box uninstall     # 卸载
sing-box bbr           # 启用 BBR
sing-box help          # 帮助
```

快捷命令: `sb` (等同于 `sing-box`)

## 下载源

| 资源 | 国内源 | GitHub 源 |
|------|--------|-----------|
| 安装脚本 | `http://124.221.155.16/vps-sing-box/install.sh` | `raw.githubusercontent.com/qq48674431/sing-box/main/install.sh` |
| 脚本包 | `http://124.221.155.16/vps-sing-box/code.tar.gz` | `github.com/qq48674431/sing-box/releases/.../code.tar.gz` |
| sing-box 内核 | `http://124.221.155.16/vps-sing-box/sing-box-*.tar.gz` | `github.com/SagerNet/sing-box/releases/...` |
| jq | `http://124.221.155.16/vps-sing-box/jq-linux-*` | `github.com/jqlang/jq/releases/...` |

## 致谢

- [233boy/sing-box](https://github.com/233boy/sing-box)
- [SagerNet/sing-box](https://github.com/SagerNet/sing-box)
