#!/bin/bash
# cn-mirror.sh — 把系统软件源切换到中国大陆镜像(阿里云),或还原
#
# 用法:
#   sudo bash cn-mirror.sh            切换到阿里云镜像
#   sudo bash cn-mirror.sh --restore  还原切换前的源文件
#
# 支持:Debian/Ubuntu(apt,含 deb822 的 .sources 格式)、Alpine(apk)
# 切换前自动把原文件备份为 <原文件>.bak-xwpfcn(仅首次备份,不覆盖)。
# 主脚本在依赖安装时若软件源更新失败,也会询问是否调用同一套切换逻辑。

set -u

if [ "$(id -u)" -ne 0 ]; then
    echo "错误: 需要 root 权限" >&2
    exit 1
fi

APT_FILES=()
[ -f /etc/apt/sources.list ] && APT_FILES+=(/etc/apt/sources.list)
for f in /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources; do
    [ -f "$f" ] && APT_FILES+=("$f")
done

restore() {
    local restored=0 f
    for f in "${APT_FILES[@]}"; do
        if [ -f "${f}.bak-xwpfcn" ]; then
            cp -a "${f}.bak-xwpfcn" "$f"
            echo "✓ 已还原 $f"
            restored=1
        fi
    done
    if [ -f /etc/apk/repositories.bak-xwpfcn ]; then
        cp -a /etc/apk/repositories.bak-xwpfcn /etc/apk/repositories
        echo "✓ 已还原 /etc/apk/repositories"
        restored=1
    fi
    [ "$restored" = "1" ] || echo "未找到 .bak-xwpfcn 备份,无可还原文件"
}

switch_to_cn() {
    local changed=0 f
    for f in "${APT_FILES[@]}"; do
        grep -qE 'deb\.debian\.org|security\.debian\.org|archive\.ubuntu\.com|security\.ubuntu\.com|ports\.ubuntu\.com' "$f" 2>/dev/null || continue
        [ -f "${f}.bak-xwpfcn" ] || cp -a "$f" "${f}.bak-xwpfcn"
        sed -i -e 's|deb\.debian\.org|mirrors.aliyun.com|g' \
               -e 's|security\.debian\.org|mirrors.aliyun.com|g' \
               -e 's|archive\.ubuntu\.com|mirrors.aliyun.com|g' \
               -e 's|security\.ubuntu\.com|mirrors.aliyun.com|g' \
               -e 's|ports\.ubuntu\.com|mirrors.aliyun.com|g' "$f"
        echo "✓ 已切换 $f 到阿里云镜像"
        changed=1
    done
    if [ -f /etc/apk/repositories ] && grep -q 'dl-cdn.alpinelinux.org' /etc/apk/repositories 2>/dev/null; then
        [ -f /etc/apk/repositories.bak-xwpfcn ] || cp -a /etc/apk/repositories /etc/apk/repositories.bak-xwpfcn
        sed -i 's|dl-cdn.alpinelinux.org|mirrors.aliyun.com|g' /etc/apk/repositories
        echo "✓ 已切换 /etc/apk/repositories 到阿里云镜像"
        changed=1
    fi
    if [ "$changed" != "1" ]; then
        echo "未找到可切换的海外官方源(可能已是国内源,或发行版暂不支持)"
        return 1
    fi
    echo "正在刷新软件源缓存..."
    if command -v apt-get >/dev/null 2>&1; then
        apt-get update
    elif command -v apk >/dev/null 2>&1; then
        apk update
    fi
}

case "${1:-}" in
    --restore) restore ;;
    "") switch_to_cn ;;
    *) echo "用法: sudo bash cn-mirror.sh [--restore]" >&2; exit 1 ;;
esac
