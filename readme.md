### 这是一个为懒人制作的路由器drcom一键配置包

#### 1.注意事项：

- 适用于重庆大学AB校区及虎溪校区
- 仅在Pandora Box上测试通过，请自行百度刷机方法
- 本配置包集成了检测网络连接的功能

#### 2.使用方法

1. [下载此配置包](https://github.com/purefkh/CQU_drcom/releases/)，并解压

2. 使用 `scp工具` 将 __解压后的文件夹__ 上传到路由器的 `/tmp/` 路径下

3. 使用 `putty` 等ssh工具，登录你的路由器

4. 在 `putty` 中执行以下命令

   ``` bash
   cd /tmp/CQU_drcom
   sh setup.sh
   ```

5. 享受路由器吧
