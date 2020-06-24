#!/bin/sh

TAG="$1"

git checkout "$TAG"

# mupdf .gitmodules uses relative paths, assuming the projects are in the parent directory of the mupdf directory. This replaces those paths with GitHub urls to those projects.
sed -i -E 's/url = ..\/(.+).git/url = https:\/\/github.com\/ArtifexSoftware\/\1/g' .gitmodules

sudo apt-get update -qq && sudo apt-get -qq -y install xorg-dev mesa-common-dev libgl1-mesa-dev libxcursor-dev libxrandr-dev libxinerama-dev libgtk2.0-dev

gcc -Wl,--no-as-needed `pkg-config --cflags --libs gtk+-2.0` platform/x11/file_chooser.c -o file_chooser ; strip file_chooser
( cd thirdparty/ ; git submodule init ; git submodule update )
make prefix=/usr install DESTDIR=$(readlink -f appdir) ; find appdir/

mkdir -p ./appdir/usr/share/hicolor/scalable/apps ; wget -c "https://ghostscript.com/~tor/mupdf-logo/mupdf-logo.svg" -O ./appdir/usr/share/hicolor/scalable/apps/mupdf.svg
rm -rf  ./appdir/usr/include appdir/usr/lib/*.a # Don't need to ship developer files in AppImage

# MuPDF
cp -r appdir mupdf.AppDir
cp file_chooser mupdf.AppDir/usr/bin
mkdir -p ./mupdf.AppDir/usr/share/applications ; cp platform/x11/mupdf.desktop ./mupdf.AppDir/usr/share/applications/
rm ./mupdf.AppDir/usr/bin/{mjsgen,mujstest,mupdf-x11,mupdf-x11-curl,muraster,mutool}
wget -c "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
chmod a+x linuxdeployqt*.AppImage
unset QTDIR; unset QT_PLUGIN_PATH ; unset LD_LIBRARY_PATH
export VERSION=$(git rev-parse --short HEAD) # linuxdeployqt uses this for naming the file
./linuxdeployqt*.AppImage ./mupdf.AppDir/usr/bin/file_chooser -bundle-non-qt-libs
./linuxdeployqt*.AppImage ./mupdf.AppDir/usr/share/applications/*.desktop -bundle-non-qt-libs
./linuxdeployqt*.AppImage ./mupdf.AppDir/usr/share/applications/*.desktop -appimage

# mutool
cp -r appdir mutool.AppDir
rm ./mutool.AppDir/usr/bin/{mjsgen,mujstest,muraster,mupdf*}
mkdir -p ./mutool.AppDir/usr/share/applications ; cp platform/x11/mutool.desktop ./mutool.AppDir/usr/share/applications/
./linuxdeployqt*.AppImage ./mutool.AppDir/usr/share/applications/*.desktop -bundle-non-qt-libs
./linuxdeployqt*.AppImage ./mutool.AppDir/usr/share/applications/*.desktop -appimage

# mujstest
cp -r appdir mujstest.AppDir
rm ./mujstest.AppDir/usr/bin/{mjsgen,mutool,muraster,mupdf*}
mkdir -p ./mujstest.AppDir/usr/share/applications ; cp platform/x11/mujstest.desktop ./mujstest.AppDir/usr/share/applications/
./linuxdeployqt*.AppImage ./mujstest.AppDir/usr/share/applications/*.desktop -bundle-non-qt-libs
./linuxdeployqt*.AppImage ./mujstest.AppDir/usr/share/applications/*.desktop -appimage

rm ./linuxdeployqt*.AppImage
wget -c https://github.com/probonopd/uploadtool/raw/master/upload.sh
bash upload.sh ./*.AppImage*
