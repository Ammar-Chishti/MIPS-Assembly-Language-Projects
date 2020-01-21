.text


# [$s1] $s0 - Address of str1
# [$s3] $s2 - Address of str2
# [$s4] - first char of str1 (for special case)
# [$s5] - first char of str2 (for special case)
# $s6 - Holds the answer to the subtraction
strcmp:

	# Allocate space for $s registers
	# Add more (if necessary)
	addiu $sp, $sp -40
    sw $s0 0($sp)
    sw $s1 4($sp)
    sw $s2 8($sp)
    sw $s3 12($sp)
    sw $s4 16($sp)
    sw $s5 20($sp)
    sw $s6 24($sp)
    sw $s7 28($sp)
    
    move $s0, $a0
    move $s2, $a1
    
    beqz $s2, str1Len	# If str2 is 0 
    
    li $t0, 1
    beq $s2, $t0, strcrmp_Special_Case		# If str2 is 1
    
    lb $s4 ($s0)
    lb $s5 ($s2)
    
    lb $s1 ($s0)
    lb $s3 ($s2)
    
    # If str1 is empty
    beqz $s4, str2EmptyCheck
    
    # If str2 is empty, but str1 is not empty, return the length of str1
    beqz, $s5, str1Len

strcmp_while:

	# If str1 is empty
    beqz $s1, str2EmptyCheckEnd
    
strcmp_while2:
	
	# If str1 and str2 are not empty, and the characters if str1 and str2 are equal, pass
    beq $s1, $s3, strcmp_while_update
    
    # If the characters are not equal, subtract the first character from the second
    subu $s6, $s1, $s3	# $s6 not holds the answer to $s1 - $s3
    move $v0, $s6
    
    lw $s0 0($sp)
    lw $s1 4($sp)
    lw $s2 8($sp)
    lw $s3 12($sp)
    lw $s4 16($sp)
    lw $s5 20($sp)
    lw $s6 24($sp)
    lw $s7 28($sp)
    addi $sp, $sp, 40
    jr $ra


strcmp_while_update:

	addiu $s0, $s0, 1	# Increment $t1 by 1
	addiu $s2, $s2, 1	# Increment #t3 by 1
	
	lb $s1, ($s0)
	lb $s3, ($s2)
    
    j strcmp_while
	



str2EmptyCheck:
	
	# If str2 is also empty, return 0.
	beqz $s5, bothEmptyCheckDone
	
	
	# If str2 is not empty, get the length of str2, multiply by -1, return
str2Len:
	
	move $s7, $ra
	move $a0, $s2	# $a0 should now have the address of str2
	
	jal strlen
	
	move $ra, $s7
	
	li $t0, -1
	mul $v0, $v0, $t0
	
	lw $s0 0($sp)
	lw $s1 4($sp)
	lw $s2 8($sp)
	lw $s3 12($sp)
	lw $s4 16($sp)
	lw $s5 20($sp)
	lw $s6 24($sp)
	lw $s7 28($sp)
	addi $sp, $sp, 40
	jr $ra


str1Len:	# If Str2 is empty
	
	move $s7, $ra
	
	jal strlen
	
	move $ra, $s7
	
	lw $s0 0($sp)
	lw $s1 4($sp)
	lw $s2 8($sp)
	lw $s3 12($sp)
	lw $s4 16($sp)
	lw $s5 20($sp)
	lw $s6 24($sp)
	lw $s7 28($sp)
	addi $sp, $sp, 40
    
	jr $ra


strcrmp_Special_Case:
	
	li $v0, -3
	
	lw $s0 0($sp)
	lw $s1 4($sp)
	lw $s2 8($sp)
	lw $s3 12($sp)
	lw $s4 16($sp)
	lw $s5 20($sp)
	lw $s6 24($sp)
	lw $s7 28($sp)
	addi $sp, $sp, 40
	jr $ra
	
	
