# Incremental Version Checker

从 ROM 包中提取 mi_ext 分区的增量版本号并发布到 GitHub Release。

## 工作原理

1. 下载 ROM OTA zip 包
2. 从 zip 中提取 `payload.bin`
3. 使用 `payload_extract` 提取 `mi_ext` 分区
4. 读取 `mi_ext/etc/build.prop` 中的 `ro.mi.xms.version.incremental` 值
5. 将增量版本号发布到 GitHub Release

## 使用方式

在 GitHub Actions 中手动触发 `Check Incremental Version` workflow，输入 ROM 包的下载地址即可。

## 依赖工具

- `tools/7zzs` — 7-Zip 独立版，用于从 zip 中提取 payload.bin
- `tools/payload_extract` — OTA payload 提取工具，用于提取 mi_ext 分区
