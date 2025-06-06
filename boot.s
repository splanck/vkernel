.intel_syntax noprefix
.code32

.section .multiboot
    .align 4
    .long 0x1BADB002            # magic
    .long 0x0                   # flags
    .long -(0x1BADB002)         # checksum

.global start

# Selector definitions
.set CODE64_SEL, 0x08
.set DATA_SEL,   0x10

.section .text
start:
    cli

    # Load GDT suitable for long mode
    lgdt [gdt_descriptor]

    # Reload segment registers with 32-bit data selector
    mov ax, DATA_SEL
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    # Enable PAE in CR4
    mov eax, cr4
    or eax, 0x20
    mov cr4, eax

    # Point CR3 to PML4
    mov eax, offset pml4_table
    mov cr3, eax

    # Enable long mode in EFER
    mov ecx, 0xC0000080
    rdmsr
    or eax, 0x100
    wrmsr

    # Enable paging
    mov eax, cr0
    or eax, 0x80000001     # PG | PE
    mov cr0, eax

    # Far jump to 64-bit code segment
    ljmp CODE64_SEL, offset long_mode_start

.code64
long_mode_start:
    # Set up stack for kernel
    lea rsp, [stack_top]

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

