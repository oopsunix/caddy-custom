#!/usr/bin/env bash
set -e

# 设置 GitHub 仓库地址
REPO="oopsunix/caddy-custom"

# 检查权限
if [ "$EUID" -ne 0 ]; then
  echo "❌ 请使用 root 权限运行此脚本 (例如: sudo ./update_caddy.sh)"
  exit 1
fi

echo "🔍 检测系统架构..."
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        CADDY_ARCH="amd64"
        ;;
    aarch64|arm64)
        CADDY_ARCH="arm64"
        ;;
    *)
        echo "❌ 不支持的系统架构: $ARCH"
        exit 1
        ;;
esac

echo "✅ 系统架构: $CADDY_ARCH"

echo "🌐 获取最新 Release 版本信息..."
LATEST_TAG=$(curl -sL "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_TAG" ]; then
    echo "❌ 无法获取最新版本信息，请检查网络或 GitHub API 限制。"
    exit 1
fi

# 移除开头的 v (如果存在)，用于拼接文件名
VERSION="${LATEST_TAG#v}"
echo "🎉 发现最新版本: v$VERSION"

FILENAME="caddy-${VERSION}-linux-${CADDY_ARCH}.tar.gz"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_TAG/$FILENAME"

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

echo "⬇️ 正在下载 Caddy v$VERSION..."
curl -sL -O "$DOWNLOAD_URL"

echo "📦 解压文件..."
tar -xzf "$FILENAME"

# 查找现有的 caddy 可执行文件路径
CADDY_BIN_PATH=$(command -v caddy || echo "/usr/bin/caddy")

echo "🔄 替换现有的 Caddy 二进制文件 ($CADDY_BIN_PATH)..."

# 备份旧版本（如果存在）
if [ -f "$CADDY_BIN_PATH" ]; then
    cp "$CADDY_BIN_PATH" "${CADDY_BIN_PATH}.bak"
    echo "💾 已备份旧版本至 ${CADDY_BIN_PATH}.bak"
fi

# 停止 Caddy 服务（如果通过 systemd 运行）
if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet caddy; then
    echo "🛑 停止 Caddy 服务..."
    systemctl stop caddy
    SERVICE_STOPPED=true
fi

# 替换二进制文件并设置权限
mv caddy "$CADDY_BIN_PATH"
chmod +x "$CADDY_BIN_PATH"

# 恢复 Caddy 服务
if [ "$SERVICE_STOPPED" = true ]; then
    echo "▶️ 重新启动 Caddy 服务..."
    systemctl start caddy
fi

# 清理临时文件
cd - >/dev/null
rm -rf "$TMP_DIR"

echo "✨ 更新完成！当前 Caddy 版本信息："
$CADDY_BIN_PATH version
$CADDY_BIN_PATH list-modules | grep -E -v "^  Standard modules:" | head -n 10
echo "✅ 您现在可以使用包含自定义插件的 Caddy 了！"
