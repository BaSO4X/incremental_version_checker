#!/bin/bash

URL="$1"              # ROM 包下载地址
GITHUB_ENV="$2"       # 输出环境变量

Red='\033[1;31m'    # 粗体红色
Yellow='\033[1;33m' # 粗体黄色
Blue='\033[1;34m'   # 粗体蓝色
Green='\033[1;32m'  # 粗体绿色

payload_extract=./tools/payload_extract

mkdir -p ./tools
chmod -R 755 ./tools

# ROM zip 名称
rom_zip_name=$(echo "$URL" | awk -F'/' '{print $NF}' | awk -F'?' '{print $1}')
# ROM OS 版本号
rom_os_version=$(echo "$URL" | awk -F'/' '{print $(NF-1)}')
# 机型代号（zip 文件名第一个 - 前的部分）
model=$(echo "$rom_zip_name" | cut -d'-' -f1 | head -n 1 | tr -d '\r')

# 直接从 URL 提取 mi_ext 分区（无需下载完整 ROM）
echo -e "${Red}- 开始提取 mi_ext 分区"
mkdir -p ./images
$payload_extract -s -o ./images/ -i "${URL}" -X mi_ext -T0
echo -e "${Green}- 提取完成"

# 读取增量版本号
echo -e "${Red}- 开始读取增量版本号"
mi_ext_build_prop=./images/mi_ext/etc/build.prop
incremental_version=$(grep "ro.mi.xms.version.incremental=" "$mi_ext_build_prop" | awk -F "=" '{print $2}' | head -n 1 | tr -d '\r')
echo -e "${Blue}- 机型代号: $model"
echo -e "${Blue}- 增量版本号: $incremental_version"

echo "model=$model" >>$GITHUB_ENV
echo "incremental_version=$incremental_version" >>$GITHUB_ENV
echo "rom_os_version=$rom_os_version" >>$GITHUB_ENV

echo -e "${Green}- 完成!"
