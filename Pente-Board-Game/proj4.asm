# CSE 220 Programming Project #4
# Name: Ammar Chishti
# Net ID: achishti
# SBU ID: 111717583

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text

load_board:
	addi $sp, $sp, -40
	sw $s0, 0($sp)		# $s0 - Original Board address
	sw $s1, 4($sp)		# $s1 - Filename
	sw $s2, 8($sp)		# $s2 - Rows
	sw $s3, 12($sp)		# $s3 - Columns
	sw $s4, 16($sp)		# $s4 - (rows * columns + rows) for board_replace function
	sw $s5, 20($sp)		# $s5 - $ra saver
	sw $s6, 24($sp)		# $s6 - row address -> Register offset to add after
	sw $s7, 28($sp)		# $s7 - col address -> Starting address of actual board
	
	move $s0, $a0
	move $s1, $a1
	move $s6, $a2
	move $s7, $a3
	
	addi $sp, $sp, -9808 # Start of reading the file
	li $v0, 13			
	move $a0, $s1
	li $a1, 0
	syscall
	
	beq $v0, -1, load_board_failed_done   # If the file cannot be read, end the program
	
	li $a0, 3		# Reading 6 bytes of the file
	li $v0, 14
	move $a1, $sp
	li $a2, 6
	syscall
	
	move $a0, $a1
	move $s5, $ra
	jal load_row_col_board	# To load the row and col integer values into $v0, and $v1
	move $ra, $s5
	
	move $s2, $v0
	move $s3, $v1
	
	#sw $s2, ($s6)		# Storing row and column values into memory locations
	#sw $s3, ($s7)
	
	sw $s2, 0($s0)	# Storing row and column values into memory locations
	sw $s3, 4($s0)
	
	lw $s6, ($sp)		# $s6 contains offset to add
	
	mult $s2, $s3
	mflo $s7
	addu $s7, $s7, $s2
	move $s4, $s7		# $s4 has (row * column + rows)
	addu $s7, $s7, $s6	# $s7 now has (row * columns + rows + offset)
	
	li $v0, 16		# Closing the file
	li $a0, 3
	syscall
	
	li $v0, 13		# Opening the File again
	move $a0, $s1
	li $a1, 0
	syscall
	
	addi $sp, $sp, 4	# This is because we allocated 1 word for the offset value
	li $a0, 3		# Reading the File again
	li $v0, 14
	move $a1, $sp
	move $a2, $s7
	syscall
	
	addu $a1, $a1, $s6	# Adding offset to file reading address
	move $s7, $a1		# $s7 now has the starting address of the actual board
	move $a0, $s0		# $a0 has the board address in memory
	move $a1, $s7		# $a1 has the actual board address from the file
	move $a2, $s4		# $a2 has (rows * columns + rows)
	move $s5, $ra
	jal load_board_struct	# To load the board data from the file into memory
	move $ra, $s5
	
	addi $sp, $sp, 9804
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


load_board_failed_done:
	addi $sp, $sp, 9808
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


get_slot:
	addi $sp, $sp, -40
	sw $s0, 0($sp)		# $s0 - Original Board struct address
	sw $s1, 4($sp)		# $s1 - RowIndex (Row to search for)
	sw $s2, 8($sp)		# $s2 - ColIndex (Column to search for)
	sw $s3, 12($sp)		# $s3 - Row
	sw $s4, 16($sp)		# $s4 - Columns
	sw $s5, 20($sp)		# $s5 - Byte selector for Board Struct
	sw $s6, 24($sp)		# $s6 - offset to add to Board adress
    
    move $s0, $a0
    addiu $s0, $s0, 8
    move $s1, $a1
    move $s2, $a2
    lw $s3, 0($a0)
    lw $s4, 4($a0)
    
    blt $s1, $zero, get_slot_failed		# Error handling
    bge $s1, $s3, get_slot_failed
    blt $s2, $zero, get_slot_failed
    bge $s2, $s4, get_slot_failed
    
    mult $s1, $s4	# Multiply rowIndex by Columns
    mflo $s6
    addu $s6, $s6, $s2		# Add ColIndex
    
    addu $s0, $s6, $s0
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
		lw $s7, 28($sp)
		addi $sp, $sp, 40
    	jr $ra
	

set_slot:
	addi $sp, $sp, -40
	sw $s0, 0($sp)		# $s0 - Original Board struct address
	sw $s1, 4($sp)		# $s1 - RowIndex (Row to search for)
	sw $s2, 8($sp)		# $s2 - ColIndex (Column to search for)
	sw $s3, 12($sp)		# $s3 - Character to set
	sw $s4, 16($sp)		# $s4 - $ra saver
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	move $s4, $ra
	jal goto_slot
	move $ra, $s4
	move $s0, $v0
	
	sb $s3 ($s0)
	move $v0, $s3
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	addi $sp, $sp, 40
    jr $ra
	

place_piece:
	addi $sp, $sp, -40
	sw $s0, 0($sp)		# $s0 - Original Board struct address
	sw $s1, 4($sp)		# $s1 - RowIndex (Row to search for)
	sw $s2, 8($sp)		# $s2 - ColIndex (Column to search for)
	sw $s3, 12($sp)		# $s3 - Row
	sw $s4, 16($sp)		# $s4 - Columns
	sw $s5, 20($sp)		# $s5 - Byte selector for Board Struct
	sw $s6, 24($sp)		# $s6 - offset to add to Board adress -> $ra saver
	sw $s7, 28($sp)		# $s7 - Player byte
    
    move $s0, $a0
    addiu $a0, $a0, 8
    move $s1, $a1
    move $s2, $a2
    move $s7, $a3
    
    bne $s7, 88, Player_Check2	# If byte is not an X
    
    place_piece_part2:
    
    	lw $s3, 0($s0)
    	lw $s4, 4($s0)
    
    	blt $s1, $zero, get_slot_failed		# Error handling
    	bge $s1, $s3, get_slot_failed
    	blt $s2, $zero, get_slot_failed
    	bge $s2, $s4, get_slot_failed
    
    	mult $s1, $s4	# Multiply rowIndex by Columns
    	mflo $s6
    	addu $s6, $s6, $s2		# Add ColIndex
    
    	addu $a0, $s6, $a0		# $s0 now has the index of [row][col]
    	
    	lb $s5, ($a0)
    	bne $s5, 46, place_piece_failed		# If the slot you are trying to put is not a period
    	
    	move $a0, $s0	# We have to call set_slot in this function(?)
    	move $a1, $s1
    	move $a2, $s2
    	move $a3, $s7
    	move $s6, $ra
    	jal set_slot
    	move $ra, $s6
    	
    	#sb $s7 ($s0)
    	#move $v0, $s7
    
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
    
    Player_Check2:
    	bne $s7, 79, place_piece_failed		# If byte is not an O
    	j place_piece_part2
    
	place_piece_failed:
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
    

game_status:
	addi $sp, $sp, -40
	sw $s0, 0($sp)		# $s0 - Original Board struct address
	sw $s1, 4($sp)		# $s1 - Upper limit
	sw $s2, 8($sp)		# $s2 - byte selector
	sw $s3, 12($sp)		# $s3 - Number of X's
	sw $s4, 16($sp)		# $s4 - Number of O's
	sw $s5, 20($sp)		# $s5 - Lower limit
	
	move $s0, $a0
	addiu $a0, $a0, 8
	
	lb $t0, 0($s0)
	lb $t1, 4($s0)
	mult $t0, $t1
	mflo $s1			# $s1 now has the upper limit
	
	li $s5, 0
	li $s3, 0
	li $s4, 0
	lb $s2 ($a0)
	
	game_status_for:
		beq $s5, $s1, game_status_done
		
		beq $s2, 88, game_status_X_Found
		beq $s2, 79, game_status_O_Found
		
		j game_status_for_update
	
	game_status_for_update:
		addiu $a0, $a0, 1
		addiu $s5, $s5, 1
		lb $s2, ($a0)
		j game_status_for
	
	game_status_X_Found:
		addiu $s3, $s3, 1
		j game_status_for_update
	
	game_status_O_Found:
		addiu $s4, $s4, 1
		j game_status_for_update
	
	game_status_done:
		move $v0, $s3
		move $v1, $s4
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		addi $sp, $sp, 40
		jr $ra
		
	


