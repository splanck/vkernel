#!/usr/bin/env bash
set -e
set -o pipefail

# Default versions if not set via env vars
BINVER=${BINVER:-2.42}
GCCVER=${GCCVER:-13.2.0}
TARGET=${TARGET:-x86_64-elf}
PREFIX="$HOME/opt/cross"
export PATH="$PREFIX/bin:$PATH"

mkdir -p "$HOME/src"
cd "$HOME/src"

# Download sources
if [ ! -f binutils-$BINVER.tar.xz ]; then
    wget https://ftp.gnu.org/gnu/binutils/binutils-$BINVER.tar.xz
fi
if [ ! -f gcc-$GCCVER.tar.xz ]; then
    wget https://ftp.gnu.org/gnu/gcc/gcc-$GCCVER/gcc-$GCCVER.tar.xz
fi

# Extract
if [ ! -d binutils-$BINVER ]; then
    tar xf binutils-$BINVER.tar.xz
fi
if [ ! -d gcc-$GCCVER ]; then
    tar xf gcc-$GCCVER.tar.xz
fi

# Build binutils
mkdir -p build-binutils
cd build-binutils
../binutils-$BINVER/configure --target="$TARGET" --prefix="$PREFIX" \
    --with-sysroot --disable-nls --disable-werror
make -j$(nproc)
make install
cd ..

# Build GCC (only C for bare-metal)
mkdir -p build-gcc
cd build-gcc
../gcc-$GCCVER/configure --target="$TARGET" --prefix="$PREFIX" \
    --disable-nls --enable-languages=c --without-headers
make -j$(nproc) all-gcc
make -j$(nproc) all-target-libgcc
make install-gcc
make install-target-libgcc
cd ..

echo "Toolchain for $TARGET installed to $PREFIX"
