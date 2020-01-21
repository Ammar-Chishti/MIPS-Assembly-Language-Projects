# CSE 220 Programming Project #3
# Ammar Chishti
# achishti
# 111717583

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text
initialize:
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# Original struct
	sw $s1, 4($sp)	# Original num_rows
	sw $s2, 8($sp)	# Original num_cols
	sw $s3, 12($sp)	# Original character
	sw $s4, 16($sp) # struct byteloader
	sw $s5, 20($sp) # num_rows * num_col
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	bltz $s1, initialize_failed
	bltz $s2, initialize_failed
	
	move $v0, $s1
	move $v1, $s2
	
	sb $s1, ($a0)
	addi $a0, $a0, 1
	sb $s2, ($a0)
	addi $a0, $a0, 1
	
	mult $s1, $s2
	mflo $s5
	
	initialize_while:
		beqz $s5, initialize_done
		sb $s3, ($a0)
	
	initialize_while_update:
		addi $a0, $a0, 1
		addi $s5, $s5, -1
		j initialize_while
	
	initialize_done:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		addi $sp, $sp, 40
		jr $ra
	
	initialize_failed:
		li $v0, -1
		li $v1, -1
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		addi $sp, $sp, 40
		jr $ra

load_game:
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# Original state address
	sw $s1, 4($sp)	# Filename
	sw $s2, 8($sp)	# Row Value
	sw $s3, 12($sp)	# Column Value
	sw $s4, 16($sp) # $ra saver
	sw $s5, 20($sp) # state address modified
	sw $s6, 24($sp) # Offset to add to file address
	#sw $s7, 28($sp)
	
	move $s0, $a0
	move $s1, $a1
	move $s4, $ra
	move $s5, $a0
	
	addi $sp, $sp, -9808	# Start of reading the file. This is because the maximum board size can be 99x99
	li $v0, 13
	move $a0, $s1
	li $a1, 0
	syscall
	
	li $t9, -1
	beq $v0, $t9, load_board_failed_done	# If the file cannot be read, end the program
	
	move $a0, $v0
	move $a1, $sp
	li $a2, 6	# Reading 6 bytes of the file
	li $v0, 14		
	syscall
	
	move $a0, $a1
	jal load_row_col_state
	lb $s6, 4($sp)
	
	move $s2, $v0
	move $s3, $v1
	
	move $s5, $s0	# Storing row and column into memory locations
	sb $s2, ($s5)
	addi $s5, $s5, 1
	sb $s3, ($s5)
	
	li $v0, 16		# Close the file
	li $a0, 3
	syscall
	
	li $v0, 13		# Open the file again
	move $a0, $s1
	li $a1, 0
	syscall
	
	mult $s2, $s3
	mflo $t9
	add $t9, $t9, $s6	# Adding offset
	add $t9, $t9, $s2	# Adding rows
	
	li $a0, 3	# Opening the file with (rows * column + rows) + offset for the whole state struct
	li $v0, 14
	move $a1, $sp
	move $a2, $t9
	syscall
	
	move $a0, $s0
	add $a1, $a1, $s6	# Adding offset to address so we are at the board
	sub $t9, $t9, $s6	# Subtract offset because we don't want to read offset many times
	move $a2, $t9
	jal load_state_struct
	
	addi $sp, $sp, 9808
	move $ra, $s4
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	#lw $s7, 28($sp)
	addi $sp, $sp, 40
	jr $ra
	
	
	load_board_failed_done:
		li $v0, -1
		li $v1, -1
		addi $sp, $sp, 9808
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		#lw $s7, 28($sp)
		addi $sp, $sp, 40
		jr $ra

get_slot:
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# Original state address
	sw $s1, 4($sp)	# Row Value
	sw $s2, 8($sp)	# Col Value
	sw $s3, 12($sp) # struct numRows
	sw $s4, 16($sp) # struct numCols
	sw $s5, 20($sp) # Byte selector for state struct
	sw $s6, 24($sp) # offset to add to state address to get character
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	lb $s3, 0($s0)
	lb $s4, 1($s0)
	addiu $s0, $s0, 2	# So we are at the start of the board
	
	blt $s1, $0, get_slot_failed	# Error handling
	bge $s1, $s3, get_slot_failed
	blt $s2, $0, get_slot_failed
	bge $s2, $s4, get_slot_failed
	
	mult $s1, $s4		# Multiply rowIndex by Columns
	mflo $s6
	addu $s6, $s6, $s2	# Add ColIndex
	
	addu $s0, $s0, $s6
	lb $s5, ($s0)
	move $v0, $s5
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	addi $sp, $sp, 40
	jr $ra
	
	get_slot_failed:
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
	

