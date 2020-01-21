# Ammar Chishti
# achishti
# 111717583

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text
to_lowercase:
	
	move $t0, $a0    #$t0 now contains the str address
	li $t3, 0	 #Counter to store number of letters converted to lower case
	
	lb $t1, 0($t0)   #While Loop start case, beginning of String
	j whileLoop_to_lowercase
	
	whileLoop_to_lowercase:
	    beqz $t1, to_lowercase_done    #End Case. If character is null, end loop.
		
	    #If a character is not a Capital Letter, pass
    	blt $t1, 64, to_lowercase_pass
    	bgt $t1, 91, to_lowercase_pass
    	    
    	#Else, add 32 to ascii value, increment $v0 by 1, store
    	addiu $t1, $t1, 32
    	addiu, $t3, $t3, 1
    	sb $t1, 0($t0)
    	    
    	#Select next character and repeat the loop
    	addiu $t0, $t0, 1
    	lb $t1, 0($t0)
    	j whileLoop_to_lowercase
	
	to_lowercase_pass:
	    #Select next character and repeat the loop
	    addiu $t0, $t0, 1
	    lb $t1, 0($t0)
	    j whileLoop_to_lowercase
	
	to_lowercase_done:
	    move $v0, $t3
	    jr $ra


strlen:

	move $t0, $a0	#$t0 now contains the str address
	li $t3, 0		#Counter to store the length of the Srring
	
	lb $t1, 0($t0)   #While Loop start case, beginning of String
	j whileLoop_strlen
	
	whileLoop_strlen:
		beqz $t1, strlen_done    #End Case. If character is null, end loop.
	    
		addiu $t3, $t3, 1	     #Add one to the length register

		addiu $t0, $t0, 1	     #Update the loop
		lb $t1, 0($t0)
		j whileLoop_strlen
	
	strlen_done:
	    move $v0, $t3
	    jr $ra
	

count_letters:
    move $t0, $a0	#$t0 now contains the str address
	li $t3, 0	 	#Counter to store number of letters
	
	lb $t1, 0($t0)   #While Loop start case, beginning of String
	j whileLoop_count_letters
	
	whileLoop_count_letters:
	    beqz $t1, to_lowercase_done    # End Case. If character is null, end loop.
		blt $a2, 9, encode_EndOfMessage # If ab length is less than 9, append 5 b's and end program
		
	    #If a character is not a Letter, pass
    	blt $t1, 64, count_letters_pass
    	bgt $t1, 123, count_letters_pass
    	
    	blt $t1, 91, count_letters_increment
    	bgt $t1, 96, count_letters_increment
    	    
    	#Select next character and repeat the loop
    	addiu $t0, $t0, 1
    	lb $t1, 0($t0)
    	j whileLoop_count_letters
    
    count_letters_increment:
    	addiu $t3, $t3, 1
	
	count_letters_pass:
	    #Select next character and repeat the loop
	    addiu $t0, $t0, 1
	    lb $t1, 0($t0)
	    j whileLoop_count_letters
	
	count_letters_done:
	    move $v0, $t3
	    jr $ra


