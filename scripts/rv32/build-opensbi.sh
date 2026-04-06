#!/bin/sh
set -eux
# REQUIRES: .versions and .env to be sourced first
: "${VERSIONS_WERE_SET:?source .versions before running build-opensbi.sh}"
: "${ENV_WAS_SET:?source .env before running build-opensbi.sh}"

git clone --depth 1 --branch "$OPENSBI_VERSION" https://github.com/riscv-software-src/opensbi
cd opensbi
make CROSS_COMPILE="${TOOLCHAIN_PREFIX}" \
     PLATFORM=generic \
     PLATFORM_RISCV_XLEN=32 \
     -j$(nproc)

echo "OPENSBI_ARTIFACT_ROOT=$(pwd)/build/platform/generic/firmware" >> ${GITHUB_ENV:-/dev/null}