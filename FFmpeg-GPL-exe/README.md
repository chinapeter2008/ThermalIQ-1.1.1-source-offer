# ffmpeg.exe — GPL 对应源码与构建材料

本目录提供 ThermalIQ 1.1.1 随包 `ffmpeg.exe` 的完整对应源码和构建材料。

## 二进制身份

| 项 | 值 |
|---|---|
| 大小 | 8,745,984 B |
| SHA-256 | `569637259D986831D38A9ECAD8E86F90EB836F2026345469113FCC549C66CD88` |
| 版本 | `ffmpeg version 53bbede`（源码 `RELEASE=7.1.5`） |
| 编译器 | `gcc 13.1.0 (x86_64-posix-seh-rev1, Built by MinGW-Builds project)` |
| 许可 | `License: GPL version 3 or later` |
| 依赖 | `bcrypt.dll`、`KERNEL32.dll`、`msvcrt.dll`、`SHELL32.dll`、`WS2_32.dll` |

随包位置：`third_party/ffmpeg.exe`、`build-embed/ffmpeg.exe`、
`build-embed-rel/ffmpeg.exe`、`build-legacy/ffmpeg.exe`、
`build-legacy-rel/ffmpeg.exe`、`build_qtc/ffmpeg.exe`，六份哈希一致。

## 源码组成

| 文件 | 说明 |
|---|---|
| `ffmpeg-7.1.5.tar.gz` | 未修改的 FFmpeg n7.1.5 官方源码 |
| `x264-stable.tar.gz` | 未修改的 x264 stable 源码，`X264_BUILD 165`，`GPL-2.0-or-later` |
| `nasm-2.16.03-win64.zip` | 构建用 NASM 2.16.03，非链接组件 |
| `build-ffmpeg-gpl.sh` | 完整构建脚本：静态 libx264 → 静态 ffmpeg.exe |
| `configure.log` | configure 完整输出，含 `License: GPL version 3 or later` |
| `build.log` | make 完整日志 |
| `ffmpeg.exe.sha256` | 产物校验值 |
| `LICENSES/GPL-3.0.txt` | GPL v3 全文 |
| `LICENSES/x264-COPYING.txt` | x264 许可全文 |

## 构建

环境：Windows x64、Git Bash、Qt 6.7.3 自带 MinGW 13.1.0、NASM 2.16.03。

```bash
cd FFmpeg-GPL-exe
tar -xzf ffmpeg-7.1.5.tar.gz
tar -xzf x264-stable.tar.gz
bash build-ffmpeg-gpl.sh
```

脚本默认路径为原构建机 `D:/hwcw/ThermalIQ/_ffbuild`；在其他机器复现时
修改脚本顶部的 `ROOT`、`X264_PREFIX`、`FFMPEG_PREFIX`。脚本会生成一个
只返回 x264 编译参数的 `pkg-config` shim，不依赖系统 pkg-config。

关键 configure 选项：

```text
--enable-gpl --enable-version3 --enable-libx264
--enable-static --disable-shared --disable-everything
--enable-ffmpeg --disable-ffprobe --disable-ffplay
--disable-doc --disable-debug --disable-autodetect
--enable-avfilter --enable-swscale --enable-swresample
--enable-d3d11va --enable-hwaccel=h264_d3d11va,hevc_d3d11va
--enable-demuxer=rtsp,rtp,h264,mov,mpegts,image2,sdp,rdt
--enable-decoder=h264,hevc,mjpeg
--enable-encoder=libx264,mjpeg
--enable-muxer=mp4,mov,mjpeg
--enable-parser=h264,hevc,mjpeg
--enable-protocol=file,pipe,rtp,tcp,udp,http
```

该构建只含 libx264，不含 x265，也不含 gyan full build 的其他外部库。
原 gyan 7.1.1-full 已不再随 ThermalIQ 分发，其备份仅保留在构建机，
不进入交付目录。

## 验证

- `-hwaccels`：`d3d11va` 已启用；
- 编码器：`libx264`、`mjpeg`；
- 解码器：`h264`、`hevc`、`mjpeg`；
- 复用器：`mp4`、`mov`、`mjpeg`；
- 本机 MP4 → libx264 → MP4：退出码 0，输出 344,476 B；
- RTSP 回环收流 → libx264 → MP4：退出码 0，输出 472,365 B，4 s / 32 帧；
- legacy 预览 MJPEG 管道：退出码 0，输出 336,252 B。

命令行为与 ThermalIQ 现有调用保持一致：

```text
录像:       -i rtsp://... -c:v libx264 -preset ultrafast -tune zerolatency \
            -movflags +faststart -flush_packets 1 -f mp4 out.mp4
legacy 预览: -i rtsp://... -an -f mjpeg -r 8 -q:v 4 -
```

## 许可

`ffmpeg.exe` 以 GPL v3 分发；x264 为 GPL-2.0-or-later，按 GPL v3 兼容方式
组合。FFmpeg 与 x264 源码均未修改，裁剪只通过 configure 选项实现。

源码请求：`chinapeter2008@163.com`（自最后一次分发起至少三年有效）。