encode_plaintext:
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal strlen
	lw $ra, ($sp)
	addi $sp, $sp, 4
	move $fp, $v0
	
	li $t8, 0		#$t8 Register to access bacon code characters
	move $t7, $a1	#Address of ab_text
	li $t6, 0		#$t6 Register to access ab_text characters
	move $t5, $a0	#Address of plaintext
	li $t4, 0		#$t4 Register to access the plaintext
	
	li $v0, 0		#Zero out the answer registers
	li $v1, 0
	
	lb $t4, 0($t5)
	
	blt $a2, 5, only_Done	#return without making any changes right before return
	
	j encode_WhileLoop
	
	encode_WhileLoop:
		ble $a2, 9, encode_EndOfMessage # If ab length is less than or equal to 9, append 5 b's
		beq $fp, $zero, encode_EndOfMessage  
		beqz $t4, encode_Complete	# Only called when the entire plaintext was successfully encoded	
		
		#If a character is a space
		beq $t4, 32, encode_Space_Initializer
		
		#If a character is an exclamation mark
		beq $t4, 33, encode_Exclamation_Initializer
		
		#If a character is a single quotation
		beq $t4, 39, encode_SingleQuote_Initializer
		
		#If a character is a comma
		beq $t4, 44, encode_Comma_Initializer
		
		#If a character is a period
		beq $t4, 46, encode_Period_Initializer
		
		#If a character is not a lowercase letter, pass
    	blt $t4, 97, encode_Pass
    	bgt $t4, 122, encode_Pass
    		
    	move $t0, $t4	#$t0 is the result of the subtract and multiply operation, lower bound of the for loop
    	addi $t0, $t0, -97
    	
    	li $t3, 5		#$t3 now only holds the value 5
    	mul $t0, $t0, $t3
    	
    	li $t1, 0
    	addi $t1, $t0, 5	#t1 is the upper bound of the for loop
    	
    	j encode_ForLoop #Call this when lower and upper bound ($t0 and $t1) are initialized and ready
    	
    								
					
    encode_WhileLoop_End:
    
        addiu $v0, $v0, 1	#If the while loop went through, a character was successfully encoded as a 5 letter code
        
        ble $a2, 9, encode_EndOfMessage # If ab length is less than or equal to 9, append 5 b's
        
    	#Select next character and repeat the loop
    	addiu $t5, $t5, 1
    	lb $t4, 0($t5)
    	j encode_WhileLoop
    	
    encode_ForLoop:
    	beq $t0, $t1, encode_WhileLoop_End    #If the lower and upper are equal, exit
    	move $t9, $a3	#Address of bacon codes. This needs to go in the for loop to reset
    	add $t9, $t9, $t0	#$t9 is now at Bacon_code position $t0
    	
    	lb $t8 ($t9)	#$t8 now holds the correct letter character
    		
    	#move $a0, $t8
    	#li $v0, 11
    	#syscall
    		
    	move $t6, $t8	#Store the correct letter into the position of ab_text
    	sb $t6, ($t7)
    	addiu $t7, $t7, 1
    	
    	addiu $a2, $a2, -1	#Decrease the length of ab by 1
    		
    	addi $t0, $t0, 1 #Add 1 to lower bound
    	addi $t9, $t9, 1 #Add 1 to bacon codes array
    	j encode_ForLoop
    		
    		
    encode_Space_Initializer:
    	li $t0, 130
    	li $t1, 135
    	j encode_ForLoop
    
    encode_Exclamation_Initializer:
    	li $t0, 135
    	li $t1, 140
    	j encode_ForLoop
    	
    encode_SingleQuote_Initializer:
    	li $t0, 140
    	li $t1, 145
    	j encode_ForLoop
    	
    encode_Comma_Initializer:
    	li $t0, 145
    	li $t1, 150
    	j encode_ForLoop
    	
    encode_Period_Initializer:
    	li $t0, 150
    	li $t1, 155
    	j encode_ForLoop
    		
    	
    	
    encode_Pass:
		#Select next character and repeat the loop
		addiu $t5, $t5, 1
		lb $t4, 0($t5)
		j encode_WhileLoop
	
	encode_EndOfMessage:
		li $fp, 0
		li $t2, 'B'
		sb $t2 ($t7)
		
		addiu $t7, $t7, 1
		sb $t2 ($t7)
		
		addiu $t7, $t7, 1
		sb $t2 ($t7)
		
		addiu $t7, $t7, 1
		sb $t2 ($t7)
		
		addiu $t7, $t7, 1
		sb $t2 ($t7)
		
		beq $t4, $zero, encode_Complete
		addiu $t5, $t5, 1	#Increment Plaintext, if the next value is null, increment
    	lb $t4, 0($t5)
    	beqz $t4, encode_Complete

		jr $ra
		
	only_Done:
		jr $ra		
	
	encode_Complete: # Only called when the entire plaintext was successfully encoded	
		addi $v1, $v1, 1 
	    jr $ra
	
	
