#!/bin/sh

make ARCH=riscv CROSS_COMPILE=/opt/riscv-linux/bin/riscv64-unknown-linux-gnu- -j12 install

