#!/bin/bash

# Terminatorの起動
terminator --title=${CONTAINER_NAME} & 

# フォアグラウンドのプロセスを維持
tail -f /dev/null
