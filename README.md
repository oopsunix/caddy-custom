# 🚀 Caddy Custom Builder

[![Build Binary](https://github.com/oopsunix/caddy-custom/actions/workflows/build.yaml/badge.svg)](https://github.com/oopsunix/caddy-custom/actions/workflows/build.yaml)
[![Build Docker](https://github.com/oopsunix/caddy-custom/actions/workflows/docker.yaml/badge.svg)](https://github.com/oopsunix/caddy-custom/actions/workflows/docker.yaml)

这是一个基于 GitHub Actions 的自动化构建项目，旨在定期追踪 [Caddy Server](https://github.com/caddyserver/caddy) 的官方发布，并自动编译集成常用第三方插件的自定义版本。

## 🌟 项目特性

- **自动追踪更新**：每月自动检查 Caddy 官方最新 Release 标签，确保始终基于最新稳定版构建。
- **多架构支持**：原生编译并提供适用于 `linux/amd64` 和 `linux/arm64` 架构的产物。
- **插件动态集成**：通过 `plugins.list` 集中管理插件，构建过程自动解析并注入。
- **全自动分发**：
  - **GitHub Release**: 提供编译好的 `.tar.gz` 压缩包及对应的 `sha256` 校验文件。
  - **Docker Image**: 自动构建多架构镜像并推送到 **Docker Hub** 与 **GitHub Container Registry (GHCR)**。

## 📦 已集成插件

当前版本已预装以下增强插件（详见 [plugins.list](./plugins.list)）：
- `cgi`: 运行 CGI 脚本支持。
- `webdav`: 完整的 WebDAV 读写支持。
- `cloudflare`: 自动完成 Cloudflare DNS-01 挑战（用于通配符证书）。
- `alidns`: 自动完成阿里云 DNS-01 挑战（用于国内环境）。
- `layer4`: 四层（TCP/UDP）代理与过滤支持。

## 🚀 快速开始

### 1. 使用二进制 Release (推荐用于原生部署)

#### 自动一键安装/更新 (推荐)
如果您已经通过[官方包管理器](https://caddyserver.com/docs/install#debian-ubuntu-raspbian)安装了原版 Caddy，可以使用本项目提供的一键脚本，它会自动下载最新版、停止服务、备份并替换原版二进制文件：
```bash
curl -sL https://raw.githubusercontent.com/oopsunix/caddy-custom/main/update_caddy.sh | sudo bash
```

#### 手动下载与部署
您可以从 [Releases](https://github.com/oopsunix/caddy-custom/releases) 页面获取最新的编译产物：

1. **下载**: 选择对应架构的包（如 `caddy-2.x.x-linux-amd64.tar.gz`）。
2. **校验**:
   ```bash
   sha256sum -c caddy-2.x.x-linux-amd64.tar.gz.sha256
   ```
3. **解压与替换**:
   ```bash
   tar -zxvf caddy-2.x.x-linux-amd64.tar.gz
   sudo systemctl stop caddy # 如果服务正在运行
   sudo mv caddy /usr/bin/caddy
   sudo chmod +x /usr/bin/caddy
   sudo systemctl start caddy
   ```
4. **验证**:
   ```bash
   caddy version
   caddy list-modules # 查看已集成的插件
   ```

### 2. 使用 Docker 镜像 (推荐用于容器化部署)
可以直接拉取已构建好的多架构镜像：
```bash
# Docker Hub
docker pull oopsunix/caddy:latest

# GHCR
docker pull ghcr.io/oopsunix/caddy:latest
```

## 🛠️ 工作流详情

| 工作流 | 触发频率 | 产出物内容 |
| :--- | :--- | :--- |
| **Build Binary** | 每月1号 10:00 (CST) | 独立的 amd64/arm64 压缩包 + SHA256 校验和 |
| **Build Docker** | 每月1号 10:30 (CST) | 多架构 Docker 镜像 (Manifest List) |

## 📄 开源协议
本项目基于 [Apache License 2.0](./LICENSE) 协议开源。Caddy 核心及集成插件遵循其各自的开源协议。

---

> [!TIP]
> 如果这个项目对您有所帮助，欢迎点个 **Star** 🌟 鼓励一下！
