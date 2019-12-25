# 测试用分支

## 0.即将取消对于OpenWrt以外系统的支援

## 1.注意事项：
0. 本分支相较于主分支侧重点不同，更加倾向于为用户尽可能提供更多可控制项。
1. 适用于重庆大学AB校区及虎溪校区，原则上替换配置文件以及镜像后适用于所有使用哆点认证校园网的学校。
2. 在OpenWrt以及Pandorabox上均测试通过，请自行百度刷机方法。原本为为newifi y1s单独设计，现支援openwrt后均可使用。
3. 推荐使用OpenWrt官方提供的固件，不推荐任何论坛等的魔改固件，此外Pandorabox已不被积极的开发，出现的任何问题请自行解决。在OpenWrt中使用[ 重庆大学开源软件镜像站](http://mirrors.cqu.edu.cn/openwrt/)作为软件源，所以请务必连接好内网。
4. 本配置包集成了检测网络连接的功能（目前本分支上不可用，正在积极修复）
5. 一切有关drcom-generic的问题请到[drcom-generic](https://github.com/drcom-generic)下提问。
6. 请仔细阅读提问的智慧。

## 2.使用方法

1. 下载`release`中的`DEV Release`

2. 使用 `winscp工具` 将 __解压后的文件夹__ 上传到路由器的 `/root` 路径下
> Linux 下请执行：
```bash
scp CQU_drcom* -r root@192.168.1.1:/root/
```

3. 使用 `putty` 等ssh工具，登录你的路由器

4. 在 `putty` 中执行以下命令

   ``` bash
   cd CQU_drcom
   sh setup.sh
   ```

5. 如果返回联网失败，可稍后再次检查网络连通情况

## 關於啓動腳本
位置: `/etc/init.d/drcomctl`
```sh
#stop drcom
/etc/init.d/drcomctl stop
#restart drcom
/etc/init.d/drcomctl restart
#start drcom
/etc/init.d/drcomctl start
#enable drcom at system start
/etc/init.d/drcomctl enable
```
所有有關的控制項目可至`Luci` -> `System - Startup` -> `Initscripts`尋找。
## CHANGE LOG
2019.12.25
HAPPY XMAS!
- 重写部分功能，添加所有功能为函数，在主体部分直接按照步骤调用即可
- （上面部分的原因）由于固件升级以后有关 drcom 认证的部分被覆盖掉，但是网络设置的相关没必要更改，因此主体分支更改为判断是否进行了系统升级

2019.11.22
- 修正echo行为（@Hagb）
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
其余部分除openwrt预编译包外均遵循GPLv3许可证 ，请勿用作商用。
### drcom-generic
AGPLv3

特别指出禁止任何个人或者公司将 [drcoms](http://github.com/drcoms/) 的代码投入商业使用，由此造成的后果和法律责任均与本人无关。
</br>
其中latest-wired.py来自项目[drcom-generic](https://github.com/drcoms/drcom-generic)