check_horizontal_capture:
	addi $sp, $sp, -40
	sw $s0, 0($sp)		# $s0 - Board Struct Address
	sw $s1, 4($sp)		# $s1 - RowIndex
	sw $s2, 8($sp)		# $s2 - ColIndex
	sw $s3, 12($sp)		# $s3 - Player Byte
	sw $s4, 16($sp)		# $s4 - $ra Saver
	sw $s5, 20($sp)		# $s5 - Opposite of Player Byte
	sw $s6, 24($sp)		# $s6 - Check Right Boolean -> RightCheckWin
	sw $s7, 28($sp)		# $s7 - Check Left Boolean -> LeftCheckWin
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	move $s4, $ra
	jal get_slot
	move $ra, $s4
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	li $v0, 0
	
	li $s6, 0
	li $s7, 0
	
	bne $a3, 88, Horizontal_Capture_Check2		# If byte is not an X
	li $s5, 79	# If the byte is an X, make the opposite an O
	
	Horizontal_Capture_Part2:
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		move $s4, $ra
		jal get_slot
		move $ra, $s4
		
		bne $v0, $s3, Capture_Failed		# If the slot at the given row and col is not equal to player
		
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		move $s4, $ra
		jal goto_slot
		move $ra, $s4
		move $a0, $v0	# $a0 now contains the address at the specified row and col
		
		lb $t0, 4($s0)	# $t0 now has numCols
		
		move $a2, $s2
		addiu $a2, $a2, 3
		blt, $a2, $t0, CheckRightBooleanTrue	# If colIndex + 3 < numCol, checkRightBoolean = 1
		
	Horizontal_Capture_2.1:
		move $a2, $s2
		addiu $a2, $a2, -3
		bgez, $a2, CheckLeftBooleanTrue		# If colIndex - 3 >= 0, checkLeftBoolean = 1
	
	Horizontal_Capture_2.2:
		beqz, $s6, CheckBothBooleanFalseHorizontal	# If both BooleanChecks are False, return 0
	
	Horizontal_Capture_2.3:
		beq, $s7, 1, LeftCheckWin	# If checkLeftBoolean is true, check the left to see if there is a win
	
	Horizontal_Capture_2.4:
		beq $s6, 1, RightCheckWin	# If checkRightBoolean is true, check the right to see if there is a win
	
	Horizontal_Capture_2.5:	
		beqz $s7, Capture_None
		beq $s7, 2, Capture_Two
		beq $s7, 4, Capture_Four
		
		j Capture_None
			

	# All of the checking for check_horizontal_capture
	CheckRightBooleanTrue:
		li $s6, 1
		j Horizontal_Capture_2.1

	CheckLeftBooleanTrue:
		li $s7, 1
		j Horizontal_Capture_2.2

	Horizontal_Capture_Check2:
		bne $a3, 79, Capture_Failed		# If byte is not an O
		li $s5, 88	# If the byte is an O, make the opposite an X
    	j Horizontal_Capture_Part2
    
    CheckBothBooleanFalseHorizontal:
    	beqz $s7, Capture_None
    	j Horizontal_Capture_2.3
    
    LeftCheckWin:	# $a0 - Board	$a1 - Row	$a2 - Col	$a3 - Player Byte
    	move $a0, $s0
    	move $a1, $s1
    	move $a2, $s2
    	move $a3, $s3
    	move $s4, $ra
    	jal goto_slot	
    	move $ra, $s4
    	move $a0, $v0	# $a0 now contains the address at the specified row and col
    	
    	addiu $a0, $a0, -1
    	li $t0, 0	# Success Counter
    	lb $t1, ($a0)
    	
    	beq $t1, $s5, LeftInc1	# If byte selected is equal to opposite of player, Increment $t0
    	
    LeftCheckWin1:
    
    	addiu $a0, $a0, -1
    	lb $t1, ($a0)
    	beq $t1, $s5, LeftInc2 # If byte selected is equal to opposite of player, Increment $t0
    
    LeftCheckWin2:
    	
    	addiu $a0, $a0, -1
    	lb $t1, ($a0)
    	beq $t1, $s3, LeftInc3	# If byte selected is equal to player, Increment $t0
    	
    LeftCheckWin3:
    
    	beq $t0, 3, ClearLeft	# If success counter is 3, that means that left needs to be cleared
    	j Horizontal_Capture_2.4
    	
    	
    	LeftInc1:
    		addiu $t0, $t0, 1
    		j LeftCheckWin1
    	
    	LeftInc2:
    		addiu $t0, $t0, 1
    		j LeftCheckWin2
    	
    	LeftInc3:
    		addiu $t0, $t0, 1
    		j LeftCheckWin3
    		
    
    ClearLeft:  # $a0 - Board	$a1 - Row	$a2 - Col	$a3 - Player Byte
    	move $a0, $s0
    	move $a1, $s1
    	move $a2, $s2
    	move $a3, $s3
    	move $s4, $ra
    	jal goto_slot	
    	move $ra, $s4
    	move $a0, $v0	# $a0 now contains the address at the specified row and col
    	
    	addiu $a0, $a0, -1
    	lb $t0 ($a0)
    	li $t0, 46
    	sb $t0 ($a0)
    	
    	addiu $a0, $a0, -1
    	lb $t0 ($a0)
    	li $t0, 46
    	sb $t0 ($a0)
    	
    	li $s7, 2
    	j Horizontal_Capture_2.4
    
    
    RightCheckWin:	# $a0 - Board	$a1 - Row	$a2 - Col	$a3 - Player Byte
    	move $a0, $s0
    	move $a1, $s1
    	move $a2, $s2
    	move $a3, $s3
    	move $s4, $ra
    	jal goto_slot	
    	move $ra, $s4
    	move $a0, $v0	# $a0 now contains the address at the specified row and col
    	
    	addiu $a0, $a0, 1
    	li $t0, 0	# Success Counter
    	lb $t1, ($a0)
    	
    	beq $t1, $s5, RightInc1	# If byte selected is equal to opposite of player, Increment $t0
    	
    RightCheckWin1:
    
    	addiu $a0, $a0, 1
    	lb $t1, ($a0)
    	beq $t1, $s5, RightInc2 # If byte selected is equal to opposite of player, Increment $t0
    
    RightCheckWin2:
    	
    	addiu $a0, $a0, 1
    	lb $t1, ($a0)
    	beq $t1, $s3, RightInc3	# If byte selected is equal to player, Increment $t0
    	
    RightCheckWin3:
    
    	beq $t0, 3, ClearRight   # If success counter is 3, that means that left needs to be cleared
    	j Horizontal_Capture_2.5
    	
    	
    	RightInc1:
    		addiu $t0, $t0, 1
    		j RightCheckWin1
    	
    	RightInc2:
    		addiu $t0, $t0, 1
    		j RightCheckWin2
    	
    	RightInc3:
    		addiu $t0, $t0, 1
    		j RightCheckWin3
    		
    
    ClearRight:  # $a0 - Board	$a1 - Row	$a2 - Col	$a3 - Player Byte
    	move $a0, $s0
    	move $a1, $s1
    	move $a2, $s2
    	move $a3, $s3
    	move $s4, $ra
    	jal goto_slot	
    	move $ra, $s4
    	move $a0, $v0	# $a0 now contains the address at the specified row and col
    	
    	addiu $a0, $a0, 1
    	lb $t0 ($a0)
    	li $t0, 46
    	sb $t0 ($a0)
    	
    	addiu $a0, $a0, 1
    	lb $t0 ($a0)
    	li $t0, 46
    	sb $t0 ($a0)
    	
    	addiu $s7, $s7, 2
    	j Horizontal_Capture_2.5
    	
    	
    
    Capture_Failed:
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
    
    Capture_None:
    	li $v0, 0
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
    
    Capture_Two:
    	li $v0, 2
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
    
    Capture_Four:
    	li $v0, 4
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
    	
	
	

