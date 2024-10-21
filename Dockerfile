# ベースイメージの設定
FROM nvidia/opengl:base-ubuntu22.04 

# 引数でHumbleとIronを選べるようにする
ARG ROS_DISTRO=humble

# 環境変数の設定
ENV DEBIAN_FRONTEND=noninteractive
ENV __NV_PRIME_RENDER_OFFLOAD=1
ENV __GLX_VENDOR_LIBRARY_NAME=nvidia

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    terminator \
    lsb-release

# ROSのリポジトリをsource listに追加
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - \
    && echo "deb http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list

# ROS2のインストール
RUN apt-get update && apt-get install -y \
    ros-${ROS_DISTRO}-desktop-full

# colconのインストール
RUN apt-get install -y python3-colcon-common-extensions

# Gazeboのインストール
RUN apt-get install -y gazebo \
    ros-${ROS_DISTRO}-gazebo-*

# rqtのプラグインをインストール
RUN apt-get install -y ros-${ROS_DISTRO}-rqt-*

# ワークスペースの作成
RUN mkdir -p ~/ros2_ws/src
WORKDIR /root/ros2_ws/
RUN /bin/bash -c '. /opt/ros/humble/setup.bash; colcon build'

# エントリーポイントを設定し毎回bashをsourceせずに済むよう設定
COPY ./ros_entrypoint.sh /
RUN chmod +x /ros_entrypoint.sh
ENTRYPOINT ["/ros_entrypoint.sh"]

# コマンドを設定
CMD ["bash"]
