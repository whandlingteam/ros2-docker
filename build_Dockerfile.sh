#!/bin/bash

# ディストリビューションの指定（引数で受け取るか、デフォルトを使用）
# 必要な変数をエクスポートして、全プロセスで使えるようにする
ROS_DISTRO="humble"
IMAGE_NAME="ros2_${ROS_DISTRO}"
HOST_WORKSPACE_DIR="$HOME/ros_ws/${IMAGE_NAME}"
CONTAINER_WORKSPACE_DIR="/root/ros_ws/"

DEV_WS="$HOME/dev_ws"

# 必要なディレクトリの作成
echo "Creating necessary directories for ROS ${ROS_DISTRO}..."
mkdir -p ${HOST_WORKSPACE_DIR}/build
mkdir -p ${HOST_WORKSPACE_DIR}/install
mkdir -p ${HOST_WORKSPACE_DIR}/log
mkdir -p ${HOST_WORKSPACE_DIR}/src
mkdir -p ${DEV_WS}/config/terminator
echo ""

# Dockerfileの実行
echo "Building Image..."
docker build -t ${IMAGE_NAME} --build-arg ROS_DISTRO=${ROS_DISTRO} --build-arg CONTAINER_WORKSPACE_DIR=${CONTAINER_WORKSPACE_DIR} --build-arg IMAGE_NAME=${IMAGE_NAME} .
echo "Image built successfully!"