check_vertical_capture:

    addi $sp, $sp, -40
	sw $s0, 0($sp)		# $s0 - Board Struct Address
	sw $s1, 4($sp)		# $s1 - RowIndex
	sw $s2, 8($sp)		# $s2 - ColIndex
	sw $s3, 12($sp)		# $s3 - Player Byte
	sw $s4, 16($sp)		# $s4 - $ra Saver
	sw $s5, 20($sp)		# $s5 - Opposite of Player Byte
	sw $s6, 24($sp)		# $s6 - Check Up Boolean -> UpCheckWin
	sw $s7, 28($sp)		# $s7 - Check Down Boolean -> DownCheckWin
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	move $s4, $ra
	jal get_slot
	move $ra, $s4
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	li $v0, 0
	
	li $s6, 0
	li $s7, 0
	
	bne $a3, 88, Vertical_Capture_Check2		# If byte is not an X
	li $s5, 79	# If the byte is an X, make the opposite an O
	
	Vertical_Capture_Part2:
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		move $s4, $ra
		jal get_slot
		move $ra, $s4
		
		bne $v0, $s3, Capture_Failed		# If the slot at the given row and col is not equal to player
		
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		move $s4, $ra
		jal goto_slot
		move $ra, $s4
		move $a0, $v0	# $a0 now contains the address at the specified row and col
		
		lb $t0, 0($s0)	# $t0 now has numRows
		
		move $a1, $s1
		addiu $a1, $a1, 3
		blt, $a1, $t0, CheckDownBooleanTrue	# If rowIndex + 3 < numRow, checkDownBoolean = 1
		
	Vertical_Capture_2.1:
		move $a1, $s1
		addiu $a1, $a1, -3
		bgez, $a1, CheckUpBooleanTrue		# If rowIndex - 3 >= 0, checkUpBoolean = 1
	
	Vertical_Capture_2.2:
		beqz, $s6, CheckBothBooleanFalseVertical	# If both BooleanChecks are False, return 0
	
	Vertical_Capture_2.3:
		beq, $s7, 1, DownCheckWin	# If checkDownBoolean is true, check downward to see if there is a win
	
	Vertical_Capture_2.4:
		beq $s6, 1, UpCheckWin	# If checkUpBoolean is true, check upward to see if there is a win
	
	Vertical_Capture_2.5:	
		beqz $s7, Capture_None
		beq $s7, 2, Capture_Two
		beq $s7, 4, Capture_Four
		
		j Capture_None
			

	# All of the checking for check_vertical_capture
	CheckUpBooleanTrue:
		li $s6, 1
		j Vertical_Capture_2.2

	CheckDownBooleanTrue:
		li $s7, 1
		j Vertical_Capture_2.1

	Vertical_Capture_Check2:
		bne $a3, 79, Capture_Failed		# If byte is not an O
		li $s5, 88	# If the byte is an O, make the opposite an X
    	j Vertical_Capture_Part2
    
    CheckBothBooleanFalseVertical:
    	beqz $s7, Capture_None
    	j Vertical_Capture_2.3
    
    DownCheckWin:	# $a0 - Board	$a1 - Row	$a2 - Col	$a3 - Player Byte
    	addiu $s7, $s7, -1
    	move $a0, $s0
    	move $a1, $s1
    	move $a2, $s2
    	move $a3, $s3
    	move $s4, $ra
    	jal goto_slot	
    	move $ra, $s4
    	move $a0, $v0	# $a0 now contains the address at the specified row and col
    	
    	lw $t2, 4($s0)
    	addu $a0, $a0, $t2	# Add numCol to go down a col
    	li $t0, 0	# Success Counter
    	lb $t1, ($a0)
    	
    	beq $t1, $s5, DownInc1	# If byte selected is equal to opposite of player, Increment $t0
    	
    DownCheckWin1:
    
    	addu $a0, $a0, $t2 # Add numCol to go down a col
    	lb $t1, ($a0)
    	beq $t1, $s5, DownInc2 # If byte selected is equal to opposite of player, Increment $t0
    
    DownCheckWin2:
    	
    	addu $a0, $a0, $t2 # Add numCol to go down a col
    	lb $t1, ($a0)
    	beq $t1, $s3, DownInc3	# If byte selected is equal to player, Increment $t0
    	
    DownCheckWin3:
    
    	beq $t0, 3, ClearDown	# If success counter is 3, that means that down needs to be cleared
    	j Vertical_Capture_2.4
    	
    	
    	DownInc1:
    		addiu $t0, $t0, 1
    		j DownCheckWin1
    	
    	DownInc2:
    		addiu $t0, $t0, 1
    		j DownCheckWin2
    	
    	DownInc3:
    		addiu $t0, $t0, 1
    		j DownCheckWin3
    		
    
    ClearDown:  # $a0 - Board	$a1 - Row	$a2 - Col	$a3 - Player Byte
    	move $a0, $s0
    	move $a1, $s1
    	move $a2, $s2
    	move $a3, $s3
    	move $s4, $ra
    	jal goto_slot	
    	move $ra, $s4
    	move $a0, $v0	# $a0 now contains the address at the specified row and col
    	
    	lw $t2, 4($s0)
    	
    	addu $a0, $a0, $t2
    	lb $t0 ($a0)
    	li $t0, 46
    	sb $t0 ($a0)
    	
    	addu $a0, $a0, $t2
    	lb $t0 ($a0)
    	li $t0, 46
    	sb $t0 ($a0)
    	
    	li $s7, 2
    	j Vertical_Capture_2.4
    
    
    UpCheckWin:	# $a0 - Board	$a1 - Row	$a2 - Col	$a3 - Player Byte
    	move $a0, $s0
    	move $a1, $s1
    	move $a2, $s2
    	move $a3, $s3
    	move $s4, $ra
    	jal goto_slot	
    	move $ra, $s4
    	move $a0, $v0	# $a0 now contains the address at the specified row and col
    	
    	lw $t2, 4($s0)
    	li $t3, -1
    	mul $t2, $t2, $t3
    	
    	addu $a0, $a0, $t2
    	li $t0, 0	# Success Counter
    	lb $t1, ($a0)
    	
    	beq $t1, $s5, UpInc1	# If byte selected is equal to opposite of player, Increment $t0
    	
    UpCheckWin1:
    
    	addu $a0, $a0, $t2
    	lb $t1, ($a0)
    	beq $t1, $s5, UpInc2	# If byte selected is equal to opposite of player, Increment $t0
    
    UpCheckWin2:
    	
    	addu $a0, $a0, $t2
    	lb $t1, ($a0)
    	beq $t1, $s3, UpInc3	# If byte selected is equal to player, Increment $t0
    	
    UpCheckWin3:
    
    	beq $t0, 3, ClearUp   # If success counter is 3, that means that up needs to be cleared
    	j Vertical_Capture_2.5
    	
    	
    	UpInc1:
    		addiu $t0, $t0, 1
    		j UpCheckWin1
    	
    	UpInc2:
    		addiu $t0, $t0, 1
    		j UpCheckWin2
    	
    	UpInc3:
    		addiu $t0, $t0, 1
    		j UpCheckWin3
    		
    
    ClearUp:  # $a0 - Board	$a1 - Row	$a2 - Col	$a3 - Player Byte
    	move $a0, $s0
    	move $a1, $s1
    	move $a2, $s2
    	move $a3, $s3
    	move $s4, $ra
    	jal goto_slot	
    	move $ra, $s4
    	move $a0, $v0	# $a0 now contains the address at the specified row and col
    	
    	lw $t2, 4($s0)
    	li $t3, -1
    	mul $t2, $t2, $t3
    	
    	addu $a0, $a0, $t2
    	lb $t0 ($a0)
    	li $t0, 46
    	sb $t0 ($a0)
    	
    	addu $a0, $a0, $t2
    	lb $t0 ($a0)
    	li $t0, 46
    	sb $t0 ($a0)
    	
    	addiu $s7, $s7, 2
    	j Vertical_Capture_2.5
    	
    	

