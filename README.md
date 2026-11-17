# ThermalIQ 1.1.1 — 第三方开源源码交付包

版本：ThermalIQ 1.1.1  
生成日期：2026-11-17  
适用产品：ThermalIQ Infrared Thermal Analysis Workstation（Windows x64）

本目录用于履行 Qt（LGPL-3.0）、FFmpeg 内嵌解码库（LGPL-3.0）与
`ffmpeg.exe`（GPL-3.0）的对应源码提供义务。ThermalIQ 应用自身源码
（`src/`、`ThermalIQ.exe`）不属于本交付包，保持闭源。

## 目录

```text
ThermalIQ-1.1.1/
├─ README.md                      本文件
├─ SHA256SUMS.txt                 全部归档文件的 SHA-256
├─ THIRD-PARTY-NOTICES.txt        与安装包一致的第三方声明
├─ LICENSES/                      通用许可文本
├─ FFmpeg-LGPL/                   内嵌解码库（5 个 DLL）的源码与构建材料
│  ├─ ffmpeg-7.1.5.tar.gz
│  ├─ build-trimmed.sh
│  ├─ build.log
│  ├─ LICENSE.txt
│  └─ README.md
├─ FFmpeg-GPL-exe/                录像用 ffmpeg.exe 的源码与构建材料
│  ├─ ffmpeg-7.1.5.tar.gz
│  ├─ x264-stable.tar.gz
│  ├─ nasm-2.16.03-win64.zip
│  ├─ build-ffmpeg-gpl.sh
│  ├─ configure.log
│  ├─ build.log
│  ├─ ffmpeg.exe.sha256
│  ├─ README.md
│  └─ LICENSES/
└─ Qt/                            Qt 6.7.3 官方源码包（qtbase/qtsvg/qttranslations）
   ├─ qtbase-everywhere-src-6.7.3.tar.xz
   ├─ qtsvg-everywhere-src-6.7.3.tar.xz
   ├─ qttranslations-everywhere-src-6.7.3.tar.xz
   └─ md5sums.txt                 Qt 官方校验文件
```

## 组件与对应源码

| 随包组件 | 许可 | 对应源码 |
|---|---|---|
| Qt6Core/Gui/Widgets/Network/Sql/Svg 及 plugins | LGPL-3.0 | `Qt/` 下 qtbase、qtsvg、qttranslations 三个官方源码包 |
| avcodec-61、avformat-61、avutil-59、swscale-8、swresample-5 | LGPL-3.0 | `FFmpeg-LGPL/` |
| `ffmpeg.exe` | GPL-3.0 | `FFmpeg-GPL-exe/` |

## 构建方法

### FFmpeg 内嵌解码库（LGPL）

```bash
export PATH="/c/Qt/Tools/mingw1310_64/bin:$PATH"
cd FFmpeg-LGPL
tar -xzf ffmpeg-7.1.5.tar.gz
cd FFmpeg-n7.1.5
sh ../build-trimmed.sh
```

`build-trimmed.sh` 内含完整 configure 参数与安装前缀；构建日志见
`FFmpeg-LGPL/build.log`。产物为 5 个动态 DLL，未静态链入 ThermalIQ.exe。

### 录像用 ffmpeg.exe（GPL）

```bash
# 需要 Git Bash、Qt 6.7.3 自带 MinGW 13.1.0、NASM 2.16.03
cd FFmpeg-GPL-exe
tar -xzf ffmpeg-7.1.5.tar.gz
tar -xzf x264-stable.tar.gz
bash build-ffmpeg-gpl.sh
```

脚本会先构建静态 `libx264.a`，再以 `--enable-gpl --enable-version3
--enable-libx264` 构建静态 `ffmpeg.exe`。完整 configure 参数、License 行与
构建日志见同目录 `configure.log`、`build.log`。脚本内路径为原构建机的
`D:/hwcw/ThermalIQ/_ffbuild`，在其他机器复现时请同步修改 `ROOT` 变量。

构建出的 `ffmpeg.exe` 只依赖 Windows 系统 DLL
（`bcrypt.dll`、`KERNEL32.dll`、`msvcrt.dll`、`SHELL32.dll`、`WS2_32.dll`），
不依赖 libx264 DLL 或其他第三方运行库。

## 验证记录

- `ffmpeg.exe -hwaccels`：`d3d11va` 已启用；
- 编码器：`libx264`、`mjpeg`；
- 解码器：`h264`、`hevc`、`mjpeg`；
- 复用器：`mp4`、`mov`、`mjpeg`；
- 本机 MP4 → libx264 → MP4：通过；
- RTSP 回环（`-rtsp_flags listen` 收流）→ libx264 → MP4：通过；
- legacy 预览 MJPEG 管道（`-f mjpeg -r 8 -q:v 4`）：通过。

## 许可与源码请求

许可文本见 `LICENSES/` 与各子目录。源码获取地址：

    公开仓库：https://github.com/chinapeter2008/ThermalIQ-1.1.1-source-offer
    固定版本：https://github.com/chinapeter2008/ThermalIQ-1.1.1-source-offer/releases/tag/v1.1.1
    E-mail：chinapeter2008@163.com

本源码包自最后一次分发之日起至少三年内有效；请求仅在必要时收取物理介质
成本，不收取源码费用。

## 完整性

本目录已包含 Qt、FFmpeg LGPL、FFmpeg GPL 三块对应的全部源码与构建材料。
三个 Qt 官方归档均已通过官方 `md5sums.txt` 校验，校验文件保存在 `Qt/md5sums.txt`；
`SHA256SUMS.txt` 覆盖本目录内所有文件，可直接用于分发后完整性核对。
