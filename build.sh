#!/bin/sh
# Build the TOS 7 submission package for Memos.
# Produces: memos.tar.gz and memos.tar.gz.sha256
set -e

APPID=memos
VERSION=1.0.3

tar -czf "${APPID}.tar.gz" config.ini "${APPID}.lang" "${APPID}.svg" docker-compose.yml
sha256sum "${APPID}.tar.gz" > "${APPID}.tar.gz.sha256"

echo "built ${APPID}.tar.gz (version ${VERSION})"
cat "${APPID}.tar.gz.sha256"
