CC ?= x86_64-elf-gcc
AS ?= x86_64-elf-as
LD ?= x86_64-elf-ld
OBJCOPY ?= x86_64-elf-objcopy
CFLAGS=-ffreestanding -m64 -nostdlib -nostdinc -fno-pic -mno-red-zone -c
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

kernel.bin: kernel.elf
	$(OBJCOPY) -O binary $< $@

iso: kernel.bin
	mkdir -p iso/boot/grub
	echo 'set timeout=0' > iso/boot/grub/grub.cfg
	echo 'set default=0' >> iso/boot/grub/grub.cfg
	echo 'multiboot2 /boot/kernel.bin' >> iso/boot/grub/grub.cfg
	cp kernel.bin iso/boot/
	grub-mkrescue -o kernel.iso iso >/dev/null 2>&1

clean:
	rm -rf *.o kernel.elf kernel.bin kernel.iso iso

run: iso
	# Boot the ISO in QEMU with default graphical output
	qemu-system-x86_64 -cdrom kernel.iso

.PHONY: all iso clean run
