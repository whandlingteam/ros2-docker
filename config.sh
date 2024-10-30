# コンテナ名。terminatorのウィンドウ名にも反映される。
CONTAINER_NAME=ros2_humble_test

# イメージの基本設定
# ベースイメージの設定。タグは https://hub.docker.com/r/nvidia/opengl/tags?name=base-ubuntu から調べる
BASE_IMAGE="base-ubuntu22.04"
ROS_DISTRO=humble
IMAGE_NAME=ros2_${ROS_DISTRO}

# ホスト側PCの設定
DEV_WS=${HOME}/dev_ws # terminatorの設定ファイル置き場
HOST_WORKSPACE=${HOME}/ros_ws/${IMAGE_NAME}

# コンテナ側設定
CONTAINER_WORKSPACE=/root/colcon_ws
