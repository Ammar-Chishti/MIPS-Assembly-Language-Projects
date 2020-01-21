.data
state: .space 1000  # way more space than we really need; not null-terminated during grading!
filename: .asciiz "game1.txt"  # you will likely need to put MARS into the same folder as this main file

.text
main:
la $a0, state
la $a1, filename
jal load_game

# report return values
move $a0, $v0
li $v0, 1
syscall

li $v0, 11
li $a0, ' '
syscall

move $a0, $v1
li $v0, 1
syscall

li $v0, 11
li $a0, '\n'
syscall

# report the contents of the struct
la $t0, state
lb $a0, 0($t0)
li $v0, 1
syscall

li $v0, 11
li $a0, ' '
syscall

lb $a0, 1($t0)
li $v0, 1
syscall

li $v0, 11
li $a0, ' '
syscall

# replace this syscall 4 with some of your own code that prints the game field in 2D
li $v0, 11
li $a0, '\n'
syscall

la $a0, state
lb $a1, 0($a0)
lb $a2, 1($a0)
jal print_board

li $v0, 10
syscall

.include "proj3.asm"
