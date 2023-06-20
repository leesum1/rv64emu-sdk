#!/usr/bin/env bash

# ROOT PATH
SDK_ROOT=$(pwd)
OPENSBI_ROOT=${SDK_ROOT}/opensbi
BUSYBOX_ROOT=${SDK_ROOT}/busybox-1_36_stable
LINUX_ROOT=${SDK_ROOT}/linux
# IMAGE PATH
LINUX_BIN=${LINUX_ROOT}/arch/riscv/boot/Image
OPENSBI_ELF=${OPENSBI_ROOT}/build/platform/generic/firmware/fw_payload.elf

############################################
# You need to modify the following path according to your own environment
# RV64EMU
RV64EMU=/home/leesum/workhome/riscv64-emu
# CROSS_COMPILE
CROSS_COMPILE=/opt/riscv-linux/bin/riscv64-unknown-linux-gnu-
############################################

# Build Linux
cp rv64emu_linux_defconfig ${LINUX_ROOT}/arch/riscv/configs/
make -C ${LINUX_ROOT} ARCH=riscv CROSS_COMPILE=${CROSS_COMPILE} rv64emu_linux_defconfig
make -C ${LINUX_ROOT} ARCH=riscv CROSS_COMPILE=${CROSS_COMPILE} -j$(nproc)

# Build dts
dtc -I dts  -O dtb dts/rv64emu-signal.dts -o dts/rv64emu-signal.dtb
# Build opensbi with linux payload
cd ${OPENSBI_ROOT}
make clean
make PLATFORM=generic \
     CROSS_COMPILE=$CROSS_COMPILE \
     FW_PAYLOAD_PATH=$LINUX_BIN \
     FW_FDT_PATH=$SDK_ROOT/dts/rv64emu-signal.dtb -j$(nproc)

# Run rv64emu
cd $RV64EMU
cargo run --release  -- \
	  --img ${OPENSBI_ELF} \
	  --num-harts 1 
