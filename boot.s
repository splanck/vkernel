.code32

.section .multiboot,"a"
    .align 8
multiboot_header:
    .long 0xE85250D6            # magic (multiboot2)
    .long 0                     # architecture (i386)
    .long header_end - multiboot_header
    .long -(0xE85250D6 + 0 + (header_end - multiboot_header))
    .align 8
    .short 0                    # end tag type
    .short 0
    .long 8                     # size
header_end:

.global start

# Selector definitions
.set CODE64_SEL, 0x08
.set DATA_SEL,   0x10

.section .text
start:
    cli

    # Load GDT suitable for long mode
    lgdt gdt_descriptor

    # Reload segment registers with 32-bit data selector
    movw $DATA_SEL, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs
    movw %ax, %ss

    # Enable PAE in CR4
    mov %cr4, %eax
    orl $0x20, %eax
    mov %eax, %cr4

    # Point CR3 to PML4
    movl $pml4_table, %eax
    mov %eax, %cr3

    # Enable long mode in EFER
    movl $0xC0000080, %ecx
    rdmsr
    orl $0x100, %eax
    wrmsr

    # Enable paging
    mov %cr0, %eax
    orl $0x80000001, %eax     # PG | PE
    mov %eax, %cr0

    # Far jump to 64-bit code segment
    ljmp $CODE64_SEL, $long_mode_start

.code64
long_mode_start:
    # Set up stack for kernel
    leaq stack_top(%rip), %rsp

    .extern kernel_entry
    jmp kernel_entry

.section .bss
    .align 16
stack_bottom:
    .skip 4096
stack_top:

.section .data
    .align 4096
pml4_table:
    .quad pdpt_table + 0x3
    .fill 511,8,0

    .align 4096
pdpt_table:
    .quad pd_table + 0x3
    .fill 511,8,0

    .align 4096
pd_table:
    .quad 0x00000083  # 2MiB identity mapping
    .fill 511,8,0

    .align 8
    .global gdt_descriptor

    .quad 0

gdt:
    .quad 0x0000000000000000      # Null descriptor
    .quad 0x00af9a000000ffff      # 64-bit code
    .quad 0x00af92000000ffff      # 64-bit data

    .set gdt_size, . - gdt

gdt_descriptor:
    .word gdt_size - 1
    .quad gdt

