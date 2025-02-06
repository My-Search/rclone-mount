#!/bin/bash

# 服务名
service_name="rclone-mount.service"
service_file="/etc/systemd/system/$service_name"

# 检查 systemd 是否已存在该服务
if systemctl list-units --type=service | grep -q "$service_name"; then
    echo "检测到 $service_name 服务已存在。"
    read -p "您想卸载该服务还是继续安装新服务？（卸载请输入 u，安装请输入 i）： " action
    if [[ "$action" == "u" ]]; then
        # 停止并删除服务
        echo "正在停止并删除服务：$service_name"
        sudo systemctl stop $service_name
        sudo systemctl disable $service_name
        sudo rm -f $service_file
        echo "服务已卸载。"
        exit 0
    elif [[ "$action" == "i" ]]; then
        echo "继续安装服务..."
    else
        echo "无效输入，退出。"
        exit 1
    fi
else
    echo "未检测到 $service_name 服务，直接进入安装流程。"
    action="i"
fi

# 只有在选择安装时才要求输入参数
if [[ "$action" == "i" ]]; then
    # 提示用户输入变量
    read -p "请输入 rclone 配置的远程名称（例如 OneDrive）: " remote_name
    read -p "请输入远程目录路径（例如 /RN-data）: " remote_path
    read -p "请输入本地挂载点路径（例如 /local/mount/OneDrive）: " local_mount

    # 检查本地挂载点目录是否存在，如果不存在则创建
    if [ ! -d "$local_mount" ]; then
        echo "本地挂载点目录不存在，正在创建：$local_mount"
        mkdir -p "$local_mount"
    fi

    # 创建 systemd 服务文件
    echo "正在创建 systemd 服务文件：$service_file"
    cat <<EOF | sudo tee $service_file
[Unit]
Description=Rclone Mount for $remote_name:$remote_path
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/bin/rclone mount ${remote_name}:${remote_path} ${local_mount} \\
    --vfs-cache-mode full
ExecStop=/bin/fusermount -qzu ${local_mount}
Restart=on-failure
User=$USER
Group=$(id -gn $USER)

[Install]
WantedBy=multi-user.target
EOF

    # 重新加载 systemd 配置
    echo "重新加载 systemd 配置..."
    sudo systemctl daemon-reload

    # 启用并启动服务
    echo "启用并启动 rclone-onedrive 服务..."
    sudo systemctl enable $service_name
    sudo systemctl start $service_name

    echo "服务已安装并启动。"
fi
