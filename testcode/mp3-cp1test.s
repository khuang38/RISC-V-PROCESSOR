lw_sw_all:
.align 4
.section .text
.globl _start
_start:

lui x12, 1
nop
nop
nop
addi x12, x12, 0x134

lw sp, 8(x12)



 lw x2, LVAL2
 lw x3, LVAL3

 addi x2, x1, 1
addi x0, x0, x0

 add x3, x1, x2

addi x10, x12, 
 la x10, line1
 la x9, line2
 la x8, line3
 sw x1, 0(x10) 
 sw x2, 0(x9) 
 sw x3, 0(x8) 
 
 lw x7, line1
 lw x6, line2
 lw x5, line3

 slli x7, x7,8
 srli x6, x6,16
 
 lw x2, LVAL4
 lw x3, LVAL5

 addi x3, x3, 1
 and x10, x10, 0
 addi x10, x10, 2
 
 beq x2, x3, A
 nop
 nop
 nop
 and x2, x2, 0
 slli x2, x2, 8

HALT:
 beq x0, x0, HALT

A:
 lw x4, LVAL6 
 lw x5, LVAL4

 sub x7, x4, x5 
 bge x7, x10, A
 nop
 nop
 nop
 lw x8, LVAL7
 beq x0, x0, HALT
 
 
 


 

 







.section .rodata



:      .word 0x11111111
line2:      .word 0x66666666
line3:      .word 0x38383838
LVAL1:	    .word 0xffffffff
LVAL2:	    .word 0x0000ffff
LVAL3:	    .word 0x7fffffff
LVAL4:      .word 0x00000001
LVAL5:      .word 0x00000000
LVAL6:      .word 0x0000000a
LVAL7:      .word 0x00000011 #17
