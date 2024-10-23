#!/bin/bash

CONTAINER_NAME="ros2_humble"
IMAGE_NAME="ros2_humble"

WORKSPACE_DIR="$HOME/ros_ws/${IMAGE_NAME}"
CONTAINER_COLCON_WS="/root/colcon_ws"
DEV_WS="$HOME/dev_ws"

# rockerコマンドの実行（ディストリビューションごとのコンテナを立ち上げ）
# コンテナ間の共有メモリのデバイスファイルをマウントすることでコンテナ間の通信が可能
echo "Starting rocker with ${CONTAINER_NAME} and Terminator config..."
rocker --nvidia --x11 --network host --privileged --nocleanup --name ${CONTAINER_NAME} \
  ${IMAGE_NAME}:latest \
  --volume ${WORKSPACE_DIR}/build:${CONTAINER_COLCON_WS}/build \
  --volume ${WORKSPACE_DIR}/install:${CONTAINER_COLCON_WS}/install \
  --volume ${WORKSPACE_DIR}/log:${CONTAINER_COLCON_WS}/log \
  --volume ${WORKSPACE_DIR}/src:${CONTAINER_COLCON_WS}/src \
  --volume ${DEV_WS}/config/terminator:/root/.config/terminator \
  --volume=/dev/shm:/dev/shm:rw \
  --volume=/dev:/dev \
  --env ROS_DISTRO=humble \
  --env IMAGE_NAME=${IMAGE_NAME} \
  --env CONTAINER_WORKSPACE_DIR=${CONTAINER_COLCON_WS} 
