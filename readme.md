# 这是一个为懒人制作的路由器drcom一键配置包

## 1.注意事项：

- 适用于重庆大学AB校区及虎溪校区
- 在OpenWrt以及Pandorabox上测试通过，请自行百度刷机方法
- 目前更推荐OpenWrt，在Pandorabox中可能会因为架构问题无法安装python，而在OpenWrt中使用[ 重庆大学开源软件镜像站](http://mirrors.cqu.edu.cn/openwrt/)作为软件源，不会出现该问题，所以请务必连接好内网
- 本配置包集成了检测网络连接的功能
- 配置包中的 `latest-wired.py` 填写账号密码，并将 `IS_TEST = False` 改为 `IS_TEST = True` 后可直接在电脑上使用

## 2.使用方法

1. 下载此配置包，并解压

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
