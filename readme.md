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

1. 在[RELEASE](https://github.com/purefkh/CQU_drcom/releases)中下载[此配置包](https://github.com/purefkh/CQU_drcom/archive/v1.1.zip)，并解压

2. 使用 `winscp工具` 将 __解压后的文件夹__ 上传到路由器的 `/tmp/` 路径下
> Linux 下请执行：
```bash
scp CQU_drcom* -r root@192.168.1.1:/root/
```

3. 使用 `putty` 等ssh工具，登录你的路由器

4. 在 `putty` 中执行以下命令

   ``` bash
   cd /tmp/CQU_drcom
   sh setup.sh
   ```

5. 如果返回联网失败，可稍后再次检查网络连通情况
6. 享受路由器吧

## 许可证

AGPLv3

特别指出禁止任何个人或者公司将 [drcoms](http://github.com/drcoms/) 的代码投入商业使用，由此造成的后果和法律责任均与本人无关。
</br>
其中latest-wired.py来自项目[drcom-generic](https://github.com/drcoms/drcom-generic)
