# 这是一个为懒人制作的路由器drcom一键配置包

## 1.注意事项：

- 适用于重庆大学AB校区及虎溪校区
- 仅在Pandora Box上测试通过，请自行百度刷机方法
- 本配置包集成了检测网络连接的功能
- 配置包中的 `latest-wired_ab.py` 和 `latest-wired_d.py` 填写账号密码，并将 `IS_TEST = False` 改为 `IS_TEST = True` 后可直接在电脑上使用

## 2.使用方法

1. [下载此配置包](https://github.com/purefkh/CQU_drcom/archive/master.zip)，并解压

2. 使用 `scp工具` 将 __解压后的文件夹__ 上传到路由器的 `/tmp/` 路径下

3. 使用 `putty` 等ssh工具，登录你的路由器

4. 在 `putty` 中执行以下命令

   ``` bash
   cd /tmp/CQU_drcom
   sh setup.sh
   ```

5. 如果返回联网失败，可稍后再次检查网络连通情况；若连接成功，执行 `rm -r /tmp/setup/` 删除此配置程序

6. 享受路由器吧

## 许可证

AGPLv3

特别指出禁止任何个人或者公司将 [drcoms](http://github.com/drcoms/) 的代码投入商业使用，由此造成的后果和法律责任均与本人无关。 
</br>
其中latest-wired.py来自项目[drcom-generic](https://github.com/drcoms/drcom-generic)

