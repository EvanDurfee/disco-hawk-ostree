#!/usr/bin/env bash

# Builds Ghostty from the official source tarball. Runs in the "ghostty"
# build stage; the installed tree in /out/ghostty is copied into the final image.
set -oue pipefail

GHOSTTY_VERSION=1.4.0
GHOSTTY_SHA256=cb188ac6c3a8278d5fd7bfef15d8c017104c87f638b5560eb38024a71ae0f005

# Must match .minimum_zig_version in Ghostty's build.zig.zon
ZIG_VERSION=0.17.0
ZIG_SHA256=1cbe9df9f27e6b78d14ccbca43b6703a404ef79ef1c463de901d7f088d4e2026

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
