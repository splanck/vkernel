.intel_syntax noprefix
.code64

.global _start
.global kernel_entry
.extern kernel_main

.section .text
kernel_entry:
_start:
    cli
    # Load data segment selector (assume 0x10)
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    # Set up stack pointer
    lea rsp, [stack_top]

    call kernel_main

hang:
    hlt
    jmp hang

.section .bss
    .align 16
stack_bottom:
    .skip 4096
stack_top:

