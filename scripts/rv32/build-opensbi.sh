#!/bin/sh
set -eux
# REQUIRES: .versions and .env to be sourced first
: "${MSTK_VERSIONS_WERE_SET:?source .versions before running build-opensbi.sh}"
: "${MSTK_ENV_WAS_SET:?source .env before running build-opensbi.sh}"

git clone --depth 1 --branch "${MSTK_OPENSBI_VERSION}" https://github.com/riscv-software-src/opensbi
cd opensbi
make CROSS_COMPILE="${MSTK_TOOLCHAIN_PREFIX}" \
     PLATFORM=generic \
     PLATFORM_RISCV_XLEN=32 \
     -j$(nproc)

export OPENSBI_ARTIFACT_ROOT=$(pwd)/build/platform/generic/firmware
echo "OPENSBI_ARTIFACT_ROOT=${OPENSBI_ARTIFACT_ROOT}" >> ${GITHUB_ENV:-/dev/null}
cd "${OPENSBI_ARTIFACT_ROOT}" && for f in fw*.bin fw*.elf fw*.o; do
  cp "$f" "rv32-$f"
done