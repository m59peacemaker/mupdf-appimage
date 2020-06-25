#!/bin/bash

set -e

git checkout "$BUILD_TAG"

# mupdf .gitmodules uses relative paths, assuming the projects are in the parent directory of the mupdf directory. This replaces those paths with GitHub urls to those projects.
sed -i -E 's/url = ..\/(.+).git/url = https:\/\/github.com\/ArtifexSoftware\/\1/g' .gitmodules
git submodule update --init

# add files needed for appimage
rsync -a "${GITHUB_WORKSPACE}/project-root/ci/mupdf-files/" ./

sudo apt-get update -qq \
	&& sudo apt-get -qq -y install \
		xorg-dev \
		mesa-common-dev \
		libgl1-mesa-dev \
		libglu1-mesa-dev \
		libxcursor-dev \
		libxrandr-dev \
		libxinerama-dev \
		libgtk2.0-dev \
		mesa-common-dev \
		libgl1-mesa-dev \
		libglu1-mesa-dev \
		xorg-dev \
		libxcursor-dev \
		libxrandr-dev \
		libxinerama-dev

gcc -Wl,--no-as-needed `pkg-config --cflags --libs gtk+-2.0` platform/x11/file_chooser.c -o file_chooser ; strip file_chooser
( cd thirdparty/ ; git submodule init ; git submodule update )
make prefix=/usr install DESTDIR=$(readlink -f appdir) ; find appdir/

mkdir -p ./appdir/usr/share/hicolor/scalable/apps;
wget -c "https://ghostscript.com/~tor/mupdf-logo/mupdf-logo.svg" -O ./appdir/usr/share/hicolor/scalable/apps/mupdf.svg
rm -rf  ./appdir/usr/include appdir/usr/lib/*.a # Don't need to ship developer files in AppImage

# MuPDF
cp -r appdir mupdf.AppDir
cp file_chooser mupdf.AppDir/usr/bin
mkdir -p ./mupdf.AppDir/usr/share/applications;
cp platform/x11/mupdf.desktop ./mupdf.AppDir/usr/share/applications/
ls mupdf.AppDir
ls mupdf.AppDir/usr
ls mupdf.AppDir/usr/bin
rm ./mupdf.AppDir/usr/bin/{mupdf-x11,muraster,mutool}
wget -c "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
chmod a+x linuxdeployqt*.AppImage
unset QTDIR; unset QT_PLUGIN_PATH ; unset LD_LIBRARY_PATH

# linuxdeployqt uses this for naming the AppImage file
#export VERSION=$(git rev-parse --short HEAD)
export VERSION="${BUILD_TAG}"

./linuxdeployqt*.AppImage ./mupdf.AppDir/usr/bin/file_chooser -bundle-non-qt-libs
./linuxdeployqt*.AppImage ./mupdf.AppDir/usr/share/applications/*.desktop -bundle-non-qt-libs
./linuxdeployqt*.AppImage ./mupdf.AppDir/usr/share/applications/*.desktop -appimage

# mutool
cp -r appdir mutool.AppDir
rm ./mutool.AppDir/usr/bin/{muraster,mupdf*}
mkdir -p ./mutool.AppDir/usr/share/applications;
cp platform/x11/mutool.desktop ./mutool.AppDir/usr/share/applications/
./linuxdeployqt*.AppImage ./mutool.AppDir/usr/share/applications/*.desktop -bundle-non-qt-libs
./linuxdeployqt*.AppImage ./mutool.AppDir/usr/share/applications/*.desktop -appimage

mupdf_AppImage_name="`echo MuPDF-*.AppImage`"
mupdf_AppImage_path="${PWD}/${mupdf_AppImage_name}"

mutool_AppImage_name="`echo mutool-*.AppImage`"
mutool_AppImage_path="${PWD}/${mutool_AppImage_name}"

echo "::set-output name=mupdf_AppImage_name::${mupdf_AppImage_name}"
echo "::set-output name=mupdf_AppImage_path::${mupdf_AppImage_path}"

echo "::set-output name=mutool_AppImage_name::${mutool_AppImage_name}"
echo "::set-output name=mutool_AppImage_path::${mutool_AppImage_path}"
