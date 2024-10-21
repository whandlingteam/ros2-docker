#!/bin/bash

DOCKER_WS=docker_ws
ROS_DISTRIBUTION=humble

# connect volumes between host and docker-image
# TODO: docker_wsを利用
if [ ! -d /home/developer/.config/terminator ]; then
    mkdir -p /home/developer/.config/terminator
    ln -s /home/developer/dev_ws/config/terminator_config /home/developer/.config/terminator/config
fi

# TODO: ユーザー名はもっとわかりやすくする。
# TODO: git関連設定も事前にやらせておく。
# 
rocker --nvidia --x11 --user --network host --privileged --nocleanup --git --name $(ROS_DISTRIBUTION) ros2_$(ROS_DISTRIBUTION):latest