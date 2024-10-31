#!/bin/bash

# 環境変数からCONTAINER_NAMEを読み取る
CONTAINER_NAME=${CONTAINER_NAME}

# Terminatorの起動
terminator --title=${CONTAINER_NAME} & 

# フォアグラウンドのプロセスを維持
tail -f /dev/null
