# 进阶内容说明
## 命令行选项
```bash
-V, --dry-run   Run the script without installation.
-h, --help  Show help message.
```
## 进程管理

由于 OpenWrt 下 busybox 与一般 Linux 控制台没有太多差距，因此可以参照一般 Linux 控制台的使用方法去使用。 </br>
drcom 自启动服务位于 `/etc/init.d/drcomctl`
 ```bash
 # 启动服务
 /etc/init.d/drcomctl start
 # 关闭服务
 /etc/init.d/drcomctl stop
 # 重启服务
 /etc/init.d/drcomctl restart
 # 设置自动启动
 /etc/init.d/drcomctl enable
 ```
 也可以在 Luci (http://192.168.1.1 一般为此机的IP) System - Startup 中找到该管理的 luci app 。通过网页控制台进行管理。

 ## python 脚本测试

 由于 latest-wired.py 本身取自 drcom-generic 项目，因此配置包中的 `latest-wired.py` 将 `IS_TEST = False` 改为 `IS_TEST = True` 后可直接进行测试。
