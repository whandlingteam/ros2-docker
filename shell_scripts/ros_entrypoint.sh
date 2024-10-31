#!/bin/bash

# based on "https://github.com/Tiryoh/docker-ros2/blob/master/humble/ros_entrypoint.sh"
# Copyright 2019-2024 Tiryoh <tiryoh@gmail.com>
# 
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0

ROS_DISTRO=${ROS_DISTRO}
CONTAINER_WORKSPACE=${CONTAINER_WORKSPACE}
CONTAINER_NAME=${CONTAINER_NAME} # start_terminator.sh内で利用

# ROSの環境を設定
if [ -f "/opt/ros/${ROS_DISTRO}/setup.bash" ]; then
    source /opt/ros/${ROS_DISTRO}/setup.bash
else
    echo "Error: /opt/ros/${ROS_DISTRO}/setup.bash not found!"
    exit 1
fi

# ワークスペースの各ディレクトリの確認と作成
for DIR in build install log src; do
    if [ ! -d "${CONTAINER_WORKSPACE}/${DIR}" ]; then
        mkdir -p ${CONTAINER_WORKSPACE}/${DIR}
    fi
done

if [ ! -d "/root/.config/terminator" ]; then
    mkdir -p /root/.config/terminator
fi

# ROS環境のセットアップ（.bashrcに重複追加しないようにチェック）
if ! grep -Fxq "source /opt/ros/${ROS_DISTRO}/setup.bash" /root/.bashrc; then
    echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /root/.bashrc
fi

# ターミナルが存在しない場合（再attach時）に Terminator を再起動
if ! pgrep -x "terminator" > /dev/null; then
    bash /start_terminator.sh
fi

# 終了せずに常駐プロセスを保持
tail -f /dev/null