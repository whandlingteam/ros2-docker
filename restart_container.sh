#!/bin/bash

# config.shの読み込み
source config.sh

docker exec -it ${CONTAINER_NAME} /start_terminator.sh
