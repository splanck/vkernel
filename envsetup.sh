#!/usr/bin/env bash
# Set up environment variables for the cross compiler
PREFIX="${HOME}/opt/cross"
export PATH="${PREFIX}/bin:${PATH}"
export CC="x86_64-elf-gcc"
export AS="x86_64-elf-as"
export LD="x86_64-elf-ld"
export OBJCOPY="x86_64-elf-objcopy"