str2EmptyCheckEnd:

	# If str2 is also empty, return 0.
	beqz $s3, bothEmptyCheckDone
	
	# If not, just return
	j strcmp_while2


bothEmptyCheckDone:	# If both Strings are empty
	
	lw $s0 0($sp)
    lw $s1 4($sp)
    lw $s2 8($sp)
    lw $s3 12($sp)
    lw $s4 16($sp)
    lw $s5 20($sp)
    lw $s6 24($sp)
    lw $s7 28($sp)
    addi $sp, $sp, 40
	
	li $v0, 0
	jr $ra






# [$s1] $s0 - Address of strings
# $s2 - For loop counter (Answer to be returned)
# $s3 - Upper limit for for loop (strings_length)
# $s4 - Address of target
# $s5 - Stores $ra
find_string:
	
	# Allocate space for $s registers
	addiu $sp, $sp -40
    sw $s0 0($sp)
    sw $s1 4($sp)
    sw $s2 8($sp)
    sw $s3 12($sp)
    sw $s4 16($sp)
    sw $s5 20($sp)
    
    blt $a2, 1, find_string_failed_done	# If strings_length is less than 2
    
    li $s2, 0
    li $s3, 0
    move $s4, $a0
    move $s0, $a1
    move $s3, $a2
    
    
find_string_for:
	
	beq $s2, $s3, find_string_failed_done	# If the counter is equal to the upper limit, you know the string cannot be in there, return -1
	
    beqz $s2, find_string_strcmp_firstcase	# If the counter is 0, call strcmp
    
    beqz $s1, find_string_strcmp	# If you find null terminator, update and call strcmp
    
    j find_string_for_update

find_string_for_update:
	
	addiu $s0, $s0, 1	# Add 1 to address
	addiu $s2, $s2, 1	# Add 1 to for loop counter
	
	lb $s1, ($s0)
	j find_string_for


find_string_strcmp_firstcase:
	
	move $a0, $s0	# $a0 now has address strings or str1 for strcmp
	move $a1, $s4	# $a1 now has address of target
	move $s5, $ra
	
	jal strcmp
	
	move $ra, $s5
	beqz $v0, find_string_done
	j find_string_for_update

find_string_strcmp:
	
	addiu $s0, $s0, 1	# Add 1 to address
	addiu $s2, $s2, 1	# Add 1 to for loop counter
	lb $s1, ($s0)
	
	move $a0, $s0	# $a0 now has address strings or str1 for strcmp
	move $a1, $s4	# $a1 now has address of target
	move $s5, $ra
	
	jal strcmp
	
	move $ra, $s5
	beqz $v0, find_string_done
	j find_string_for
			
	
find_string_done:

	move $v0, $s2
	
	lw $s0 0($sp)
    lw $s1 4($sp)
    lw $s2 8($sp)
    lw $s3 12($sp)
    lw $s4 16($sp)
    lw $s5 20($sp)
    addi $sp, $sp, 40
    
	jr $ra

find_string_failed_done:
	
	li $v0, -1
	
	lw $s0 0($sp)
    lw $s1 4($sp)
    lw $s2 8($sp)
    lw $s3 12($sp)
    lw $s4 16($sp)
    lw $s5 20($sp)
    addi $sp, $sp, 40
    
	jr $ra
	
	
# [$s1] $s0 = $s0 is the hash table, $s1 is the capacity
# $s2 is the asciiSum of the String
# $s3 - The answer register
hash:
	
	# Allocate space for $s registers
	# Add more (if necessary)
	addi $sp, $sp, -20
	sw $s0 0($sp)
    sw $s1 4($sp)
    sw $s2 8($sp)
    sw $s3 12($sp)
    sw $s4 16($sp)
    
    lb $s1, 0($a0)	# $s1 is the capacity
    
    move $s4, $a0
    move $a0, $a1	# $a0 now has the string address
    
    move $s3, $ra
    jal asciiSum
    move $ra, $s3
    
    move $s2, $v0	# $s2 now has the ascii sum
    
    div $s2, $s1
    
    mfhi $v0
    
    move $a0, $s4
	
	lw $s0 0($sp)
    lw $s1 4($sp)
    lw $s2 8($sp)
    lw $s3 12($sp)
    lw $s4 16($sp)
    addi $sp, $sp, 20
	jr $ra


# [$s1] $s0 - Address of HashTable
# $s2 - Lower counter
# $s3 - Upper Limit (2 * Capacity + 1)
clear:
	
	# Allocate space for $s registers
	# Add more (if necessary)
	addi $sp, $sp, -20
	sw $s0 0($sp)
    sw $s1 4($sp)
    sw $s2 8($sp)
    sw $s3 12($sp)
    
    move $s0, $a0	# $s0 now has the address of the hashtable
    
    lb $s3, ($s0)
    
    li $t0, 2
    mul $s3, $s3, $t0
    addiu $s3, $s3, 1	# $s1 now is the upper limit
    
    li $s2, 0			# Set Lower counter to 0
    addiu $s0, $s0, 4	# Set address of hash to start at size
    j clear_while_update

clear_while:
	beq $s2, $s3, clear_done
	j clear_while_update


clear_while_update:
	lw $s1, ($s0)
	move $s1, $zero
	sw $s1, ($s0)
	
	addiu $s0, $s0, 4	# Iterate hash to next key or value
	addiu $s2, $s2, 1	# Increment counter by 1
	j clear_while
	

clear_done:

	lw $s0 0($sp)
    lw $s1 4($sp)
    lw $s2 8($sp)
    lw $s3 12($sp)
	addi $sp, $sp, 20
	jr $ra
	
	
	
# $s0 - Original Hash table address
# $s1 - Hash table key address accessor
# $s2 - String address
# $s3 - For loop counter
# $s4 - Capacity of Hashtable (upper limit for for loop counter)
# $s5 - Hashtable address to modify
# $s6 - hashIndex (called by hash(hash_table, key))
# $s7 - hashIndex modified to add to Hash table address ((2 + hashIndex) * 4)
# $t0 - Counter to keep track of probes
get:

	# Allocate space for $s registers
	addi $sp, $sp, -40
	sw $s0 0($sp)
    sw $s1 4($sp)
    sw $s2 8($sp)
    sw $s3 12($sp)
    sw $s4 16($sp)
    sw $s5 20($sp)
    sw $s6 24($sp)
    sw $s7 28($sp)
    
    move $s2, $a1
    move $s0, $a0
    lb $s4, ($s0)	# $s4 now has the capacity of the hashtable
    li $s3, 0		# For loop counter
    
    sw $ra, 32($sp)
    jal hash
    lw $ra, 32($sp)
    
    move $s6, $v0	# $s6 should now have hashindex
    li $t0, 0		# Probe counter
    
    move $s7, $s6
    addiu $s7, $s7, 2
    li $t9, 4
    mul $s7, $s7, $t9		# $s7 should now have the correct amount to add by to hash address
    
    move $s5, $s0
    addu $s5, $s5, $s7
    lw $s1, ($s5)			# $s1 should now have the address of the specific key
    

get_for:
	beq $s3, $s4, get_notFound_done
	
	move $a0, $s2	# Move String address into $a0
	move $a1, $s1	# Move key address into $a1
	
	sw $ra, 32($sp)
	sw $t0, 36($sp)
    jal get_checker	# If $v0 is 131 after this, String and key are equal, if $v0 is 2, key is empty
    lw $ra, 32($sp)
    lw $t0, 36($sp)
    
    li $t8, 131
    beq $v0, $t8, get_Equal_Done
   	
   	li $t7, 132
   	beq $v0, $t7, get_Empty_Done
   	
   	#jr $ra
	
