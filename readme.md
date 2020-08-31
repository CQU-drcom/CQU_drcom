# 这是一个为懒人制作的路由器drcom一键配置包
## 0.分支说明
本分支为代码主分支，一般正常使用，较为稳定。
***DEV*** 分支为测试分支，一般可使用。
两分支区别在于 ***DEV*** 提供了更多选项（包含静态地址设置），而主分支（即本分）侧重于稳定以及通常情况下的快速配置，请按需选择。

## 1.注意事项：
- 请刷入国内魔改固件或者部分论坛私有固件的同志 ***自行解决*** 出现的一切可能造成的包含：***损坏、异常使用*** 等情况。我们只保证来自 ***openwrt.org***的固件使用正常。Pandorabox、魔改版openwrt、pandavan不作任何保证可以正常使用。因此刷入以上固件的同志请保证自己具有 ***shell编程基础***
- 适用于重庆大学AB校区及虎溪校区
- 在OpenWrt<s>以及Pandorabox</s>上测试通过，请自行百度刷机方法
- 目前更推荐OpenWrt，在Pandorabox中可能会因为架构问题无法安装python，而在OpenWrt中使用[ 重庆大学开源软件镜像站](http://mirrors.cqu.edu.cn/openwrt/)作为软件源，不会出现该问题，所以请务必连接好内网
- 本配置包集成了检测网络连接的功能
- 配置包中的 `latest-wired.py` 填写账号密码，并将 `IS_TEST = False` 改为 `IS_TEST = True` 后可直接在电脑上使用

## 2.使用方法

1. 在[RELEASE](https://github.com/purefkh/CQU_drcom/releases)中下载[此配置包](https://github.com/purefkh/CQU_drcom/releases/tag/v2.2.2)，并解压

2. 使用 `winscp工具` 将 __解压后的文件夹__ 上传到路由器的 `/root/` 路径下
> Linux 下请执行：
```bash
scp CQU_drcom* -r root@192.168.1.1:/root/
```

3. 使用 `putty` 等ssh工具，登录你的路由器

4. 在 `putty` 中执行以下命令

   ``` bash
   cd
   sh setup.sh
   ```

5. 如果返回联网失败，可稍后再次检查网络连通情况
6. 享受路由器吧

## 3.进程管理

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
 亦可以在 Luci (http://192.168.1.1 一般为此机的IP) System - Startup 中找到该管理的 luci app 。通过网页控制台进行管理。

## CHANGE LOG
2020.08.31
- 修改了部分变量沿用旧变量名称的错误
- 更新了 B 区的配置文件

2020.08.29
- 修改了部分变量名称
- 修复部署 drcom 时产生的 `permission denied` 的错误

2020.05.28
- 重写网络连通性判断部分，尝试以 http code 作为核验对象以减小对服务器的负担

2019.12.25
HAPPY XMAS!
- 重写部分功能，添加所有功能为函数，在主体部分直接按照步骤调用即可
- （上面部分的原因）由于固件升级以后有关 drcom 认证的部分被覆盖掉，但是网络设置的相关没必要更改，因此主体分支更改为判断是否进行了系统升级

2019.11.22
- 修正echo行为（[@Hagb](https://github.com/hagb)）
- 调整系统信息收集功能

2019.09.18
- 替换了虎溪校区配置文件为最新版本

2019.09.16
- 修正了啓動腳本`99-drcom`中的錯誤

2019.09.14
- 修正了ESSID显示错误的问题
- 修正了WiFi开启后无SSID的问题
- 修正了部分流程
- 增加了设置静态IP的功能（意味着可用于研究生办公室以及部分实验室区域）
- 增加了base64编码方式
- 去除了冗余文件

2019.09.12
- 修复了开启WiFi电源后无E SSID的问题
 
 
## 许可证

AGPLv3

特别指出禁止任何个人或者公司将 [drcoms](http://github.com/drcoms/) 的代码投入商业使用，由此造成的后果和法律责任均与本人无关。
</br>
其中latest-wired.py来自项目[drcom-generic](https://github.com/drcoms/drcom-generic)
