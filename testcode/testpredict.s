.align 4
.section .text
.globl _start
    # Refer to the RISC-V ISA Spec for the functionality of
    # the instructions in this test program.
_start:

        and x1, x1, 0 #x1->a
        and x2, x2, 0 #x2->i
        and x3, x3, 0
        add x3, x3, 10
loop:
        beq x2, x3, halt
        and x2, x2, 1
        beq x2, x0, else
        add x1, x1, 1
        add x2, x2, 1
        beq x0, x0, loop
else:
        add x1, x1, 2
        add x2, x2, 1
        beq x0, x0, loop

halt:
        beq x0, x0, halt






.section .rodata
.balign 256