check_diagonal_capture:
	addi $sp, $sp, -40
	sw $s0, 0($sp)		# $s0 - Board Struct Address
	sw $s1, 4($sp)		# $s1 - RowIndex
	sw $s2, 8($sp)		# $s2 - ColIndex
	sw $s3, 12($sp)		# $s3 - Player Byte
	sw $s4, 16($sp)		# $s4 - $ra Saver
	sw $s5, 20($sp)		# $s5 - Opposite of Player Byte
	sw $s6, 24($sp)		# $s6 - Check Right Boolean -> RightCheckWin
	sw $s7, 28($sp)		# $s7 - Check Left Boolean -> LeftCheckWin
	li $t0, 0			# $t0 - Check Up Boolean -> UpBooleanWin
	li $t1, 0			# $t1 - Check Down Boolean -> DownBooleanWin
						# $t2 - numRows -> Success counter
						# $t3 - numCols
						# $t9 - answer register
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	move $s4, $ra
	jal get_slot
	move $ra, $s4
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	li $v0, 0
	
	li $s6, 0
	li $s7, 0
	li $t5, 0
	sw $t9, 32($sp)
	
	bne $a3, 88, Diagonal_Capture_Check2		# If byte is not an X
	li $s5, 79	# If the byte is an X, make the opposite an O
	
	Diagonal_Capture_Part2:
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		move $s4, $ra
		jal get_slot
		move $ra, $s4
		
		bne $v0, $s3, Capture_Failed		# If the slot at the given row and col is not equal to player
		
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		move $s4, $ra
		jal goto_slot
		move $ra, $s4
		move $a0, $v0	# $a0 now contains the address at the specified row and col
		
		lb $t2, 0($s0)	# $t2 now has numRows
		lb $t3, 4($s0)	# $t3 now has numCols
		
		move $a2, $s2
		addiu $a2, $a2, 3
		blt, $a2, $t3, CheckRightBooleanTrueDiagonal	# If colIndex + 3 < numCol, checkRightBoolean = 1
		
	Diagonal_Capture_2.1:
		move $a2, $s2
		addiu $a2, $a2, -3
		bgez, $a2, CheckLeftBooleanTrueDiagonal		# If colIndex - 3 >= 0, checkLeftBoolean = 1
		
	Diagonal_Capture_2.2:
		move $a1, $s1
		addiu $a1, $a1, 3
		blt, $a1, $t2, CheckDownBooleanTrueDiagonal	# If rowIndex + 3 < numRows, checkDownBooleanTrue = 1
	
	Diagonal_Capture_2.3:
		move $a1, $s1
		addiu $a1, $a1, -3
		bgez, $a1, CheckUpBooleanTrueDiagonal	# If rowIndex - 3 > 0, checkUpBooleanTrue = 1
	
	Diagonal_Capture_2.4:
		beqz $s6, CheckAllBooleanFalse	# If all of the checkers are false, just end the program
		
	Diagonal_Capture_2.5:
		# If checkLeftBoolean is true, see if checkTopBoolean or checkBottomBoolean is true.
		beq $s7, 1 CheckLeftTopBoolean	# If they are, check the topleft or bottomleft diagonal
		
	Diagonal_Capture_2.6:
		# If checkRightBoolean is true, see if checkTopBoolean or checkBottomBoolean is true.
		beq $s6, 1 CheckRightTopBoolean	# If they are, check the topright or bottomright diagonal
	
	Diagonal_Capture_2.7:
		lw $v0, 32($sp)
		
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
			

	# All of the checking for check_diagonal_capture
	CheckRightBooleanTrueDiagonal:
		li $s6, 1
		j Diagonal_Capture_2.1

	CheckLeftBooleanTrueDiagonal:
		li $s7, 1
		j Diagonal_Capture_2.2
		
	CheckDownBooleanTrueDiagonal:
		li $t1, 1
		j Diagonal_Capture_2.3
		
	CheckUpBooleanTrueDiagonal:
		li $t0, 1
		j Diagonal_Capture_2.4
	

	Diagonal_Capture_Check2:
		bne $a3, 79, Capture_Failed		# If byte is not an O
		li $s5, 88	# If the byte is an O, make the opposite an X
    	j Diagonal_Capture_Part2
    	
    
    CheckAllBooleanFalse:
    	beqz $s7, CheckAllBooleanFalse2
    	j Diagonal_Capture_2.5
    
    CheckAllBooleanFalse2:
    	beqz $t0, CheckAllBooleanFalse3
    	j Diagonal_Capture_2.5
    
    CheckAllBooleanFalse3:
    	beqz $t1, Capture_None
    	j Diagonal_Capture_2.5
    
    
    CheckLeftTopBoolean:
    	beq $t0, 1, NorthwestCheckWin	# If CheckUpBoolean is true, check northwest to see if there is a win
    CheckLeftDownBoolean:
    	beq $t1, 1, SouthwestCheckWin	# If CheckDownBoolean is true, check southwest to see if there is a win
    	j Diagonal_Capture_2.6	# If neither CheckUpBoolean or CheckDownBoolean is true, just check the right
    
    CheckRightTopBoolean:
    	beq $t0, 1, NortheastCheckWin	# If CheckUpBoolean is true, check northeast to see if there is a win
    CheckRightDownBoolean:
    	beq $t1, 1, SoutheastCheckWin	# If CheckDownBoolean is true, check southeast to see if there is a win
    	j Diagonal_Capture_2.7	# If neither CheckUpBoolean or CheckDownBoolean is true, just check the right
    
    NorthwestCheckWin:	# $a0 - Board	$a1 - Row	$a2 - Col	$a3 - Player Byte
    	move $a0, $s0
    	move $a1, $s1
    	move $a2, $s2
    	move $a3, $s3
    	move $s4, $ra
    	jal goto_slot	
    	move $ra, $s4
    	move $a0, $v0	# $a0 now contains the address at the specified row and col
    	
    	li $t2, 0		# Success counter
    	lw $t3, 4($s0)
    	li $t4, -1
    	mul $t3, $t3, $t4
    	addu $a0, $a0, $t3	# add -(numCol) to go up a col
    	addiu $a0, $a0, -1	# add -1 to go left 1
    	
    	lb $t4, ($a0)
    	
    	beq $t4, $s5, NorthWestInc1 # If byte selected is equal to opposite of player, Increment $t2
    	
    NorthWestCheckWin1:
    
    	addu $a0, $a0, $t3
    	addiu $a0, $a0, -1
    	lb $t4, ($a0)
    	beq $t4, $s5, NorthWestInc2 # If byte selected is equal to opposite of player, Increment $t2
    
    NorthWestCheckWin2:
    	
    	addu $a0, $a0, $t3
    	addiu $a0, $a0, -1
    	lb $t4, ($a0)
    	beq $t4, $s3, NorthWestInc3 # If byte selected is equal to player byte, Increment $t2
    	
    NorthWestCheckWin3:
    
    	beq $t2, 3, ClearNorthWest	# If success counter is 3, that means that northwest needs to be cleared
    	j CheckLeftDownBoolean	# If not a success, check LeftBottomBoolean
    	
    	NorthWestInc1:
    		addiu $t2, $t2, 1
    		j NorthWestCheckWin1
    	
    	NorthWestInc2:
    		addiu $t2, $t2, 1
    		j NorthWestCheckWin2
    	
    	NorthWestInc3:
    		addiu $t2, $t2, 1
    		j NorthWestCheckWin3
    
    ClearNorthWest:  # $a0 - Board	$a1 - Row	$a2 - Col	$a3 - Player Byte
    	move $a0, $s0
    	move $a1, $s1
    	move $a2, $s2
    	move $a3, $s3
    	move $s4, $ra
    	jal goto_slot	
    	move $ra, $s4
    	move $a0, $v0	# $a0 now contains the address at the specified row and col
    	
    	lw $t3, 4($s0)
    	li $t4, -1
    	mul $t3, $t3, $t4
    	
    	addu $a0, $a0, $t3
    	addiu $a0, $a0, -1
    	
    	lb $t4 ($a0)
    	li $t4, 46
    	sb $t4 ($a0)
    	
    	addu $a0, $a0, $t3
    	addiu $a0, $a0, -1
    	
    	lb $t4 ($a0)
    	li $t4, 46
    	sb $t4 ($a0)
    	
    	lw $t5, 32($sp)
    	addiu $t5, $t5, 2
    	sw $t5, 32($sp) 
    	j CheckLeftDownBoolean
    	
    
    SouthwestCheckWin:	# $a0 - Board	$a1 - Row	$a2 - Col	$a3 - Player Byte
    	move $a0, $s0
    	move $a1, $s1
    	move $a2, $s2
    	move $a3, $s3
    	move $s4, $ra
    	jal goto_slot	
    	move $ra, $s4
    	move $a0, $v0	# $a0 now contains the address at the specified row and col
    	
    	li $t2, 0		# Success counter
    	lw $t3, 4($s0)
    	addu $a0, $a0, $t3	# add numCol to go down a col
    	addiu $a0, $a0, -1	# add -1 to go left 1
    	
    	lb $t4, ($a0)
    	
    	beq $t4, $s5, SouthWestInc1 # If byte selected is equal to opposite of player, Increment $t2
    	
    SouthWestCheckWin1:
    
    	addu $a0, $a0, $t3
    	addiu $a0, $a0, -1
    	lb $t4, ($a0)
    	beq $t4, $s5, SouthWestInc2 # If byte selected is equal to opposite of player, Increment $t2
    
    SouthWestCheckWin2:
    	
    	addu $a0, $a0, $t3
    	addiu $a0, $a0, -1
    	lb $t4, ($a0)
    	beq $t4, $s3, SouthWestInc3 # If byte selected is equal to player byte, Increment $t2
    	
    SouthWestCheckWin3:
    
    	beq $t2, 3, ClearSouthWest	# If success counter is 3, that means that southwest needs to be cleared
    	j Diagonal_Capture_2.6	# If not a success, check the right instead
    	
    	SouthWestInc1:
    		addiu $t2, $t2, 1
    		j SouthWestCheckWin1
    	
    	SouthWestInc2:
    		addiu $t2, $t2, 1
    		j SouthWestCheckWin2
    	
    	SouthWestInc3:
    		addiu $t2, $t2, 1
    		j SouthWestCheckWin3
    
    ClearSouthWest:  # $a0 - Board	$a1 - Row	$a2 - Col	$a3 - Player Byte
    	move $a0, $s0
    	move $a1, $s1
    	move $a2, $s2
    	move $a3, $s3
    	move $s4, $ra
    	jal goto_slot	
    	move $ra, $s4
    	move $a0, $v0	# $a0 now contains the address at the specified row and col
    	
    	lw $t3, 4($s0)
    	addu $a0, $a0, $t3	# add numCol to go down a col
    	addiu $a0, $a0, -1	# add -1 to go left 1
    	
    	lb $t4 ($a0)
    	li $t4, 46
    	sb $t4 ($a0)
    	
    	addu $a0, $a0, $t3
    	addiu $a0, $a0, -1
    	
    	lb $t4 ($a0)
    	li $t4, 46
    	sb $t4 ($a0)
    	
    	lw $t5, 32($sp)
    	addiu $t5, $t5, 2
    	sw $t5, 32($sp)
    	j Diagonal_Capture_2.6
    	
    
    NortheastCheckWin:	# $a0 - Board	$a1 - Row	$a2 - Col	$a3 - Player Byte
    	move $a0, $s0
    	move $a1, $s1
    	move $a2, $s2
    	move $a3, $s3
    	move $s4, $ra
    	jal goto_slot	
    	move $ra, $s4
    	move $a0, $v0	# $a0 now contains the address at the specified row and col
    	
    	li $t2, 0		# Success counter
    	lw $t3, 4($s0)
    	li $t4, -1
    	mul $t3, $t3, $t4
    	addu $a0, $a0, $t3	# add -(numCol) to go up a col
    	addiu $a0, $a0, 1	# add 1 to go right 1
    	
    	lb $t4, ($a0)
    	
    	beq $t4, $s5, NortheastInc1 # If byte selected is equal to opposite of player, Increment $t2
    	
    NortheastCheckWin1:
    
    	addu $a0, $a0, $t3
    	addiu $a0, $a0, 1
    	lb $t4, ($a0)
    	beq $t4, $s5, NortheastInc2 # If byte selected is equal to opposite of player, Increment $t2
    
    NortheastCheckWin2:
    	
    	addu $a0, $a0, $t3
    	addiu $a0, $a0, 1
    	lb $t4, ($a0)
    	beq $t4, $s3, NortheastInc3 # If byte selected is equal to player byte, Increment $t2
    	
    NortheastCheckWin3:
    
    	beq $t2, 3, ClearNortheast	# If success counter is 3, that means that northeast needs to be cleared
    	j CheckRightDownBoolean	# If not a success, check RightBottomBoolean
    	
    	NortheastInc1:
    		addiu $t2, $t2, 1
    		j NortheastCheckWin1
    	
    	NortheastInc2:
    		addiu $t2, $t2, 1
    		j NortheastCheckWin2
    	
    	NortheastInc3:
    		addiu $t2, $t2, 1
    		j NortheastCheckWin3
    
    ClearNortheast:  # $a0 - Board	$a1 - Row	$a2 - Col	$a3 - Player Byte
    	move $a0, $s0
    	move $a1, $s1
    	move $a2, $s2
    	move $a3, $s3
    	move $s4, $ra
    	jal goto_slot	
    	move $ra, $s4
    	move $a0, $v0	# $a0 now contains the address at the specified row and col
    	
    	lw $t3, 4($s0)
    	li $t4, -1
    	mul $t3, $t3, $t4
    	
    	addu $a0, $a0, $t3	# add -(numCol) to go up a col
    	addiu $a0, $a0, 1	# add 1 to go right 1
    	
    	lb $t4 ($a0)
    	li $t4, 46
    	sb $t4 ($a0)
    	
    	addu $a0, $a0, $t3
    	addiu $a0, $a0, 1
    	
    	lb $t4 ($a0)
    	li $t4, 46
    	sb $t4 ($a0)
    	
    	lw $t5, 32($sp)
    	addiu $t5, $t5, 2
    	sw $t5, 32($sp)
    	j CheckRightDownBoolean
    	
    	
    SoutheastCheckWin:	# $a0 - Board	$a1 - Row	$a2 - Col	$a3 - Player Byte
    	move $a0, $s0
    	move $a1, $s1
    	move $a2, $s2
    	move $a3, $s3
    	move $s4, $ra
    	jal goto_slot	
    	move $ra, $s4
    	move $a0, $v0	# $a0 now contains the address at the specified row and col
    	
    	li $t2, 0		# Success counter
    	lw $t3, 4($s0)
    	addu $a0, $a0, $t3	# add numCol to go up a col
    	addiu $a0, $a0, 1	# add 1 to go right 1
    	
    	lb $t4, ($a0)
    	
    	beq $t4, $s5, SoutheastInc1 # If byte selected is equal to opposite of player, Increment $t2
    	
    SoutheastCheckWin1:
    
    	addu $a0, $a0, $t3
    	addiu $a0, $a0, 1
    	lb $t4, ($a0)
    	beq $t4, $s5, SoutheastInc2 # If byte selected is equal to opposite of player, Increment $t2
    
    SoutheastCheckWin2:
    	
    	addu $a0, $a0, $t3
    	addiu $a0, $a0, 1
    	lb $t4, ($a0)
    	beq $t4, $s3, SoutheastInc3 # If byte selected is equal to player byte, Increment $t2
    	
    SoutheastCheckWin3:
    
    	beq $t2, 3, ClearSoutheast	# If success counter is 3, that means that southeast needs to be cleared
    	j Diagonal_Capture_2.7	# If not a success, end the program
    	
    	SoutheastInc1:
    		addiu $t2, $t2, 1
    		j SoutheastCheckWin1
    	
    	SoutheastInc2:
    		addiu $t2, $t2, 1
    		j SoutheastCheckWin2
    	
    	SoutheastInc3:
    		addiu $t2, $t2, 1
    		j SoutheastCheckWin3
    
    ClearSoutheast:  # $a0 - Board	$a1 - Row	$a2 - Col	$a3 - Player Byte
    	move $a0, $s0
    	move $a1, $s1
    	move $a2, $s2
    	move $a3, $s3
    	move $s4, $ra
    	jal goto_slot	
    	move $ra, $s4
    	move $a0, $v0	# $a0 now contains the address at the specified row and col
    	
    	lw $t3, 4($s0)
    	
    	addu $a0, $a0, $t3	# add numCol to go up a col
    	addiu $a0, $a0, 1	# add 1 to go right 1
    	
    	lb $t4 ($a0)
    	li $t4, 46
    	sb $t4 ($a0)
    	
    	addu $a0, $a0, $t3
    	addiu $a0, $a0, 1
    	
    	lb $t4 ($a0)
    	li $t4, 46
    	sb $t4 ($a0)
    	
    	lw $t5, 32($sp)
    	addiu $t5, $t5, 2
    	sw $t5, 32($sp)
    	j Diagonal_Capture_2.7 
    