get_for_update1:
	
	addiu $t0, $t0, 1	# Add one to number of probes
	addiu $s3, $s3, 1	# Add one to for loop counter
	addiu $s6, $s6, 1	# Add one to hashIndex counter
	beq $s3, $s4, get_notFound_done
	beq $s6, $s4, get_Reset_HashIndex	# If the hashIndex counter == capacity, set it back to 0
	
get_for_update2:
	move $s7, $s6
    addiu $s7, $s7, 2
    li $t9, 4
    mul $s7, $s7, $t9		# $s7 should now have the correct amount to add by to hash address
    
	move $s5, $s0
    addu $s5, $s5, $s7
    lw $s1, ($s5)			# $s1 should now have the address of the specific key
    j get_for
	

get_Reset_HashIndex:
	li $s6, 0
	j get_for_update2
	

get_Equal_Done:
	
	move $v0, $s6	# Move hashindex to $v0
	move $v1, $t0	# Move probes to $v1
	
	lw $s0 0($sp)
    lw $s1 4($sp)
    lw $s2 8($sp)
    lw $s3 12($sp)
    lw $s4 16($sp)
    lw $s5 20($sp)
    lw $s6 24($sp)
    lw $s7 28($sp)
    addi $sp, $sp, 40
    jr $ra

get_Empty_Done:
	
	li $t2, -1
	move $v0, $t2	# Move -1 to $v0
	move $v1, $t0	# Move probes to $v1
	
	lw $s0 0($sp)
    lw $s1 4($sp)
    lw $s2 8($sp)
    lw $s3 12($sp)
    lw $s4 16($sp)
    lw $s5 20($sp)
    lw $s6 24($sp)
    lw $s7 28($sp)
    addi $sp, $sp, 40
    jr $ra
	

get_notFound_done:
	
	addiu $s4, $s4, -1	# Subtract capacity by 1
	li $v0, -1
	move $v1, $s4	# Load capacity-1 into $v1
	
	lw $s0 0($sp)
    lw $s1 4($sp)
    lw $s2 8($sp)
    lw $s3 12($sp)
    lw $s4 16($sp)
    lw $s5 20($sp)
    lw $s6 24($sp)
    lw $s7 28($sp)
    addi $sp, $sp, 40
    jr $ra
	
	
# $a0 - Original Hashtable address
# $a1 - String key address
# $a2 - String value address
# $s0 - Hashtable address to modify
# $s1 - Capacity
# $s2 - Size
# $s3 - hashIndex
# $s4 - hashIndex modified to add to Hash table address
# $s5 - number to add to get from key to value
# $s6 - Counter to keep track of probes
# $s7 - $ra holder
# $t0 - Original Hashtable address
# $t1 - String key address
# $t2 - String value address
put:

	# Allocate space for $s registers
	addi $sp, $sp, -80
	sw $s0 0($sp)
    sw $s1 4($sp)
    sw $s2 8($sp)
    sw $s3 12($sp)
    sw $s4 16($sp)
    sw $s5 20($sp)
    sw $s6 24($sp)
    sw $s7 28($sp)
    
    move $t0, $a0
    move $t1, $a1
    move $t2, $a2
    
    lw $s1, ($a0)	# $s1 now has the capacity
    lw $s2, 4($a0)	# $s2 now has the size
    
    li $s6, 0		# $s6 keeps track of probes
    
    sw $t0 32($sp)
    sw $t1 36($sp)
    sw $t2 40($sp)
    move $s7, $ra
    jal hash
    move $ra, $s7
    lw $t0 32($sp)
    lw $t1 36($sp)
    lw $t2 40($sp)
    
    move $s3, $v0	# $s3 now has the hashindex
    
    sw $t0 32($sp)
    sw $t1 36($sp)
    sw $t2 40($sp)
    move $s7, $ra
    jal get
    move $ra, $s7
    lw $t0 32($sp)
    lw $t1 36($sp)
    lw $t2 40($sp)
    
    bgez $v0, put_KeyFound	# If the result is greater or equal to 0, key is found
    blez $v0, put_KeyEmpty	# If the result is less than 0, empty space
    

