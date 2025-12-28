#!/bin/bash

# ==========================================
# Rclone 多挂载点管理助手 v3.2 (终极版)
# 功能：安装、管理多个 Rclone 挂载服务
# 更新：新增“彻底卸载”功能（先清理所有挂载，再删除脚本）
# ==========================================

# 定义服务文件的前缀
SERVICE_PREFIX="rclone-mount-"
# 定义全局命令名称
GLOBAL_CMD_NAME="rclone-mount"
# 定义安装路径
INSTALL_PATH="/usr/local/bin/$GLOBAL_CMD_NAME"

# 获取当前非 root 用户（如果在 sudo 下运行）
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
else
    REAL_USER="$USER"
fi
REAL_GROUP=$(id -gn "$REAL_USER")

# 检查 fuse3
check_fuse() {
    if ! command -v fusermount3 > /dev/null 2>&1; then
        echo "检测到未安装 fuse3，正在尝试自动安装..."
        if command -v apt > /dev/null 2>&1; then
            sudo apt update && sudo apt install -y fuse3
        elif command -v yum > /dev/null 2>&1; then
            sudo yum install -y fuse3
        elif command -v dnf > /dev/null 2>&1; then
            sudo dnf install -y fuse3
        else
            echo "无法识别包管理器，请手动安装 fuse3。"
        fi
    fi
}

# --- 核心功能：安装新挂载 ---
install_mount() {
    echo "----------------------------------------"
    echo "即将创建一个新的 Rclone 挂载服务。"
    echo "----------------------------------------"

    # 1. 获取 Rclone 配置名称
    while true; do
        echo "提示：请输入 rclone config 中显示的名称 (例如 OneDrive)"
        read -p "1. 请输入 Rclone 远程配置名称: " remote_name
        
        remote_name=$(echo "$remote_name" | xargs)

        if [[ "$remote_name" =~ ^[a-zA-Z0-9._-]+$ ]]; then
            mount_tag="$remote_name"
            service_name="${SERVICE_PREFIX}${mount_tag}.service"
            service_file="/etc/systemd/system/$service_name"
            
            if [ -f "$service_file" ]; then
                echo "错误：服务 '$service_name' 已存在！" 
            else
                break
            fi
        else
            echo "错误：配置名称包含不支持的字符。"
        fi
    done

    # 2. 获取路径信息
    read -p "2. 请输入远程目录路径 (默认 /，直接回车即可): " remote_path
    [ -z "$remote_path" ] && remote_path="/" 
    
    default_mount_point="/home/$REAL_USER/Mount/$remote_name"
    read -p "3. 请输入本地挂载路径 (默认 $default_mount_point): " local_mount
    [ -z "$local_mount" ] && local_mount="$default_mount_point"

    # 3. 准备环境
    check_fuse
    if [ ! -d "$local_mount" ]; then
        echo "本地目录不存在，正在创建: $local_mount"
        mkdir -p "$local_mount"
        chown "$REAL_USER:$REAL_GROUP" "$local_mount"
    fi

    # 4. 获取 rclone 路径
    rclone_bin=$(command -v rclone)
    if [ -z "$rclone_bin" ]; then
        echo "错误：未找到 rclone，请先安装 rclone。"
        exit 1
    fi

    # 5. 生成 systemd 服务文件
    echo "正在生成服务文件: $service_file"
    
    cat <<EOF | sudo tee $service_file > /dev/null
[Unit]
Description=Rclone Mount for $remote_name
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
Environment=RCLONE_CONFIG_DIR=/home/$REAL_USER/.config/rclone
ExecStart=$rclone_bin mount ${remote_name}:${remote_path} ${local_mount} \\
    --allow-other \\
    --vfs-cache-mode full \\
    --vfs-cache-max-age 24h \\
    --vfs-read-chunk-size-limit off \\
    --buffer-size 64M \\
    --log-level INFO \\
    --log-file /tmp/rclone-${mount_tag}.log
ExecStop=/bin/fusermount -qzu ${local_mount}
Restart=on-failure
User=$REAL_USER
Group=$REAL_GROUP

[Install]
WantedBy=multi-user.target
EOF

    # 6. 启动服务
    echo "正在启动服务..."
    sudo systemctl daemon-reload
    sudo systemctl enable "$service_name"
    sudo systemctl start "$service_name"

    if systemctl is-active --quiet "$service_name"; then
        echo -e "\n✅ 挂载成功！"
    else
        echo -e "\n❌ 挂载启动失败，请检查配置。"
        echo "查看日志: cat /tmp/rclone-${mount_tag}.log"
    fi
}

