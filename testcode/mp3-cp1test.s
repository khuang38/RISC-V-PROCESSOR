lw_sw_all:
.align 4
.section .text
.globl _start
_start:


 
# lw x1, LVAL1
# lw x2, LVAL2
# lw x3, LVAL3

 lui x12,0
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
 addi x12, x12, 0x174
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
 lw x1, 0(x12)  # lw x1, LVAL1
 lw x2, 4(x12)  # lw x2, LVAL2
 lw x3, 8(x12)  # lw x3, LVAL3
 

 addi x2, x1, 1
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
 add x3, x1, x2

 addi x10, x12, 28 #la x10, LVAL8
 addi x9, x12, 32  #la x9, LVAL9
 addi x8, x12, 36  #la x8, LVAL10

 sw x1, 0(x10) # sw x1, LVAL8
 sw x2, 0(x9)  # sw x2, LVAL9
 sw x3, 0(x8)  # sw x3, LVAL10

 lw x7, 0(x10) # lw x7, LVAL8
 lw x6, 0(x9)  # lw x6, LVAL9
 lw x5, 0(x8)  # lw x5, LVAL10

   addi x0, x0, 0 #nop
 slli x7, x7,8
 srli x6, x6,16
 
 lw x2, 12(x12) #lw x2, LVAL4
 lw x3, 16(x12) #lw x3, LVAL5
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
 addi x3, x3, 1
 and x10, x10, 0
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
 addi x10, x10, 2
 
 beq x2, x3, A
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
 and x2, x2, 0
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
 slli x2, x2, 8

HALT:
 beq x0, x0, HALT

A:
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
 lw x4, 20(x12) #lw x4, LVAL6 
 lw x5, 12(x12) #lw x5, LVAL4 
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
B: 
   addi x4, x4, -1
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
 sub x7, x4, x5 
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
 bge x7, x10, B
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
   addi x0, x0, 0 #nop
 lw x8, 24(x12) #lw x8, LVAL7
 beq x0, x0, HALT

 







.section .rodata



LVAL1:	    .word 0xffffffff #0
LVAL2:	    .word 0x0000ffff #4
LVAL3:	    .word 0x7fffffff #8
LVAL4:      .word 0x00000001 #12
LVAL5:      .word 0x00000000 #16
LVAL6:      .word 0x0000000a #20
LVAL7:      .word 0x00000011 #24
LVAL8:      .word 0x11111111 #line1 28
LVAL9:      .word 0x66666666 #line2 32
LVAL10:     .word 0x38383838 #line3 36