put_KeyFound:
	
	move $s3, $v0	# hashIndex is replaced with the index of the found key
	
	move $s4, $s3	# $s4 is going to be the number to get to the hashindex value
	
	addiu $s4, $s4, 2	# (hashindex + 2) * 4 = key value
	li $t9, 4
	mul $s4, $s4, $t9
	
	li $t8, 4
	mul $t7, $s1, $t8	# $t7 has (4 * capacity)
	
	add $s4, $s4, $t7	# $s4 has the value to get to the hashindex value address
	
	move $s0, $t0
	addu $s0, $s0, $s4	
	lw $s7, ($s0)		# $a0 now has the address of the hashtable value to modify
	move $s7, $t2		# $a1 now has the value you want to replace $a0 with
	sw $s7, ($s0)		# Storing the new word
	
	lw $s0 0($sp)
    lw $s1 4($sp)
    lw $s2 8($sp)
    lw $s3 12($sp)
    lw $s4 16($sp)
    lw $s5 20($sp)
    lw $s6 24($sp)
    lw $s7 28($sp)
    addi $sp, $sp, 80
    jr $ra

put_KeyEmpty:
	beq $s1, $s2, fullHashDone	# If capacity == size
	
	# $s3 hashindex
	# $s4 hashindex modified
	# $s6 probes
	
	move $a0, $t0
	move $a1, $t1
	sw $t0 32($sp)
    sw $t1 36($sp)
    sw $t2 40($sp)
    move $s7, $ra
    jal get			# $v1 now has the number of probes to add to hashindex
    move $ra, $s7
    lw $t0 32($sp)
    lw $t1 36($sp)
    lw $t2 40($sp)
    
    move $s4, $s3
    add $s4, $s4, $v1	# hashindex + probes = mix
    bge $s4, $s1, put_Reset_HashIndex	# If Hashindex is >= capacity

put_KeyEmpty2:
	sw $s4, 44($sp)
    sw $v1, 48($sp)
        
        
    addiu $s4, $s4, 2	# (mix + 2) * 4 = key value
	li $t9, 4
	mul $s4, $s4, $t9	# $s4 now has the correct value to add to access key
	
	move $s0, $t0
	add $s0, $s0, $s4
	
	lw $t9, ($s0)
	move $t9, $t1
	sw $t9, ($s0)		# Updating key
	
	li $t9, 4
	mul $t9, $s1, $t9	# 4 * capacity value
	
	add $s0, $s0, $t9	
	
	lw $t9, ($s0)
	move $t9, $t2
	sw $t9, ($s0)		# Updating value
	
	move $t9, $t0		# Increase capacity
	lw $t8, 4($t9)
	addiu $t8, $t8, 1
	sw $t8, 4($t9)
	
	lw $t8, 44($sp)
	lw $t9, 48($sp)
	move $v0, $t8
	move $v1, $t9
	
	lw $s0 0($sp)
    lw $s1 4($sp)
    lw $s2 8($sp)
    lw $s3 12($sp)
    lw $s4 16($sp)
    lw $s5 20($sp)
    lw $s6 24($sp)
    lw $s7 28($sp)
    addi $sp, $sp, 80
    jr $ra
	
	

put_Reset_HashIndex:
	sub $s4, $s4, $s1
	j put_KeyEmpty2
    


fullHashDone:
	
	move $a0, $t0
	move $a1, $t1
	move $a2, $t2

	li $v0, -1
	li $v0, -1
	
	lw $s0 0($sp)
    lw $s1 4($sp)
    lw $s2 8($sp)
    lw $s3 12($sp)
    lw $s4 16($sp)
    lw $s5 20($sp)
    lw $s6 24($sp)
    lw $s7 28($sp)
    addi $sp, $sp, 80
    jr $ra
	