encrypt:
	
	#Loading (size of String of plaintext * -1) into $t8
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal strlen
	lw $ra ($sp)
	addi $sp, $sp, 4
	
	#move $t8, $v0		# Plaintext length is initially in $v0
	addi $sp, $sp -4	# Storing plaintext length onto stack
	sb $v0, ($sp)
	addi $sp, $sp, 4
	li $t0, -1
	mul $t8, $t8, $t0
	li $t0, 0
	
	#Loading the lowercase plaintext into $t9
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal to_lowercase
	lw $ra ($sp)
	addi $sp, $sp, 4
	move $t9, $t0
	li $t0, 0
	add $t9, $t9, $t8
	li $t8, 0
	
	move $fp, $a1	# Move ciphertext to $fp
	
	move $a1, $a2	# Move ab_text to $a1
	move $a2, $a3	# Move ab_text_length to $a2
	lw $a3, ($sp)	# Move bacon_codes to $a3
	
	#Call encode_plaintext and store ab_text in $t7
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal encode_plaintext
	lw $ra ($sp)
	addi $sp, $sp, 4
	la $t7, ab_text
	
	move $t9, $fp	# Move ciphertext (in $fp) to $t9
	move $t8, $t7	# Move ab_text in $t7 to $t8
	li $fp, 0
	
	li $t1, 0		#N register
	lbu $t7, ($t9)	#$t7 is the register that accesses ciphertext	
	j encrypt_while
	
	encrypt_while:
		lb $t6, ($t8)
		beqz $t7, encrypt_done
		beqz $t6, encrypt_done
		
		#li $v0 11
		#move $a0, $t6
		#syscall
		
		# If a character is not a letter, pass
		blt $t7, 65, encrypt_while_end
		bgt $t7, 122, encrypt_while_end
		
		blt $t7, 91, encrypt_uppercase_check # If the letter is a lowercase
		bgt $t7, 96, encrypt_lowercase_check # If the letter is an uppercase
		j encrypt_while_end
		
		encrypt_uppercase_check:
			#lb $t6, ($t8)
			
			beq $t6, 65, encrypt_uppercase_A	# If the ab_text value is an 'A'
			beq $t6, 66, encrypt_uppercase_B	# If the ab_text value is a 'B'
		
			addi $t8, $t8, 1	#Increment AB_Text
			j encrypt_while_end
		
		encrypt_lowercase_check:
			#lb $t6, ($t8)
			
			beq $t6, 65, encrypt_lowercase_A	# If the ab_text value is an 'A'
			beq $t6, 66, encrypt_lowercase_B	# If the ab_text value is a 'B'
			
			addi $t8, $t8, 1	#Increment AB_Text
			j encrypt_while_end
	
	
	
	encrypt_uppercase_A:	#make lowercase, increment both registers
		
		addi $t7, $t7, 32
		sb $t7, ($t9)		#Store it back into ciphertext
		addi $t1, $t1, 1	#Increment N register by 1
		addi $t8, $t8, 1	#Increment AB_Text
		j encrypt_while_end
		
	encrypt_uppercase_B:	#Increment both registers
		
		addi $t1, $t1, 1	#Increment N register by 1
		addi $t8, $t8, 1	#Increment AB_Text
		j encrypt_while_end
	
	encrypt_lowercase_A:
	
		addi $t1, $t1, 1	#Increment N register by 1
		addi $t8, $t8, 1	#Increment AB_Text
		j encrypt_while_end
	
	encrypt_lowercase_B:
	
		addi $t7, $t7, -32
		sb $t7, ($t9)	#Store it back into ciphertext
		addi $t1, $t1, 1	#Increment N register by 1
		addi $t8, $t8, 1	#Increment AB_Text
		j encrypt_while_end	
	
	
	encrypt_while_end:
		addiu $t9, $t9, 1
    	lb $t7, 0($t9)
    	j encrypt_while
		
	add1:
		li $v1, 1
		j done
		#jr $ra
		
		
	encrypt_done:
		#li $v0, 0
		#li $v1, 0
		li $t0, 0
	
		
		lb $t0 ($sp)
		addi $sp, $sp, 4
		
		li $t2, 5
		mul $t0, $t0, $t2
		addi $t0, $t0, 5	#$t0 now contains the (5 * length) + 5 value
		
		move $v0, $t1
		beq $t0, $t1, add1 
		j done
	
	done:
    	jr $ra
	
	
