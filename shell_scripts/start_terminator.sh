#!/bin/bash

# Terminatorの起動
terminator --title=${IMAGE_NAME} & 

# フォアグラウンドのプロセスを維持
tail -f /dev/null