set_slot:
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# Original state address
	sw $s1, 4($sp)	# Row Value
	sw $s2, 8($sp)	# Col Value
	sw $s3, 12($sp) # Char to set
	sw $s4, 16($sp) # struct numRows
	sw $s5, 20($sp) # struct numCols
	sw $s6, 24($sp) # offset to add to state address to get character
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	lb $s4, 0($s0)
	lb $s5, 1($s0)
	addi $s0, $s0, 2
	
	blt $s1, $0, set_slot_failed	# Error handling
	bge $s1, $s4, set_slot_failed
	blt $s2, $0, set_slot_failed
	bge $s2, $s5, set_slot_failed
	
	mult $s1, $s5	# Multiply rowIndex by Columns
	mflo $s6
	addu $s6, $s6, $s2	# Add ColIndex
	
	addu $s0, $s0, $s6
	sb $s3, ($s0)
	
	
	move $v0, $s3
    lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	addi $sp, $sp, 40
	jr $ra
	
	set_slot_failed:
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

rotate:
    addi $sp, $sp, -40
	sw $s0, 0($sp)	# Original Piece struct address
	sw $s1, 4($sp)	# Rotation value
	sw $s2, 8($sp)	# Original rotated piece address
	sw $s3, 12($sp) # $ra saver
	sw $s4, 16($sp) # row piece byte
	sw $s5, 20($sp) # col piece byte
	sw $s6, 24($sp) # Rotation value % 4 -> Rotation value % 2
	#sw $s7, 28($sp)
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $ra
	lb $s4, 0($s0)
	lb $s5, 1($s0)
	
	bltz, $s1, rotate_failed
	
	move $a0, $s2
	lb $a1, 0($s0)
	lb $a2, 1($s0)
	li $a3, '.'
	jal initialize
	
	move $a0, $s0
	li $a1, -1
	li $a2, -1
	jal get_slot
	
	move $a0, $s0
	li $a1, -1
	li $a2, -1
	jal set_slot
	
	li $t9, 4
	div $s1, $t9
	mfhi $s6
	
	li $t9, 1
	beq $s4, $t9, I_piece_rotate_check
	
	li $t9, 4
	beq $s4, $t9, I_piece_rotate_check
	
	li $t9, 2
	beq $s4, $t9, O_piece_check_col
	beq $s5, $t9, O_piece_check_row	# Technically this naming is off. If $s4 is not 2, the piece by definition cannot be an O
	
	li $v0, 10
	syscall
	
	rotate_piece_success:
		move $ra, $s3
    	move $v0, $s1
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		#lw $s7, 28($sp)
		addi $sp, $sp, 40
		jr $ra
    
    rotate_failed:
    	move $ra, $s3
    	li $v0, -1
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		#lw $s7, 28($sp)
		addi $sp, $sp, 40
		jr $ra
	
	I_piece_rotate_check:
		li $t9, 2
		div $s6, $t9	# $s6 = $s6 % 2
		mfhi $s6
		
		li $t9, 1
		bne $s6, $t9, I_O_piece_write	# If $s6 is not 1, then we don't really need to swap anything
		
		j I_piece_rotate_decide
	
	I_piece_rotate_decide:
		li $t9, 1
		beq $s4, $t9, I_piece_rotate_1_swap
		
		li $t9, 4
		beq $s4, $t9, I_piece_rotate_4_swap
	
	I_piece_rotate_1_swap:
		li $t9, 4
		sb $t9, 0($s2)
		
		li $t9, 1
		sb $t9, 1($s2)
		j I_O_piece_write
	
	I_piece_rotate_4_swap:
		li $t9, 1
		sb $t9, 0($s2)
		
		li $t9, 4
		sb $t9, 1($s2)
		j I_O_piece_write
	
	I_O_piece_write:
		li $t9, 'O'
		move $a0, $s2
		addi $a0, $a0, 2
		
		sb $t9, 0($a0)
		sb $t9, 1($a0)
		sb $t9, 2($a0)
		sb $t9, 3($a0)
		
		li $t9, '.'
		sb $t9, 4($a0)
		sb $t9, 5($a0)
		
		move $ra, $s3
		move $v0, $s1
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		#lw $s7, 28($sp)
		addi $sp, $sp, 40
		jr $ra
	
	O_piece_check_row:
		li $t9, 2
		beq $s4, $t9, O_piece_rotate
		
		li $t9, 3
		beq $s4, $t9, six_byte_piece_rotate_prep #three_two_piece_rotate
		j rotate_failed
	
	O_piece_check_col:
		li $t9, 2
		beq $s5, $t9, O_piece_rotate
		
		li $t9, 3
		beq $s5, $t9, six_byte_piece_rotate_prep #two_three_piece_rotate
		j rotate_failed
	
	O_piece_rotate:
		j I_O_piece_write
	
	six_byte_piece_rotate_prep:
		move $a0, $s0
		move $a2, $s2
		lb $t9, 0($s0)	# Taking row and col from first two bytes of piece and putting in rotated_piece
		sb $t9, 0($s2)
		lb $t9, 1($s0)
		sb $t9, 1($s2)
		
		addi $a0, $a0, 2
		addi $a2, $a2, 2
		
		lb $t9 0($a0)
		sb $t9, 0($a2)
		lb $t9, 1($a0)
		sb $t9, 1($a2)
		lb $t9, 2($a0)
		sb $t9, 2($a2)
		lb $t9, 3($a0)
		sb $t9, 3($a2)
		lb $t9, 4($a0)
		sb $t9, 4($a2)
		lb $t9, 5($a0)
		sb $t9, 5($a2)
		j six_byte_piece_rotate_while
	
		
	six_byte_piece_rotate_while:
		beqz $s6, rotate_piece_success
		
		move $a0, $s0
		move $a1, $s6
		move $a2, $s2
		jal rotate_piece
		
	six_byte_piece_rotate_while_update:
		addi $s6, $s6, -1
		j six_byte_piece_rotate_while
			

