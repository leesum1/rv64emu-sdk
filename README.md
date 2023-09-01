# RV64emu-sdk
This is a sdk for [rv64emu](https://github.com/leesum1/RV64emu-rs), which contains busybox, linux kernel and opensbi.

![run_linux](https://cdn.jsdelivr.net/gh/leesum1/doc/img/leesum1.gif)

## Get source code
Because the linux kernel is **TOO LARGE!!!!!**, so use `--depth 1` to clone the source code.
```shell
git submodule update --init --depth 1
```

## How to build busybox
> refer to [busybox](https://busybox.net)

Actrually, you can use the busybox binary in `rootfs` directory directly.Which is built with CFLAG `CFLAGS += -march=rv64imac -mabi=lp64`.

### Create console for linux
> the rootfs is based on busybox
```shell
cd rootfs
mkdir dev
sudo mknod dev/console c 5 1
sudo mknod dev/null c 1 3
sudo mknod dev/zero c 1 5
```

## Run linux kernel on rv64emu
> Before build linux kernel, you must create a console device for linux, refer to `Create console for linux`.


The defconfig file for linux kernel is `rv64emu_linux_defconfig`.The script `rv64emu_run_linux.sh` will build devicetree,linux kernel(with initrootfs support) and opensbi(with linux payload) automatically, and then run linux kernel on rv64emu.

You shall modify the script `rv64emu_run_linux.sh` to change the path of `rv64emu` and `riscv-gnu-toolchain` according to your environment.





