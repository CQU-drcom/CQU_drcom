# 这是一个为懒人制作的路由器drcom一键配置包
## 分支说明
本脚本主要分为以下两个分支：
- master: 相对更加稳定的分支
- dev: 开发用分支，用来测试一些新的功能和实现

通常情况下请使用主分支即 master 分支的代码，在 release 部分为 stable release 。这部分代码通常经过了多次试验确保在一般情况下能够正常使用。

## 使用事项
请先查阅 **针对此项目的说明** 部分。</br>

通过 [GITHUB release](https://github.com/purefkh/CQU_drcom/releases) 下载当前的 **稳定版本** 进行使用。通常稳定版本会带有 Stable Release 字样。并上传至路由器存储进行使用。
需要准备的工具:

|操作系统|需要的工具或工具集|
|:--|---|
| Windows | Winscp 及 putty 或 XShell |
| OS X / Mac OS |默认终端（确保具有 openssh )|
| Linux 或 FreeBSD 等|默认终端模拟器（确保安装了 openssh ）|

具体使用方法如下：
1. 在[RELEASE](https://github.com/purefkh/CQU_drcom/releases)中下载[此配置包](https://github.com/CQU-drcom/CQU_drcom/archive/refs/tags/v2.3.3b.zip)，并解压
2. 将配置包上传至路由器空间：
 - Windows：使用 Winscp 工具登录路由器并将 `setup.sh` 和 `latest-wired.py` 拖入文件夹 `/root/`
 - 配置了 openssh-beta 的 Windows 或者 Mac OS 以及 Linux：
  ```bash
  # 默认你已经知道如何切换到解压后的目录
  scp latest-wired.py setup.sh USERNAME@IP:PORT:/PATH_TO_FILE/.
  ```
  一般情况下我们需要执行如下指令：
  ```bash
  scp latest-wired.py setup.sh root@192.168.1.1:/root/.
  ```
3. 使用任意终端工具登入路由器，并执行以下指令：
```bash
sh setup.sh
```
4. 设置其他信息并完成设置

## [其他帮助信息](https://github.com/purefkh/CQU_drcom/tree/master/DOCS/DOCS.md)

## 针对此项目的说明
- 这个配置包理论上适用于任何具有内网镜像站并且收录了 OpenWrt 并通过 drcom 进行认证登录的校园网环境路由器软件配置
- 默认情况下此配置包包含了校内三种认证设置的配置
- 仅仅在 OpenWrt 上测试通过，如果很不幸你的路由器只能刷入 PandoraBox ，也请不要着急：请参照 drcom-generic 项目获取配置文件并放入相应位置，只需要设置好自启动仍然可以享受路由器。详细内容请参照：[此帮助文件](https://github.com/purefkh/CQU_drcom/tree/master/DOCS/TESTED.md)
- 由于使用了重庆大学开源软件镜像站：https://mirrors.cqu.edu.cn 作为访问 OpenWrt 仓库的媒介，因此请务必确认好网络已连接上

## **特殊说明**
1. 此脚本存在网路连接的不确定性：即因为需要检测网络连通情况所以需要 ping 一下内网中某服务器，但是由于内网的不确定性目前不能保证每次都成功
2. 学校更新了配置文件：请重新抓包，或等待我们将新配置文件上传

## 静默安装
本脚本支持静默安装，请参照 `config.ini.example` 创建文件 `config.ini` 并填入必要信息。说明如下：
```bash
campus= #校区，可选值为 a,b,d
username= #用户名
password= #密码
wifi_ssid0= #多频段下 SSID 名称，缺省为 openwrt
wifi_ssid1= #多频段下 SSID 名称，缺省为 openwrt_5Ghz
client= #客户端选择，无缺省值，可选项为 python2,micropy
wifi_password0= #多频段下 WLAN 密码，缺省为空
wifi_password1= #多频段下 WLAN 密码，缺省为空
set_cron= #crontab 设置，缺省为 no, 可选值为 yes,no
```
使用 `sh setup.sh -h` 查看帮助内容，使用 `-f` 选择配置文件。


## F&Q
- - Q: 为什么我无法连接重大开源镜像站？（请检测网络连通性）
  - A: 请检查网线、网络端口是否正常。如正常请考虑你是否处在办公区域，这些区域需要使用分配的网络配置进行初步的联网
- - Q: 为什么最后网络检查失败但实际网络已经连接上？
  - A: 通常通过脚本进行拨号有一定时延，就算我们努力的将挺多时间拉长到更久仍可能出现此问题。如果确认网络已经连接上，请无视这个错误。

## 已测试的设备及说明：
[帮助文件](https://github.com/purefkh/CQU_drcom/tree/master/DOCS/TESTED.md)

## [CHANGE LOG](https://github.com/purefkh/CQU_drcom/tree/master/CHANGELOG/changelog.md)

## 许可证

AGPLv3

特别指出禁止任何个人或者公司将 [drcoms](http://github.com/drcoms/) 的代码投入商业使用，由此造成的后果和法律责任均与本人无关。
</br>
其中latest-wired.py来自项目[drcom-generic](https://github.com/drcoms/drcom-generic)
