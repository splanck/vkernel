# vkernel

This repository contains a minimal x86_64 hobby kernel.

## Building

Before building, source the environment setup script to add the cross
toolchain to your `PATH` and export the build variables:

```
source envsetup.sh
```

Then build the kernel:

```
make
```

To create a bootable ISO image:

```
make iso
```

## Running

Run the kernel in QEMU:

```
make run
```

This opens a QEMU window so the VGA output from `kernel_main` is visible.