count_overlaps:
	addi $sp, $sp, -80
	sw $s0, 0($sp)  # state original
	sw $s1, 4($sp)  # row to search (not original)
	sw $s2, 8($sp)  # col to search (not original)
	sw $s3, 12($sp) # piece original
	sw $s4, 16($sp) # piece row
	sw $s5, 20($sp) # piece col
	sw $s6, 24($sp) # state row -> piece row counter from 0 (i)
	sw $s7, 28($sp) # state col -> piece col counter from 0 (j)
	li $t0, 0		# Answer register
	move $t1, $ra	# $ra saver
	li $t2, 0		# byteloader
	move $t3, $a3	# piece modified
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	# Error Checking Start
	bltz $s1, count_overlaps_failed		# If the row and column indexes to look for are less than zero
	bltz $s2, count_overlaps_failed
	
	lb $s4, 0($s3)
	lb $s5, 1($s3)
	lb $s6, 0($s0)
	lb $s7, 1($s0)
	
	addi $s4, $s4, -1
	addi $s5, $s5, -1
	
	add $t9, $s1, $s4
	bge $t9, $s6, count_overlaps_failed
	add $t9, $s2, $s5
	bge $t9, $s7, count_overlaps_failed
	# Error Checking End
	
	lb $s4, 0($s3)
	lb $s5, 1($s3)
	li $s6, 0
	li $s7, 0
	
	addi $t3, $t3, 2
	addi $s4, $s4, -1	# need to subtract 1 from piece row otherwise we will print an extra row
	lb $t2, ($t3)
	
	count_overlaps_for_col:
		beq $s7, $s5, count_overlaps_for_row_update
		
		move $a0, $s3
		move $a1, $s6
		move $a2, $s7
		sw $t0, 32($sp)
		sw $t1, 36($sp)
		sw $t2, 40($sp)
		sw $t3, 44($sp)
		jal get_slot
		lw $t0, 32($sp)
		lw $t1, 36($sp)
		lw $t2, 40($sp)
		lw $t3, 44($sp)
		
		li $t9, 79
		beq $v0, $t9, count_overlaps_check_state
		
		
		#move $a0, $t2	This was for printing the piece out for debugging
		#li $v0, 11
		#syscall
		
		j count_overlaps_for_col_update
	
	count_overlaps_for_col_update:
		addiu $t3, $t3, 1
		lb $t2, ($t3)
		addiu $s7, $s7, 1
		j count_overlaps_for_col
	
	count_overlaps_for_row_update:
		beq $s6, $s4, count_overlaps_done
		
		#li $a0, '\n'
		#li $v0, 11
		#syscall
		
		li $s7, 0
		addiu $s6, $s6, 1
		j count_overlaps_for_col
	
	
	count_overlaps_check_state:
		move $a0, $s0
		add $a1, $s1, $s6
		add $a2, $s2, $s7
		sw $t0, 32($sp)
		sw $t1, 36($sp)
		sw $t2, 40($sp)
		sw $t3, 44($sp)
		jal get_slot
		lw $t0, 32($sp)
		lw $t1, 36($sp)
		lw $t2, 40($sp)
		lw $t3, 44($sp)
		
		li $t9, -1
		beq $v0, $t9, count_overlaps_failed
		
		li $t9, 79
		bne $v0, $t9, count_overlaps_for_col_update
		
		addi $t0, $t0, 1
		j count_overlaps_for_col_update
	
	count_overlaps_done:
		move $v0, $t0
		move $ra, $t1
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		addi $sp, $sp, 80
		jr $ra
	
	count_overlaps_failed:
		li $v0, -1
		move $ra, $t1
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		addi $sp, $sp, 80
		jr $ra


