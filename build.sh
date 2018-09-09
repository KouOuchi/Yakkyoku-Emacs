#!/bin/sh

WORK_DIR="./tmp"
CP="cp --verbose"

EMACS_VER="26.1"
DIST_DIR="/c/Apps/emacs/emacs-${EMACS_VER}"
SRCS_URL="http://ftp.gnu.org/gnu/emacs/emacs-${EMACS_VER}.tar.gz"
SRCS_TGZ="emacs-${EMACS_VER}.tar.gz"
SRC_DIR="emacs-${EMACS_VER}"
DEPS_URL="http://ftp.gnu.org/gnu/emacs/windows/emacs-26/emacs-26-x86_64-deps.zip"
DEPS_ZIP="emacs-26-x86_64-deps.zip"

PATCH_URL="http://cha.la.coocan.jp/files/emacs-25.3-windows-ime-simple.patch"
PATCH_FILE="emacs-25.3-windows-ime-simple.patch"

RELEASE_TAG=`basename ${DIST_DIR}`
RELEASE_ZIP=${RELEASE_TAG}_ime_patched.zip
RELEASE_ZIP_ABS=`realpath ${WORK_DIR}`/${RELEASE_ZIP}

echo ===
echo some checks.
echo ===
which unzip || (echo && echo Not found unzip. && exit)
which wget || (echo && echo Not found wget. && exit)
test -d ${WORK_DIR} || (mkdir -p ${WORK_DIR} || echo && echo Can\'t create dir. && exit)

echo ===
echo wget source. 
echo ===
(cd ${WORK_DIR} && wget ${SRCS_URL} -O ${SRCS_TGZ} && tar xzvf ${SRCS_TGZ})

echo ===
echo wget patch. 
echo ===
(cd ${WORK_DIR} && wget ${PATCH_URL} -O ${PATCH_FILE})

echo ===
echo patch. 
echo ===
(cd ${WORK_DIR}/${SRC_DIR} && patch -b -p0 < ../${PATCH_FILE})

echo ===
echo build.
echo ===
(cd ${WORK_DIR}/${SRC_DIR} && ./autogen.sh)
(cd ${WORK_DIR}/${SRC_DIR} && LDFLAGS="-lcomctl32 -Wl,--subsystem,windows" ./configure --without-imagemagick --without-dbus --prefix=${DIST_DIR})
(cd ${WORK_DIR}/${SRC_DIR} && make bootstrap)
(cd ${WORK_DIR}/${SRC_DIR} && make)
(cd ${WORK_DIR}/${SRC_DIR} && make install)

echo ===
echo wget deps.
echo ===
(cd ${WORK_DIR} && wget ${DEPS_URL} -O ${DEPS_ZIP} && unzip -d ${DIST_DIR} ${DEPS_ZIP})

echo ===
echo package.
echo ===
(cd ${DIST_DIR}/.. && zip -9 -r ${RELEASE_ZIP_ABS} ${RELEASE_TAG}/)

echo ===
echo done.
echo ===
