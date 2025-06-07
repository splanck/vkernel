# vkernel

This repository contains a minimal x86_64 hobby kernel.

## Building

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
