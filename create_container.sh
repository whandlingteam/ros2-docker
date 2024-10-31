#!/bin/bash

# config.shの読み込み
source config.sh

# rockerコマンドの実行（ディストリビューションごとのコンテナを立ち上げ）
# コンテナ間の共有メモリのデバイスファイルをマウントすることでコンテナ間の通信が可能
echo "Starting rocker with ${CONTAINER_NAME} and Terminator config..."
rocker --nvidia --x11 --network host --privileged --nocleanup --name ${CONTAINER_NAME} \
  ${IMAGE_NAME}:latest \
  --volume ${HOST_WORKSPACE}/build:${CONTAINER_WORKSPACE}/build \
  --volume ${HOST_WORKSPACE}/install:${CONTAINER_WORKSPACE}/install \
  --volume ${HOST_WORKSPACE}/log:${CONTAINER_WORKSPACE}/log \
  --volume ${HOST_WORKSPACE}/src:${CONTAINER_WORKSPACE}/src \
  --volume ${DEV_WS}/config/terminator:/root/.config/terminator \
  --volume=/dev/shm:/dev/shm:rw \
  --volume=/dev:/dev \
  --env BASE_IMAGE=${BASE_IMAGE} \
  --env ROS_DISTRO=${ROS_DISTRO} \
  --env IMAGE_NAME=${IMAGE_NAME} \
  --env CONTAINER_WORKSPACE=${CONTAINER_WORKSPACE} \
  --env CONTAINER_NAME=${CONTAINER_NAME}
