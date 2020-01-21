.data
str: .asciiz "Wolfie Seawolf!!! 2019??"

.text
.globl main
main:

#Call function
la $a0, str
jal to_lowercase
move $t0, $v0

#Print out the updated String
la $a0, str
li $v0, 4
syscall

#Add a newline character
li $a0, '\n'
li $v0, 11
syscall

#Print out number of letters changed from uppercase to lowercase
move $a0, $t0
li $v0, 1
syscall

#Exit
li $v0, 10
syscall

.include "proj2.asm"
