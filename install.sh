#!/bin/sh
set -eu

[ "$(id -u)" = "0" ] || { echo "请以 root 身份运行：sh install.sh"; exit 1; }

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
command -v uci >/dev/null 2>&1 || { echo "未检测到 UCI；这不是标准 OpenWrt/iStoreOS 环境。"; exit 1; }
command -v ubus >/dev/null 2>&1 || { echo "未检测到 ubus。"; exit 1; }
if ! command -v curl >/dev/null 2>&1; then
    echo "缺少 curl。请先安装 curl 包，再重新运行安装程序。"
    echo "OpenWrt/opkg: opkg update && opkg install curl"
    echo "使用 apk 的系统: apk update && apk add curl"
    exit 1
fi

mkdir -p /usr/bin /etc/init.d /usr/lib/lua/luci/controller /usr/lib/lua/luci/model/cbi
cp "$ROOT/usr/bin/campus-auth" /usr/bin/campus-auth
cp "$ROOT/etc/init.d/campus-auth" /etc/init.d/campus-auth
cp "$ROOT/usr/lib/lua/luci/controller/campus-auth.lua" /usr/lib/lua/luci/controller/campus-auth.lua
cp "$ROOT/usr/lib/lua/luci/model/cbi/campus-auth.lua" /usr/lib/lua/luci/model/cbi/campus-auth.lua
chmod 755 /usr/bin/campus-auth /etc/init.d/campus-auth
chmod 644 /usr/lib/lua/luci/controller/campus-auth.lua /usr/lib/lua/luci/model/cbi/campus-auth.lua

if [ ! -f /etc/config/campus-auth ]; then
    cp "$ROOT/etc/config/campus-auth" /etc/config/campus-auth
fi
chmod 600 /etc/config/campus-auth

/etc/init.d/campus-auth enable
/etc/init.d/campus-auth restart 2>/dev/null || /etc/init.d/campus-auth start

rm -f /tmp/luci-indexcache
/etc/init.d/rpcd restart 2>/dev/null || true
/etc/init.d/uhttpd reload 2>/dev/null || true

echo
echo "安装完成。"
echo "打开 LuCI：服务 -> 校园网自动认证"
echo "在页面本地填写账号和密码，先保持“启用自动认证”关闭，保存后点“立即认证”测试。"
echo "测试成功后再启用自动认证。"
echo "CLI 状态：/usr/bin/campus-auth status"
echo "日志：logread -e campus-auth"
echo "注意：安装包不包含任何账号或密码。"
