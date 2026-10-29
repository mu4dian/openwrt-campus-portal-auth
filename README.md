# OpenWrt Campus Portal Auth

适配目标：GL-BE3600；已有 `sta0 -> wwan` 上游；常州大学 CMCC Portal。

## 已知认证协议

- Portal 页面入口示例：`http://211.103.11.101:1028/a79.htm`
- 登录请求：`GET http://211.103.11.101:801/eportal/`
- 参数：`c=Portal`、`a=login`、`callback=dr...`、`login_method=1`
- `user_account` 格式为 `,b,<账号>`
- `user_password` 为密码
- `wlan_user_ip` 动态读取 `network.interface.wwan` 的 IPv4 地址，失败时尝试 `sta0`
- `wlan_user_mac` 默认沿用抓包中的 `000000000000`
- `wlan_ac_ip` 默认空
- `wlan_ac_name` 默认 `0011.0519.250.00`
- `jsVersion=3.0`
- 认证成功响应示例中 `result` 为 `"1"`

## 安装

1. 将压缩包上传到路由器，例如 `/tmp/campus-auth-openwrt.tar.gz`。
2. SSH 登录路由器并执行：

   ```sh
   cd /tmp
   tar -xzf campus-auth-openwrt.tar.gz
   cd campus-auth-openwrt
   sh install.sh
   ```

3. 如果安装提示缺少 curl：
   - opkg 系统：`opkg update && opkg install curl`
   - apk 系统：`apk update && apk add curl`
   - 再执行 `sh install.sh`

4. 在 LuCI 打开 **服务 → 校园网自动认证**。
5. 在本地填写账号和密码，先保存但不要开启自动认证。
6. 点击 **立即认证**，随后用“当前检测结果”和“最近日志”检查结果。
7. 确认手动认证成功后，再勾选“启用自动认证”。

## 命令行

```sh
/usr/bin/campus-auth status
/usr/bin/campus-auth login
logread -e campus-auth
```

## 自动检测逻辑

- 默认每 60 秒检查一次 `http://connectivitycheck.gstatic.com/generate_204`。
- 只有返回 HTTP 204 才视为互联网可用；否则尝试 Portal 认证。
- 成功后不记录账号、密码、Cookie、Token 或完整请求/响应。
- 认证服务由 procd 管理，开机启动。
- 当前版本不更改 Wi-Fi、`wwan`、防火墙、OpenClash 或 Travelmate 配置。

## 安全说明

- 安装包中不包含账号和密码。
- LuCI 配置文件 `/etc/config/campus-auth` 安装后设置为权限 600。
- 认证请求临时文件在 `/tmp` 下以权限 600 创建，并在请求结束后删除。
- Portal 本身使用 HTTP，因此认证请求并非 TLS 加密；请只在可信校园网络中使用。
- 请勿提交填写过凭据的配置文件、抓包、日志或路由器备份。

## 已知限制与排错

- 原开发会话中用户反馈认证成功；本次整理未重新执行路由器实机测试。
- LuCI 页面使用传统 Lua CBI，需要固件具备相应兼容支持。
- 若状态页持续显示认证失败，执行 `logread -e campus-auth`，只分享脱敏后的错误，不要分享配置文件或原始请求。
- 若认证成功但联网检测一直失败，可能是探测地址被拦截、上游网络不允许该探测地址，或 Portal 已认证但仍有限制。可在 LuCI 中改成一个你确认正常联网时返回 HTTP 204 的检测地址。
- 如果学校后端要求真实客户端 MAC，而非抓包中的 `000000000000`，需要通过进一步抓包确认后再调整。
- 卸载时运行 `sh uninstall.sh`；配置文件默认保留，避免误删本地凭据。
