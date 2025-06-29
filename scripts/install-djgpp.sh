#!/usr/bin/env bash
set -e

PREFIX=${1:-/opt/djgpp}
VERSION=v3.4
ARCHIVE=djgpp-linux64-gcc1220.tar.bz2
SHA256=8464f17017d6ab1b2bb2df4ed82357b5bf692e6e2b7fee37e315638f3d505f00
URL="https://github.com/andrewwutw/build-djgpp/releases/download/${VERSION}/${ARCHIVE}"

mkdir -p "$PREFIX"

wget -O /tmp/${ARCHIVE} "$URL"
echo "${SHA256}  /tmp/${ARCHIVE}" | shasum -a 256 --check
tar -xf /tmp/${ARCHIVE} -C "$PREFIX" --strip-components=1
rm /tmp/${ARCHIVE}

echo "DJGPP cross compiler installed to ${PREFIX}."
echo "Run 'source ${PREFIX}/setenv' to update your PATH."
