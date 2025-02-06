# rclone-mount
适用于Linux: rclone挂载到本地指定目录下，使用systemctl管理挂载与卸载

## 1、前置rclone配置
[添加一个云盘产品-OneDrive](https://github.com/My-Search/rclone-mount/blob/master/README.md)

## 2、挂载管理工具
将添加的云产品挂载到本地目录
```bash
# 注意前置条件是已经`rclone config`
bash -c "$(curl -sSL https://raw.githubusercontent.com/My-Search/rclone-mount/refs/heads/master/rclone-mount-setup.sh)"
```

管理说明
```bash
systemctl enable rclone-mount.service
# 挂载，挂载位置在执行脚本安装时已指定
systemctl stop rclone-mount.service
# 卸载挂载
systemctl start rclone-mount.service
```
