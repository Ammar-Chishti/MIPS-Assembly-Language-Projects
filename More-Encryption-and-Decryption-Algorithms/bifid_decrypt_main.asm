.data
plaintext: .ascii "This is random garbage! Notice that it is not null-terminated! You should not be seeing this text!!!!!!!!"
ciphertext: .asciiz "R#onq kTCzS,A* N;rig W(%Bm-U)"
key_square: .asciiz "g.WDO?s1Htj2X#ydhP$!o6M- Zplz'a;nVTv3Qek7SBIJ=8C,cu@9/Ym4Fxb5AKf(*RU\"rq)%wEN:0LiG"
period: .word 7
index_buffer: .ascii "This is raw, memory - it could have any contents! Go SBU!!"
trash: .ascii "random garbage"
block_buffer: .ascii "RandomTrashYea"
junk: .ascii "More random garbage"

.text
.globl main
main:
la $a0, plaintext
la $a1, ciphertext
la $a2, key_square
lw $a3, period
addi $sp, $sp, -8
la $t0, index_buffer
sw $t0, 0($sp)
la $t0, block_buffer
sw $t0, 4($sp)
jal bifid_decrypt
addi $sp, $sp, 8

move $a0, $v0
li $v0, 1
syscall

li $a0, '\n'
li $v0, 11
syscall

la $a0, plaintext
li $v0, 4
syscall

li $a0, '\n'
li $v0, 11
syscall

li $v0, 10
syscall

.include "proj2.asm"