drop_piece:
	addi $sp, $sp, -40
	sw $s0, 0($sp)  # state original
	sw $s1, 4($sp)  # col to search original
	sw $s2, 8($sp)  # rotated piece address original
	sw $s3, 12($sp) # $ra saver
	sw $s4, 16($sp) # row modified
	sw $s5, 20($sp) # answer register
	sw $s6, 24($sp) # piece original
	sw $s7, 28($sp) # rotation original
	
	move $s6, $a2
	move $s7, $a3
	
	move $s0, $a0
	move $s1, $a1
	lw $s2, 40($sp)
	move $s3, $ra
	
	li $t9, -1
	beq $v0, $t9, drop_piece_failed_2
	bltz $s1, drop_piece_failed_2
	lb $t9, 1($s0)
	bge $s1, $t9, drop_piece_failed_2
	
	move $a0, $s6
	move $a1, $s7
	move $a2, $s2
	jal rotate
	
	lb $t9, 1($s2)
	addi $t9, $t9, -1
	add $t9, $t9, $s1
	lb $t8, 1($s0)
	bge $t9, $t8, drop_piece_failed_3
	
	move $a0, $s0
	li $a1, 0
	move $a2, $s1
	move $a3, $s2
	jal count_overlaps
	bnez $v0, drop_piece_failed_1
	#li $t9, -1
	#beq $v0, $t9, drop_piece_failed_1
	
	li $s4, 1
	
	drop_piece_while:
		move $a0, $s0
		move $a1, $s4
		move $a2, $s1
		move $a3, $s2
		jal count_overlaps
		bnez $v0, drop_piece_insert
	
	drop_piece_while_update:
		addi $s4, $s4, 1
		j drop_piece_while
	
	
	drop_piece_insert:
		addi $s4, $s4, -1
		move $s5, $s4
		
		move $a0, $s0
		move $a1, $s4
		move $a2, $s1
		move $a3, $s2
		jal drop_piece_insert_location
		j drop_piece_done
	
	
	drop_piece_done:
		move $ra, $s3
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
	
	drop_piece_failed_1:
		li $v0, -1
		j drop_piece_failed
	
	drop_piece_failed_2:
		li $v0, -2
		j drop_piece_failed
	
	drop_piece_failed_3:
		li $v0, -3
		j drop_piece_failed
	
	drop_piece_failed:
		move $ra, $s3
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
	

check_row_clear:
	addi $sp, $sp, -40
	sw $s0, 4($sp)  # state original
	sw $s1, 8($sp)  # row original
	sw $s2, 12($sp)  # $ra saver
	sw $s3, 16($sp) # state row
	sw $s4, 20($sp) # state modified
	sw $s5, 24($sp) # state col modified
	sw $s6, 28($sp) # state col original
	sw $s7, 32($sp) # state address before for swapping -> byteloader
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $ra
	lb $s3, 0($s0)
	move $s4, $a0
	lb $s6, 1($s0)
	
	bltz $s1, check_row_clear_failed
	bge $s1, $s3, check_row_clear_failed
	
	lb $t9, 1($s0)
	mult $t9, $s1
	mflo $t9
	addi $s4, $s4, 2
	add $s4, $s4, $t9	# $s4 is now at the proper row address
	
	lb $s5, 1($s0)
	lb $t8, ($s4)
	
	check_row_clear_check_while:
		beqz $s5, check_row_clear_swap
		
		li $t9, 79
		bne $t8, $t9, check_row_clear_not_full
	
	check_row_clear_check_while_update:
		addi $s5, $s5, -1
		addi $s4, $s4, 1
		lb $t8, ($s4)
		j check_row_clear_check_while
	
	
	check_row_clear_swap:
		beqz $s1, check_row_clear_first_row	
	
		sub $s4, $s4, $s6	# we are at the original row address from the main file
		sub $s7, $s4, $s6	# 1 row below
	
	check_row_clear_swap_while:
		beqz $s1, check_row_clear_first_row
		
		move $a0, $s7
		li $a1, 0
		move $a2, $s4
		li $a3, 0
		sw $s6, 0($sp)
		jal bytecopy
	
	check_row_clear_swap_while_update:
		sub $s4, $s4, $s6
		sub $s7, $s7, $s6
		addi $s1, $s1, -1
		j check_row_clear_swap_while
	
	check_row_clear_first_row:
		move $s5, $s6		# We have the state col
		move $s4, $s0
		addi $s4, $s4, 2	# we are at the start of the first row in state
		
	check_row_clear_first_row_while:
		beqz $s5, check_row_clear_done
		
		li $t9, 46
		sb $t9, ($s4)
	
	check_row_clear_first_row_while_update:
		addi $s5, $s5, -1
		addi $s4, $s4, 1
		j check_row_clear_first_row_while
	
	
	check_row_clear_done:
		li $v0, 1
		move $ra, $s2
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		lw $s7, 32($sp)
		addi $sp, $sp, 40
		jr $ra
	
	check_row_clear_not_full:
		li $v0, 0
		move $ra, $s2
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		lw $s7, 32($sp)
		addi $sp, $sp, 40
		jr $ra
	
	check_row_clear_failed:
		li $v0, -1
		move $ra, $s2
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		lw $s7, 32($sp)
		addi $sp, $sp, 40
		jr $ra
		