check_horizontal_winner:
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# Board address in memory
	sw $s1, 4($sp)	# Row Value - 1
	sw $s2, 8($sp)	# Col Value
	sw $s3, 12($sp)	# num_row counter from 0
	sw $s4, 16($sp) # num_col counter from 0
	sw $s5, 20($sp)	# byte loader
	sw $s6, 24($sp) # Player byte
	sw $s7, 28($sp) # Row Value
	
	bne $a1, 88, horizontal_check_playercheck
	
check_horizonal_winner_start:
	move $s0, $a0
	lw $s7, 0($a0)
	lw $s2, 4($a0)
	move $s6, $a1
	li $s3, 0
	li $s4, 0
	addiu $s1, $s7, -1
	
	addiu $s0, $s0, 8
	lb $s5, ($s0)
	
	horizontal_win_for_col:	# Iterating through each character in row
		beq $s4, $s2, horizontal_win_for_row_update	# When i = num_col
		
		beq $s5, $s6, horizontal_win_positionright_check # If player byte is found
		
		j horizontal_win_for_col_update
	
	horizontal_win_for_col_update:
		addiu $s0, $s0, 1	# Update board address
		lb $s5, ($s0)
		addiu $s4, $s4, 1	# Increment num_col counter
		j horizontal_win_for_col
	
	horizontal_win_for_row_update:
		beq $s3, $s1, horizontal_win_notfound_done	# When i = num_row - 1
		
		#li $a0, '\n'
		#li $v0, 11
		#syscall
		
		li $s4, 0	# reset num_col counter
		addiu $s3, $s3, 1	# Increment num_row counter
		j horizontal_win_for_col  # -> Going to the next row
	

	horizontal_win_notfound_done:
		
		li $v0, -1
		li $v1, -1
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
		
	horizontal_win_positionright_check:
		move $t0, $s4
		addiu $t0, $t0, 4
		
		blt $t0, $s2, horizontal_check_right_call	# Player byte's position + 4 < num_col
		j horizontal_win_for_col_update
	
	horizontal_check_right_call:
		
		move $a0, $s0	# Move the current board address to $a0
		move $a1, $s6	# Move Player byte to $a1
		sw $ra, 32($sp)
		jal horizontal_check_right
		lw $ra, 32($sp)
		
		beq $v0, 1, horizontal_check_win_success
		j horizontal_win_for_col_update
		
	horizontal_check_playercheck:
		bne $a1, 79, horizontal_win_notfound_done
		j check_horizonal_winner_start
		
	horizontal_check_win_success:
		
		move $v0, $s3
		move $v1, $s4
		
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
		
	

check_vertical_winner:
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# Board address in memory
	sw $s1, 4($sp)	# Row Value - 1
	sw $s2, 8($sp)	# Col Value
	sw $s3, 12($sp)	# num_row counter from 0
	sw $s4, 16($sp) # num_col counter from 0
	sw $s5, 20($sp)	# byte loader
	sw $s6, 24($sp) # Player byte
	sw $s7, 28($sp) # Row Value
	
	bne $a1, 88, vertical_check_playercheck
	
check_vertical_winner_start:
	move $s0, $a0
	lw $s7, 0($a0)
	lw $s2, 4($a0)
	move $s6, $a1
	li $s3, 0
	li $s4, 0
	addiu $s1, $s7, -1
	
	addiu $a0, $a0, 8
	lb $s5, ($a0)
	 
	vertical_win_for_col:	# Iterating through each character in row
		beq $s4, $s2, vertical_win_for_row_update	# When i = num_col
		
		beq $s5, $s6, vertical_win_positionbottom_check # If player byte is found
		
		j vertical_win_for_col_update
	
	vertical_win_for_col_update:
		addiu $a0, $a0, 1	# Update board address
		lb $s5, ($a0)
		addiu $s4, $s4, 1	# Increment num_col counter
		j vertical_win_for_col
	
	vertical_win_for_row_update:
		beq $s3, $s1, vertical_win_notfound_done	# When i = num_row - 1
		
		#li $a0, '\n'
		#li $v0, 11
		#syscall
		
		li $s4, 0	# reset num_col counter
		addiu $s3, $s3, 1	# Increment num_row counter
		j vertical_win_for_col  # -> Going to the next row
	

	vertical_win_notfound_done:
		li $v0, -1
		li $v1, -1
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
		
	vertical_win_positionbottom_check:
		move $t0, $s3								# Move rowIndex to $t0
		addiu $t0, $t0, 4
		
		blt $t0, $s7, vertical_check_bottom_call	# Player byte's position + 4 < num_rows
		j vertical_win_for_col_update
	
	vertical_check_bottom_call:
		
		#move $a0, $s0	# Move the current board address to $a0
		move $a1, $s6	# Move Player byte to $a1
		move $a2, $s2	# NumCols
		sw $ra, 32($sp)
		sw $a0, 36($sp)
		jal vertical_check_down
		lw $ra, 32($sp)
		lw $a0, 36($sp)
		
		beq $v0, 1, vertical_check_win_success
		j vertical_win_for_col_update
		
	vertical_check_playercheck:
		bne $a1, 79, vertical_win_notfound_done
		j check_vertical_winner_start
		
	vertical_check_win_success:
		
		move $v0, $s3
		move $v1, $s4
		
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
    
    
    
    
    

