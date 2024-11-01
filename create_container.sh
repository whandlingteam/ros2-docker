#!/bin/bash

# config.sh の読み込み
source config.sh

# X11 の設定
xhost +local:docker

# コンテナの実行
docker run -itd \
  --name ${CONTAINER_NAME} \
  --network host \
  --privileged \
  --gpus all \
  -e DISPLAY=${DISPLAY} \
  -e CONTAINER_NAME=${CONTAINER_NAME} \
  -e ROS_DISTRO=${ROS_DISTRO} \
  -e CONTAINER_WORKSPACE=${CONTAINER_WORKSPACE} \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v ${HOST_WORKSPACE}/build:${CONTAINER_WORKSPACE}/build \
  -v ${HOST_WORKSPACE}/install:${CONTAINER_WORKSPACE}/install \
  -v ${HOST_WORKSPACE}/log:${CONTAINER_WORKSPACE}/log \
  -v ${HOST_WORKSPACE}/src:${CONTAINER_WORKSPACE}/src \
  -v ${DEV_WS}/config/terminator:/root/.config/terminator \
  ${IMAGE_NAME}:latest