simulate_game:
	addi $sp, $sp, -80
	sw $s0, 4($sp)  # state original
	sw $s1, 8($sp)  # filename original
	sw $s2, 12($sp) # moves original
	sw $s3, 16($sp) # rotated_piece original
	sw $s4, 20($sp) # num_pieces to drop original
	sw $s5, 24($sp) # pieces array original
	sw $s6, 28($sp) # state modified
	sw $s7, 32($sp) # moves modifed
	sw $fp, 36($sp) # register to store temp values
					# $t0 - $ra saver (40)
					# $t1 - num_successful_drops (44)
					# $t2 - move_number (48)
					# $t3 - moves_length (52)
					# $t4 - game_over (56)
					# $t5 - score (60)
					# $t6 - piece_type (64) -> piece
					# $t7 - rotation (68)
					# $t8 - col (72)
					# $t9 - invalid (76)
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	lw $s4, 80($sp)
	lw $s5, 84($sp)
	move $s6, $a0
	move $s7, $a2
	move $t0, $ra
	
	move $a0, $s0
	move $a1, $s1
	jal load_game
	li $fp, -1
	beq $v0, $fp, simulate_game_failed_check

simulate_game_no_error:
	li $t1, 0 	# num_successful_drops = 0
	li $t2, 0	# move_number = 0
	
	move $a0, $s2
	jal strlen
	li $fp, 4
	div $v0, $fp
	mflo $t3	# moves_length = len(moves) / 4
	li $t4, 0	# game_over = False
	li $t5, 0	# score = 0
	
	simulate_game_while_game_over_check:
		beqz $t4, simulate_game_while_num_successful_drops_check	# If game_over is false, go to the next check
		j simulate_game_done
	
	simulate_game_while_num_successful_drops_check:
		blt $t1, $s4, simulate_game_while_move_number_check			# if num_successful_drops < num_pieces_to_drop
		j simulate_game_done
	
	simulate_game_while_move_number_check:
		blt $t2, $t3, simulate_game_while							# If move_number < moves_length
		j simulate_game_done
	
	simulate_game_while:
		lb $t6, 0($s7)	# piece_type
		
		lb $t7, 1($s7)	# rotation
		addi $t7, $t7, -48
		
		lb $t8, 2($s7)	# column
		addi $t8, $t8, -48
		li $fp, 10
		mult $t8, $fp
		mflo $t8
		
		lb $fp, 3($s7)
		addi $fp, $fp, -48
		add $t8, $t8, $fp
		
		li $t9, 0		# invalid = False
		
		li $fp, 84
		beq $t6, $fp, simulate_game_piece_T
		li $fp, 74
		beq $t6, $fp, simulate_game_piece_J
		li $fp, 90
		beq $t6, $fp, simulate_game_piece_Z
		li $fp, 79
		beq $t6, $fp, simulate_game_piece_O
		li $fp, 83
		beq $t6, $fp, simulate_game_piece_S
		li $fp, 76
		beq $t6, $fp, simulate_game_piece_L
		li $fp, 73
		beq $t6, $fp, simulate_game_piece_I
		
	simulate_game_while_have_piece:
		move $a0, $s0
		move $a1, $t8
		move $a2, $t6
		move $a3, $t7
		sw $s3, 0($sp)
		sw $t0, 40($sp)
		sw $t1, 44($sp)
		sw $t2, 48($sp)
		sw $t3, 52($sp)
		sw $t4, 56($sp)
		sw $t5, 60($sp)
		sw $t6, 64($sp)
		sw $t7, 68($sp)
		sw $t8, 72($sp)
		sw $t9, 76($sp)
		jal drop_piece
		lw $t0, 40($sp)
		lw $t1, 44($sp)
		lw $t2, 48($sp)
		lw $t3, 52($sp)
		lw $t4, 56($sp)
		lw $t5, 60($sp)
		lw $t6, 64($sp)
		lw $t7, 68($sp)
		lw $t8, 72($sp)
		lw $t9, 76($sp)
		
		li $fp, -2
		beq $v0, $fp, simulate_game_invalid_change_true
		li $fp, -3
		beq $v0, $fp, simulate_game_invalid_change_true
		li $fp, -1
		beq $v0, $fp, simulate_game_game_over_change_true
	
	simulate_game_while_after_drop_piece_check:
		lb $a0, 0($s7)
		li $v0, 11
		syscall
		
		lb $a0, 1($s7)
		syscall
		
		lb $a0, 2($s7)
		syscall
		
		lb $a0, 3($s7)
		syscall
		
		li $a0, '\n'
		syscall
		
		move $a0, $s0	# This is purely just for debugging
		lb $a1, 0($a0)
		lb $a2, 1($a0)
		jal print_board
		
		li $a0 '\n'
		li $v0, 11
		syscall
		syscall
		
		li $fp, 1
		beq $t9, $fp, simulate_game_if_invalid
		
		move $a0, $s0
		sw $s3, 0($sp)
		sw $t0, 40($sp)
		sw $t1, 44($sp)
		sw $t2, 48($sp)
		sw $t3, 52($sp)
		sw $t4, 56($sp)
		sw $t5, 60($sp)
		sw $t6, 64($sp)
		sw $t7, 68($sp)
		sw $t8, 72($sp)
		sw $t9, 76($sp)
		jal check_lines_cleared
		lw $t0, 40($sp)
		lw $t1, 44($sp)
		lw $t2, 48($sp)
		lw $t3, 52($sp)
		lw $t4, 56($sp)
		lw $t5, 60($sp)
		lw $t6, 64($sp)
		lw $t7, 68($sp)
		lw $t8, 72($sp)
		lw $t9, 76($sp)
		
		li $fp, 1
		beq $v0, $fp, simulate_game_while_score_increase_40
		li $fp, 2
		beq $v0, $fp, simulate_game_while_score_increase_100
		li $fp, 3
		beq $v0, $fp, simulate_game_while_score_increase_300
		li $fp, 4
		beq $v0, $fp, simulate_game_while_score_increase_1200
	
	simulate_game_while_update:
		addi $t1, $t1, 1	# move_number += 1
		addi $t2, $t2, 1	# num_successful_drops += 1
		addi $s7, $s7, 4	# add 4 to moves address so we can extract the next piece, column, and rotation
		j simulate_game_while_game_over_check
	
	simulate_game_while_update_invalid:
		addi $s7, $s7, 4	# add 4 to moves address so we can extract the next piece, column, and rotation
		j simulate_game_while_game_over_check
	
	
	simulate_game_piece_T:
		move $t6, $s5
		j simulate_game_while_have_piece
	
	simulate_game_piece_J:
		move $t6, $s5
		addi $t6, $t6, 8
		j simulate_game_while_have_piece
	
	simulate_game_piece_Z:
		move $t6, $s5
		addi $t6, $t6, 16
		j simulate_game_while_have_piece
	
	simulate_game_piece_O:
		move $t6, $s5
		addi $t6, $t6, 24
		j simulate_game_while_have_piece
		
	simulate_game_piece_S:
		move $t6, $s5
		addi $t6, $t6, 32
		j simulate_game_while_have_piece
	
	simulate_game_piece_L:
		move $t6, $s5
		addi $t6, $t6, 40
		j simulate_game_while_have_piece
	
	simulate_game_piece_I:
		move $t6, $s5
		addi $t6, $t6, 48
		j simulate_game_while_have_piece
	
	
	simulate_game_invalid_change_true:
		li $t9, 1	# invalid = True
		j simulate_game_while_after_drop_piece_check
	
	simulate_game_game_over_change_true:
		li $t4, 1	# game_over = True
		li $t9, 1	# invalid = True
		j simulate_game_while_after_drop_piece_check
	
	simulate_game_if_invalid:
		addi $t2, $t2, 1	# move_number += 1
		j simulate_game_while_update_invalid
	
	
	simulate_game_while_score_increase_40:
		addi $t5, $t5, 40
		j simulate_game_while_update
		
	simulate_game_while_score_increase_100:
		addi $t5, $t5, 100
		j simulate_game_while_update
		
	simulate_game_while_score_increase_300:
		addi $t5, $t5, 300
		j simulate_game_while_update
		
	simulate_game_while_score_increase_1200:
		addi $t5, $t5, 1200
		j simulate_game_while_update
	
	
	simulate_game_done:
		move $v0, $t1
		move $v1, $t5
		move $ra, $t0
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		lw $fp, 32($sp)
		addi $sp, $sp, 80
		jr $ra
	
	simulate_game_failed_check:
		beq $v1, $fp, simulate_game_failed
		j simulate_game_no_error
	
	simulate_game_failed:
		li $v0, 0
		li $v1, 0
		move $ra, $t0
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		lw $fp, 32($sp)
		addi $sp, $sp, 80
		jr $ra
		

