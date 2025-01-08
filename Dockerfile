ARG BASE_IMAGE
FROM nvidia/opengl:${BASE_IMAGE}

ARG ROS_DISTRO
ARG CONTAINER_WORKSPACE

ENV BASE_IMAGE=${BASE_IMAGE}
ENV ROS_DISTRO=${ROS_DISTRO}
ENV CONTAINER_WORKSPACE=${CONTAINER_WORKSPACE}

# 環境変数の設定
ENV DEBIAN_FRONTEND=noninteractive
ENV __NV_PRIME_RENDER_OFFLOAD=1
ENV __GLX_VENDOR_LIBRARY_NAME=nvidia

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ROSのリポジトリをsource listに追加
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - \
    && echo "deb http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list


# ROS2のインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-desktop \
    ros-dev-tools \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# colconとrosdep、GUIや解析に用いるパッケージのインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-colcon-common-extensions \
    python3-rosdep \
    # gazebo \
    # ros-${ROS_DISTRO}-gazebo-* \
    # ros-${ROS_DISTRO}-rqt-* \
    # ros-${ROS_DISTRO}-plotjuggler-ros \
    terminator \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ワークスペースの作成
RUN apt-get update && apt-get upgrade -y && \
    rosdep init && \
    rosdep update

# エントリーポイントと必要なスクリプトをイメージ内(rootディレクトリ配下)に設定
COPY shell_scripts/ros_entrypoint.sh /
COPY shell_scripts/start_terminator.sh /
RUN chmod +x /ros_entrypoint.sh /start_terminator.sh

# ビープ音の無効化（うざいので）
RUN echo "set bell-style none" >> ~/.inputrc

# 再起動時もENTRYPOINTを再実行させる
ENTRYPOINT ["/ros_entrypoint.sh"]