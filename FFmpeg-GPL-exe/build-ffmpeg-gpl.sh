#!/bin/sh
# Build the minimal GPL ffmpeg.exe shipped with ThermalIQ.
#
# This script, together with the unmodified FFmpeg n7.1.5 source archive and the
# unmodified x264 source archive, is the "complete corresponding source" for the
# ffmpeg.exe distributed with ThermalIQ. See THIRD-PARTY-NOTICES.txt section 3.
#
# Toolchain: mingw-w64 GCC 13.1.0 (Qt 6.7.3 bundled MinGW 13.1.0), NASM 2.16.03.
#
# Usage (Git Bash on Windows):
#   bash build-ffmpeg-gpl.sh
#
# Inputs expected under _ffbuild/gpl-src/:
#   ffmpeg-gpl-src/          unmodified FFmpeg n7.1.5 source tree
#   x264-stable/             unmodified x264 stable source tree
#   nasm-2.16.03/nasm.exe    NASM assembler
# Outputs under _ffbuild/gpl-build/:
#   x264-prefix/             static libx264 + headers
#   ffmpeg-prefix/           configured prefix (the binary is built in-tree)

set -e

export PATH="/c/Qt/Tools/mingw1310_64/bin:/d/hwcw/ThermalIQ/_ffbuild/gpl-src/nasm-2.16.03:/d/hwcw/ThermalIQ/_ffbuild/gpl-build/bin:$PATH"

ROOT=/d/hwcw/ThermalIQ/_ffbuild
SRC=$ROOT/gpl-src
BUILD=$ROOT/gpl-build
X264_SRC=$SRC/x264-stable
FFMPEG_SRC=$SRC/ffmpeg-gpl-src
X264_PREFIX=D:/hwcw/ThermalIQ/_ffbuild/gpl-build/x264-prefix
FFMPEG_PREFIX=D:/hwcw/ThermalIQ/_ffbuild/gpl-build/ffmpeg-prefix

# Minimal pkg-config shim: the build only needs x264. This avoids requiring a
# system pkg-config installation and keeps the recipe reproducible.
mkdir -p "$BUILD/bin"
cat > "$BUILD/bin/pkg-config" <<EOF
#!/bin/sh
case "\$1" in
  --version) echo "0.29.2"; exit 0 ;;
  --exists) exit 0 ;;
  --cflags) echo "-I$X264_PREFIX/include"; exit 0 ;;
  --cflags-only-I) echo "-I$X264_PREFIX/include"; exit 0 ;;
  --libs) echo "-L$X264_PREFIX/lib -lx264"; exit 0 ;;
  --variable=includedir) echo "$X264_PREFIX/include"; exit 0 ;;
  --modversion) echo "0.165.x"; exit 0 ;;
  *) exit 0 ;;
esac
EOF
chmod +x "$BUILD/bin/pkg-config"

# ---------------------------------------------------------------- x264
# Static library only, no CLI. --disable-opencl keeps the dependency set to
# what the shipped binary actually needs.
cd "$X264_SRC"
./configure --prefix="$X264_PREFIX" --enable-static --disable-cli --disable-opencl
mingw32-make -j8
mkdir -p "$X264_PREFIX/lib" "$X264_PREFIX/include"
cp libx264.a "$X264_PREFIX/lib/"
cp x264.h x264_config.h "$X264_PREFIX/include/"

# ---------------------------------------------------------------- FFmpeg
# The feature set is deliberately minimal and matches what ThermalIQ invokes:
#   recording:  -i rtsp://... -c:v libx264 -f mp4 out.mp4
#   legacy preview fallback: -i rtsp://... -f mjpeg -r 8 -q:v 4 -
# Everything else (ffprobe, ffplay, most codecs/muxers/filters) is disabled.
cd "$FFMPEG_SRC"
./configure \
  --prefix="$FFMPEG_PREFIX" \
  --pkg-config="$BUILD/bin/pkg-config" \
  --arch=x86_64 --target-os=mingw32 \
  --enable-gpl --enable-version3 --enable-libx264 \
  --enable-static --disable-shared \
  --disable-everything \
  --enable-ffmpeg --disable-ffprobe --disable-ffplay \
  --disable-doc --disable-debug --disable-autodetect \
  --enable-avfilter --enable-swscale --enable-swresample \
  --enable-d3d11va --enable-hwaccel=h264_d3d11va,hevc_d3d11va \
  --enable-demuxer=rtsp,rtp,h264,mov,mpegts,image2,sdp,rdt \
  --enable-decoder=h264,hevc,mjpeg \
  --enable-encoder=libx264,mjpeg \
  --enable-muxer=mp4,mov,mjpeg \
  --enable-parser=h264,hevc,mjpeg \
  --enable-protocol=file,pipe,rtp,tcp,udp,http \
  --enable-filter=fps,scale,format,aformat,anull,null,trim,atrim,crop,transpose,hflip,vflip,rotate,setpts,aresample \
  --extra-cflags="-O2 -I$X264_PREFIX/include" \
  --extra-ldflags="-static -L$X264_PREFIX/lib"

mingw32-make -j8

echo "Built: $FFMPEG_SRC/ffmpeg.exe"