decode_ciphertext:
	
	move $t9, $a0 # Move ciphertext to $t9
	li $t8, 0	  # $t8 is the iterator of $t9
	lb $t8, ($t9)
	
	move $t7, $a1 # Move ab_text to $t7
	li $t6, 0	  # $t6 is the iterator of $t6
	lb $t6, ($t7)
	
	addi $sp, $sp, -4
	sw $ra ($sp)
	jal count_letters
	lw $ra ($sp)
	addi $sp, $sp 4
	 
	move $t5, $v0	# Move letter count of ciphertext to $t5
	li $v0, 0		# $v0 is now the register that will hold the answer (return value)
	
	bgt $t5, $a2, decode_failed
	blt $t5, 5, decode_failed
	
	li $t0, 0	# Counter for For loop to check if it's done or not
	li $t1, 0	# Counter to check for every 5 letters
	li $t2, 0	# Counter to check if there are 5 B's
	li $t3, 0	# Register where A or B is loaded to store into AB_Text
	j decode_for
	
	decode_for:
		beq $t0, $t5, decode_done
		
		# If a letter is not a character, pass
		blt $t8, 65, decode_for_non_letter_update
		bgt $t8, 122, decode_for_non_letter_update
		
		blt $t8, 91, decode_uppercase # If the letter is a lowercase
		bgt $t8, 96, decode_lowercase # If the letter is an uppercase
		j decode_for
		
	decode_for_non_letter_update:
		addi $t9, $t9, 1 # Increment ciphertext by one
		lb $t8, ($t9)
		j decode_for
	
	decode_lowercase:
		li $t3, 'A'
		sb $t3, ($t7)
		addi $t1, $t1, 1	# Add one to the check 5 letter register
		addi $v0, $v0, 1	# Add one to the answer register
		addi $t0, $t0, 1	# Add one to the for loop counter
		addi $t7, $t7, 1	# Increment ab_text array by 1
		lb $t6, ($t7)
		beq $t1, 5, decode_B_check # If you come across a block of 5 letters
		j decode_for_update
		
	decode_uppercase:
		li $t3, 'B'
		sb $t3, ($t7)
		addi $t2, $t2, 1	# Add one to the B register
		addi $t1, $t1, 1 	# Add one to the check 5 letter register
		addi $t0, $t0, 1	# Add one to the for loop counter
		addi $v0, $v0, 1	# Add one to the answer register
		addi $t7, $t7, 1	# Increment ab_text array by 1
		lb $t6, ($t7)
		
		beq $t1, 5, decode_B_check # If you come across a block of 5 letters
		j decode_for_update
	
	decode_B_check:
		beq $t2, 5, decode_done		# If you come accross the end of message, done
		
		li $t1, 0
		li $t2, 0
		
		j decode_for_update
	
	decode_for_update:
		addi $t0, $t0, 1 # Increment for loop counter by one
		addi $t9, $t9, 1 # Increment ciphertext by one
		lb $t8, ($t9)
		j decode_for
	

decode_done:
	jr $ra 
	
	
decode_failed:
	li $v0, -1
    jr $ra
	
	
decrypt: 

	addi $sp, $sp, -4
	sw $a1 ($sp)	# Storing plaintext onto stack
	
	addi $sp, $sp, -4
	sw $a3, ($sp)	# Storing ab_text length onto stack
	
	move $a1, $a2	# Move ab_text into $a1
	move $a2, $a3	# Move ab_text_length into $a2
	
	addi $sp, $sp, -4
	sw $ra, ($sp)
	jal decode_ciphertext	#After this function is called, $t7 has ab_text but needs to be reset
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	beq $v0, -1, decrypt_failed
	
	li $t1, -1
	mul $v0, $v0, $t1
	move $t9, $t7
	add $t9, $t9, $v0	#$t9 should now have ab_text reset to its original address
	mul $v0, $v0, $t1	#$v0 should now be the original $v0
	li $v0, 0			#Reset answer register
	
	lw $t0 ($sp)		#t0 now has ab_text_length
	addi $sp, $sp, 4
	
	lw $t7 ($sp)		#$t7 now has plaintext address
	addi $sp, $sp, 4
	
	#lw $t9, ($sp)
	#addi $sp, $sp, 4
	
	#lw $t8, ($sp)
	#addi $sp, $sp, 4
	
	lb $t8, ($t9)		# $t8 is the iterator of $t9 ab_text
	lb $t6, ($t7)		# $t6 is the iterator of $t7 plaintext
	
	li $t1, 0			# Counter for ab_text for loop
	li $t2, 0			# $t2 is going to be the answer register to store into plaintext
	li $t3, 0			# $t3 is going to be the counter to keep track of if we reached 5 letters in ab_text
	li $t4, 1			# Register to xor $t3 by
	
	decrypt_for:
		beq $t1, $t0, decrypt_done
		
		beq $t8, 65, decrypt_A_convert
		beq $t8, 66, decrypt_B_convert
		
		j decrypt_for_update
		
	
	decrypt_for_update:
		addi $t1, $t1, 1	#Increment for loop counter
		addi $t9, $t9, 1	#Increment ab_text pointer
		lb $t8, ($t9)		#Load new character from ab_text
		j decrypt_for
	
