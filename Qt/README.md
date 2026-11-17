# Qt 6.7.3 源码包

本目录包含以下三个官方源码归档，与安装包内的 Qt DLL 及插件一一对应：

| 源码包 | 覆盖的随包文件 | 官方地址 |
|---|---|---|
| `qtbase-everywhere-src-6.7.3.tar.xz` | `Qt6Core.dll`、`Qt6Gui.dll`、`Qt6Widgets.dll`、`Qt6Network.dll`、`Qt6Sql.dll`；`platforms/qwindows.dll`；`sqldrivers/qsqlite.dll`；`imageformats/qgif/qico/qjpeg.dll`；`styles/qmodernwindowsstyle.dll`；`tls/qopensslbackend/qschannelbackend.dll`；`networkinformation/qnetworklistmanager.dll`；`generic/qtuiotouchplugin.dll` | https://download.qt.io/archive/qt/6.7/6.7.3/submodules/qtbase-everywhere-src-6.7.3.tar.xz |
| `qtsvg-everywhere-src-6.7.3.tar.xz` | `Qt6Svg.dll`；`imageformats/qsvg.dll`；`iconengines/qsvgicon.dll` | https://download.qt.io/archive/qt/6.7/6.7.3/submodules/qtsvg-everywhere-src-6.7.3.tar.xz |
| `qttranslations-everywhere-src-6.7.3.tar.xz` | `translations/qtbase_zh_CN.qm` | https://download.qt.io/archive/qt/6.7/6.7.3/submodules/qttranslations-everywhere-src-6.7.3.tar.xz |

三个归档均已通过 Qt 官方 `md5sums.txt` 校验（`md5sums.txt` 一并保存在本目录）：

| 源码包 | 大小 | 官方 MD5 |
|---|---:|---|
| `qtbase-everywhere-src-6.7.3.tar.xz` | 49,426,156 B | `cd4bd448867e169fd0510a787e448c8c` |
| `qtsvg-everywhere-src-6.7.3.tar.xz` | 1,792,980 B | `6521016a4ddaab33241321ced0e9c56b` |
| `qttranslations-everywhere-src-6.7.3.tar.xz` | 1,547,944 B | `21f12d044aa9f035f51721582b30b78c` |

Qt 使用官方二进制、未修改、动态链接；应用自身源码不因动态链接而需要开放。

若最终 1.1.1 安装包实际带入 `Qt6Concurrent.dll` 或
`Qt6OpenGLWidgets.dll`，二者源码仍在 `qtbase`，无需新增模块。