# ALL HELPER FUNCTIONS GO UNDER HERE

# $a0 - state
# $a1 - row to insert
# $a2 - col
# $a3 - piece
drop_piece_insert_location:
	addi $sp, $sp, -44
	sw $s0, 0($sp)	# state original
	sw $s1, 4($sp)	# row to insert
	sw $s2, 8($sp)	# col to insert
	sw $s3, 12($sp) # piece
	sw $s4, 16($sp) # num_row counter from 0
	sw $s5, 20($sp) # col_row counter from 0
	sw $s6, 24($sp) # $ra saver
	sw $s7, 28($sp) # byteloader
	lb $t0, 0($a3)	# piece row
	lb $t1, 1($a3)  # piece col
	move $t2, $a3	# piece address original
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	li $s4, 0
	li $s5, 0
	move $s6, $ra
	
	addiu $s3, $s3, 2
	addi $t0, $t0, -1
	lb $s7, ($s3)
	
	drop_piece_insert_location_for_col:
		beq $s5, $t1, drop_piece_insert_location_for_row_update
		
		move $a0, $t2
		move $a1, $s4
		move $a2, $s5
		sw $t0, 32($sp)
		sw $t1, 36($sp)
		sw $t2, 40($sp)
		jal get_slot
		lw $t0, 32($sp)
		lw $t1, 36($sp)
		lw $t2, 40($sp)
		
		li $t9, 79
		beq $v0, $t9, drop_piece_insert_state
		
		#move $a0, $s7	#This is printing out the piece for debugging
		#li $v0, 11
		#syscall
		
		j drop_piece_insert_location_for_col_update
	
	drop_piece_insert_location_for_col_update:
		addiu $s3, $s3, 1
		lb $s7, ($s3)
		addiu $s5, $s5, 1
		j drop_piece_insert_location_for_col
	
	drop_piece_insert_location_for_row_update:
		beq $s4, $t0, drop_piece_insert_location_done
		
		#li $a0, '\n'
		#li $v0, 11
		#syscall
		
		li $s5, 0
		addiu $s4, $s4, 1
		j drop_piece_insert_location_for_col
	
	drop_piece_insert_location_done:
		move $ra, $s6
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		addi $sp, $sp, 44
		jr $ra
	
	
	drop_piece_insert_state:
		move $a0, $s0
		add $a1, $s1, $s4
		add $a2, $s2, $s5
		li $a3, 79
		jal set_slot
		j drop_piece_insert_location_for_col_update
	
	

