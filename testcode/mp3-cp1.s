#  mp3-cp1.s version 2.0
.align 4
.section .text
.globl _start
_start:
    lui x1, %hi(NEGTWO)
    nop
    nop
    nop
    nop
    lw x1, %lo(NEGTWO)(x1)
    lui x2, %hi(TWO)
    nop
    nop
    nop
    nop
    lw x2, %lo(TWO)(x2)
    lui x4, %hi(ONE)
    nop
    nop
    nop
    nop
    lw x4, %lo(ONE)(x4)
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    beq x0, x0, LOOP
    nop
    nop
    nop
    nop
    nop
    nop
    nop

.section .rodata
.balign 256
ONE:    .word 0x00000001
TWO:    .word 0x00000002
NEGTWO: .word 0xFFFFFFFE
TEMP1:  .word 0x00000001
GOOD:   .word 0x600D600D
BADD:   .word 0xBADDBADD

	
.section .text
.align 4
LOOP:
    add x3, x1, x2 # X3 <= X1 + X2
    and x5, x1, x4 # X5 <= X1 & X4
    not x6, x1     # X6 <= ~X1
    lui x9, %hi(TEMP1)
    nop
    nop
    nop
    nop
    addi x9, x9, %lo(TEMP1) # X9 <= address of TEMP1
    nop
    nop
    nop
    nop
    nop
    nop
    sw x6, 0(x9)   # TEMP1 <= x6
    lui x7, %hi(TEMP1)
    nop
    nop
    nop
    nop
    lw x7, %lo(TEMP1)(x7) # X7    <= TEMP1
    add x1, x1, x4 # X1    <= X1 + X4
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    blt x0, x1, DONEa
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    beq x0, x0, LOOP
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    lui x1, %hi(BADD)
    nop
    nop
    nop
    nop
    lw x1, %lo(BADD)(x1)
HALT:	
    beq x0, x0, HALT
    nop
    nop
    nop
    nop
    nop
    nop
    nop
		
DONEa:
    lui x1, %hi(GOOD)
    nop
    nop
    nop
    nop
    lw x1, %lo(GOOD)(x1)
DONEb:	
    beq x0, x0, DONEb
    nop
    nop
    nop
    nop
    nop
    nop
    nop
	