check_sw_ne_diagonal_winner:
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# Board address in memory
	sw $s1, 4($sp)	# Row Value
	sw $s2, 8($sp)	# Col Value - 1
	sw $s3, 12($sp)	# num_row counter from 0
	sw $s4, 16($sp) # num_col counter from 0
	sw $s5, 20($sp)	# byte loader
	sw $s6, 24($sp) # Player byte
	sw $s7, 28($sp) # Col Value
	
	bne $a1, 88, swne_check_playercheck
	
check_swne_winner_start:
	move $s0, $a0
	
	
	lw $s7, 4($s0)
	lw $s1, 0($s0)
	move $s6, $a1
	li $s3, 0
	li $s4, 0
	addiu $s2, $s7, -1
	
	#lb $s5, ($a0)
	
	addiu $a0, $a0, 8
	
	swne_win_for_col:	# Iterating through each character in row
		lb $s5, ($a0)
		beq $s3, $s1, swne_win_for_row_update	# When i = num_row
		
		beq $s5, $s6, swne_win_positionne_check # If player byte is found
		
		j swne_win_for_col_update
	
	swne_win_for_col_update:
		addu $a0, $a0, $s7	# Update board address
		addiu $s3, $s3, 1	# Increment num_row counter
		j swne_win_for_col
	
	swne_win_for_row_update:
		beq $s4, $s2, swne_win_notfound_done	# When i = num_col - 1
		
		#li $a0, '\n'
		#li $v0, 11
		#syscall
		
		li $s3, 0	# reset num_row counter
		addiu $s4, $s4, 1	# Increment num_col counter
		move $a0, $s0
		addiu $a0, $a0, 8
		addu $a0, $a0, $s4
		j swne_win_for_col  # -> Going to the next col -> Don't pay attention to branch names they might be reversed
	

	swne_win_notfound_done:
		li $v0, -1
		li $v1, -1
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
		
	swne_win_positionne_check:
		move $t0, $s4
		addiu $t0, $t0, 4
		
		ble $t0, $s2, swne_check_2	# Player byte's position + 4 < num_col
		j swne_win_for_col_update
	
	swne_check_2:
		move $t0, $s3
		addiu $t0, $t0, -4			# Subtract 4 from current row
		
		bgez $t0, swne_check_ne_call	# Player byte's row - 4 >= 0
		j swne_win_for_col_update
	
	swne_check_ne_call:
		
		#move $a0, $s0	# Move the current board address to $a0
		move $a1, $s6	# Move Player byte to $a1
		move $a2, $s7	# numCols
		sw $a0, 36($sp)
		sw $ra, 32($sp)
		jal swne_check_ne
		lw $ra, 32($sp)
		lw $a0, 36($sp)
		
		beq $v0, 1, swne_check_win_success
		j swne_win_for_col_update
		
	swne_check_playercheck:
		bne $a1, 79, swne_win_notfound_done
		j check_swne_winner_start
		
	swne_check_win_success:
		
		move $v0, $s3
		move $v1, $s4
		
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
		
		
		

check_nw_se_diagonal_winner:
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# Board address in memory
	sw $s1, 4($sp)	# Row Value
	sw $s2, 8($sp)	# Col Value - 1
	sw $s3, 12($sp)	# num_row counter from 0
	sw $s4, 16($sp) # num_col counter from 0
	sw $s5, 20($sp)	# byte loader
	sw $s6, 24($sp) # Player byte
	sw $s7, 28($sp) # Col Value
	
	bne $a1, 88, nwse_check_playercheck
	
check_nwse_winner_start:
	move $s0, $a0
	
	lw $s7, 4($s0)
	lw $s1, 0($s0)
	move $s6, $a1
	li $s3, 0
	li $s4, 0
	addiu $s2, $s7, -1
	
	#lb $s5, ($a0)
	addiu $a0, $a0, 8
	
	nwse_win_for_col:	# Iterating through each character in row
		lb $s5, ($a0)
		beq $s3, $s1, nwse_win_for_row_update	# When i = num_row
		
		beq $s5, $s6, nwse_win_positionse_check # If player byte is found
		
		j nwse_win_for_col_update
	
	nwse_win_for_col_update:
		addu $a0, $a0, $s7	# Update board address
		addiu $s3, $s3, 1	# Increment num_row counter
		j nwse_win_for_col
	
	nwse_win_for_row_update:
		beq $s4, $s2, nwse_win_notfound_done	# When i = num_col - 1
		
		#li $a0, '\n'
		#li $v0, 11
		#syscall
		
		li $s3, 0	# reset num_row counter
		addiu $s4, $s4, 1	# Increment num_col counter
		move $a0, $s0
		addiu $a0, $a0, 8
		addu $a0, $a0, $s4
		j nwse_win_for_col  # -> Going to the next col -> Don't pay attention to branch names they might be reversed
	

	nwse_win_notfound_done:
		
		li $v0, -1
		li $v1, -1
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
		
	nwse_win_positionse_check:
		move $t0, $s4
		addiu $t0, $t0, 4
		
		blt $t0, $s7, nwse_check_2	# Player byte's position + 4 < num_col
		j nwse_win_for_col_update
	
	nwse_check_2:
		move $t0, $s3
		addiu $t0, $t0, 4			# Add 4 from current row
		
		blt $t0, $s1 nwse_check_se_call	# Player byte's row + 4 < num_rows
		j nwse_win_for_col_update
	
	nwse_check_se_call:
		
		#move $a0, $s0	# Move the current board address to $a0
		move $a1, $s6	# Move Player byte to $a1
		move $a2, $s7	# numCols
		sw $a0, 36($sp)
		sw $ra, 32($sp)
		jal nwse_check_se
		lw $ra, 32($sp)
		lw $a0, 36($sp)
		
		beq $v0, 1, nwse_check_win_success
		j nwse_win_for_col_update
		
	nwse_check_playercheck:
		bne $a1, 79, nwse_win_notfound_done
		j check_nwse_winner_start
		
	nwse_check_win_success:
		
		move $v0, $s3
		move $v1, $s4
		
		addi $sp, $sp, 40
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		jr $ra