# $a0 - piece struct address
# $a1 - rotation value % 4
# $a2 - rotated_piece address
rotate_piece:
	addi $sp, $sp, -40
	sw $s0, 0($sp)  # piece struct address original
	sw $s1, 4($sp)  # rotation value % 4
	sw $s2, 8($sp)  # rotated_piece address
	sw $s3, 12($sp) # index 0 char holder
	sw $s4, 16($sp) # index 1 char holder
	sw $s5, 20($sp) # index 2 char holder
	sw $s6, 24($sp) # index 3 char holder
	sw $s7, 28($sp) # index 4 char holder
	li $t0, 0		# index 5 char holder
	li $t1, 0		# row holder
	li $t2, 0		# col holder
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	
	addi $a2, $a2, 2
	lb $s3, 0($a2)
	lb $s4, 1($a2)
	lb $s5, 2($a2)
	lb $s6, 3($a2)
	lb $s7, 4($a2)
	lb $t0, 5($a2)
	
	lb $t1, 0($s2)
	li $t9, 2
	beq $t1, $t9, rotate_piece_two_three
	li $t9, 3
	beq $t1, $t9, rotate_piece_three_two
	
	rotate_piece_done:
		lb $t1, 0($s2)	# Swap the row and col in the struct
		lb $t2, 1($s2)
		sb $t2, 0($s2)
		sb $t1, 1($s2)
	
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
	
	rotate_piece_two_three:
		sb $s3, 1($a2)
		sb $s4, 3($a2)
		sb $s5, 5($a2)
		sb $s6, 0($a2)
		sb $s7, 2($a2)
		sb $t0, 4($a2)
		j rotate_piece_done
	
	rotate_piece_three_two:
		sb $s3, 2($a2)
		sb $s4, 5($a2)
		sb $s5, 1($a2)
		sb $s6, 4($a2)
		sb $s7, 0($a2)
		sb $t0, 3($a2)
		j rotate_piece_done

load_state_struct:
	addi $sp, $sp, -40
	sw $s0, 0($sp)  # Starting address of struct in memory (add 2 to get to board)
	sw $s1, 4($sp)  # Starting address of board in file (NOT THE NUMBERS BUT THE BOARD)
	sw $s2, 8($sp)  # (Rows * columns + rows) - 1
	sw $s3, 12($sp) # Byte selector of board in memory
	sw $s4, 16($sp) # Byte selector of board from file
	sw $s5, 20($sp) # Number of O's
	sw $s6, 24($sp) # Number of Invalid Characters
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	
	li $s3, 0
	li $s4, 0
	li $s5, 0
	li $s6, 0
	
	addi $a0, $a0, 2	# Setting $a0 to starting address of board
	addi $a2, $a2, -1	# We need to subtract 1 because we are already at the first byte
	lb $s4, ($a1)
	
	load_state_struct_for:
		beqz $a2, load_state_struct_done
		
		li $t9, 79
		beq $s4, $t9, O_Found
		li $t9, 46
		beq $s4, $t9, ._Found
		li $t9, 10
		beq $s4, $t9, newline_Found
		
		j invalid_Found
	
	O_Found:
		sb $s4, ($a0) 		# Store O in struct
		addiu $a0, $a0, 1	# Update struct address
		addiu $a1, $a1, 1	# Update board address from file
		addi $s5, $s5, 1	# Increment O Counter
		addi $a2, $a2, -1	# Increment for loop
		lb $s4, ($a1)
		j load_state_struct_for
	
	._Found:
		sb $s4, ($a0) 		# Store . in struct
		addiu $a0, $a0, 1	# Update struct address
		addiu $a1, $a1, 1	# Update board address from file
		addi $a2, $a2, -1	# Increment for loop
		lb $s4, ($a1)
		j load_state_struct_for
	
	newline_Found:
		addiu $a1, $a1, 1
		addiu $a2, $a2, -1
		lb $s4, ($a1)
		j load_state_struct_for
	
	invalid_Found:
		li $t9, 46
		sb $t9, ($a0) 		# Store . in struct
		addiu $a0, $a0, 1	# Update struct address
		addiu $a1, $a1, 1	# Update board address from file
		addiu $s6, $s6, 1	# Increment invalid character counter
		addi $a2, $a2, -1	# Increment for loop
		lb $s4, ($a1)
		j load_state_struct_for
	
	
	load_state_struct_done:
		move $v0, $s5
		move $v1, $s6
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		addi $sp, $sp, 40
		jr $ra


