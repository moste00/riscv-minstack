#!/bin/sh
set -eux
# REQUIRES: .versions and .env to be sourced first
: "${MSTK_VERSIONS_WERE_SET:?source .versions before running build-busybox.sh}"
: "${MSTK_ENV_WAS_SET:?source .env before running build-busybox.sh}"

BUSYBOX_TARBALL=busybox-${MSTK_BUSYBOX_VERSION}.tar.bz2
BUSYBOX_URL=https://busybox.net/downloads

wget -q "$BUSYBOX_URL/$BUSYBOX_TARBALL" && tar -xf "$BUSYBOX_TARBALL"
cd "${BUSYBOX_TARBALL%.tar.bz2}"

# config for RV32 single static binary
make ARCH=riscv CROSS_COMPILE="${MSTK_TOOLCHAIN_PREFIX}" defconfig
sed -i'' 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
sed -i'' 's/CONFIG_TC=y/CONFIG_TC=n/' .config
sed -i'' 's/CONFIG_HWCLOCK=y/CONFIG_HWCLOCK=n/' .config

make ARCH=riscv CROSS_COMPILE="${MSTK_TOOLCHAIN_PREFIX}" -j$(nproc)

echo "BUSYBOX_ARTIFACT_ROOT=$(pwd)" >> ${GITHUB_ENV:-/dev/null}