.data
ciphertext: .asciiz "Cse 220 AnD csE 320 FoRM A twO-CoURSe seQUeNce. 11001101 is a BInarY nUMBer. 81FE2D is A bAsE-16 NUMBer. Base conversion is FUN!"
plaintext: .asciiz "@@@@@@@@@@@@@@@@@@@@@@@@@"
ab_text: .ascii "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
null: .byte 0
.align 2
ab_text_length: .word 81

.text
.globl main
main:
la $a0, ciphertext
la $a1, plaintext
la $a2, ab_text
lw $a3, ab_text_length
addi $sp, $sp, -4
la $t0, bacon_codes
sw $t0, 0($sp)
jal decrypt
addi $sp, $sp, 4

move $t0, $v0

la $a0, plaintext
li $v0, 4
syscall

li $a0, '\n'
li $v0, 11
syscall

move $a0, $t0
li $v0, 1
syscall

li $a0, '\n'
li $v0, 11
syscall

li $v0, 10
syscall

.include "proj2.asm"
.include "bacon_codes.asm"
