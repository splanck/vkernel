# vkernel

This repository contains a minimal x86_64 hobby kernel.

## Building

First set up the cross‑compiler environment (the toolchain can be built with
`build_toolchain.sh` and installs to `$HOME/opt/cross`):

```bash
source envsetup.sh
```

```
make
```

To create a bootable ISO image (uses `grub/grub.cfg` for the boot menu):

```
make iso
```

## Running

Run the kernel in QEMU:

```
make run
```

This opens a QEMU window so the VGA output from `kernel_main` is visible.
