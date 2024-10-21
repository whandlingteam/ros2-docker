#!/bin/bash

# 毎回コンテナ起動する度にsource ../setup.bashを実行するのは面倒なのでここに記述してCOPY ./ros_entrypoint.sh / でコンテナ内にコピー
source /opt/ros/humble/setup.bash
source ~/ros2_ws/install/setup.bash
exec "$@"