simulate_game:
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# $s0 - Starting of board address
	sw $s1, 4($sp)	# $s1 - Filename -> Player, Row, Col
	sw $s2, 8($sp)	# $s2 - Turns (The null terminated string encoding) address
	sw $s3, 12($sp)	# $s3 - Num_Turns_To_Play
	sw $s4, 16($sp) # $s4 - Game_Over
	sw $s5, 20($sp)	# $s5 - Turns_Length
	sw $s6, 24($sp) # $s6 - Valid_Num_Term
	sw $s7, 28($sp) # $s7 - Turn_Number
	move $t8, $a2	# $t8 - Turns address to modify
	li $t7, 0 		# $t7 - Turns byte selector
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	sw $ra, 32($sp)
	jal load_board
	lw $ra, 32($sp)
	beq $v0, -1, simulate_game_load_board_failed	# If load_board failed
	
	li $s4, 0	# Game_Over is now false
	li $s6, 0	# Valid Num_Terms
	li $s7, 0	# Turn_Number
	
	move $a0, $s2
	sw $ra, 32($sp)
	jal turns_length
	lw $ra, 32($sp)
	move $s5, $v0
	
	li $t0, 5
	div $s5, $t0
	mflo $s5	# $s5 has the turns_length
	
	simulate_game_while:
		beqz $s4, valid_num_turnsLESSnum_turns_to_play_CHECK	# If Game_Over is false
		j end_simulate_game
		
	simulate_game_while1.1:	
		j extract_from_turn	# Takes in $t8, Result = ($s1) - Row, 4($s1) - Col, 8($s1) - Player Byte
	
	simulate_game_while1.2:
		move $a0, $s0	# Board
		lw $a1, 4($s1)	# Row
		lw $a2, 8($s1)	# Col
		lw $a3, 0($s1)	# Player
		sw $ra, 32($sp)
		sw $t8, 36($sp)
		jal place_piece
		lw $t8, 36($sp)
		lw $ra, 32($sp)
		
		addiu $t8, $t8, 5	# Increment Strings address
		addiu $s7, $s7, 1	# Increment Turn_Number
		
		beq $v0, -1, simulate_game_while	# If we cannot place a piece due to invalid player, etc, skip the turn
		
		addiu $s6, $s6, 1	# Increment Valid_Num_Turns
		
		move $a0, $s0	# Board
		lw $a1, 4($s1)	# Row
		lw $a2, 8($s1)	# Col
		lw $a3, 0($s1)	# Player
		sw $ra, 32($sp)
		sw $t8, 36($sp)
		jal check_horizontal_capture
		lw $t8, 36($sp)
		lw $ra, 32($sp)
		
		move $a0, $s0	# Board
		lw $a1, 4($s1)	# Row
		lw $a2, 8($s1)	# Col
		lw $a3, 0($s1)	# Player
		sw $ra, 32($sp)
		sw $t8, 36($sp)
		jal check_vertical_capture
		lw $t8, 36($sp)
		lw $ra, 32($sp)
		
		move $a0, $s0	# Board
		lw $a1, 4($s1)	# Row
		lw $a2, 8($s1)	# Col
		lw $a3, 0($s1)	# Player
		sw $ra, 32($sp)
		sw $t8, 36($sp)
		jal check_diagonal_capture
		lw $t8, 36($sp)
		lw $ra, 32($sp)
		
		move $a0, $s0	# Board
		lw $a1, 0($s1)	# Player
		sw $ra, 32($sp)
		sw $t8, 36($sp)
		jal check_horizontal_winner
		lw $t8, 36($sp)
		lw $ra, 32($sp)
		bgtz $v0, record_winner
		
		move $a0, $s0	# Board
		lw $a1, 0($s1)	# Player
		sw $ra, 32($sp)
		sw $t8, 36($sp)
		jal check_vertical_winner
		lw $t8, 36($sp)
		lw $ra, 32($sp)
		bgtz $v0, record_winner
		
		move $a0, $s0	# Board
		lw $a1, 0($s1)	# Player
		sw $ra, 32($sp)
		sw $t8, 36($sp)
		jal check_sw_ne_diagonal_winner
		lw $t8, 36($sp)
		lw $ra, 32($sp)
		bgtz $v0, record_winner
		
		move $a0, $s0	# Board
		lw $a1, 0($s1)	# Player
		sw $ra, 32($sp)
		sw $t8, 36($sp)
		jal check_nw_se_diagonal_winner
		lw $t8, 36($sp)
		lw $ra, 32($sp)
		bgtz $v0, record_winner
		
		move $a0, $s0	# Board
		sw $ra, 32($sp)
		sw $t8, 36($sp)
		jal game_status
		lw $t8, 36($sp)
		lw $ra, 32($sp)
		
		addu $v0, $v0, $v1	# $r1 + $r2
		lw $t6, 0($s0)
		lw $t7, 4($s0)
		mul $t6, $t6, $t7	# Total number of slots in board
		
		beq $v0, $t6, tie_game
		j simulate_game_while
		
		
		
		
		
	
	
	
	# All of the checking
	valid_num_turnsLESSnum_turns_to_play_CHECK:
		blt $s6, $s3, turn_numberLESSturns_length_CHECK
		j tie_game
	
	turn_numberLESSturns_length_CHECK:
		blt $s7, $s5, simulate_game_while1.1
		j tie_game
	
	extract_from_turn:
		lb $t0, 0($t8)
		sw $t0, 0($s1)	# Player is stored in 0($s1)
		
		lb $t0, 1($t8)
		lb $t1, 2($t8)
		
		addiu $t0, $t0, -48
		addiu $t1, $t1, -48
		li $t3, 10
		mul $t0, $t0, $t3
		
		addu $t0, $t0, $t1
		sw $t0, 4($s1)	# Row int value is stored in 4($s1)
		
		lb $t0, 3($t8)
		lb $t1, 4($t8)
		
		addiu $t0, $t0, -48
		addiu $t1, $t1, -48
		li $t3, 10
		mul $t0, $t0, $t3
		
		addu $t0, $t0, $t1
		sw $t0, 8($s1)	# Col int value is stored in 8($s1)
		
		j simulate_game_while1.2
		
	record_winner:
		li $s4, 1	# Game_Over is now true
		move $v1, $a1
		j end_simulate_game
		
		
		
	tie_game:
		move $v0, $s6
		li $v1, -1
		
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
		
		
	
	
	end_simulate_game:
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

	simulate_game_load_board_failed:
		li $v0, 0
		li $v1, -1
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

# Helper Functions
print_board:	# Takes arguments $a0 - board, $a1 - row address, $a2 - col address
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# Board address in memory
	sw $s1, 4($sp)	# Row Value
	sw $s2, 8($sp)	# Col Value
	sw $s3, 12($sp)	# num_row counter from 0
	sw $s4, 16($sp) # col_row counter from 0
	sw $s5, 20($sp)	# byte loader
	#sw $s6, 24($sp)	# \n holder
	
	move $s0, $a0
	addiu $s0, $s0, 8
	lw $s1, 0($a0)
	lw $s2, 4($a0)
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
		addi $sp, $sp, 40
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		#lw $s6, 24($sp)
		jr $ra
	
	
	



load_row_col_board:	# Takes in $a0 the starting address of the board, returns rows in $v0, col in $v1
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# Stores starting address of board from $a0
	sw $s1, 4($sp)	# Starting address of board to modify
	sw $s2, 8($sp)	# Address selector of $s1
	sw $s3, 12($sp)	# Not sure but used it somewhere
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
		beq $s4, 2, load_row_col_done		# If \n counter hits 2
		addiu $s3, $s3, 1
		beq $s2, 10, load_row_col_foundnewline	# If selector hits a \n
	
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
		sw $s3, 40($sp)
	
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		addi $sp, $sp, 40
		jr $ra
	

load_board_struct:
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# Stores starting address of board in memory + 8
	sw $s1, 4($sp)	# Starting address of board from file
	sw $s2, 8($sp)	# (Rows * Columns + Rows) from $a2
	sw $s3, 12($sp)	# Address selector of board in memory from $s0
	sw $s4, 16($sp)	# Address selector of board from file in $s1
	sw $s5, 20($sp) # Number of X's
	sw $s6, 24($sp)	# Number of O's
	sw $s7, 28($sp)	# Number of Invalid Characters
	
	move $s0, $a0
	addiu $s0, $s0, 8
	move $s1, $a1
	move $s2, $a2
	li $s5, 0
	li $s6, 0
	li $s7, 0
	li $t0, 0		# Counter until $s2
	
	lb $s3, ($s0)
	lb $s4, ($s1)

	load_board_struct_for:
		beq $t0, $s2, load_board_struct_done	# If we reach the end of the board $t0 < $s2
	
		beq $s4, 88, X_Found			# If X is found on the file board
		beq $s4, 79, O_Found			# If O is found on the file board
		beq $s4, 46, ._Found			# If . is found on the file board
		beq $s4, 10, newline_Found		# If \n is found on the file board
	
		j invalid_Found

	X_Found:
		sb $s4, ($s0)		# Store X in struct
		addiu $s1, $s1, 1	# Update struct address
		addiu $s0, $s0, 1	# Update board address from file
		addiu $s5, $s5, 1	# Increment X Counter
		addiu $t0, $t0, 1	# Increment for loop counter
		lb $s3, ($s0)
		lb $s4, ($s1)
		j load_board_struct_for
	
	O_Found:
		sb $s4, ($s0)		# Store O in struct
		addiu $s1, $s1, 1	# Update struct address
		addiu $s0, $s0, 1	# Update board address from file
		addiu $s6, $s6, 1	# Increment O Counter
		addiu $t0, $t0, 1	# Increment for loop counter
		lb $s3, ($s0)
		lb $s4, ($s1)
		j load_board_struct_for

	._Found:
		sb $s4, ($s0)		# Store . in struct
		addiu $s1, $s1, 1	# Update struct address
		addiu $s0, $s0, 1	# Update board address from file
		addiu $t0, $t0, 1	# Increment for loop counter
		lb $s3, ($s0)
		lb $s4, ($s1)
		j load_board_struct_for

	newline_Found:
		addiu $s1, $s1, 1
		addiu $t0, $t0, 1
		lb $s3, ($s0)
		lb $s4, ($s1)
		j load_board_struct_for

	invalid_Found:
		li $t1, 46
		sb $t1, ($s0)
		addiu $s1, $s1, 1	# Update struct address
		addiu $s0, $s0, 1	# Update board address from file
		addiu $t0, $t0, 1	# Increment for loop counter
		addiu $s7, $s7, 1	# Increment invalid counte register
		lb $s3, ($s0)
		lb $s4, ($s1)
		j load_board_struct_for

	load_board_struct_done:	
		move $v0, $s5
		sll $v0, $v0, 8
		or $v0, $v0, $s6
		sll $v0, $v0, 8
		or $v0, $v0, $s7	# $v0 now has the answer as an unsigned  binary number
	
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		addi $sp, $sp, 40
		jr $ra