load_row_col_state:	# Takes in $a0 the starting address of the board, returns rows in $v0, col in $v1
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# Stores starting address of board from $a0
	sw $s1, 4($sp)	# Starting address of board to modify
	sw $s2, 8($sp)	# Address selector of $s1
	sw $s3, 12($sp)	# Offset of where the actual board starts
	sw $s4, 16($sp) # \n Counter
	sw $s5, 20($sp)	# Immediate value temp register
	sw $s6, 24($sp)	# Register to save answer
	
	li $s3, 0
	li $v0, 0
	li $v1, 0
	li $s4, 0
	li $s6, 0
	move $s0, $a0
	
	move $s1, $a0
	lb $s2, ($s1)
	
	load_row_col_while:
		li $t9, 2
		beq $s4, $t9, load_row_col_done		# If \n counter hits 2
		addiu $s3, $s3, 1
		li $t9, 10
		beq $s2, $t9, load_row_col_foundnewline	# If selector hits a \n
	
		li $s5, 10		# Multiply digit by 10 and then add the current digit
		mult $s6, $s5
		mflo $s6
	
		addiu $s2, $s2, -48		# Convert string to literal
		addu $s6, $s6, $s2		# Add new value to current answer register $s6
	
	
	load_row_col_update:
		addiu $s1, $s1, 1
		lb $s2, ($s1)
		j load_row_col_while


	load_row_col_foundnewline:
		addiu $s4, $s4, 1
		beqz $v0, load_row_col_updatev0	# If $v0 is 0, update $v0, otherwise update $v1
	
		move $v1, $s6
		j load_row_col_update

	load_row_col_updatev0:
		move $v0, $s6
		li $s6, 0
		j load_row_col_update

	load_row_col_done:
		#sw $s3, 168($sp)
		sw $s3, 44($sp)
	
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		addi $sp, $sp, 40
		jr $ra

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

# $a0 - state
# $v0 - number of lines cleared by dropping this piece
check_lines_cleared:
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# state original
	sw $s1, 4($sp)  # row counter
	sw $s2, 8($sp)  # answer/count register
	sw $s3, 12($sp) # $ra saver
	
	move $s0, $a0
	li $s2, 0
	move $s3, $ra
	lb $s1, 0($s0)
	addi $s1, $s1 -1
	
	check_lines_cleared_while:
		bltz $s1, check_lines_cleared_done
		
		move $a0, $s0
		move $a1, $s1
		jal check_row_clear
		li $t9, 1
		beq $v0, $t9, check_lines_cleared_increment
		
	check_lines_cleared_while_update:
		addi $s1, $s1, -1
		j check_lines_cleared_while
	
	
	check_lines_cleared_increment:
		addi $s2, $s2, 1
		j check_lines_cleared_while
	
	check_lines_cleared_done:
		move $v0, $s2
		move $ra, $s3
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		addi $sp, $sp, 40
		jr $ra
		

print_board:	# Takes arguments $a0 - board, $a1 - row val, $a2 - col val
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# Board address in memory
	sw $s1, 4($sp)	# Row Value
	sw $s2, 8($sp)	# Col Value
	sw $s3, 12($sp)	# num_row counter from 0
	sw $s4, 16($sp) # num_col counter from 0
	sw $s5, 20($sp)	# byte loader
	
	move $s0, $a0
	addiu $s0, $s0, 2	# 2 instead of 8 because the board starts at 2
	move $s1, $a1
	move $s2, $a2
	#lw $s1, 0($a0)
	#lw $s2, 4($a0)
	li $s3, 0
	li $s4, 0
	addiu $s1, $s1, -1
	
	lb $s5, ($s0)
	
	print_board_for_col:
		beq $s4, $s2, print_board_for_row_update	# When i = num_col
		move $a0, $s5
		li $v0, 11
		syscall
		j print_board_for_col_update
	
	print_board_for_col_update:
		addiu $s0, $s0, 1
		lb $s5, ($s0)
		addiu $s4, $s4, 1
		j print_board_for_col
	
	print_board_for_row_update:
		beq $s3, $s1, print_board_done	# When i = num_row - 1
		
		li $a0, '\n'
		li $v0, 11
		syscall
		
		li $s4, 0
		addiu $s3, $s3, 1
		j print_board_for_col
	
	
	print_board_done:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		addi $sp, $sp, 40
		jr $ra
	

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
