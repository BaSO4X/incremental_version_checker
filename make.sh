#!/bin/bash

URL="$1"              # ROM 包下载地址
GITHUB_ENV="$2"       # 输出环境变量
GITHUB_WORKSPACE="$3" # 工作目录

Red='\033[1;31m'    # 粗体红色
Yellow='\033[1;33m' # 粗体黄色
Blue='\033[1;34m'   # 粗体蓝色
Green='\033[1;32m'  # 粗体绿色

a7z="$GITHUB_WORKSPACE"/tools/7zzs
payload_extract="$GITHUB_WORKSPACE"/tools/payload_extract

mkdir -p "$GITHUB_WORKSPACE"/tools
chmod -R 755 "$GITHUB_WORKSPACE"/tools

# ROM zip 名称
rom_zip_name=$(echo "$URL" | awk -F'/' '{print $NF}' | awk -F'?' '{print $1}')
# ROM OS 版本号
rom_os_version=$(echo "$URL" | awk -F'/' '{print $(NF-1)}')

Start_Time() {
  Start_s=$(date +%s)
  Start_ns=$(date +%N)
}

End_Time() {
  local End_s End_ns time_s time_ns
  End_s=$(date +%s)
  End_ns=$(date +%N)
  time_s=$((10#$End_s - 10#$Start_s))
  time_ns=$((10#$End_ns - 10#$Start_ns))
  if ((time_ns < 0)); then
    ((time_s--))
    ((time_ns += 1000000000))
  fi

  local ns ms sec min hour
  ns=$((time_ns % 1000000))
  ms=$((time_ns / 1000000))
  sec=$((time_s % 60))
  min=$((time_s / 60 % 60))
  hour=$((time_s / 3600))

  if ((hour > 0)); then
    echo -e "${Green}- 本次$1用时: ${Blue}$hour小时$min分$sec秒$ms毫秒"
  elif ((min > 0)); then
    echo -e "${Green}- 本次$1用时: ${Blue}$min分$sec秒$ms毫秒"
  elif ((sec > 0)); then
    echo -e "${Green}- 本次$1用时: ${Blue}$sec秒$ms毫秒"
  elif ((ms > 0)); then
    echo -e "${Green}- 本次$1用时: ${Blue}$ms毫秒"
  else
    echo -e "${Green}- 本次$1用时: ${Blue}$ns纳秒"
  fi
}

### 下载 ROM 包
echo -e "${Red}- 开始下载 ROM 包"
Start_Time
curl -L -o "$GITHUB_WORKSPACE"/"${rom_zip_name}" "${URL}"
End_Time 下载 ROM 包
### 下载结束

### 解包
echo -e "${Red}- 开始解压 ROM 包"
mkdir -p "$GITHUB_WORKSPACE"/rom_zip
mkdir -p "$GITHUB_WORKSPACE"/images

echo -e "${Yellow}- 提取 payload.bin"
Start_Time
$a7z x "$GITHUB_WORKSPACE"/"${rom_zip_name}" -o"$GITHUB_WORKSPACE"/rom_zip payload.bin >/dev/null
rm -rf "$GITHUB_WORKSPACE"/"${rom_zip_name}"
End_Time 解压 ROM 包

echo -e "${Red}- 开始解 Payload (提取 mi_ext 分区)"
Start_Time
$payload_extract -s -o "$GITHUB_WORKSPACE"/images/ -i "$GITHUB_WORKSPACE"/rom_zip/payload.bin -X mi_ext -T0
rm -rf "$GITHUB_WORKSPACE"/rom_zip/payload.bin
End_Time 解 Payload
### 解包结束

### 读取增量版本号
echo -e "${Red}- 开始读取增量版本号"
mi_ext_build_prop=$GITHUB_WORKSPACE/images/mi_ext/etc/build.prop
incremental_version=$(grep "ro.mi.xms.version.incremental=" "$mi_ext_build_prop" | awk -F "=" '{print $2}')
echo -e "${Blue}- 增量版本号: $incremental_version"
echo "incremental_version=$incremental_version" >>$GITHUB_ENV
echo "rom_os_version=$rom_os_version" >>$GITHUB_ENV
### 读取结束

echo -e "${Green}- 完成!"
