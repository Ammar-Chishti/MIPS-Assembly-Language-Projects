.data
decoded_str: .ascii "This is random garbage! Notice that it is not null-terminated! You should not be seeing this text!"
encoded_str: .asciiz "dOqiM365ZOqckUWvreW9h3m5du4puVn5lCFKhCFKhVWXBqWdmp=="
base64_table: .asciiz "HWegnLO7mM0Q6XwTplBduqSNJsZhkrf25cUoE49bAvPtz8IKDyVjiYC31/+axFRG"
trash: .ascii "random garbage"

.text
.globl main
main:
la $a0, decoded_str
la $a1, encoded_str
la $a2, base64_table
jal base64_decode

move $a0, $v0
li $v0, 1
syscall

li $a0, '\n'
li $v0, 11
syscall

la $a0, decoded_str
li $v0, 4
syscall

li $a0, '\n'
li $v0, 11
syscall

li $v0, 10
syscall

.include "proj2.asm"
