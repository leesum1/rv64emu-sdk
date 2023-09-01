#!/usr/bin/env bash

# ROOT PATH
SDK_ROOT=$(pwd)
OPENSBI_ROOT=${SDK_ROOT}/opensbi
BUSYBOX_ROOT=${SDK_ROOT}/busybox-1_36_stable
LINUX_ROOT=${SDK_ROOT}/linux
# IMAGE PATH
LINUX_CONFIG=rv64emu_linux_defconfig
LINUX_BIN=${LINUX_ROOT}/arch/riscv/boot/Image
OPENSBI_ELF=${OPENSBI_ROOT}/build/platform/generic/firmware/fw_payload.elf
DTS_FILE=${SDK_ROOT}/dts/rv64emu-signal-128m

############################################
# You need to modify the following path according to your own environment
# RV64EMU
RV64EMU=/home/leesum/workhome/riscv64-emu
# CROSS_COMPILE
CROSS_COMPILE=/opt/riscv-linux/bin/riscv64-unknown-linux-gnu-
############################################

# Build Linux
cp ${SDK_ROOT}/${LINUX_CONFIG} ${LINUX_ROOT}/arch/riscv/configs/
make -C ${LINUX_ROOT} ARCH=riscv CROSS_COMPILE=${CROSS_COMPILE} ${LINUX_CONFIG}
make -C ${LINUX_ROOT} ARCH=riscv CROSS_COMPILE=${CROSS_COMPILE} -j$(nproc)

# Build dts
dtc -I dts -O dtb ${DTS_FILE}.dts -o ${DTS_FILE}.dtb
# Build opensbi with linux payload
cd ${OPENSBI_ROOT}
make clean
make PLATFORM=generic \
     CROSS_COMPILE=$CROSS_COMPILE \
     FW_PAYLOAD_PATH=$LINUX_BIN \
     FW_FDT_PATH=${DTS_FILE}.dtb -j$(nproc)

# Run rv64emu
cd $RV64EMU
cargo run --release --example=linux_system -- --img ${OPENSBI_ELF} \
     --num-harts 1
