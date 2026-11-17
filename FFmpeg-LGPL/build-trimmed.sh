#!/bin/sh
# 裁剪版 LGPL FFmpeg 构建（内嵌解码专用）
# 目标：只保留红外热像仪 RTSP 流所需的最小解码面，把 88 MB 压到 10~15 MB。
# 依赖：MinGW 13.1（Qt 自带）+ Git Bash（提供 POSIX shell 与 sed/awk）
set -eu

export PATH="/c/Qt/Tools/mingw1310_64/bin:$PATH"
cd /d/hwcw/ThermalIQ/_ffbuild/FFmpeg-n7.1.5

./configure \
  --prefix=/d/hwcw/ThermalIQ/_ffbuild/prefix \
  --arch=x86_64 --target-os=mingw32 \
  --cc=gcc --cxx=g++ --ar=ar --ranlib=ranlib \
  --enable-shared --disable-static --enable-version3 \
  --disable-gpl --disable-nonfree \
  --disable-programs --disable-doc --disable-avdevice --disable-avfilter \
  --disable-autodetect --disable-zlib --disable-iconv --disable-sdl2 \
  --disable-x86asm \
  --disable-everything \
  --enable-decoder=h264,hevc,mjpeg \
  --enable-parser=h264,hevc,mjpeg \
  --enable-demuxer=rtsp,mov,mpegts,h264,image2 \
  --enable-protocol=file,rtsp,rtp,tcp,udp,http,https \
  --enable-swscale --enable-swresample \
  --enable-bsf=h264_mp4toannexb,hevc_mp4toannexb

mingw32-make -j8
mingw32-make install

echo "=== 产物 ==="
ls -l /d/hwcw/ThermalIQ/_ffbuild/prefix/bin
