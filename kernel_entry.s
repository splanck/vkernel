.code64

.global _start
.global kernel_entry
.extern kernel_main

.section .text
kernel_entry:
_start:
    cli
    # Load data segment selector (assume 0x10)
    movw $0x10, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs
    movw %ax, %ss

    # Set up stack pointer
    leaq stack_top(%rip), %rsp

    call kernel_main

hang:
    hlt
    jmp hang

.section .bss
    .align 16
stack_bottom:
    .skip 4096
stack_top:

