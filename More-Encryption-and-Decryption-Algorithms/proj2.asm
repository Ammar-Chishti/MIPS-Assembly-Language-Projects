# CSE 220 Programming Project #2
# Ammar Chishti
# achishti
# 111717583

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text

strlen:
    addi $sp, $sp, -20
	sw $s0, 0($sp)  # str address
	sw $s1, 4($sp)  # str address byte loader
	sw $s2, 8($sp)  # answer register
	
	li $s2, 0
	move $s0, $a0
	lb $s1, ($s0)
	
	strlen_while:
		beqz $s1, strlen_while_done
		addi $s2, $s2, 1
	
	strlen_while_update:
		addi $s0, $s0, 1
		lb $s1, ($s0)
		j strlen_while
	
	strlen_while_done:
		move $v0, $s2
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		addi $sp, $sp, 20
    	jr $ra

index_of:
	addi $sp, $sp, -20
	sw $s0, 0($sp)  # str address
	sw $s1, 4($sp)	# char to look for
	sw $s2, 8($sp)  # str address byte loader
	sw $s3, 12($sp) # index count register
	
	move $s0, $a0
	move $s1, $a1
	
	li $s3, 0
	lb $s2, ($s0)
	
	index_of_while:
		beq $s2, $s1, index_of_found
		beqz $s2, index_of_while_done
		addi $s3, $s3, 1
	
	index_of_while_update:
		addi $s0, $s0, 1
		lb $s2, ($s0)
		j index_of_while
	
	index_of_while_done:	# If the character is never found
		li $v0, -1
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		addi $sp, $sp, 20
    	jr $ra
    
    index_of_found:
    	move $v0, $s3
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		addi $sp, $sp, 20
    	jr $ra

bytecopy:
	lw $t0, 0($sp)
	
	addi $sp, $sp, -40
	sw $s0, 0($sp)  # src
	sw $s1, 4($sp)  # src_pos
	sw $s2, 8($sp)  # destination
	sw $s3, 12($sp) # dest_pos
	sw $s4, 16($sp) # length
	sw $s5, 20($sp) # src_pos byte loader
	sw $s6, 24($sp) # dest_position byte loader
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	move $s4, $t0
	li $v0, 0		# Answer register
	
	blez $s4, bytecopy_failed	# If length is less than or equal to 0, bytecode failed
	bltz $s1, bytecopy_failed	# If src_pos is less than 0, bytecode failed
	bltz $s3, bytecopy_failed	# If dest_pos is less than 0, bytecode failed
	
	add $s0, $s0, $s1	# Add src_position to src
	add $s2, $s2, $s3	# Add dest_position to dest
	
	lb $s5, ($s0)
	
	bytecopy_while:
		beqz $s4, bytecopy_done
		
		sb $s5, ($s2)
		addiu $v0, $v0, 1
	
	
	bytecopy_while_update:
	    addiu $s0, $s0, 1
	    addiu $s2, $s2, 1
	    addiu $s4, $s4, -1
		lb $s5, ($s0)
		j bytecopy_while
		
	
	bytecopy_done:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		addi $sp, $sp, 40
    	jr $ra
	
	bytecopy_failed:
		li $v0, -1
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		addi $sp, $sp, 40
    	jr $ra


scramble_encrypt:
	addi $sp, $sp, -40
	sw $s0, 0($sp)  # ciphertext original
	sw $s1, 4($sp)  # plaintext original
	sw $s2, 8($sp)  # alphabet original
	sw $s3, 12($sp) # ciphertext byteloader
	sw $s4, 16($sp) # plaintext byteloader
	sw $s5, 20($sp) # alphabet byteloader
	sw $s6, 24($sp) # numEncrypted
	sw $s7, 28($sp) # alphabet modified
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s7, $a0
	
	li $s6, 0
	lb $s4, ($s1)
	
	scramble_encrypt_while:
		beqz $s4, scramble_encrypt_done
		
		move $a0, $s4
		move $t9, $ra
		jal scramble_encrypt_helper
		move $ra, $t9
		li $t0, -1
		beq $v0, $t0, scramble_encrypt_non_alphabet
		
		move $a2, $s2
		add $a2, $a2, $v0
		lb $t0, ($a2)	# Getting the corresponding index value from alphabet
		
		sb $t0, ($s7)
		addi $s7, $s7, 1
		
		addi $s6, $s6, 1    # Increment numEncrypted
		
	scramble_encrypt_while_update:
		addi $s1, $s1, 1
		lb $s4, ($s1)
		j scramble_encrypt_while
	
	scramble_encrypt_non_alphabet:
		sb $s4, ($s7)
		addi $s7, $s7, 1
		j scramble_encrypt_while_update
	
	scramble_encrypt_done:
		sb $0, ($s7)
	
		move $v0, $s6
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		addi $sp, $sp, 40
    	jr $ra


scramble_decrypt:
	addi $sp, $sp, -40
	sw $s0, 0($sp)  # plaintext original
	sw $s1, 4($sp)  # ciphertext original
	sw $s2, 8($sp)  # alphabet original
	sw $s3, 12($sp) # plaintext size counter
	sw $s4, 16($sp) # ciphertext byteloader
	sw $s5, 20($sp) # numDecrypted
	sw $s6, 24($sp) # $ra saver
	sw $s7, 28($sp) # plaintext modified
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s6, $ra
	move $s7, $a0
	
	li $s3, 0
	li $s5, 0
	lb $s4, ($s1)
	
	scramble_decrypt_while:
		beqz $s4, scramble_decrypt_done
		
		move $a0, $s2
		move $a1, $s4
		jal index_of
		li $t0, -1
		beq $v0, $t0, scramble_decrypt_not_alphabet
		
		move $a0, $v0
		jal scramble_decrypt_helper
		
		sb $v0, ($s7)
		addi $s7, $s7, 1
		addi $s5, $s5, 1
	
	scramble_decrypt_while_update:
		addi $s1, $s1, 1
		lb $s4, ($s1)
		j scramble_decrypt_while
	
	
	scramble_decrypt_not_alphabet:
		sb $s4, ($s7)
		addi $s7, $s7, 1
		j scramble_decrypt_while_update
	
	scramble_decrypt_done:
		move $v0, $s5
		sb $0, ($s7)
		move $ra, $s6
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		addi $sp, $sp, 40
		jr $ra
	

base64_encode:
	addi $sp, $sp, -40
	sw $s0, 0($sp)  # encoded_str original
	sw $s1, 4($sp)  # str original
	sw $s2, 8($sp)  # base_64 table original
	sw $s3, 12($sp) # encodedSize
	sw $s4, 16($sp) # str byteloader
	sw $s5, 20($sp) # $ra saver
	sw $s6, 24($sp) # encoded_str modified
	sw $s7, 28($sp) # helper function saver
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s5, $ra
	move $s6, $a0
	
	li $s3, 0
	lb $s4, ($s1)
	
	base64_encode_while:
		beqz $s4, base64_encode_done
		
		move $a0, $s1
		jal base_64_encode_helper
		move $s7, $v0
		
		li $t0, 2
		beq $v1, $t0, base64_encode_2_left
		
		li $t0, 1
		beq $v1, $t0, base64_encode_1_left
		
		andi $t0, $s7, 0x00FC0000	
		srl $t0, $t0, 18	# $t0 now has the first of four characters
		move $a2, $s2
		add $a2, $a2, $t0
		lb $t1, ($a2)
		sb $t1, ($s6)
		addi $s6, $s6, 1
		
		andi $t0, $s7, 0x0003F000
		srl $t0, $t0, 12
		move $a2, $s2
		add $a2, $a2, $t0
		lb $t1, ($a2)
		sb $t1, ($s6)
		addi $s6, $s6, 1
		
		andi $t0, $s7, 0x00000FC0
		srl $t0, $t0, 6
		move $a2, $s2
		add $a2, $a2, $t0
		lb $t1, ($a2)
		sb $t1, ($s6)
		addi $s6, $s6, 1
		
		andi $t0, $s7, 0x0000003F
		move $a2, $s2
		add $a2, $a2, $t0
		lb $t1, ($a2)
		sb $t1, ($s6)
		addi $s6, $s6, 1
		
		addi $s3, $s3, 4	# Increment encodedSize
		
	base64_encode_while_update:
		addi $s1, $s1, 3
		lb $s4, ($s1)
		j base64_encode_while
	
	
	base64_encode_2_left:
		andi $t0, $s7, 0x00FC0000	
		srl $t0, $t0, 18
		move $a2, $s2
		add $a2, $a2, $t0
		lb $t1, ($a2)
		sb $t1, ($s6)
		addi $s6, $s6, 1
		
		andi $t0, $s7, 0x0003F000
		srl $t0, $t0, 12
		move $a2, $s2
		add $a2, $a2, $t0
		lb $t1, ($a2)
		sb $t1, ($s6)
		addi $s6, $s6, 1
		
		addi $s3, $s3, 2
		
		li $t1, 61
		sb $t1, ($s6)
		addi $s6, $s6, 1
		
		sb $t1, ($s6)
		addi $s6, $s6, 1
		
		j base64_encode_done
	
	base64_encode_1_left:
		
		andi $t0, $s7, 0x0003F000
		srl $t0, $t0, 12
		move $a2, $s2
		add $a2, $a2, $t0
		lb $t1, ($a2)
		sb $t1, ($s6)
		addi $s6, $s6, 1
		
		andi $t0, $s7, 0x00000FC0
		srl $t0, $t0, 6
		move $a2, $s2
		add $a2, $a2, $t0
		lb $t1, ($a2)
		sb $t1, ($s6)
		addi $s6, $s6, 1
		
		addi $s3, $s3, 3
		
		li $t1, 61
		sb $t1, ($s6)
		addi $s6, $s6, 1
		
		j base64_encode_done
	
	base64_encode_done:
		move $v0, $s3
		sb $0, ($s6)
		move $ra, $s5
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		addi $sp, $sp, 40
		jr $ra


base64_decode:
	addi $sp, $sp, -40
	sw $s0, 0($sp)  # decoded_str original
	sw $s1, 4($sp)  # encoded_str original
	sw $s2, 8($sp)  # base_64 table original
	sw $s3, 12($sp) # modified encoded_str
	sw $s4, 16($sp) # decoded_str modified
	sw $s5, 20($sp) # decoded size
	sw $s6, 24($sp) # $ra saver
	sw $s7, 28($sp) # helper function result saver
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s6, $ra
	move $s3, $a1
	move $s4, $a0
	li $s5, 0
	
	base64_decode_while:
		
		move $a0, $s3
		move $a1, $s2
		jal base64_decode_helper
		
		andi $t0, $v0, 0x00FF0000
		beqz $t0, base64_decode_done
		srl $t0, $t0, 16
		sb $t0, ($s4)
		addi $s4, $s4, 1
		addi $s5, $s5, 1
		
		andi $t0, $v0, 0x0000FF00
		beqz $t0, base64_decode_done
		srl $t0, $t0, 8
		sb $t0, ($s4)
		addi $s4, $s4, 1
		addi $s5, $s5, 1
		
		andi $t0, $v0, 0x000000FF
		beqz $t0, base64_decode_done
		sb $t0, ($s4)
		addi $s4, $s4, 1
		addi $s5, $s5, 1
	
	base64_while_update:
		addi $s3, $s3, 4
		j base64_decode_while
	
	base64_decode_done:
		
		sb $0, ($s4)
		move $ra, $s6
		move $v0, $s5
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		addi $sp, $sp, 40
		jr $ra

# $t2 - $t8 are empty until this point
bifid_encrypt:
	lw $t0, 0($sp) # Index_buffer
	lw $t1, 4($sp) # Block_buffer
	
	addi $sp, $sp, -40
	sw $s0, 0($sp)  # ciphertext original
	sw $s1, 4($sp)  # plaintext original
	sw $s2, 8($sp)  # key_square original
	sw $s3, 12($sp) # period original
	sw $s4, 16($sp) # index_buffer original	
	sw $s5, 20($sp) # block_buffer original
	sw $s6, 24($sp) # plaintext modified
	sw $s7, 28($sp) # plaintext byteloader
					# $t2 - $ra saver
					# $t3 - index_buffer modified
					# $t4 - 
					# $t5 - block_buffer modified
					# $t6 - 
					# $t7 - 
					# $t9 - temp garbage register
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	move $s4, $t0
	move $s5, $t1
	move $s6, $a1
	li $s7, 0
	move $t2, $ra
	move $t3, $t0
	li $t4, 0 # 2 * strlen(plaintext)
	move $t5, $t1
	li $t6, 0
	li $t7, 0
	
	move $a0, $s1
	jal strlen
	sll $t4, $v0, 1
	
	#move $a0, $s2
	#li $a1, 4
	#li $a2, 3
	#jal find_char_grid
	#li $t0, 11
	
bifid_encrypt_while:
	move $a0, $s6
	move $a1, $t3
	move $a2, $s3
	move $a3, $s2
	jal plaintext_to_index_buffer
	li $t9, -1
	beq $v0, $t9, bifid_encrypt_end	# If we have reached the end of the plaintext
	
	move $a0, $t3
	move $a1, $s5
	move $a2, $s3
	jal index_to_block_buffer
	
	move $a0, $s5
	li $a1, 0
	move $a2, $t3	# Moving modified index_buffer to destination
	li $a3, 0
	sll $t9, $s3, 1
	sw $t9, 0($sp)
	jal bytecopy
	
	#move $a0, $s4
	#jal print_index_buffer

bifid_encrypt_while_update:
	sll $t9, $s3, 1
	add $t3, $t3, $t9
	add $s6, $s6, $s3
	j bifid_encrypt_while

bifid_encrypt_end:

	move $a0, $s4
	move $a1, $t4
	jal print_index_buffer
	
	move $a0, $s0
	move $a1, $s4
	move $a2, $s2
	move $a3, $t4
	jal index_to_ciphertext_encode
	
	move $ra, $t2
	jr $ra
	
	
	
	
	
	
	li $v0, 10
	syscall
	
	
	
	
	
	
	
	bifid_encrypt_plaintext_to_index_buffer_while_update:
		addi $s6, $s6, 1	# Increment plaintext
		lb $s7, ($s6)
		addi $t3, $t3, 2	# Increment index_buffer
		addi $t7, $t7, -1
		#j bifid_encrypt_plaintext_to_index_buffer_while
	
	
	bifid_encrypt_plaintext_to_index_buffer_while_done:
		move $t7, $s3
		
		#move $a0, 
		
		
		#j bifid_encrypt_index_buffer_to_block_buffer_while
	
	#bifid_encrypt_index_buffer_to_block_buffer_while:
	
	#bifid_encrypt_index_buffer_to_block_buffer_while_update:
	
		#addi $t7, $t7, -1
		#j bifid_encryot_index_buffer_to_block_buffer_while
		
		
		
		
		
		
		
		
		
		
	
	
	
	
	bifid_encrypt_row_even_while:
		beqz $t7, bifid_encrypt_row_even_while_done
	
	bifid_encrypt_row_even_while_update:
		
		
		addi $t7, $t7, -1
		j bifid_encrypt_row_even_while
	
	
	
	
	bifid_encrypt_row_even_while_done:
		li $a0, 11
		
	
	
	sw $s5, 20($sp) # plaintext modified
	sw $s6, 24($sp) # plaintext byteloader
	sw $s7, 28($sp) # $ra saver
					# $t2 - index_buffer modified
					# $t3 - index_buffer byteloader
					# $t4 - 
	
					# $t2 - index_buffer modified
					# $t3 - index_buffer byteloader
					# $t4 - period counter
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	move $s4, $t0
	move $s5, $a1
	li $s6, 0
	move $s7, $ra
	move $t2, $t0
	li $t3, 0
	
	bifid_encrypt_row_start:
		move $t4, $s3
		move $s5, $s1
		lb $s6, ($s5)
	bifid_encrypt_row_while:
		beqz $s6, bifid_encrypt_done
		beqz $t4, bifid_encrypt_col_start
		
		move $a0, $s2
		move $a1, $s6
		jal find_row_col
		
		sb $v0, ($t2)
	
	bifid_encrypt_row_while_update:
		addi $s5, $s5, 1
		lb $s6, ($s5)
		addi $t2, $t2, 1
		lb $t3, ($t2)
		addi $t4, $t4, -1
		j bifid_encrypt_row_while
	
	bifid_encrypt_col_start:
		move $t4, $s3
		move $s5, $s1
		lb $s6, ($s5)
	bifid_encrypt_col_while:
		beqz $s6, bifid_encrypt_done
		beqz $t4, bifid_encrypt_done
		
		move $a0, $s2
		move $a1, $s6
		jal find_row_col
		
		sb $v1, ($t2)
		
	bifid_encrypt_col_while_update:
		addi $s5, $s5, 1
		lb $s6, ($s5)
		addi $t2, $t2, 1
		lb $t3, ($t2)
		addi $t4, $t4, -1
		j bifid_encrypt_col_while
	
	
	bifid_encrypt_done:
		lb $a0, 7($s4)
		li $v0, 1
		syscall
		
		
		jr $ra
		
		
		
		
	
	#move $a0, $a2
	#move $a2, $a1
	#lb $a1, ($a2)
	#jal find_row_col
	#move $a0, $v0,
	#li $v0, 11
	#syscall
	
	li $v0, 11
	
	


bifid_decrypt:
	jr $ra


# ALL HELPER FUNCTIONS GO UNDER HERE

# $a0 - Char from plaintext
scramble_encrypt_helper:
	addi $sp, $sp, -20
	sw $s0, 0($sp) # Char from plaintext
	
	move $s0, $a0
	
	li $t0, 65
	blt $s0, $t0, scramble_encrypt_helper_failed
	li $t0, 122
	bgt $s0, $t0, scramble_encrypt_helper_failed
	
	li $t0, 91
	blt $s0, $t0, scramble_encrypt_helper_capital_letter
	
	li $t0, 96
	bgt $s0, $t0, scramble_encrypt_helper_lowercase_letter
	j scramble_encrypt_helper_failed
	
	scramble_encrypt_helper_capital_letter:
		addi $v0, $s0, -65
		lw $s0, 0($sp)
		addi $sp, $sp, 20
		jr $ra
	
	scramble_encrypt_helper_lowercase_letter:
		addi $v0, $s0, -71
		lw $s0, 0($sp)
		addi $sp, $sp, 20
		jr $ra
	
	scramble_encrypt_helper_failed:
		li $v0, -1
		lw $s0, 0($sp)
		addi $sp, $sp, 20
		jr $ra

# $a0 - Character from ciphertext
scramble_decrypt_helper:
	addi $sp, $sp, -20
	sw $s0, 0($sp)	# Character from ciphertext
	
	move $s0, $a0
	
	li $t0, 26
	blt $s0, $t0, scramble_decrypt_helper_isUppercase
	
	li $t0, 52
	blt $s0, $t0, scramble_decrypt_helper_isLowercase
	
	
	scramble_decrypt_helper_isUppercase:
		addi $v0, $s0, 65
		addi $sp, $sp, 20
		jr $ra
	
	scramble_decrypt_helper_isLowercase:
		addi $v0, $s0, 71
		addi $sp, $sp, 20
		jr $ra

# $a0 - str to encode
base_64_encode_helper:
	addi $sp, $sp, -20
	sw $s0, 0($sp)	# $a0 original
	sw $s1, 4($sp)	# original byte loader
	
	li $v0, 0
	
	lb $s1, ($a0)
	or $v0, $s1, $v0
	
	addi $a0, $a0, 1
	lb $s1, ($a0)
	beqz $s1, base_64_encode_helper_2_left
	
	sll $v0, $v0, 8
	or $v0, $s1, $v0
	
	addi $a0, $a0, 1
	lb $s1, ($a0)
	beqz $s1, base_64_encode_helper_1_left
	
	sll $v0, $v0, 8
	or $v0, $s1, $v0
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	addi $sp, $sp, 20
	jr $ra
	
	base_64_encode_helper_2_left:
		li $v1, 2
		sll $v0, $v0, 16
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		addi $sp, $sp, 20
		jr $ra
	
	base_64_encode_helper_1_left:
		li $v1, 1
		sll $v0, $v0, 8
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		addi $sp, $sp, 20
		jr $ra

# $a0 - encoded str
# $a1 - base64 table
base64_decode_helper:
	addi $sp, $sp, -40
	sw $s0, 0($sp)  # encoded str original
	sw $s1, 4($sp)  # base64 table original
	sw $s2, 8($sp)  # $ra saver
	sw $s3, 12($sp) # encoded str modified
	sw $s4, 16($sp) # result register
	sw $s5, 20($sp) # saver
	
	move $s0, $a0
	move $s1, $a1
	move $s3, $a0
	move $s2, $ra
	li $s4, 0
	
	move $a0, $s1
	lb $a1, ($s3)
	jal index_of
	
	sll $s5, $v0, 18	# First character is now in => "1000"
	
	addi $s3, $s3, 1
	move $a0, $s1
	lb $a1, ($s3)
	
	li $t0, 61
	beq $a1, $t0, base64_decode_helper_done
	beqz $a1, base64_decode_helper_done
	jal index_of
	
	sll $v0, $v0, 12
	or $s5, $s5, $v0	# Second character is now in => "1200"
	
	addi $s3, $s3, 1
	move $a0, $s1
	lb $a1, ($s3)
	
	li $t0, 61
	beq $a1, $t0, base64_decode_helper_done
	beqz $a1, base64_decode_helper_done
	jal index_of
	
	sll $v0, $v0, 6
	or $s5, $s5, $v0	# Third character is now in => "1230"
	
	addi $s3, $s3, 1
	move $a0, $s1
	lb $a1, ($s3)
	
	li $t0, 61
	beq $a1, $t0, base64_decode_helper_done
	beqz $a1, base64_decode_helper_done
	jal index_of
	
	or $s5, $s5, $v0	# Fourth character is now in => "1234"
	
	
	base64_decode_helper_done:
		move $ra, $s2
		move $v0, $s5
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		addi $sp, $sp, 40
		jr $ra

# $a0 - key square
# $a1 - plaintext char
find_row_col:
	addi $sp, $sp, -40
	sw $s0, 0($sp)  # Key Square original
	sw $s1, 4($sp)  # Plaintext Char
	sw $s2, 8($sp)  # Key Square modified
	sw $s3, 12($sp) # $ra saver
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a0
	move $s3, $ra
	
	jal index_of
	li $t0, 9
	div $v0, $t0
	
	mfhi $v1
	mflo $v0
	
	move $ra, $s3
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 40
	jr $ra

# $a0 - Key Square
# $a1 - row
# $a2 - col
find_char_grid:
	addi $sp, $sp, -20
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	
	li $s4, 9
	mult $a1, $s4
	mflo $s4
	add $s4, $s4, $a2
	
	add $s4, $s4, $a0
	lb $v0, ($s4)
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	addi $sp, $sp, 20
	jr $ra


# $a0 - plaintext address
# $a1 - index address
# $a2 - period
# $a3 - key_square
# $v0 - 
plaintext_to_index_buffer:
	addi $sp, $sp, -40
	sw $s0, 0($sp)  # plaintext address original
	sw $s1, 4($sp)  # index_buffer address original
	sw $s2, 8($sp)  # period value => counter
	sw $s3, 12($sp) # $ra saver
	sw $s4, 16($sp) # plaintext address modified
	sw $s5, 20($sp) # plaintext byteloader
	sw $s6, 24($sp) # index_buffer modified
	sw $s7, 28($sp) # Key Square
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s4, $a0
	move $s6, $a1
	move $s7, $a3
	move $s3, $ra
	
	#sll $s2, $s2, 1 # Multiplying period by 2
	lb $s5, ($s4)
	
	plaintext_to_index_buffer_while:
		beqz $s2, plaintext_to_index_buffer_done
		beqz $s5, plaintext_to_index_buffer_end
		
		move $a0, $s7
		move $a1, $s5
		jal find_row_col
		sb $v0, ($s6)
		sb $v1, 1($s6)
	
	plaintext_to_index_buffer_while_update:
		addi $s2, $s2, -1
		addi $s4, $s4, 1 # Increment plaintext
		lb $s5, ($s4)
		addi $s6, $s6, 2 # Increment index_buffer
		j plaintext_to_index_buffer_while	
	
	plaintext_to_index_buffer_done:
		move $ra, $s3
		#move $v0, $s4
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		addi $sp, $sp, 40
		jr $ra
	
	plaintext_to_index_buffer_end:
		move $ra, $s3
		li $v0, -1
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		addi $sp, $sp, 40
		jr $ra

# $a0 - index_buffer
# $a1 - block_buffer
# $a2 - period
# Takes all even indexes and stores them in block_buffer, then takes all odd indexes and stores them after
index_to_block_buffer:
	addi $sp, $sp, -40
	sw $s0, 0($sp)  # index_buffer original
	sw $s1, 4($sp)  # block_buffer original
	sw $s2, 8($sp)  # period value
	sw $s3, 12($sp) # index_buffer modified
	sw $s4, 16($sp) # index_buffer byteloader
	sw $s5, 20($sp) # block_buffer modified
	sw $s6, 24($sp) # block_buffer byteloader
	sw $s7, 28($sp) # $ra saver
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a0
	li $s4, 0
	move $s5, $a1
	li $s6, 0
	move $s7, $ra
	
	move $t9, $s2
	lb $s4, ($s3)
	index_to_block_buffer_row_while:
		beqz $t9, index_to_block_buffer_col
		sb $s4, ($s5)
	
	index_to_block_buffer_row_while_update:
		addi $s5, $s5, 1
		addi $s3, $s3, 2
		lb $s4, ($s3)
		addi $t9, $t9, -1
		j index_to_block_buffer_row_while
	
	
	index_to_block_buffer_col:
		move $s3, $s0
		addi $s3, $s3, 1
		
		lb $s4, ($s3)
		move $t9, $s2
	index_to_block_buffer_col_while:
		beqz $t9, index_to_block_buffer_done
		sb $s4, ($s5)
	
	index_to_block_buffer_col_while_update:
		addi $s5, $s5, 1
		addi $s3, $s3, 2
		lb $s4, ($s3)
		addi $t9, $t9, -1
		j index_to_block_buffer_col_while
	
	index_to_block_buffer_done:
		move $ra, $s7
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		addi $sp, $sp, 40
		jr $ra

# $a0 - ciphertext address
# $a1 - index_buffer address
# $a2 - key_square
# $a3 - size of index_buffer
index_to_ciphertext_encode:
	addi $sp, $sp, -40
	sw $s0, 0($sp)  # ciphertext original
	sw $s1, 4($sp)  # index_buffer original
	sw $s2, 8($sp)  # key_square original
	sw $s3, 12($sp) # size of index buffer
	sw $s4, 16($sp) # index_buffer byteloader
	sw $s5, 20($sp) # index_buffer modified
	sw $s6, 24($sp) # index_buffer byteloader 2
	sw $s7, 28($sp) # $ra saver
	
	move $a0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	move $s5, $a1
	move $s7, $ra
	
	
	lb $s4, ($s5)
	lb $s6, 1($s5)
	index_to_ciphertext_encode_while:
		beqz $s3, index_to_ciphertext_encode_done
		
		#sb $s4, ($a0)
		#addi $a0, $a0, 1
		#sb $s6, ($a0)
		#addi $s0, $a0, 1
		
	index_to_ciphertext_encode_while_update:
		addi $s5, $s5, 2
		lb $s4, ($s5)
		lb $s6, ($s5)
		addi $s3, $s3, -2
		j index_to_ciphertext_encode
	
	index_to_ciphertext_encode_done:
		move $ra, $s7
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		addi $sp, $sp, 40
		jr $ra

# $a0 - index buffer
# $a1 - size
print_index_buffer:
	
	move $t0, $a0
	lb $a0, ($t0)
	
	print_index_buffer_while:
		beqz $a1, exit
		
		li $v0, 1
		syscall
		
		#li $a0, '\n'
		#li $v0, 11
		#syscall
	
	print_index_buffer_while_update:
		addi $t0, $t0, 1
		lb $a0, ($t0)
		addi $a1, $a1, -1
		j print_index_buffer_while

exit:
	li $v0, 10
	syscall


		
	
	
	
	
		
	
	
	


#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
