ROS2をdockerでちゃちゃっと試したり、複数バージョンのROS2が混在する環境において管理しやすいようにするリポジトリ。
ROS1用リポジトリは現在整備中。。。

今回はros2用のコンテナ内でGPUが使用できるようにするが、CUDAのインストールには関知しない。
仮にコンテナ内でcudaを用いたい場合は、別途インストールすること。


# 事前準備
## Nouveua(ヌーヴォー)の無効化
NouveuaはNVIDIAのオープンソースドライバで、Ubuntuのデフォルトで使われているが、NVIDIAのGPUを使うときには非推奨。
このステップを無視していきなりNVIDIAドライバを入れると、Nouveuaと競合してしまい、GPUが使えなくなる可能性があるらしい。

ただ、筆者は普通にNouveua無効化ステップをすっ飛ばしてNVIDIAドライバを入れても問題なかった（自動で無効化される？）。まあ念の為無効化しときましょう。

```bash
lsmod | grep -i nouveau
```

と入れ、何か表示されるようなら、無効化する。

`/etc/modprobe.d/blacklist-nouveau.conf`を作成し、以下を記述

```bash
blacklist nouveau
options nouveau modeset=0
```
ファイルを保存し、以下を実行することで設定を再読込する

```bash
sudo update-initramfs -u
```

## NVIDIAドライバのインストール
ドライバがすでに入ってないことの確認

```bash
dpkg -l | grep nvidia
```

と入れ、何も出てこなければOK。このままインストールのステップ(最新バージョンのインストール)に進む。