# Very similar to get_slot except $v0  now has the address pointing to the rowIndex and colIndex in the board struct
goto_slot:	# $a0 - board, $a1 - rowIndex, $a2 - colIndex
	addi $sp, $sp, -40
	sw $s0, 0($sp)		# $s0 - Original Board struct address
	sw $s1, 4($sp)		# $s1 - RowIndex (Row to search for)
	sw $s2, 8($sp)		# $s2 - ColIndex (Column to search for)
	sw $s3, 12($sp)		# $s3 - Row
	sw $s4, 16($sp)		# $s4 - Columns
	sw $s5, 20($sp)		# $s5 - Byte selector for Board Struct
	sw $s6, 24($sp)		# $s6 - offset to add to Board adress
    
    move $s0, $a0
    addiu $s0, $s0, 8
    move $s1, $a1
    move $s2, $a2
    lw $s3, 0($a0)
    lw $s4, 4($a0)
    
    blt $s1, $zero, get_slot_failed		# Error handling
    bge $s1, $s3, get_slot_failed
    blt $s2, $zero, get_slot_failed
    bge $s2, $s4, get_slot_failed
    
    mult $s1, $s4	# Multiply rowIndex by Columns
    mflo $s6
    addu $s6, $s6, $s2		# Add ColIndex
    
    addu $s0, $s6, $s0
    move $v0, $s0
    
    lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	addi $sp, $sp, 40
    jr $ra
    


horizontal_check_right: # $a0 - board address pointing to current cell to check		$a1 - Player byte	$v0 - If success is found or not
	addi $sp, $sp, -20
	sw $s0, ($sp)	# $s0 - board address
	sw $s1, 4($sp)	# $s1 - player byte
	sw $s2, 8($sp)	# $s2 - Success counter
	sw $s3, 12($sp) # $s3 - Byte selector
	
	move $s0, $a0
	move $s1, $a1
	li $s2, 0
	
	addiu $a0, $a0, 1
	lb $s3, ($a0)
	beq $s3, $s1, horizontal_check_success_inc1
	
horizontal_check_right1.1:
	addiu $a0, $a0, 1
	lb $s3, ($a0)
	beq $s3, $s1, horizontal_check_success_inc2

horizontal_check_right1.2:
	addiu $a0, $a0, 1
	lb $s3, ($a0)
	beq $s3, $s1, horizontal_check_success_inc3
	
horizontal_check_right1.3:
	addiu $a0, $a0, 1
	lb $s3, ($a0)
	beq $s3, $s1, horizontal_check_success_inc4
	
horizontal_check_right1.4:
	beq $s2, 4, horizontal_check_right_found
	
	li $v0, 0		# Else just end the function
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 20
	jr $ra

horizontal_check_right_found:
	li $v0, 1		
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 20
	jr $ra
	
		
		horizontal_check_success_inc1:
			addiu $s2, $s2, 1
			j horizontal_check_right1.1
		
		horizontal_check_success_inc2:
			addiu $s2, $s2, 1
			j horizontal_check_right1.2
		
		horizontal_check_success_inc3:
			addiu $s2, $s2, 1
			j horizontal_check_right1.3
			
		horizontal_check_success_inc4:
			addiu $s2, $s2, 1
			j horizontal_check_right1.4
			
			


vertical_check_down: # $a0 - board address pointing to current cell to check		$a1 - Player byte	$a2 - numCols $v0 - If success is found or not
	addi $sp, $sp, -20
	sw $s0, ($sp)	# $s0 - board address
	sw $s1, 4($sp)	# $s1 - player byte
	sw $s2, 8($sp)	# $s2 - Success counter
	sw $s3, 12($sp) # $s3 - Byte selector
	
	move $s0, $a0
	move $s1, $a1
	li $s2, 0
	
	addu $a0, $a0, $a2
	lb $s3, ($a0)
	beq $s3, $s1, vertical_check_success_inc1
	
vertical_check_right1.1:
	addu $a0, $a0, $a2
	lb $s3, ($a0)
	beq $s3, $s1, vertical_check_success_inc2

vertical_check_right1.2:
	addu $a0, $a0, $a2
	lb $s3, ($a0)
	beq $s3, $s1, vertical_check_success_inc3
	
vertical_check_right1.3:
	addu $a0, $a0, $a2
	lb $s3, ($a0)
	beq $s3, $s1, vertical_check_success_inc4
	
vertical_check_right1.4:
	beq $s2, 4, vertical_check_right_found
	
	li $v0, 0		# Else just end the function
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 20
	jr $ra

vertical_check_right_found:
	li $v0, 1	
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 20
	jr $ra
	
		
		vertical_check_success_inc1:
			addiu $s2, $s2, 1
			j vertical_check_right1.1
		
		vertical_check_success_inc2:
			addiu $s2, $s2, 1
			j vertical_check_right1.2
		
		vertical_check_success_inc3:
			addiu $s2, $s2, 1
			j vertical_check_right1.3
			
		vertical_check_success_inc4:
			addiu $s2, $s2, 1
			j vertical_check_right1.4


swne_check_ne: # $a0 - board address pointing to current cell to check		$a1 - Player byte	$a2 - numCols $v0 - If success is found or not
	addi $sp, $sp, -20
	sw $s0, ($sp)	# $s0 - board address
	sw $s1, 4($sp)	# $s1 - player byte
	sw $s2, 8($sp)	# $s2 - Success counter
	sw $s3, 12($sp) # $s3 - Byte selector
	
	move $s0, $a0
	move $s1, $a1
	li $s2, 0
	
	li $t0, -1
	mul $a2, $a2, $t0
	
	addu $a0, $a0, $a2
	addiu $a0, $a0, 1
	lb $s3, ($a0)
	beq $s3, $s1, swne_check_ne_inc1
	
swne_check_ne1.1:
	addu $a0, $a0, $a2
	addiu $a0, $a0, 1
	lb $s3, ($a0)
	beq $s3, $s1, swne_check_ne_inc2

swne_check_ne1.2:
	addu $a0, $a0, $a2
	addiu $a0, $a0, 1
	lb $s3, ($a0)
	beq $s3, $s1, swne_check_ne_inc3
	
swne_check_ne1.3:
	addu $a0, $a0, $a2
	addiu $a0, $a0, 1
	lb $s3, ($a0)
	beq $s3, $s1, swne_check_ne_inc4
	
swne_check_ne1.4:
	beq $s2, 4, swne_check_ne_found
	
	li $v0, 0		# Else just end the function
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 20
	jr $ra

swne_check_ne_found:
	li $v0, 1	
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 20
	jr $ra
	
		
		swne_check_ne_inc1:
			addiu $s2, $s2, 1
			j swne_check_ne1.1
		
		swne_check_ne_inc2:
			addiu $s2, $s2, 1
			j swne_check_ne1.2
		
		swne_check_ne_inc3:
			addiu $s2, $s2, 1
			j swne_check_ne1.3
			
		swne_check_ne_inc4:
			addiu $s2, $s2, 1
			j swne_check_ne1.4


nwse_check_se: # $a0 - board address pointing to current cell to check		$a1 - Player byte	$a2 - numCols $v0 - If success is found or not
	addi $sp, $sp, -20
	sw $s0, ($sp)	# $s0 - board address
	sw $s1, 4($sp)	# $s1 - player byte
	sw $s2, 8($sp)	# $s2 - Success counter
	sw $s3, 12($sp) # $s3 - Byte selector
	
	move $s0, $a0
	move $s1, $a1
	li $s2, 0
	
	addu $a0, $a0, $a2
	addiu $a0, $a0, 1
	lb $s3, ($a0)
	beq $s3, $s1, nwse_check_se_inc1
	
nwse_check_se1.1:
	addu $a0, $a0, $a2
	addiu $a0, $a0, 1
	lb $s3, ($a0)
	beq $s3, $s1, nwse_check_se_inc2

nwse_check_se1.2:
	addu $a0, $a0, $a2
	addiu $a0, $a0, 1
	lb $s3, ($a0)
	beq $s3, $s1, nwse_check_se_inc3
	
nwse_check_se1.3:
	addu $a0, $a0, $a2
	addiu $a0, $a0, 1
	lb $s3, ($a0)
	beq $s3, $s1, nwse_check_se_inc4
	
nwse_check_se1.4:
	beq $s2, 4, nwse_check_se_found
	
	li $v0, 0		# Else just end the function
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 20
	jr $ra

nwse_check_se_found:
	li $v0, 1	
	lw $s0, ($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 20
	jr $ra
	
		
		nwse_check_se_inc1:
			addiu $s2, $s2, 1
			j nwse_check_se1.1
		
		nwse_check_se_inc2:
			addiu $s2, $s2, 1
			j nwse_check_se1.2
		
		nwse_check_se_inc3:
			addiu $s2, $s2, 1
			j nwse_check_se1.3
			
		nwse_check_se_inc4:
			addiu $s2, $s2, 1
			j nwse_check_se1.4


turns_length:	# $a0 - turns string
	
	li $t0, 0
	lb $t1, ($a0)
	
	turns_length_while:
		beq $t1, $zero, turns_length_done
	
	
	turns_length_update:
		addiu $t0, $t0, 1
		addiu $a0, $a0, 1
		lb $t1, ($a0)
		j turns_length_while
	
	turns_length_done:
		move $v0, $t0
		jr $ra
	
	
	
			
 
	



	
	




