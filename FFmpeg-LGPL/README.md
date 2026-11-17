# FFmpeg LGPL 开发库（内嵌解码用）

本目录存放 ThermalIQ 内嵌 libav 解码所需的头文件、导入库与运行时 DLL。
目录整体受 `.gitignore` 排除（`/third_party/`），**不入版本库**；换机器或重新克隆后
需按本文「构建方式」重建。

## 版本与来源

| 项 | 值 |
| --- | --- |
| FFmpeg 版本 | n7.1.5 源码自建（libavcodec **61**.x / libavformat 61 / libavutil 59 / libswscale 8） |
| 构建方式 | **裁剪构建**：MinGW-w64 gcc 13.1（Qt 自带 `C:/Qt/Tools/mingw1310_64`）+ Git Bash 执行 `configure` |
| 构建脚本 | `_ffbuild/build-trimmed.sh`（源码包 `_ffbuild/ffmpeg-7.1.5.tar.gz`） |
| 许可证 | **LGPL v3**（`--enable-version3 --enable-shared --disable-static --disable-gpl --disable-nonfree`） |
| 运行体积 | 5 个 DLL 合计 **4.14 MB**（通用预编译包为 88.1 MB） |
| 与现有 `third_party/ffmpeg.exe` 关系 | 大版本对齐（7.1.x），但**不是同一个包**：exe 为 GPL full build（含 libx264/libx265），仅作独立进程调用，不链接 |

> 关键点：**内嵌链接不可使用 GPL 构建**。GPL 构建一旦被链接，整个 ThermalIQ 会被传染为 GPL，
> 与闭源交付冲突。当前 `third_party/ffmpeg.exe` 属 GPL v3，只能在「独立进程调用」形态下使用，
> 这也是录像链路继续沿用它的前提。

## 目录结构

```
third_party/ffmpeg-lgpl/
├── include/{libavcodec,libavformat,libavutil,libswscale}/   # 头文件（130 个）
├── lib/lib{avcodec,avformat,avutil,swscale,swresample}.dll.a # MinGW 导入库
├── bin/{avcodec-61,avformat-61,avutil-59,swscale-8,swresample-5}.dll
├── LICENSE.txt                                              # LGPL 全文（随包分发）
└── README.md                                                # 本文件
```

`bin/` 必须包含 **swresample-5.dll**：虽然代码不直接链接 swresample，但
`avcodec-61.dll` 的导入表依赖它（`objdump -p` 可验证），缺该文件表现为程序启动即报
「找不到 avcodec-61.dll」或加载后崩溃。

依赖闭包（`objdump -p` 实测，裁剪版）：

```
avformat-61 → avcodec-61, avutil-59, WS2_32, msvcrt
avcodec-61  → avutil-59, msvcrt
swscale-8   → avutil-59, msvcrt
swresample-5→ avutil-59, msvcrt
avutil-59   → libwinpthread-1, bcrypt(=BCryptGenRandom), msvcrt
```

即：除本目录 5 个 DLL 外，只需 MinGW 运行库 `libwinpthread-1.dll`（安装包已随 Qt 一起分发）。

## 构建方式（裁剪构建）

```bash
# Git Bash
C:/Qt/Tools/mingw1310_64/bin 加入 PATH 后执行：
sh _ffbuild/build-trimmed.sh
```

脚本内 `configure` 关键参数：

```
--enable-shared --disable-static --enable-version3 --disable-gpl --disable-nonfree
--disable-programs --disable-doc --disable-avdevice --disable-avfilter
--disable-autodetect --disable-zlib --disable-iconv --disable-sdl2
--disable-x86asm                     # 本机无 nasm；有 nasm 时去掉可再换 ~10% 解码性能
--disable-everything
--enable-decoder=h264,hevc,mjpeg     # 现场只需这三类软解
--enable-parser=h264,hevc,mjpeg
--enable-demuxer=rtsp,mov,mpegts,h264,image2
--enable-protocol=file,rtsp,rtp,tcp,udp,http,https
--enable-swscale --enable-swresample
--enable-bsf=h264_mp4toannexb,hevc_mp4toannexb
```

产物落在 `_ffbuild/prefix`，再拷贝 `include/`、`lib/*.dll.a`、`bin/*.dll` 到本目录。

> 回退路径：若裁剪构建在本机不可用，可改用 BtbN 的 LGPL shared 预编译包
> （`tools/fetch_ffmpeg_lgpl.ps1`，88.1 MB），许可同为 LGPL v3，接口与文件名一致，
> 直接覆盖本目录即可，不需改代码。

## 与 CMake 的约定

- `CMakeLists.txt` 依据 `include/libavcodec/avcodec.h` 是否存在决定
  `ENABLE_EMBEDDED_FFMPEG` 的默认值：存在=ON（内嵌），不存在=OFF（回退子进程）。
- 显式 `-DENABLE_EMBEDDED_FFMPEG=ON` 而本目录缺库时，配置阶段直接 FATAL，
  避免「以为在测内嵌、其实在跑子进程」。
- 构建后 `avcodec-61.dll` 等 5 个 DLL 由 POST_BUILD 自动拷到 exe 同目录（测试 exe 在
  `tests/` 子目录，另有单独一条 POST_BUILD）。

## 许可义务（交付前必须确认）

1. 随安装包分发 `LICENSES/LGPL-3.0.txt` 与 `THIRD-PARTY-NOTICES.txt`（仓库根）。
2. 保持**动态链接**，不得把 libav 静态链入 exe。
3. 提供源码获取方式（notices 中已写明 FFmpeg 官方源码地址、所用版本与上述 configure 参数）。
4. LGPL v3 的「Installation Information」义务针对 User Product（消费类设备）；
   本软件为桌面工作站软件，不构成 User Product，但仍建议在交付说明中保留该段说明。