すでにドライバが入っており、それが古いバージョンの場合は、アップデートするために一度削除する。（古いかどうか確かめる方法は[次のステップ](#古いバージョンの削除)に後述）

### すでにあるNVIDIAドライバが古いものか確かめる方法
```bash
dpkg -l | grep nvidia-driver
```

と入れる。

```bash
ii  nvidia-driver-550                          550.35.03-0ubuntu1                      amd64        NVIDIA driver metapackage
```
のように出てきた場合、`nvidia-driver-550`の**550**がバージョン番号にあたるので覚えておく。

`ubuntu-drivers devices |grep recommended`

と入れ、出てきたものを確認する。

```bash
driver   : nvidia-driver-560 - third-party non-free recommended
```

とあるので、**560**が最新バージョンかつ推奨(recommended)だとわかる。
550より560のほうが新しいので、550を削除して560をインストールする。

### 古いバージョンの削除
```bash
sudo apt-get --purge remove nvidia-*
```

### 最新バージョンのインストール
#### 自動インストール
ドライバの選択方法を「手動インストール」にて後述するが、面倒な人は

```bash
sudo ubuntu-drivers autoinstall
```

というコマンドで自動で最新のドライバをインストールすることもできる。

#### 手動インストール
オートでなく手動でやりたい硬派な人は以下を実行する。

```bash
$ ubuntu-drivers devices |grep recommended
```

```bash
driver   : nvidia-driver-565 - third-party non-free recommended
```

と出るので
「`nvidia-driver-560`」の部分をメモしておく。

何も出てこなければ、

```bash
ubuntu-drivers devices
```

と入れ、`「nvidia-driver-○○○`」の部分のうち、数値の一番大きいものを選択。

```bash
$ ubuntu-drivers devices
== /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0 ==
modalias : pci:v000010DEd000028A0sv00001558sd00001460bc03sc00i00
vendor   : NVIDIA Corporation
driver   : nvidia-driver-535-open - distro non-free
driver   : nvidia-driver-560-open - third-party non-free
driver   : nvidia-driver-545 - third-party non-free
driver   : nvidia-driver-545-open - distro non-free
driver   : nvidia-driver-535 - third-party non-free
driver   : nvidia-driver-555 - third-party non-free
driver   : nvidia-driver-535-server-open - distro non-free
driver   : nvidia-driver-550 - third-party non-free
driver   : nvidia-driver-550-open - third-party non-free
driver   : nvidia-driver-565 - third-party non-free recommended
driver   : nvidia-driver-565-open - third-party non-free
driver   : nvidia-driver-535-server - distro non-free
driver   : nvidia-driver-555-open - third-party non-free
driver   : nvidia-driver-560 - third-party non-free
driver   : nvidia-driver-525 - third-party non-free
driver   : xserver-xorg-video-nouveau - distro free builtin
```

以下を実行する（○○○の部分は適宜変更すること）

```bash
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt update
sudo apt install nvidia-driver-○○○
```
インストールを終えたら、再起動することでドライバのインストールが完了する。

```bash
sudo reboot
```

### ドライバ起動チェック
再起動したら、ターミナルから以下を入力し、ドライバが正常にインストールされているか確認する。

```bash
$ nvidia-smi
Mon Nov 11 11:20:05 2024       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 560.35.03              Driver Version: 560.35.03      CUDA Version: 12.6     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 4060 ...    Off |   00000000:01:00.0  On |                  N/A |
| N/A   40C    P5              5W /   20W |      80MiB /   8188MiB |     20%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A      3246      G   /usr/lib/xorg/Xorg                             69MiB |
+-----------------------------------------------------------------------------------------+
```

参考: [ubuntuにCUDA、nvidiaドライバをインストールするメモ](https://qiita.com/porizou1/items/74d8264d6381ee2941bd)


# docker, NVIDIA Container Toolkitのインストール

```bash
bash install_prerequired.sh
```
と入れると、docker、NVIDIA Container Toolkitが自動でインストールされる。 

# `config.sh`の編集

コンテナやイメージに用いられる設定は`config.sh`において一元的に管理されるので、コンテナ名などを変更したいときにはここから編集すること。

なお、`BASE_IMAGE`と`ROS_DISTRO`を変更することで、ROSのバージョンを変更できる（以下はROS2のhumbleの場合）。

```bash
# コンテナ名。ホスト側から作業ディレクトリ名として設定され、terminatorのウィンドウ名にも反映される。
CONTAINER_NAME=ros2-humble

# イメージの基本設定
# ベースイメージの設定。タグは https://hub.docker.com/r/nvidia/opengl/tags?name=base-ubuntu から調べる
BASE_IMAGE="base-ubuntu22.04"
ROS_DISTRO=humble
```

# Dockerfileのイメージビルド

```bash
bash build_Dockerfile.sh
```

途中で
```bash
 WARN: InvalidDefaultArgInFrom: Default value for ARG nvidia/opengl:${BASE_IMAGE} results in empty or invalid base image name (line 2)  
```
のような怒られが発生するが、適切な値が渡されているようなので気にしなくてOK。

初回だと20~30分ほどかかるので、気長に待とう。（2回目以降はキャッシュを用いて早く行われる）

完了後、`docker images ls -a`を入れると、以下のように`ros2-humble`というイメージが作成されていることが確認できる。（以降はコンテナ名が`ros2-humble`であることを前提に話を進める）

`build_Dockerfile.sh`の`IMAGE_NAME`を変更して、新たなイメージを作成することもできる。

# コンテナの作成

```bash
bash create_container.sh
```

を実行すると、`config.sh`内で定義した`CONTAINER_NAME`の`ros2-humble`という名前のコンテナが作成され、Terminatorが立ち上がる。

TerminatorはROSのように複数プロセスを同時に扱う上で非常に便利なので、使い方は各自で調べておこう！（参考: [ターミナル環境の構築: Terminatorのインストール](https://ryonakagami.github.io/2020/12/22/ubuntu-terminator/)）


# 動作確認
新たに立ち上がったTerminator内で動作確認を行う。

## ROS2が入っているか確認

```powershell
root@sharge-disk-v3ma002:~# ls
colcon_ws
root@sharge-disk-v3ma002:~# cd colcon_ws/
root@sharge-disk-v3ma002:~/colcon_ws# ros2 topic list 
/parameter_events
/rosout
```

## nvidiaドライバを認識できているかも確認

```bash
root@sharge-disk-v3ma002:~/colcon_ws# nvidia-smi
Mon Nov 11 02:57:19 2024       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 560.35.03              Driver Version: 560.35.03      CUDA Version: N/A      |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 4060 ...    Off |   00000000:01:00.0  On |                  N/A |
| N/A   40C    P8              2W /   20W |      80MiB /   8188MiB |     54%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
+-----------------------------------------------------------------------------------------+

```

## GUIアプリの起動確認

ホスト側の画面に`rviz2`が表示される（`rviz2`と打ったターミナルでCtrl+Cを押すとrviz2を閉じられる）。

```powershell
root@sharge-disk-v3ma002:~/colcon_ws# rviz2
```


## ディレクトリのマウントの確認

`create_container.sh`において一部のコンテナ側ディレクトリがホスト側のディレクトリにマウント（直結）されるよう設定されている。

なお、ホスト側ディレクトリ（`${HOST_WORKSPACE}/build`等）は自動作成されるので、ユーザーがあらかじめ準備しておく必要はない。

```bash
# コンテナの実行
docker run -itd \
  ...
  # ROS2関連
  -v ${HOST_WORKSPACE}/build:${CONTAINER_WORKSPACE}/build \
  -v ${HOST_WORKSPACE}/install:${CONTAINER_WORKSPACE}/install \
  -v ${HOST_WORKSPACE}/log:${CONTAINER_WORKSPACE}/log \
  -v ${HOST_WORKSPACE}/src:${CONTAINER_WORKSPACE}/src \
  # Terminator設定ファイル
  -v ${DEV_WS}/config/terminator:/root/.config/terminator \
  ...
```

ちなみにホスト側ワークスペース（`HOST_WORKSPACE`）やコンテナ側ワークスペース（`CONTAINER_WORKSPACE`）は`config.sh`において

```bash
CONTAINER_NAME=ros2-humble
HOST_WORKSPACE=${HOME}/ros_ws/${CONTAINER_NAME}
CONTAINER_WORKSPACE=/root/colcon_ws
DEV_WS=${HOME}/dev_ws
```

と指定され、上記の場合`HOST_WORKSPACE`は`~/ros_ws/ros2-humble`、`CONTAINER_WORKSPACE`は`/root/colcon_ws`となる。

試しに`-v ${HOST_WORKSPACE}/src:${CONTAINER_WORKSPACE}/src`の部分が適切にマウントされてるか検証しよう。

コンテナ側のターミナルにおいて、`~/colcon_ws/src`に移動し、`HelloWorld`というファイルを作成する。
```powershell
root@sharge-disk-v3ma002:~# cd colcon_ws/
root@sharge-disk-v3ma002:~/colcon_ws# ls
build  install  log  src
root@sharge-disk-v3ma002:~/colcon_ws# cd src/
root@sharge-disk-v3ma002:~/colcon_ws/src# touch HelloWorld
root@sharge-disk-v3ma002:~/colcon_ws/src# ls
HelloWorld
```

次に、ホスト側ターミナルから先ほどのファイルが見えるか確認する（ここではCLIでやっているが、当然ホスト側なので「ファイル」からGUI操作してもOK）
```bash
$ ls ~/ros_ws/ros2-humble/src/
HelloWorld
```

次に、ホスト側から`HelloWorld`を消してみる

```bash
$ rm -f ~/ros_ws/ros2-humble/src/HelloWorld 
```

コンテナ側から`HelloWorld`が消えていることを確認

```powershell
root@sharge-disk-v3ma002:~/colcon_ws/src# find HelloWorld
find: ‘HelloWorld’: No such file or directory
```
# コンテナの終了
終了するときは、ホスト側ターミナルにおいて`docker stop ros2-humble`を入れる。（15秒ほどかかるので、すぐに反応が返ってこなくても焦らないこと）

コンテナのTerminatorのバツを押してTerminatorを終了することでコンテナから抜けることはできるが、コンテナ自体はバックグラウンドで動いたまま。`docker stop ros2-humble`を入れてコンテナを停止させること。

なお、間違えてTerminatorをバツボタンで終了させてしまったときはホスト側ターミナルから
```bash
$ bash restart_container.sh
(terminator:181): dbind-WARNING **: 03:02:22.099: Couldn't connect to accessibility bus: Failed to connect to socket /run/user/1000/at-spi/bus_1: No such file or directory
ConfigBase::load: Unable to open /etc/xdg/terminator/config ([Errno 2] No such file or directory: '/etc/xdg/terminator/config')
Gtk-Message: 03:02:22.143: Failed to load module "canberra-gtk-module"
Unable to connect to DBUS Server, proceeding as standalone
Unable to load Keybinder module. This means the hide_window shortcut will be unavailable
Unable to bind hide_window key, another instance/window has it.
ActivityWatch plugin unavailable as we cannot import Notify
PluginRegistry::load_plugins: Importing plugin activitywatch.py failed: module 'activitywatch' has no attribute 'AVAILABLE'
PluginRegistry::load_plugins: Importing plugin command_notify.py failed: Namespace Notify not available
```
を実行する、なんか色々エラーっぽいのが表示されるが実行には問題ない。

# バックグラウンドで稼働中のコンテナの確認

`docker ps -a`を入れると、コンテナの一覧が表示される。(`ps`はprocessの略で、オプション`-a`は全てのコンテナを表示するためのもの)

```bash
$ docker container ps -a
CONTAINER ID   IMAGE                    COMMAND                CREATED          STATUS         PORTS     NAMES
09b5ccb3791d   ros2_humble:latest       "/ros_entrypoint.sh"   19 minutes ago   Up 8 seconds             ros2-humble
```

`STATUS`の列が`Exited~`になっていれば、正常に終了している。

もしも`STATUS`が`Up~`になっている場合は、バックグラウンドで動いているので、`docker stop ros2-humble`と入れてコンテナを停止させる。

# 2回目以降のコンテナの立ち上げ方
コンテナを再度立ち上げたいときは、`docker start ros2-humble`と入れればいい。

# コンテナの削除
コンテナを削除したい場合は、`docker rm ros2-humble`と入れる。なお、実行中(STATUSがexited~でない)のコンテナは削除できないので、`docker ps -a`で確認し、必要ならば`docker stop ros2-humble`を入れてから削除すること。(`docker rm -f ros2-humble`と入れると強制削除できるが、おすすめしない)

参考文献: 

- [Docker・rocker でGUIとGPUが使えるROS 2 Humbleの環境を作る](https://qiita.com/porizou1/items/76980fbd0d1675eecf7f)

- [Docker環境でTerminatorを使えるようにする](https://qiita.com/memristor09/items/4cf351a16629f7ddc377)

- [Dockerコンテナ内の ROS 2 環境でRealSense D435を使用する](https://qiita.com/porizou1/items/8bf56efc3307e40624af)