# コンテナ名。ホスト側から作業ディレクトリ名として設定され、terminatorのウィンドウ名にも反映される。
CONTAINER_NAME=ros2-foxy

# イメージの基本設定
# ベースイメージの設定。タグは https://hub.docker.com/r/nvidia/opengl/tags?name=base-ubuntu から調べる
BASE_IMAGE="base-ubuntu20.04"
ROS_DISTRO=foxy
IMAGE_NAME=ros2_${ROS_DISTRO}

# ホスト側PCの設定
DEV_WS=${HOME}/dev_ws # terminatorの設定ファイル置き場
HOST_WORKSPACE=${HOME}/ros_ws/${CONTAINER_NAME}

# コンテナ側設定
CONTAINER_WORKSPACE=/root/colcon_ws
