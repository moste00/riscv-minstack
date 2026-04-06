#!/bin/sh
set -eux
# REQUIRES: .versions and .env to be sourced first
: "${MSTK_VERSIONS_WERE_SET:?source .versions before running build-linux.sh}"
: "${MSTK_ENV_WAS_SET:?source .env before running build-linux.sh}"

########################### Obtain a 32-bit linux kernel ####################################################
# By building it from the sources as minimally as possible, since there is no easy way to get a prebuilt one.
#############################################################################################################

LINUX_TARBALL="linux-${MSTK_LINUX_VERSION}.tar.xz"
LINUX_CDN="https://cdn.kernel.org/pub/linux/kernel/v6.x"
BUILD_DIR="arch/riscv/boot"

# a Download the linux tarball
wget -q "${LINUX_CDN}/${LINUX_TARBALL}"
tar -xf "${LINUX_TARBALL}"

# b Build it for RISC-V 32-bit
cd "${LINUX_TARBALL%.tar.xz}"

# --- b.i Configure the build
sh ../riscv-minstack/scripts/rv32/configure-linux.sh

# --- b.ii Then actually build the kernel
make ARCH=riscv \
     CROSS_COMPILE="${MSTK_TOOLCHAIN_PREFIX}" \
     Image.gz compile_commands.json \
     -j$(nproc)

# --- b.iii Verify build output
file ${BUILD_DIR}/Image* && ls -lh ${BUILD_DIR}/ && readelf -h vmlinux | grep -E "Class|Machine"
export LINUX_ARTIFACT_ROOT=$(pwd)/${BUILD_DIR}
echo "LINUX_ARTIFACT_ROOT=${LINUX_ARTIFACT_ROOT}" >> ${GITHUB_ENV:-/dev/null}
cd "${LINUX_ARTIFACT_ROOT}" && for f in Image*; do
  cp "$f" "rv32-$f"
done
############################################### DONE ######################################################

# For debugging and checking that the build was as minimal as possible: 
# 1- Output all files that were compiled
echo "Files compiled: " $(cat compile_commands.json | grep '"file"' | sort -u)
# 2- Count all files that were compiled
echo "Number of files compiled: " $(cat compile_commands.json | grep '"file"' | wc -l)
# 3- Breakdown their lines of code by kernel subsystem
echo "cloc by subsystem: " $(cat compile_commands.json | python3 ../riscv-minstack/scripts/cloc-linux-subsys.py "$(pwd)")