delete:

	# Allocate space for $s registers
	addi $sp, $sp, -40
	sw $s0 0($sp)
    sw $s1 4($sp)
    sw $s2 8($sp)
    sw $s3 12($sp)
    sw $s4 16($sp)
    sw $s5 20($sp)
    sw $s6 24($sp)
    
    move $s5, $a0	# $s5 is the original hashindex address
    move $s0, $a0	# $s0 is hashindex to modify
    move $s1, $a1	# $s1 is $a1
    
    lb $s2, 4($s0)	# $s2 now has the size of the hashtable
    lb $s6, ($s0)	# $s6 now has the capacity of the hashtable
    
    beqz $s2, delete_Empty	# If the hashtable is empty, return (-1, 0)
    
    
    move $s3, $ra
    jal get
    move $ra, $s3
    
    blez $v0, delete_NoKey	# If the key is not found in the hashtable, return get()
    
    
    move $s4, $v0	# $s4 now has the hashindex
    
    addiu $s4, $s4, 2
    li $t9, 4
	mul $s4, $s4, $t9	# $s4 now = ((hashindex + 2) * 4)
	
	move $s0, $s5
	addu $s0, $s0, $s4
	
	lw $t9, ($s0)
	li $t9, 1
	sw $t9, ($s0)	# Key is now 1
	
	
	li $t9, 4
	mul $t9, $s6, $t9	# 4 * capacity value
	add $s0, $s0, $t9	# ((hashindex + 2) * 4) + (4 * capacity)
	
	lw $t9, ($s0)
	move $t9, $zero
	sw $t9, ($s0)		# Value is now 0
	

	lw $s0 0($sp)
    lw $s1 4($sp)
    lw $s2 8($sp)
    lw $s3 12($sp)
    lw $s4 16($sp)
    lw $s5 20($sp)
    lw $s6 24($sp)
    addi $sp, $sp, 40
	jr $ra
    
    
delete_Empty:
	
	li $v0, -1
	li $v1, 0
	
	lw $s0 0($sp)
    lw $s1 4($sp)
    lw $s2 8($sp)
    lw $s3 12($sp)
    addi $sp, $sp, 20
    jr $ra
    
delete_NoKey:
	
	lw $s0 0($sp)
    lw $s1 4($sp)
    lw $s2 8($sp)
    lw $s3 12($sp)
    addi $sp, $sp, 20
    jr $ra


# $s0 - Points to the end of the value address
# $s1 - Points to beginning of key address (in $sp)
# $s2 - Points to beginning of value address (in $sp)
# $s3 - key index saver
# $s4 - value index saver
# $s5 - Points to beginning of key address (in Strings)
# $s6 - Points to beginning of value address (in Strings)
# $s7 - jr $ra saver

# $t0 - Original hash_table address
# $t1 - Original Strings Length
# $t2 - Original FileName address
# $t5 - Constant to hold file descriptor
# $t4 - Counter to hold key/value pairs added
# $t6 - Original Strings address
# $t9 - Low scope compare register
build_hash_table:
	
	# Allocate space for $s registers
	addiu $sp, $sp -40
    sw $s0 0($sp)
    sw $s1 4($sp)
    sw $s2 8($sp)
    sw $s3 12($sp)
    sw $s4 16($sp)
    sw $s5 20($sp)
    sw $s6 24($sp)
    sw $s7 28($sp)
    
    move $t6, $a1	# $s0 has Strings address
    move $fp, $a0
    
    move $t0, $a0	# $t0 has original hashtable address
    move $t1, $a2	# $t1 has Strings_length
    move $t2, $a3	# $t3 has filename address
    sw $t0, 32($sp)	# Storing into $sp
    sw $t1, 36($sp)
    sw $t2, 40($sp)
    
    move $s7, $ra
    jal clear
    move $ra, $s7
    
    addi $sp, $sp, -80
    
    lw $a0, 120($sp) # Start of opening a file, pass filename to $a0	
	li $a1, 0
	li $a2, 0
	li $v0, 13
	syscall
	
	blt $v0, $zero, build_OpenFile_Failed 	# If $v0 is -1 meaning file was never opened, exit program
    
    li $t5, 3	# Holds file descriptor
    move $s1, $sp	# $s1 is going to point to the starting of the key address initially (at -120)
    move $s2, $sp	# $s2 is going to constanly update until it points to the starting value address
    