# --- 核心功能：卸载单个挂载 ---
uninstall_mount() {
    echo "----------------------------------------"
    echo "当前已安装的挂载服务："
    
    services=$(find /etc/systemd/system -maxdepth 1 -name "${SERVICE_PREFIX}*.service" -printf "%f\n")
    
    if [ -z "$services" ]; then
        echo "没有检测到由本脚本创建的挂载服务。"
        return
    fi

    i=1
    declare -a service_list
    SAVEIFS=$IFS
    IFS=$'\n'
    for svc in $services; do
        tag=${svc#$SERVICE_PREFIX}
        tag=${tag%.service}
        echo "$i. $tag ($svc)"
        service_list[$i]=$svc
        ((i++))
    done
    IFS=$SAVEIFS

    echo "----------------------------------------"
    read -p "请输入要卸载的序号 (输入 0 取消): " choice

    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -gt 0 ] && [ "$choice" -lt "$i" ]; then
        target_service="${service_list[$choice]}"
        echo "正在停止并删除服务: $target_service"
        sudo systemctl stop "$target_service"
        sudo systemctl disable "$target_service"
        sudo rm -f "/etc/systemd/system/$target_service"
        sudo systemctl daemon-reload
        sudo systemctl reset-failed
        echo "✅ 服务已卸载。"
    else
        echo "取消操作。"
    fi
}

# --- 核心功能：安装脚本到系统 ---
install_script_to_system() {
    echo "----------------------------------------"
    current_script=$(realpath "$0")
    if [ "$current_script" == "$INSTALL_PATH" ]; then
        echo "✅ 当前脚本已经是系统全局命令。"
        return
    fi

    sudo cp "$current_script" "$INSTALL_PATH"
    sudo chmod +x "$INSTALL_PATH"
    
    if [ -f "$INSTALL_PATH" ]; then
        echo "✅ 安装成功！现在可以输入 '$GLOBAL_CMD_NAME' 直接运行。"
        read -p "是否删除当前目录下的旧脚本文件？(y/n): " del_old
        if [[ "$del_old" == "y" ]]; then
            rm "$current_script"
            echo "旧文件已删除。"
        fi
    else
        echo "❌ 安装失败，请检查权限。"
    fi
}

# --- 核心功能：全局彻底卸载 ---
uninstall_tool_completely() {
    clear
    echo "=========================================="
    echo "       ⚠️  危险操作警告 (Warning)  ⚠️"
    echo "=========================================="
    echo "此操作将执行以下步骤："
    echo "1. 强制停止并卸载所有由本工具创建的 Rclone 挂载点。"
    echo "2. 删除所有对应的 systemd 服务文件。"
    echo "3. 删除全局命令 ($INSTALL_PATH)。"
    echo "=========================================="
    read -p "你确定要继续吗？(输入 yes 确认): " confirm

    if [ "$confirm" != "yes" ]; then
        echo "操作已取消。"
        return
    fi

    echo ""
    echo "[1/3] 正在扫描并清理挂载服务..."
    
    # 查找所有相关服务
    services=$(find /etc/systemd/system -maxdepth 1 -name "${SERVICE_PREFIX}*.service" -printf "%f\n")
    
    if [ -z "$services" ]; then
        echo "  未发现任何挂载服务。"
    else
        SAVEIFS=$IFS
        IFS=$'\n'
        for svc in $services; do
            echo "  正在移除服务: $svc"
            sudo systemctl stop "$svc"
            sudo systemctl disable "$svc" 2>/dev/null
            sudo rm -f "/etc/systemd/system/$svc"
        done
        IFS=$SAVEIFS
        
        sudo systemctl daemon-reload
        sudo systemctl reset-failed
        echo "  所有挂载服务已清理完毕。"
    fi

    echo "[2/3] 正在删除全局脚本..."
    if [ -f "$INSTALL_PATH" ]; then
        sudo rm -f "$INSTALL_PATH"
        echo "  脚本文件已删除。"
    else
        echo "  未检测到全局脚本，跳过。"
    fi

    echo "[3/3] 清理完成。"
    echo "✅ 卸载成功！Rclone 软件本身未被卸载，仅清理了挂载配置和管理工具。"
    exit 0
}

# --- 主菜单 ---
show_menu() {
    echo ""
    echo "=========================================="
    echo "   Rclone 挂载管理 v3.2 (终极版)"
    echo "=========================================="
    echo "1. 新增挂载 (Add)"
    echo "2. 卸载单个挂载 (Uninstall Single)"
    echo "3. 退出 (Exit)"
    echo "4. 安装脚本到系统 (Install to System)"
    echo "5. 彻底卸载本工具 (Global Uninstall)"
    echo "=========================================="
    read -p "请输入选项 [1-5]: " option

    case $option in
        1) install_mount ;;
        2) uninstall_mount ;;
        3) exit 0 ;;
        4) install_script_to_system ;;
        5) uninstall_tool_completely ;;
        *) echo "无效选项";;
    esac
}

# 脚本入口
if [ "$EUID" -eq 0 ]; then
    echo "警告: 建议不要直接使用 root 运行此脚本。"
    echo "建议以普通用户运行: $GLOBAL_CMD_NAME"
    read -p "是否继续？(y/n): " confirm
    if [[ "$confirm" != "y" ]]; then exit 1; fi
fi

while true; do
    show_menu
    echo ""
    read -p "按回车键返回主菜单..."
done
