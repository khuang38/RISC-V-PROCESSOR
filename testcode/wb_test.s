.align 4
.section .text
.globl _start
    # Refer to the RISC-V ISA Spec for the functionality of
    # the instructions in this test program.
_start:
	la x1, G30	# Load the address of G30 to x1
	la x8, B10	# Load the address of B10 to x8
	lw x2, G30	# Load the value of G30 to x2
	lw x3, B10	# Load the value of B10 to x3
	add x2, x3, x0	# Write the value of B10 to x3
	sw x2, 0(x1)	# Store the x2 back to G3A
	add x3, x2, x0	# Modified value of x3
	sw x3, 0(x8)	# Write it back to B10
	lw x5, S30		# x5 = 0x52205220
	lw x6, G30		# Should be 0xBAADBAAD
	lw x7, G3E		

inf:
    jal x0, inf

.section .rodata
.balign 256
.zero 96
G30: .word 0x600D600D
G32: .word 0x600D600D
G34: .word 0x600D600D
G36: .word 0x600D600D
G38: .word 0x600D600D
G3A: .word 0x600D600D
G3C: .word 0x600D600D
G3E: .word 0x600D600D

G40: .word 0x00C200C2
G42: .word 0x01480148
G44: .word 0x11221122
G46: .word 0x33443344
G48: .word 0x55665566
G4A: .word 0x77887788
G4C: .word 0x99AA99AA
G4E: .word 0xBBCCBBCC

G50: .word 0x600D600D
G52: .word 0x600D600D
G54: .word 0x600D600D
G56: .word 0x600D600D
G58: .word 0x600D600D
G5A: .word 0x600D600D
G5C: .word 0x600D600D
G5E: .word 0x600D600D

G60: .word 0x666D666D
G62: .word 0x677D677D
G64: .word 0x688D688D
G66: .word 0x699D699D
G68: .word 0x6AAD6AAD
G6A: .word 0x6BBD6BBD
G6C: .word 0x6CCD6CCD
G6E: .word 0x6DDD6DDD

G70: .word 0x600D600D
G72: .word 0x600D600D
G74: .word 0x600D600D
G76: .word 0x600D600D
G78: .word 0x600D600D
G7A: .word 0x600D600D
G7C: .word 0x600D600D
G7E: .word 0x600D600D

.balign 256
.zero 96

S30: .word 0x52205220
S32: .word 0x52205220
S34: .word 0x52205220
S36: .word 0x52205220
S38: .word 0x52205220
S3A: .word 0x52205220
S3C: .word 0x52205220
S3E: .word 0x52205220

S40: .word 0x52205220
S42: .word 0x52205220
S44: .word 0x52205220
S46: .word 0x52205220
S48: .word 0x52205220
S4A: .word 0x52205220
S4C: .word 0x52205220
S4E: .word 0x52205220

S50: .word 0x52205220
S52: .word 0x52205220
S54: .word 0x52205220
S56: .word 0x52205220
S58: .word 0x52205220
S5A: .word 0x52205220
S5C: .word 0x52205220
S5E: .word 0x52205220

S60: .word 0x5AA05AA0
S62: .word 0x5BB05BB0
S64: .word 0x5CC05CC0
S66: .word 0x5DD05DD0
S68: .word 0x5EE05EE0
S6A: .word 0x5FF05FF0
S6C: .word 0x51105110
S6E: .word 0x52205220

S70: .word 0x52205220
S72: .word 0x52205220
S74: .word 0x52205220
S76: .word 0x52205220
S78: .word 0x52205220
S7A: .word 0x52205220
S7C: .word 0x52205220
S7E: .word 0x52205220

.balign 256
.zero 96

B10: .word 0xBADDBADD
B12: .word 0xBADDBADD
B14: .word 0xB22DB22D
B16: .word 0xB33DB33D
B18: .word 0xB44DB44D
B1A: .word 0xB55DB55D
B1C: .word 0xB66DB66D
B1E: .word 0xB77DB77D

B20: .word 0xB88DB88D
B22: .word 0xB99DB99D
B24: .word 0xBAADBAAD
B26: .word 0xBBBDBBBD
B28: .word 0xBCCDBCCD
B2A: .word 0xBDDDBDDD
B2C: .word 0xBEEDBEED
B2E: .word 0xBFFDBFFD

B30: .word 0xBAADBAAD
B32: .word 0xBAADBAAD
B34: .word 0xBAADBAAD
B36: .word 0xBAADBAAD
B38: .word 0xBAADBAAD
B3A: .word 0xBAADBAAD
B3C: .word 0xBAADBAAD
B3E: .word 0xBAADBAAD

B40: .word 0xBAADBAAD
B42: .word 0xBAADBAAD
B44: .word 0xBAADBAAD
B46: .word 0xBAADBAAD
B48: .word 0xBAADBAAD
B4A: .word 0xBAADBAAD
B4C: .word 0xBAADBAAD
B4E: .word 0xBAADBAAD

B50: .word 0xBAADBAAD
B52: .word 0xBAADBAAD
B54: .word 0xBAADBAAD
B56: .word 0xBAADBAAD
B58: .word 0xBAADBAAD
B5A: .word 0xBAADBAAD
B5C: .word 0xBAADBAAD
B5E: .word 0xBAADBAAD

B60: .word 0xB88DB88D
B62: .word 0xB99DB99D
B64: .word 0xBAADBAAD
B66: .word 0xBBBDBBBD
B68: .word 0xBCCDBCCD
B6A: .word 0xBDDDBDDD
B6C: .word 0xBEEDBEED
B6E: .word 0xBFFDBFFD

B70: .word 0xBADDBADD
B72: .word 0xBADDBADD
B74: .word 0xBADDBADD
B76: .word 0xBADDBADD
B78: .word 0xBADDBADD
B7A: .word 0xBADDBADD
B7C: .word 0xBADDBADD
B7E: .word 0xBADDBADD
