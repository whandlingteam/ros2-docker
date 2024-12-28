#!/bin/bash

# config.shの読み込み
source config.sh

# 必要なディレクトリの作成
echo "Creating necessary directories for ROS ${ROS_DISTRO}..."
mkdir -p ${HOST_WORKSPACE}/build
mkdir -p ${HOST_WORKSPACE}/install
mkdir -p ${HOST_WORKSPACE}/log
mkdir -p ${HOST_WORKSPACE}/src
mkdir -p ${DEV_WS}/config/terminator
echo ""

# Dockerfileの実行
echo "Building Image..."
echo BASE_IMAGE=${BASE_IMAGE}
echo ROS_DISTRO=${ROS_DISTRO}
echo CONTAINER_WORKSPACE=${CONTAINER_WORKSPACE}
echo IMAGE_NAME=${IMAGE_NAME}

sudo chmod 666 /var/run/docker.sock

docker build -t ${IMAGE_NAME} \
  --build-arg BASE_IMAGE=${BASE_IMAGE} \
  --build-arg ROS_DISTRO=${ROS_DISTRO} \
  --build-arg CONTAINER_WORKSPACE=${CONTAINER_WORKSPACE} \
  .

echo "Image built successfully!"