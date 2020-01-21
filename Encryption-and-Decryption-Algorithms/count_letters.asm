.data
str: .asciiz "Wolfie Seawolf!!! 2019??"

.text
.globl main
main:
la $a0, str
jal count_letters

move $a0, $v0
li $v0, 1
syscall

li $v0, 10
syscall

.include "proj2.asm"
