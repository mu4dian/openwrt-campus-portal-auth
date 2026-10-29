local sys = require "luci.sys"
local util = require "luci.util"

local m = Map("campus-auth", translate("校园网自动认证"),
    translate("适用于常州大学 CMCC Portal。账号密码只保存在本路由器的本地配置中；请勿分享配置文件。"))

local s = m:section(NamedSection, "main", "campus-auth", translate("认证设置"))
s.addremove = false

local enabled = s:option(Flag, "enabled", translate("启用自动认证"))
enabled.rmempty = false
enabled.default = "0"
enabled.description = translate("启用后会定期检测互联网；检测失败时尝试 Portal 认证。")

local username = s:option(Value, "username", translate("手机号 / 账号"))
username.rmempty = false
username.datatype = "string"

local password = s:option(Value, "password", translate("校园网密码"))
password.password = true
password.rmempty = false
password.datatype = "string"
password.description = translate("请在路由器本地输入；不要把密码发到聊天或日志中。")

local interval = s:option(Value, "interval", translate("检测间隔（秒）"))
interval.datatype = "range(30,3600)"
interval.default = "60"
interval.rmempty = false

local portal = s:option(Value, "portal_url", translate("Portal 登录接口"))
portal.default = "http://211.103.11.101:801/eportal/"
portal.rmempty = false

local probe = s:option(Value, "probe_url", translate("联网检测地址"))
probe.default = "http://connectivitycheck.gstatic.com/generate_204"
probe.rmempty = false
probe.description = translate("正常联网时应返回 HTTP 204；如你的网络拦截该地址，可调整为可返回 204 的检测地址。")

local ac = s:option(Value, "wlan_ac_name", translate("无线控制器名称（wlan_ac_name）"))
ac.default = "0011.0519.250.00"
ac.rmempty = false

local acip = s:option(Value, "wlan_ac_ip", translate("无线控制器 IP（wlan_ac_ip）"))
acip.default = ""
acip.rmempty = true

local mac = s:option(Value, "wlan_user_mac", translate("客户端 MAC 参数"))
mac.default = "000000000000"
mac.rmempty = false
mac.description = translate("当前抓包显示此参数为 000000000000，因此默认沿用；若学校认证要求真实 MAC，再修改。")

local login = s:option(Button, "_login", translate("立即认证"))
login.inputtitle = translate("立即认证")
login.inputstyle = "apply"
login.write = function(self, section)
    sys.call("/usr/bin/campus-auth login >/dev/null 2>&1")
end

local status = s:option(DummyValue, "_status", translate("当前检测结果"))
status.rawhtml = false
status.cfgvalue = function(self, section)
    local out = sys.exec("/usr/bin/campus-auth status 2>/dev/null")
    return out ~= "" and out or translate("暂无状态")
end

local logs = s:option(DummyValue, "_logs", translate("最近日志"))
logs.rawhtml = true
logs.cfgvalue = function(self, section)
    local out = sys.exec("logread -e campus-auth 2>/dev/null | tail -n 8")
    if out == "" then
        out = translate("暂无日志；启用服务后会在这里显示运行记录。")
    end
    return "<pre style='white-space:pre-wrap;max-height:15em;overflow:auto'>" .. util.pcdata(out) .. "</pre>"
end

return m
