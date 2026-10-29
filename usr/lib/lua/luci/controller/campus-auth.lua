module("luci.controller.campus-auth", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/campus-auth") then
        return
    end
    entry({"admin", "services", "campus-auth"}, cbi("campus-auth"), _("校园网自动认证"), 91).dependent = false
end
