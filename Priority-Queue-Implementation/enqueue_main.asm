.data
.align 2
queue:
.half 4
.half 10
#.word p00, p03, p01, p04, p07, p06, p02, 0, 0, 0,	# Base test case
#.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,				# Enqueuing an item to empty queue
#.word p07, 0, 0, 0, 0, 0, 0, 0, 0, 0,				# Swapping once case #1
#.word p06, p07, 0, 0, 0, 0, 0, 0, 0, 0,			# Swapping once case #2
.word p01, p02, p03, p04, 0, 0, 0, 0, 0, 0,				# Swapping twice case #1
packet: .word p00
v0: .asciiz "v0: "

all_packets:
p00:
.align 2
.byte 0x18 0x00 0x9A 0x50 0x00 0x10 0x52 0x07 0x59 0xA1 0xDA 0x02 0x47 0x72 0x61 0x63 0x65 0x20 0x4D 0x75 0x72 0x72 0x61 0x79
p01:
.align 2
.byte 0x18 0x00 0x9A 0x50 0x0C 0x10 0x52 0x07 0x59 0xA1 0xE6 0x02 0x20 0x48 0x6F 0x70 0x70 0x65 0x72 0x20 0x77 0x61 0x73 0x20
p02:
.align 2
.byte 0x18 0x00 0x9A 0x50 0x18 0x10 0x52 0x07 0x59 0xA1 0xF2 0x02 0x6F 0x6E 0x65 0x20 0x6F 0x66 0x20 0x74 0x68 0x65 0x20 0x66
p03:
.align 2
.byte 0x18 0x00 0x9A 0x50 0x24 0x10 0x52 0x07 0x59 0xA1 0xFE 0x02 0x69 0x72 0x73 0x74 0x20 0x63 0x6F 0x6D 0x70 0x75 0x74 0x65
p04:
.align 2
.byte 0x18 0x00 0x9A 0x50 0x30 0x10 0x52 0x07 0x59 0xA1 0x0A 0x03 0x72 0x20 0x70 0x72 0x6F 0x67 0x72 0x61 0x6D 0x6D 0x65 0x72
p05:
.align 2
.byte 0x18 0x00 0x9A 0x50 0x3C 0x10 0x52 0x07 0x59 0xA1 0x16 0x03 0x73 0x20 0x74 0x6F 0x20 0x77 0x6F 0x72 0x6B 0x20 0x6F 0x6E
p06:
.align 2
.byte 0x18 0x00 0x9A 0x50 0x48 0x10 0x52 0x07 0x59 0xA1 0x22 0x03 0x20 0x74 0x68 0x65 0x20 0x48 0x61 0x72 0x76 0x61 0x72 0x64
p07:
.align 2
.byte 0x15 0x00 0x9A 0x50 0x54 0x10 0x12 0x07 0x59 0xA1 0x2A 0x03 0x20 0x4D 0x61 0x72 0x6B 0x20 0x49 0x2E 0x00


.text
.globl main
main:
la $a0, queue
lw $a1, packet
jal enqueue
move $s0, $v0

la $a0, v0
li $v0, 4
syscall

move $a0, $s0
li $v0, 1
syscall

li $a0, '\n'
li $v0, 11
syscall

la $a0, queue
jal print_queue

li $v0, 10
syscall

.include "proj4.asm"