build_hash_while_key:	# Keep searching until you find the key
	
	li $v0, 14		# Start of reading a file
	move $a0, $t5	# Move file descriptor to $a0
	move $a1, $s2	# $s2 now points to the char just loaded, keep going until you hit a space, make it a null, increment 1 and you will be pointing to the value	
    li $a2, 1
    syscall
    
    beqz $v0, build_hash_done	# If there is nothing left to read in the file, exit
    
    lb $t9, ($s2)	# Checking to see if you hit a space, end of the key
	beq $t9, 32, convertSpaceNull
	
	addi $s2, $s2, 1
	j build_hash_while_key

build_hash_while_value:

	li $v0, 14		# Start of reading a file
	move $a0, $t5	# Move the file descriptor to $a0
	move $a1, $s0	# Starting from the starting address of the value, load bytes 
	li $a2, 1
	syscall
	
	beqz $v0, build_hash_done	# If there is nothing left to read in the file, exit
	
	lb $t9, ($s0)	# Checking to see if you hit a newline, end of the value
	beq $t9, 10, convertNewLineNull
	
	addi $s0, $s0, 1
	j build_hash_while_value

convertSpaceNull:
	
	li $t9, 0
	sb $t9, ($s2)	# The space after the key is now null.
	addi $s2, $s2, 1 # $s2 now points to the starting value of the address, $s1 still points to the starting address of the key
	move $s0, $s2	 # $s0 now points to the starting value of the address, but it is to be incremented until end
	
	j build_hash_while_value

convertNewLineNull:
	
	li $t9, 0
	sb $t9, ($s0)		# The space after the value is now null
	addi $s0, $s0, 1	# $s0 now points to the end of the value or the character after the null terminator after the value, $s1 to key, $s2 to value
	
	move $a0, $s1	# $a0 has the starting address of key, String target
	move $a1, $t6	# $a1 has the Strings address
	lw $a2, 116($sp)# $a2 has the String Length
	move $s7, $ra
	jal find_string
	move $ra, $s7
	
	move $s3, $v0	# $s3 now holds the index of key in Strings
	
	move $a0, $s2	# $a0 has the starting address of key, String target
	move $a1, $t6	# $a1 has the Strings address
	lw $a2, 116($sp)# $a2 has the String Length
	move $s7, $ra
	jal find_string
	move $ra, $s7
	
	move $s4, $v0	# $s4 now holds the index of the value in Strings
	
	
	add $s5, $s3, $t6	# $s5 points to the starting address of key in Strings
	add $s6, $s4, $t6	# $s6 points to the starting address of Value in Strings
	
	move $a0, $fp #112($sp)	# $a0 now has hashtable address
	move $a1, $s5		# $a1 has starting address of key
	move $a2, $s6		# $a2 has starting address of value
	
	move $s7, $ra
	jal put
	move $ra, $s7
	
	addiu $t4, $t4, 1
	move $s1, $s0
	move $s2, $s0
	j build_hash_while_key
	
	lw $s0 80($sp)
    lw $s1 84($sp)
    lw $s2 88($sp)
    lw $s3 92($sp)
    lw $s4 96($sp)
    lw $s5 100($sp)
    lw $s6 104($sp)
    lw $s7 108($sp)
    # You can choose to restore arguments here if u want to
    addi $sp, $sp, 120
	jr $ra
	


build_OpenFile_Failed:
	
	lw $s0 80($sp)
    lw $s1 84($sp)
    lw $s2 88($sp)
    lw $s3 92($sp)
    lw $s4 96($sp)
    lw $s5 100($sp)
    lw $s6 104($sp)
    lw $s7 108($sp)
    # You can choose to restore arguments here if u want to
    addi $sp, $sp, 120
	jr $ra

