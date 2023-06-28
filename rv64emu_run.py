import os
import subprocess

# ROOT PATH
SDK_ROOT = os.getcwd()
OPENSBI_ROOT = os.path.join(SDK_ROOT, "opensbi")
BUSYBOX_ROOT = os.path.join(SDK_ROOT, "busybox-1_36_stable")
LINUX_ROOT = os.path.join(SDK_ROOT, "linux")
# IMAGE PATH
LINUX_BIN = os.path.join(LINUX_ROOT, "arch", "riscv", "boot", "Image")
OPENSBI_ELF = os.path.join(
    OPENSBI_ROOT, "build", "platform", "generic", "firmware", "fw_payload.elf"
)
DTS_FILE = os.path.join(SDK_ROOT, "dts", "rv64emu-signal-8m")

############################################
# You need to modify the following path according to your own environment
# RV64EMU
RV64EMU = "/home/leesum/workhome/riscv64-emu"
# CROSS_COMPILE
CROSS_COMPILE = "/opt/riscv-linux/bin/riscv64-unknown-linux-gnu-"
############################################

# Build Linux
subprocess.run(
    [
        "cp",
        "rv64emu_linux_defconfig",
        os.path.join(LINUX_ROOT, "arch", "riscv", "configs"),
    ]
)
subprocess.run(
    [
        "make",
        "-C",
        LINUX_ROOT,
        "ARCH=riscv",
        f"CROSS_COMPILE={CROSS_COMPILE}",
        "rv64emu_linux_defconfig",
    ]
)
subprocess.run(
    [
        "make",
        "-C",
        LINUX_ROOT,
        "ARCH=riscv",
        f"CROSS_COMPILE={CROSS_COMPILE}",
        "-j",
        str(os.cpu_count()),
    ]
)

# Build dts
subprocess.run(
    ["dtc", "-I", "dts", "-O", "dtb", f"{DTS_FILE}.dts", "-o", f"{DTS_FILE}.dtb"]
)

# Build opensbi with linux payload
os.chdir(OPENSBI_ROOT)
subprocess.run(["make", "clean"])
subprocess.run(
    [
        "make",
        "PLATFORM=generic",
        f"CROSS_COMPILE={CROSS_COMPILE}",
        f"FW_PAYLOAD_PATH={LINUX_BIN}",
        f"FW_FDT_PATH={DTS_FILE}.dtb",
        "-j",
        str(os.cpu_count()),
    ]
)

# Run rv64emu
os.chdir(RV64EMU)
subprocess.run(
    [
        "cargo",
        "run",
        "--release",
        "--example=linux_system",
        "--",
        "--img",
        OPENSBI_ELF,
        "--num-harts",
        "1",
    ]
)
