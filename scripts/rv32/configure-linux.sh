#!/bin/sh
set -eu

# Zero baseline, barest kernel possible
make ARCH=riscv allnoconfig

# Write a minimal config fragment
cat << EOF > minimal_initramfs.config
# ISA (set via direct inject below — choice block ignores merge_config)
CONFIG_MMU=y

# Core kernel
CONFIG_PRINTK=y
CONFIG_BINFMT_ELF=y
CONFIG_KALLSYMS=n
CONFIG_BUG=n
CONFIG_ELF_CORE=n
CONFIG_COREDUMP=n
CONFIG_MODULES=n

# Memory allocator
CONFIG_SLUB=y

# initramfs
CONFIG_BLK_DEV_INITRD=y
CONFIG_TMPFS=y

# Console
CONFIG_TTY=y
CONFIG_SERIAL_EARLYCON=y
CONFIG_HVC_RISCV_SBI=y
CONFIG_VIRTIO_CONSOLE=y

# VirtIO bus — MMIO only
CONFIG_VIRTIO=y
CONFIG_VIRTIO_MMIO=y
CONFIG_VIRTIO_PCI=n

CONFIG_VIRTIO_BLK=y

# SBI
CONFIG_RISCV_SBI=y

# Pseudo filesystems
CONFIG_PROC_FS=y
CONFIG_SYSFS=y

# Block/filesystem support
CONFIG_VIRTIO_MENU=y
CONFIG_EXT4_FS=y
CONFIG_JBD2=y
CONFIG_FS_MBCACHE=y

CONFIG_BLOCK=y

CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y

# Disabled subsystems
CONFIG_NET=n
CONFIG_CRYPTO=n
CONFIG_SOUND=n
CONFIG_USB_SUPPORT=n
CONFIG_DRM=n
CONFIG_SECURITY=n
CONFIG_AUDIT=n
CONFIG_FTRACE=n
CONFIG_KPROBES=n
CONFIG_PERF_EVENTS=n
CONFIG_PROFILING=n
CONFIG_DEBUG_INFO=n
CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT=n
CONFIG_BLK_CGROUP=n
CONFIG_EXPERT=y
CONFIG_RISCV_PMU=n
CONFIG_RISCV_PMU_SBI=n
CONFIG_RISCV_PMU_LEGACY=n
CONFIG_EFI=n
CONFIG_EFI_STUB=n
CONFIG_RD_BZIP2=n
CONFIG_RD_LZMA=n
CONFIG_RD_XZ=n
CONFIG_RD_LZO=n
CONFIG_RD_LZ4=n
CONFIG_RD_ZSTD=n
CONFIG_VT=n
CONFIG_INPUT=n
CONFIG_IO_URING=n
EOF

# Apply fragment to produce a full config
./scripts/kconfig/merge_config.sh .config minimal_initramfs.config

# Direct inject overrides AFTER merge — these have "default y" and
# olddefconfig would restore them if set via merge_config only.
# Must be appended after merge, before olddefconfig.
cat << EOF >> .config
CONFIG_NONPORTABLE=y
CONFIG_ARCH_RV32I=y
# CONFIG_ARCH_RV64I is not set
# CONFIG_RISCV_PMU is not set
# CONFIG_RISCV_PMU_LEGACY is not set
# CONFIG_RISCV_PMU_SBI is not set
# CONFIG_PERF_EVENTS is not set
# CONFIG_EFI is not set
# CONFIG_EFI_STUB is not set
CONFIG_HVC_RISCV_SBI=y
EOF

# Resolve remaining dependencies silently
make ARCH=riscv olddefconfig

echo "################################################################################"
echo "################# Kernel will compile on the following config: #################"
echo "################################################################################"
cat .config
echo "################################################################################"
echo "################################################################################"