build_hash_done:
	
	move $v0, $t4	# Moving # of key value pairs added to $v0

	lw $s0 80($sp)
	lw $s1 84($sp)
	lw $s2 88($sp)
	lw $s3 92($sp)
	lw $s4 96($sp)
	lw $s5 100($sp)
	lw $s6 104($sp)
	lw $s7 108($sp)
	# You can choose to restore arguments here if u want to
	addi $sp, $sp, 120
	jr $ra
	
	



autocorrect:
jr $ra

# Helper Functions

strlen:	# Returns the length of a String
	
	move $t1, $a0	#$t0 now contains the str address
	li $t3, 0		#Counter to store the length of the Srring
	
	lb $t0, 0($t1)   #While Loop start case, beginning of String
	j whileLoop_strlen
	
	whileLoop_strlen:
		beqz $t0, strlen_done    #End Case. If character is null, end loop.
	    
		addiu $t3, $t3, 1	     #Add one to the length register

		addiu $t1, $t1, 1	     #Update the loop
		lb $t0, 0($t1)
		j whileLoop_strlen
	
	strlen_done:
	    move $v0, $t3
	    jr $ra
	    


# [$s1] $s0 = Address of string to convert
# $s2 - Answer sum register to return
asciiSum: 	# Converts a string into the sum of ascii values
	addi $sp, $sp, -20
	sw $s0 0($sp)
    sw $s1 4($sp)
    sw $s2 8($sp)
    sw $s3 12($sp)
	move $s0, $a0
	lb $s1, ($s0)
	
	li $s2, 0

asciiSumWhile:
	beqz $s1, asciiSumDone	# If the character is null, end the loop
	addu $s2, $s2, $s1

asciiSumWhileUpdate:
	addiu $s0, $s0, 1	# Add 1 to address
	lb $s1, ($s0)
	j asciiSumWhile

asciiSumDone:
	move $v0, $s2
	lw $s0 0($sp)
    lw $s1 4($sp)
    lw $s2 8($sp)
    lw $s3 12($sp)
    addi $sp, $sp, 20
    jr $ra
    

# Takes in two Strings 
# $a0 - The address of the key you are searching for
# $a1 - The address of the key of the hashtable
# $s0 - Strlen of Str1
# $s1 - Return value of strcmp
get_checker:

	# Allocate space for $s registers
	addi $sp, $sp, -20
	sw $s0 0($sp)
	sw $s1 4($sp)
	sw $s2 8($sp)
    
	move $s2, $ra
	jal strlen
	move $ra, $s2
	
	move $s0, $v0	# $s0 now has the strlen of the key you are searching for
	
	move $s2, $ra
	jal strcmp
	move $ra, $s2
	
	move $s1, $v0	# $s1 now has the return of strcmp.
	
	beqz $s1, get_checker_match		# If String matches the key, return 0
	beq $s1, $s0, get_checker_empty	# If the key is empty
	
	
	lw $s0 0($sp)
	lw $s1 4($sp)
	lw $s2 8($sp)
	addi $sp, $sp, 20
	jr $ra

get_checker_match:
	li $v0, 131
	
	lw $s0 0($sp)
	lw $s1 4($sp)
	lw $s2 8($sp)
	addi $sp, $sp, 20
	jr $ra

get_checker_empty:
	li $v0, 132
	
	lw $s0 0($sp)
	lw $s1 4($sp)
	lw $s2 8($sp)
	addi $sp, $sp, 20
	jr $ra

# $a0 hashtable key value address
# $a1 another key value address
# you want to replace $a0 with $a1 in main memory
put_replace:

	addi $sp, $sp, -40
	sw $s0 0($sp)
    sw $s1 4($sp)
    sw $s2 8($sp)
    sw $s3 12($sp)
    
    move $s0, $a0
    move $s1, $a1
    
    
    
	
	
	
	
	




    
	
	
	
	



