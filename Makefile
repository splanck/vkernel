CC ?= x86_64-elf-gcc
AS ?= x86_64-elf-as
LD ?= x86_64-elf-ld
OBJCOPY ?= objcopy
CFLAGS=-ffreestanding -m64 -nostdlib -nostdinc -fno-pic -mno-red-zone -c -fcf-protection=none
ASFLAGS=--64
LDFLAGS=-T linker.ld -nostdlib

all: kernel.bin

boot.o: boot.s
	$(AS) $(ASFLAGS) -o $@ $<

kernel_entry.o: kernel_entry.s
	$(AS) $(ASFLAGS) -o $@ $<

kernel.o: kernel.c
	$(CC) $(CFLAGS) $< -o $@

kernel.elf: boot.o kernel_entry.o kernel.o linker.ld
	$(LD) $(LDFLAGS) -o $@ boot.o kernel_entry.o kernel.o
	@if [ -f $@ ]; then \
		ls -l $@; \
	else \
		echo "Error: kernel.elf was not created. Check the link command and file paths."; \
		exit 1; \
	fi

kernel.bin: kernel.elf
	$(OBJCOPY) -O binary $< $@

iso: kernel.bin
	mkdir -p iso/boot/grub
	cp grub/grub.cfg iso/boot/grub/
	cp kernel.bin iso/boot/
	if ! command -v grub-mkrescue >/dev/null; then \
	echo "Error: grub-mkrescue not found. Please install GRUB to build the ISO."; \
	exit 1; \
	fi
	grub-mkrescue -o kernel.iso iso

clean:
	rm -rf *.o kernel.elf kernel.bin kernel.iso iso

run: iso
	# Boot the ISO in QEMU with default graphical output
	qemu-system-x86_64 -cdrom kernel.iso

.PHONY: all iso clean run
