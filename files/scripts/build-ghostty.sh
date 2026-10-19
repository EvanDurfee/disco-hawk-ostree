#!/usr/bin/env bash

# Builds Ghostty from the official source tarball. Runs in the "ghostty"
# build stage; the installed tree in /out/ghostty is copied into the final image.
set -oue pipefail

GHOSTTY_VERSION=1.3.1
GHOSTTY_SHA256=3349d25600ffbda281197a18314f7d18791969cffe9474f0ff16a45a9ebfccdb

# Must match .minimum_zig_version in Ghostty's build.zig.zon
ZIG_VERSION=0.15.2
ZIG_SHA256=02aa270f183da276e5b5920b1dac44a63f1a49e55050ebde3aecc9eb82f93239

dnf -y install \
    gettext \
    gtk4-devel \
    gtk4-layer-shell-devel \
    libadwaita-devel \
    libX11-devel \
    pkgconf-pkg-config \
    tar \
    wayland-devel \
    xz

BUILD_DIR=$(mktemp -d)
cd "$BUILD_DIR"

curl -fsSL -o zig.tar.xz \
    "https://ziglang.org/download/${ZIG_VERSION}/zig-x86_64-linux-${ZIG_VERSION}.tar.xz"
echo "${ZIG_SHA256}  zig.tar.xz" | sha256sum -c -
mkdir zig && tar -xJf zig.tar.xz -C zig --strip-components=1

curl -fsSL -o ghostty.tar.gz \
    "https://release.files.ghostty.org/${GHOSTTY_VERSION}/ghostty-${GHOSTTY_VERSION}.tar.gz"
echo "${GHOSTTY_SHA256}  ghostty.tar.gz" | sha256sum -c -
tar -xzf ghostty.tar.gz

cd "ghostty-${GHOSTTY_VERSION}"
ZIG_GLOBAL_CACHE_DIR="$BUILD_DIR/zig-cache" DESTDIR=/out/ghostty \
    "$BUILD_DIR/zig/zig" build \
    --prefix /usr \
    -Doptimize=ReleaseFast \
    -Dcpu=baseline

rm -rf "$BUILD_DIR"
