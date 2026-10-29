#!/bin/sh
set -eu
[ "$(id -u)" = "0" ] || { echo "请以 root 身份运行"; exit 1; }

/etc/init.d/campus-auth stop 2>/dev/null || true
/etc/init.d/campus-auth disable 2>/dev/null || true
rm -f /etc/rc.d/S99campus-auth /etc/rc.d/K10campus-auth
rm -f /usr/bin/campus-auth
rm -f /etc/init.d/campus-auth
rm -f /usr/lib/lua/luci/controller/campus-auth.lua
rm -f /usr/lib/lua/luci/model/cbi/campus-auth.lua
rm -f /tmp/luci-indexcache
/etc/init.d/rpcd restart 2>/dev/null || true
/etc/init.d/uhttpd reload 2>/dev/null || true
echo "程序已卸载。为避免误删凭据，/etc/config/campus-auth 保留未删除。"
echo "如确认不再需要，可手动执行：rm -f /etc/config/campus-auth"