decrypt_A_convert:
	addi $t3, $t3, 1
	sll $t2, $t2, 1
	beq $t3, 5, plaintext_check
	j decrypt_for_update
	
decrypt_B_convert:
	addi $t3, $t3, 1
	
	sll $t2, $t2, 1
	xor $t2, $t2, $t4
	
	beq $t3, 5, plaintext_check
	j decrypt_for_update

plaintext_check:
	li $v1, 26	#Check if it is a letter or not
	blt $t2, $v1, store_plaintext
	
	j special_cases
	 	

special_cases:
	beq $t2, 26, decrypt_space
	beq $t2, 27, decrypt_exclamation
	beq $t2, 28, decrypt_quotation
	beq $t2, 29, decrypt_comma
	beq $t2, 30, decrypt_period
	beq $t2, 31, decrypt_done

store_plaintext:
	addi $t2, $t2, 65
	sb $t2, ($t7)		#Store character into plaintext
	addi $t7, $t7, 1	#Increment plaintext counter by 1
	lb $t6, ($t7)
	
	addi $v0, $v0, 1
	li $t2, 0			#Reset answer register	
	li $t3, 0			#Reset counter
	
	j decrypt_for_update

decrypt_space:
	li $t2, 32
	sb $t2, ($t7)		#Store character into plaintext
	addi $t7, $t7, 1	#Increment plaintext counter by 1
	lb $t6, ($t7)
	
	addi $v0, $v0, 1
	li $t2, 0			#Reset answer register	
	li $t3, 0			#Reset counter
	
	j decrypt_for_update

decrypt_exclamation:
	li $t2, 33
	sb $t2, ($t7)		#Store character into plaintext
	addi $t7, $t7, 1	#Increment plaintext counter by 1
	lb $t6, ($t7)
	
	addi $v0, $v0, 1
	li $t2, 0			#Reset answer register	
	li $t3, 0			#Reset counter
	
	j decrypt_for_update
	
decrypt_quotation:
	li $t2, 34
	sb $t2, ($t7)		#Store character into plaintext
	addi $t7, $t7, 1	#Increment plaintext counter by 1
	lb $t6, ($t7)
	
	addi $v0, $v0, 1
	li $t2, 0			#Reset answer register	
	li $t3, 0			#Reset counter
	
	j decrypt_for_update

decrypt_comma:
	li $t2, 44
	sb $t2, ($t7)		#Store character into plaintext
	addi $t7, $t7, 1	#Increment plaintext counter by 1
	lb $t6, ($t7)
	
	addi $v0, $v0, 1
	li $t2, 0			#Reset answer register	
	li $t3, 0			#Reset counter
	
	j decrypt_for_update

decrypt_period:
	li $t2, 32
	sb $t2, ($t7)		#Store character into plaintext
	addi $t7, $t7, 1	#Increment plaintext counter by 1
	lb $t6, ($t7)
	
	addi $v0, $v0, 1
	li $t2, 0			#Reset answer register	
	li $t3, 0			#Reset counter
	
	j decrypt_for_update

		

	
decrypt_done:
	li $t0, 92
	sb $t0, ($t7)
	addi $t7, $t7, 1
	
	li $t0, 48
	sb $t0, ($t7)
	
    jr $ra

decrypt_failed:
	jr $ra

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
