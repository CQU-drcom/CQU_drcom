* [Lenovo newifi y1 mini](#lenovo-newifi-y1-mini)
* [Lenovo newifi y1s](#lenovo-newifi-y1s)
* [Lenovo newifi 3 / newifi D2](#lenovo-newifi-3)
* [Lenovo D328](#lenovo-d328)

# Lenovo newifi y1 mini
## 固件选择
### OpenWrt
机型主页：https://openwrt.org/toh/hwdata/lenovo/lenovo_newifi_mini_y1</br>
最新稳定版本：18.06.5（无法再通过 download.openwrt.org 下载）</br>
其他版本： SNAPSHOT
### PandoraBox
## 配置指南
1. 由于目前可通过官方途径获取的仅有快照（SNAPSHOT）版本，因此推荐直接由 uboot 刷入。
2. 快照版本默认无 Luci ，因此需要首先登入控制台，更换仓库地址并刷新缓存，并安装 Luci，换源参考：[Openwrt 仓库使用帮助](https://mirrors.cqu.edu.cn/wiki/mirror-wiki/openwrt/)，安装 Luci 请执行如下指令：
```bash
opkg install luci
```
3. 由于正常途径下快照版本无法配置 Python2 ，因此需要再次更换仓库地址用来配置 Python2。关于使用 Micropython 作为解释器来运行 Drcom 的方法将在最后给出。
下面给出更换仓库地址的方法：
  1. 编辑 `/etc/opkg/distfeeds.conf`
  2. 将结尾为 `base` 和 `packages` 的行更换为：
  ```bash
  src/gz openwrt_base http://mirrors.cqu.edu.cn/openwrt/releases/19.07.3/packages/mipsel_24kc/base
  src/gz openwrt_packages http://mirrors.cqu.edu.cn/openwrt/releases/19.07.3/packages/mipsel_24kc/packages
  ```
  3. 执行：
  ```bash
  opkg update
  ```

4. 参照正常方法放入配置脚本文件即可

# Lenovo newifi y1s
## 固件选择
### OpenWrt
机型主页：https://openwrt.org/toh/hwdata/lenovo/lenovo_newifi_y1s</br>
最新稳定版本：19.07.3</br>
其他版本：SNAPSHOT
## 配置指南
1. uboot 直接输入固件，后期可直接在 Luci 刷入新固件（必须为 OpenWrt）
2. 将脚本文件放入存储，控制台直接运行脚本即可
3. 脚本是在此机型进行测试的，最初专门为此机型编写，所以通常情况下不可能存在运行错误，如果运行错误请检查固件以及网络连接等是否正常。

# Lenovo newifi 3
## 固件选择
### OpenWrt
机型主页：https://openwrt.org/toh/hwdata/d-team/d-team_newifi_d2</br>
最新稳定版本：19.07.3</br>
其他版本：SNAPSHOT</br>
## 配置指南
1. uboot 直接输入固件，后期可直接在 Luci 刷入新固件（必须为 OpenWrt）
2. 将脚本文件放入存储，控制台直接运行脚本即可

# Lenovo D328
## 机型说明
1. 此机型为联想出品的工控机，主要用于工业机械控制或者交易所等对配置要求并不高的场景
2. 这台机器个人买来加以修改作为 NAS 使用
3. 解构为 x86 因此可玩性最好，但是难度也最高，成本最高

## 配置说明
1. 默认你知道如何安装 Ubuntu Server 等
2. 修改仓库地址为[重庆大学开源软件镜像站](https://mirrors.cqu.edu.cn/wiki/mirror-wiki/ubuntu/#通用版本)
3. 更新源，并安装 Python
4. 参照 drcom-generic 项目配置 drcom
5. 直接运行即可
