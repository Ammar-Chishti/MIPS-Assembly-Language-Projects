# CSE 220 Programming Project #4
# Ammar Chishti
# achishti
# 111717583

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text

compute_checksum:
	addi $sp, $sp, -40
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	
	move $s0, $a0
	li $s6, 0
	
	lw $s1, ($s0)
	andi $s2, $s1, 0x0000FFFF	# total_length
	andi $s3, $s1, 0x0FFF0000	# msg_id
	srl $s3, $s3, 16
	andi $s4, $s1, 0xF0000000	# version
	srl $s4, $s4, 28
	
	add $s6, $s2, $s3
	add $s6, $s6, $s4
	
	lw $s1, 4($s0)
	andi $s2, $s1, 0x00000FFF	# fragment_offset
	andi $s3, $s1, 0x003FF000	# protocol
	srl $s3, $s3, 12
	andi $s4, $s1, 0x00C00000	# flags
	srl $s4, $s4, 22
	andi $s5, $s1, 0xFF000000	# priority
	srl $s5, $s5, 24
	
	add $s6, $s6, $s2
	add $s6, $s6, $s3
	add $s6, $s6, $s4
	add $s6, $s6, $s5
	
	lw $s1, 8($s0)
	andi $s2, $s1, 0x000000FF	# destination_address
	andi $s3, $s1, 0x0000FF00	# source_address
	srl $s3, $s3, 8
	
	add $s6, $s6, $s2
	add $s6, $s6, $s3
	li $t0, 0x00010000
	
	div $s6, $t0	# $s6 mod (2^16)
	mfhi $v0
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	addi $sp, $sp, 40
	jr $ra

compare_to:
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# packet 1 original
	sw $s1, 4($sp)	# packet 2 original
	sw $s2, 8($sp)	# packet 1 load word
	sw $s3, 12($sp)	# packet 2 load word
	sw $s4, 16($sp)	# packet 1 value
	sw $s5, 20($sp)	# packet 2 value
	
	move $s0, $a0
	move $s1, $a1
	
	lw $s2, ($a0)
	lw $s3, ($a1)
	
	andi $s4, $s2, 0x0FFF0000	# packet 1 msg_id
	srl $s4, $s4, 16
	
	andi $s5, $s3, 0x0FFF0000	# packet 2 msg_id
	srl $s5, $s5, 16
	
	blt $s4, $s5, compare_to_less_than
	bgt $s4, $s5, compare_to_greater_than
	beq $s4, $s5, compare_to_fragment_compare
	
	compare_to_fragment_compare:
		lw $s2, 4($a0)
		lw $s3, 4($a1)
	
		andi $s4, $s2, 0x00000FFF	# packet 1 fragment_offset
		andi $s5, $s3, 0x00000FFF	# packet 2 fragment_offset
		
		blt $s4, $s5, compare_to_less_than
		bgt $s4, $s5, compare_to_greater_than
		beq $s4, $s5, compare_to_src_address_compare
		
		compare_to_src_address_compare:
			lw $s2, 8($a0)
			lw $s3, 8($a0)
			
			andi $s4, $s2, 0x0000FF00	# packet 1 source_address
			srl $s4, $s4, 8
			
			andi $s5, $s3, 0x0000FF00	# packet 2 source_address
			srl $s5, $s5, 8
		
			blt $s4, $s5, compare_to_less_than
			bgt $s4, $s5, compare_to_greater_than
			beq $s4, $s5, compare_to_equal
			j compare_to_equal
	
	compare_to_greater_than:
		li $v0, 1
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		addi $sp, $sp, 40
		jr $ra
	
	compare_to_less_than:
		li $v0, -1
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		addi $sp, $sp, 40
		jr $ra
	
	compare_to_equal:
		li $v0, 0
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		addi $sp, $sp, 40
		jr $ra

packetize:
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# packets original address -> (modified every time so not really original)
	sw $s1, 4($sp)	# packets modified address
	sw $s2, 8($sp)	# answer register
	sw $s3, 12($sp)	# msg modified address
	sw $s4, 16($sp)	# total length
	sw $s5, 20($sp)	# fragment offset
	sw $s6, 24($sp)	# payload_size
	sw $s7, 28($sp) # version
	move $t0, $ra	# $t0 - $ra saver, $t1 payload size from packetize_saver
	
	move $s0, $a0
	move $s1, $a0
	li $s2, 0
	move $s3, $a1
	
	move $s6, $a2	# payload_size
	move $s7, $a3	# version
	
	# 40($sp) # msg_id
	# 44($sp) # priority
	# 48($sp) # protocol
	# 52($sp) # src_address
	# 56($sp) # dest_address
	
	li $s5, 0	# Initializing fragment offset
	
	packetize_msg_last_determine:	# This while loop determines if we are at the end of the message or not
		
		move $a0, $s3
		move $a1, $s6
		sw $t0, 32($sp)
		sw $t1, 36($sp)
		jal packetize_helper	# $v0 should have the actual payload size, $v1 should have the flag
		lw $t0, 32($sp)
		lw $t1, 36($sp)
		move $t1, $v0			# $t1 now has actual payload size
		
		addi $s4, $v0, 12	# Compute the total length
		
		# packet will be written to here
		
		li $t9, 0
		or $t9, $t9, $s4	# $t9 now has total_length in 16 right bits
		
		lw $t8, 40($sp)
		sll $t8, $t8, 16
		or $t9, $t9, $t8	# $t9 now has msg_id and total_length
		
		move $t8, $s7
		sll $t8, $t8, 28
		or $t9, $t9, $t8	# $t9 now has the first word
		
		sw $t9, ($s1)		# FIRST WORD OF HEADER HAS BEEN WRITTEN TO PACKET
		addi $s1, $s1, 4
		
		li $t9, 0
		or $t9, $t9, $s5	# $t9 now has fragment_offset in the right 12 bits
		
		lw $t8, 48($sp)
		sll $t8, $t8, 12
		or $t9, $t9, $t8	# $t9 now has protocol and fragment_offset
		
		beqz $v1, packetize_msg_last_determine_after_flags
		
		li $t8, 1
		sll $t8, $t8, 22
		or $t9, $t9, $t8	# $t9 now has flags, protocol, and fragment offset
		
	packetize_msg_last_determine_after_flags:
		lw $t8, 44($sp)
		sll $t8, $t8, 24
		or $t9, $t9, $t8	# $t9 now has the second word
		
		sw $t9, ($s1)		# SECOND WORD OF HEADER HAS BEEN WRITTEN TO PACKET
		addi $s1, $s1, 4
		
		li $t9, 0
		lw $t8, 56($sp)
		or $t9, $t9, $t8	# $t9 now has destination_address in the right 8 bits
		
		lw $t8, 52($sp)
		sll $t8, $t8, 8
		or $t9, $t9, $t8	# $t9 now has source_address and destination_address
		
		sw $t9, ($s1)		# PARTIAL THIRD WORD OF HEADER HAS BEEN WRITTEN TO PACKET (source and destination address)
		
		move $a0, $s0
		sw $t0, 32($sp)
		sw $t1, 36($sp)
		jal compute_checksum
		lw $t0, 32($sp)
		lw $t1, 36($sp)
		
		sll $v0, $v0, 16
		or $t9, $t9, $v0
		
		sw $t9, ($s1)		# THIRD WORD OF HEADER HAS BEEN WRITTEN TO PACKET
		addi $s1, $s1, 4
		
		move $a0, $s1
		move $a1, $t1
		move $a2, $s3
		sw $t0, 32($sp)
		sw $t1, 36($sp)
		jal packetize_write_payload
		lw $t0, 32($sp)
		lw $t1, 36($sp)
		move $s3, $v0
		
		# packet is done being written to
		
		#move $a0, $s0	# This is to print out the packet that was just written
		#move $a1, $t1
		#jal print_packet
		
		add $s5, $s5, $t1	# Update fragment offset
		addi $s2, $s2, 1	# Add 1 to answer register
		
		beqz $v1, packetize_done
		
	packetize_msg_last_determine_update:
		add $s0, $s0, $s4	# add to packets "original" address so we are at the next packet address
		move $s1, $s0
		j packetize_msg_last_determine
	
	packetize_done:
		move $v0, $s2
		move $ra, $t0
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

clear_queue:
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# queue original
	sw $s1, 4($sp)	# max queue size original
	
	move $s0, $a0
	move $s1, $a1
	
	blez $s1, clear_queue_failed
	
	li $t9, 0
	or $t9, $t9, $s1
	sll $t9, $t9, 16
	
	sw $t9, ($a0)
	addi $a0, $a0, 4
	
	clear_queue_while:
		beqz $a1, clear_queue_done
		
		sw $0, ($a0)
	
	clear_queue_while_update:
		addi $a1, $a1, -1
		addi $a0, $a0, 4
		j clear_queue_while
	
	
	
	clear_queue_done:
		li $v0, 0
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		addi $sp, $sp, 40
		jr $ra
	
	clear_queue_failed:
		li $v0, -1
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		addi $sp, $sp, 40
		jr $ra

enqueue:
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# queue original
	sw $s1, 4($sp)	# packet original
	sw $s2, 8($sp)	# answer return register
	sw $s3, 12($sp)	# queue modified
	sw $s4, 16($sp)	# $ra saver
	
	move $s0, $a0
	move $s1, $a1
	move $s3, $a0
	move $s4, $ra
	
	lh $t9, ($s0)
	lh $t8, 2($s0)
	
	beq $t9, $t8, enqueue_failed
	
	addi $s2, $t9, 1
	
	addi $s3, $s3, 4	# This is so we are pointing to the start of the packets in the queue
	lw $t0, ($s3)
	beqz $t0, enqueue_empty_queue	# Enqueuing an item to an empty queue
	
	li $t8, 4
	mult $t9, $t8
	mflo $t8
	add $s3, $s3, $t8	# $s3 is now pointing to the next available index. 
	
	sw $s1, ($s3)		# We store the packet at queue.array[size]
	
	move $a0, $s0
	move $a1, $t9
	jal enqueue_heapify
	j enqueue_done
	
	enqueue_done:
		lh $t0, ($s0)	# Add 1 to queue size
		addi $t0, $t0, 1
		sh $t0, ($s0)
		
		move $v0, $s2
		move $ra, $s4
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		addi $sp, $sp, 40
		jr $ra
	
	enqueue_failed:
		move $v0, $t8
		move $ra, $s4
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		addi $sp, $sp, 40
		jr $ra
	
	enqueue_empty_queue:
		lh $t0, ($s0)	# Add 1 to queue size
		addi $t0, $t0, 1
		sh $t0, ($s0)
		
		sw $s1, ($s3)
		move $ra, $s4
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		addi $sp, $sp, 40
		jr $ra
		

dequeue:
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# queue original
	sw $s1, 4($sp)	# queue size
	sw $s2, 8($sp)	# answer return register
	sw $s3, 12($sp) # $ra saver
	sw $s4, 16($sp)	# pointer to root packer pointer (double pointer)
	sw $s5, 20($sp) # pointer to last pakcet pointer in array (double pointer)
	
	lh $s1, ($a0)
	beqz $s1, dequeue_empty
	li $t9, 1
	beq $s1, $t9, dequeue_single
	
	move $s0, $a0
	move $s3, $ra
	
	addi $a0, $a0, 4
	lw $s2, ($a0)	# $s2 contains the first element which is the answer to return
	
	addi $t9, $s1, -1
	li $t8, 4
	mult $t9, $t8
	mflo $t9		# $t9 now has offset to get to the last packet pointer in the queue
	
	add $a0, $a0, $t9	# $a0 is now at the location of the last packet pointer
	
	lw $s5, ($a0)
	sw $0, ($a0)		# Setting the last packet address in the tree to null
	
	move $a0, $s0
	sw $s5, 4($a0)		# Setting the first packet address in the tree to the previous last packet
	
	move $a0, $s0
	jal dequeue_heapify	# Performing the heapify-down procedure
	j dequeue_done
	
		
	dequeue_done:
		lh $t0, ($s0)	# Subtract 1 from queue size
		addi $t0, $t0, -1
		sh $t0, ($s0)
	
		move $v0, $s2
		move $ra, $s3
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		addi $sp, $sp, 40
		jr $ra
	
	dequeue_empty:	# If the queue is empty
		li $v0, 0
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		addi $sp, $sp, 40
		jr $ra
	
	dequeue_single:		# If there is only one element in the queue and you want to dequeue
		
		lh $t0, ($a0)	# Subtract 1 from queue size
		addi $t0, $t0, -1
		sh $t0, ($a0)
		
		addi $a0, $a0, 4
		lw $v0, ($a0)
		sw $0, ($a0)
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		addi $sp, $sp, 40
		jr $ra

assemble_message:
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# message original
	sw $s1, 4($sp)	# queue original
	sw $s2, 8($sp)	# packetsDequeued ($v0) saver
	sw $s3, 12($sp)	# packetsChecksumTestFailed ($v1) saver
	sw $s4, 16($sp) # $ra saver
	sw $s5, 20($sp) # checksum holder
	sw $s6, 24($sp) # packet address saver
	
	move $s0, $a0
	move $s1, $a1
	li $s2, 0
	li $s3, 0
	move $s4, $ra
	
	assemble_message_while:
		lh $t9, ($s1)
		beqz $t9, assemble_message_done
		
		move $a0, $s1
		jal dequeue
		
		addi $s2, $s2, 1
		lh $s5, 10($v0)		# $t8 has the packet checksum
		
		move $s6, $v0
		
		move $a0, $v0
		jal compute_checksum
		bne $s5, $v0, assemble_message_mismatch_checksum_update
	
	assemble_message_while_continue:
		move $a0, $s0
		move $a1, $s6
		jal assemble_message_helper
		
		#move $a0, $s6
		#jal print_packet
	
	assemble_message_while_update:
		j assemble_message_while
	
	
	assemble_message_done:
		move $v0, $s2
		move $v1, $s3
		move $ra, $s4
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		addi $sp, $sp, 40
		jr $ra
	
	
	assemble_message_mismatch_checksum_update:
		addi $s3, $s3, 1
		j assemble_message_while_continue
	
		
	




# REGULAR HELPER FUNCTIONS

# $a0 - msg,	$a1 - payload_size		$v0 - payload size (does not always need to be original) $v1 - 1 if last packet or 0 if not
packetize_helper:	# Traverses the message and sees if the there is enough in the message to match the payload size
	addi $sp, $sp, -20
	sw $s0, 0($sp)	# msg original
	sw $s1, 4($sp)	# payload_size original
	sw $s2, 8($sp)	# msg byteloader
	
	move $s0, $a0
	move $s1, $a1
	
	li $v0, 0
	lb $s2, ($a0)
	
	packetize_helper_while:
		beq $v0, $a1, packetize_helper_done
		beqz $s2, packetize_helper_last_done
		
		addi $v0, $v0, 1
	
	packetize_helper_while_update:
		addi $a0, $a0, 1
		lb $s2, ($a0)
		j packetize_helper_while
	
	
	packetize_helper_done:
		li $v1, 1
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		addi $sp, $sp, 20
		jr $ra
	
	packetize_helper_last_done:
		addi $v0, $v0, 1
		li $v1, 0
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		addi $sp, $sp, 20
		jr $ra

# $a0 - packet address to write message 	$ $a1 - payload size	$ a2 - message		$v0 - new address of message
packetize_write_payload:
	
	lb $t0, ($a2)
	packetize_write_payload_while:
		beqz $a1, packetize_write_payload_done
		
		sb $t0, ($a0)
	
	packetize_write_payload_while_update:
		addi $a0, $a0, 1
		addi $a2, $a2, 1
		addi $a1, $a1, -1
		lb $t0, ($a2)
		j packetize_write_payload_while
	
	packetize_write_payload_done:
		move $v0, $a2
		jr $ra

# $a0 - queue address pointing to start of queue	$a1 - index number of newly inserted packet		$v0 - nothing
enqueue_heapify:
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# beginning of queue address original
	sw $s1, 4($sp)	# child index number
	sw $s2, 8($sp)	# parent index number
	sw $s3, 12($sp)	# queue pointer to child packet pointer (double pointer)
	sw $s4, 16($sp)	# queue pointer to parent packet pointer (double pointer
	sw $s5, 20($sp)	# $ra saver
	
	move $s0, $a0
	move $s5, $ra
	move $s1, $a1
	beqz $s1, enqueue_heapify_done	# If we are inserting at index 0. There are no comparisons to be made
	
	enqueue_heapify_while:
		beqz $s1, enqueue_heapify_done	# If the child index is 0, there cannot be any parent
		
		addi $s2, $s1, -1	# $s1 is the current child index
		li $t9, 2
		div $s2, $t9
		mflo $s2		# $s2 now has (child_index_number - 1) // 2	or parent_index
		
		move $a0, $s0
		move $a1, $s1
		move $a2, $s2
		jal queue_parent_child_identify
		move $s3, $v0
		move $s4, $v1
	
		lw $a0,	($v0)	# child packet pointer
		lw $a1, ($v1)	# parent packet pointer
		jal compare_to	# If compare_to is -1, that means parent is greater than child. We must swap the two
		
		li $t9, -1
		bne $v0, $t9, enqueue_heapify_done
		
		lw $t9, ($s3)
		lw $t8, ($s4)
		sw $t9, ($s4)
		sw $t8, ($s3)
		
		move $s1, $s2	# parent now becomes child
		
	enqueue_heapify_while_update:
		j enqueue_heapify_while
	
	
	enqueue_heapify_done:
		move $ra, $s5
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		addi $sp, $sp, 40
		jr $ra


dequeue_heapify:
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# queue original
	sw $s1, 4($sp)	# current packet pointer index
	sw $s2, 8($sp)	# left child index
	sw $s3, 12($sp)	# right child index
	sw $s4, 16($sp) # left child double pointer
	sw $s5, 20($sp) # right child double pounter
	sw $s6, 24($sp) # $ra saver
	sw $s7, 28($sp)	# current packet double pointer
	
	move $s0, $a0
	move $s6, $ra
	
	li $s1, 0
	addi $a0, $a0, 4
	move $s7, $a0
	
	
	dequeue_heapify_while:
		move $a0, $s1
		jal dequeue_heapify_get_children_indices
		move $s2, $v0
		move $s3, $v1
		lh $t9, 2($s0)
		bgt $s2, $t9, dequeue_heapify_done
		bgt $s3, $t9, dequeue_heapify_done
	
		move $a0, $s0
		move $a1, $s2
		move $a2, $s3
		jal dequeue_heapify_get_children
		move $s4, $v0
		move $s5, $v1
	
		lw $t0, ($s4)	# left child packet address
		lw $t1, ($s5)	# right child packet address
	
		beqz $t0, dequeue_heapify_done	# If it doesn't have a left child, it cannot have a right child. Therefore cannot go down.
		beqz $t1, dequeue_heapify_swap_left_child	# If it doesn't have a right child, it only has a left child
		
		move $a0, $t0	# Left
		move $a1, $t1	# Right
		jal compare_to
		
		li $t9, -1
		beq $v0, $t9, dequeue_heapify_right_child_greater_or_equal
		
		beqz $v0, dequeue_heapify_right_child_greater_or_equal
		
		li $t9, 1
		beq $v0, $t9, dequeue_heapify_left_child_greater
		
		li $v0, 10
		syscall
	
	
	dequeue_heapify_done:
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
	
	dequeue_heapify_swap_left_child:	# Swap with left and finish
		lw $t9, ($s7)	
		sw $t0, ($s7)	# Put left child in parent
		sw $t9, ($s4)	# Put parent in left child
		j dequeue_heapify_done
	
	dequeue_heapify_right_child_greater_or_equal:		# Swap with left and return back to while loop
		
		lw $t9, ($s7)	
		sw $t0, ($s7)	# Put left child in parent
		sw $t9, ($s4)	# Put parent in left child
		
		move $s1, $s2	# Reassigning parent to left child index
		move $s7, $s0
		addi $s7, $s7, 4
		
		li $t9, 4
		mult $t9, $s1
		mflo $t9
		add $s7, $s7, $t9	# Reassigning new parent double pointer
		
		j dequeue_heapify_while
	
	dequeue_heapify_left_child_greater:		# Swap with right and return back to while loop
		
		lw $t9, ($s7)	
		sw $t1, ($s7)	# Put right child in parent
		sw $t9, ($s5)	# Put parent in right child
		
		move $s1, $s3	# Reassigning parent to right child index
		move $s7, $s0
		addi $s7, $s7, 4
		
		li $t9, 4
		mult $t9, $s1
		mflo $t9
		add $s7, $s7, $t9	# Reassigning new parent double pointer
		
		j dequeue_heapify_while


assemble_message_helper:
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# message address original
	sw $s1, 4($sp)	# packet address original
	sw $s2, 8($sp)	# payloadSize
	sw $s3, 12($sp)	# fragment_offset
	sw $s4, 16($sp)	# packet payload byteloader
	
	move $s0, $a0
	move $s1, $a1
	
	lh $t9, ($s1)
	addi $s2, $t9, -12	# $s2 now has the payloadSize
	
	lw $t9, 4($s1)
	andi $s3, $t9, 0x00000FFF	# $s3 now has fragment_offset
	
	add $a0, $a0, $s3	# We are now at the start of message[fragment_offset]
	
	move $a1, $s1		
	addi $a1, $s1, 12	# $a1 is now at the start of payload for the packet
	
	lb $s4, ($a1)
	
	assemble_message_helper_while:
		beqz $s2, assemble_message_helper_done
		sb $s4, ($a0)
	
	assemble_message_helper_while_update:
		
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		addi $s2, $s2, -1
		lb $s4, ($a1)
		j assemble_message_helper_while
	
	assemble_message_helper_done:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		addi $sp, $sp, 40
		jr $ra
	


# $a0 - address to start of queue	$a1 - child index	$a2 - parent index packet
# $v0 - pointer to child index packet pointer (double pointer)		$v1 - pointer to parent index packet pointer (double pointer)
queue_parent_child_identify:
	
	addi $a0, $a0, 4	# now pointing to the start of the packets in the queue
	
	li $t9, 4
	mult $t9, $a1
	mflo $t9
	add $v0, $a0, $t9	# $v1 is the pointer to the child index packet pointer (double pointer)
	
	li $t9, 4
	mult $t9, $a2
	mflo $t9
	add $v1, $a0, $t9	# $v1 is the pointer to the parent index packet pointer (double pointer)
	
	jr $ra

# $a0 - index of current packet pointer in array		$v0 - left child index		$v1 - right child index
dequeue_heapify_get_children_indices:
	li $t9, 2
	mult $a0, $t9
	mflo $t9
	addi $v0, $t9, 1
	addi $v1, $t9, 2
	jr $ra

#	$a0 - queue struct		$a1 - left child index		$a2 - right child index		$v0 - left child packet double pointer
#	$v1 - right child packet double pointer		***If left or right child is null, will return 0 for those values
dequeue_heapify_get_children:
	addi $a0, $a0, 4
	
	li $t9, 4
	mult $t9, $a1
	mflo $t9		# What you need to add to get to left index
	
	li $t8, 4
	mult $t8, $a2
	mflo $t8		# What you need to add to get to the right index
	
	add $v0, $a0, $t9
	add $v1, $a0, $t8
	jr $ra
	
	
	
	
	
	
	

# DEBUGGING HELPER FUNCTIONS
print_str:		# $a0 - string
	li $v0, 4
	syscall
	jr $ra

print_char:		# $a0 - char
	li $v0, 11
	syscall
	jr $ra

print_int:		# $a0 - int
	li $v0, 1
	syscall
	jr $ra

print_packet:	# $a0 - packet address	# a1 - payload size
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# packet address
	sw $s1, 4($sp)	# load word register
	sw $s2, 8($sp)	# var 1 register from load word -> addr for while loop
	sw $s3, 12($sp)	# var 2 register from load word -> addr byteloader
	sw $s4, 16($sp) # var 3 register from load word -> half word
	sw $s5, 20($sp) # var 4 register from load word
	sw $s6, 24($sp) # $ra saver
	
	move $s0, $a0
	move $s6, $ra
	
	beqz $a0, print_packet_empty
	
	lw $s1, ($s0)
	andi $s2, $s1, 0x0000FFFF	# total_length
	andi $s3, $s1, 0x0FFF0000	# msg_id
	srl $s3, $s3, 16
	andi $s4, $s1, 0xF0000000	# version
	srl $s4, $s4, 28
	
	jal packet_info_print
	li $a0, '\n'
	jal print_char
	
	jal total_length_print
	move $a0, $s2
	jal print_int
	li $a0, '\n'
	jal print_char
	
	jal msg_id_print
	move $a0, $s3
	jal print_int
	li $a0, '\n'
	jal print_char
	
	jal version_print
	move $a0, $s4
	jal print_int
	li $a0, '\n'
	jal print_char
	
	lw $s1, 4($s0)
	andi $s2, $s1, 0x00000FFF	# fragment_offset
	andi $s3, $s1, 0x003FF000	# protocol
	srl $s3, $s3, 12
	andi $s4, $s1, 0x00C00000	# flags
	srl $s4, $s4, 22
	andi $s5, $s1, 0xFF000000	# priority
	srl $s5, $s5, 24
	
	jal fragment_offset_print
	move $a0, $s2
	jal print_int
	li $a0, '\n'
	jal print_char
	
	jal protocol_print
	move $a0, $s3
	jal print_int
	li $a0, '\n'
	jal print_char
	
	jal flags_print
	move $a0, $s4
	jal print_int
	li $a0, '\n'
	jal print_char
	
	jal priority_print
	move $a0, $s5
	jal print_int
	li $a0, '\n'
	jal print_char
	
	lw $s1, 8($s0)
	andi $s2, $s1, 0x000000FF	# destination_address
	andi $s3, $s1, 0x0000FF00	# source_address
	srl $s3, $s3, 8
	andi $s4, $s1, 0xFFFF0000	# checksum
	srl $s4, $s4, 16
	
	jal dest_addr_print
	move $a0, $s2
	jal print_int
	li $a0, '\n'
	jal print_char
	
	jal src_addr_print
	move $a0, $s3
	jal print_int
	li $a0, '\n'
	jal print_char
	
	jal checksum_print
	move $a0, $s4
	jal print_int
	li $a0, '\n'
	jal print_char
	
	jal payload_print
	
	move $s2, $s0
	addi $s2, $s2, 12
	lb $s3, ($s2)
	
	lh $s4, ($s0)
	addi $s4, $s4, -12	# This way is without the payload size
	
	print_packet_while:
		# beqz $a1, print_packet_done	# This way is if we have the payload size
		beqz $s4, print_packet_done
		beqz $s3, print_packet_done
		
		move $a0, $s3
		li $v0, 11
		syscall
	
	print_packet_while_update:
		addi $s2, $s2, 1
		lb $s3, ($s2)
		addi $s4, $s4, -1	# This way is without the payload size
		# addi $a1, $a1, -1
		j print_packet_while
		
	
	print_packet_done:
		li $a0, '\n'
		li $v0, 11
		syscall
		syscall
		
		move $ra, $s6
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		addi $sp, $sp, 40
		jr $ra
	
	print_packet_empty:
		li $v0, 11
		
		li $a0, 'E'
		syscall
		li $a0, 'm'
		syscall
		li $a0, 'p'
		syscall
		li $a0, 't'
		syscall
		li $a0, 'y'
		syscall
		li $a0, '\n'
		syscall
		syscall
		
		move $ra, $s6
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		addi $sp, $sp, 40
		jr $ra
		
	
	packet_info_print:
		move $t0, $ra
		li $a0, 'P'
		jal print_char
		li $a0, 'a'
		jal print_char
		li $a0, 'c'
		jal print_char
		li $a0, 'k'
		jal print_char
		li $a0, 'e'
		jal print_char
		li $a0, 't'
		jal print_char
		li $a0, ' '
		jal print_char
		li $a0, 'I'
		jal print_char
		li $a0, 'n'
		jal print_char
		li $a0, 'f'
		jal print_char
		li $a0, 'o'
		jal print_char
		move $ra, $t0
		jr $ra
	
	total_length_print:
		move $t0, $ra
		li $a0, 'T'
		jal print_char
		li $a0, 'o'
		jal print_char
		li $a0, 't'
		jal print_char
		li $a0, 'a'
		jal print_char
		li $a0, 'l'
		jal print_char
		li $a0, ' '
		jal print_char
		li $a0, 'L'
		jal print_char
		li $a0, 'e'
		jal print_char
		li $a0, 'n'
		jal print_char
		li $a0, 'g'
		jal print_char
		li $a0, 't'
		jal print_char
		li $a0, 'h'
		jal print_char
		li $a0, ':'
		jal print_char
		li $a0, ' '
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		move $ra, $t0
		jr $ra
	
	msg_id_print:
		move $t0, $ra
		li $a0, 'M'
		jal print_char
		li $a0, 's'
		jal print_char
		li $a0, 'g'
		jal print_char
		li $a0, ' '
		jal print_char
		li $a0, 'I'
		jal print_char
		li $a0, 'D'
		jal print_char
		li $a0, ' '
		jal print_char
		li $a0, '#'
		jal print_char
		li $a0, ':'
		jal print_char
		li $a0, ' '
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		move $ra, $t0
		jr $ra
	
	version_print:
		move $t0, $ra
		li $a0, 'V'
		jal print_char
		li $a0, 'e'
		jal print_char
		li $a0, 'r'
		jal print_char
		li $a0, 's'
		jal print_char
		li $a0, 'i'
		jal print_char
		li $a0, 'o'
		jal print_char
		li $a0, 'n'
		jal print_char
		li $a0, ':'
		jal print_char
		li $a0, ' '
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		move $ra, $t0
		jr $ra
	
	fragment_offset_print:
		move $t0, $ra
		li $a0, 'F'
		jal print_char
		li $a0, 'r'
		jal print_char
		li $a0, 'a'
		jal print_char
		li $a0, 'g'
		jal print_char
		li $a0, 'm'
		jal print_char
		li $a0, 'e'
		jal print_char
		li $a0, 'n'
		jal print_char
		li $a0, 't'
		jal print_char
		li $a0, ' '
		jal print_char
		li $a0, 'O'
		jal print_char
		li $a0, 'f'
		jal print_char
		li $a0, 'f'
		jal print_char
		li $a0, 's'
		jal print_char
		li $a0, 'e'
		jal print_char
		li $a0, 't'
		jal print_char
		li $a0, ':'
		jal print_char
		li $a0, ' '
		jal print_char
		jal print_char
		jal print_char
		move $ra, $t0
		jr $ra
	
	protocol_print:
		move $t0, $ra
		li $a0, 'P'
		jal print_char
		li $a0, 'r'
		jal print_char
		li $a0, 'o'
		jal print_char
		li $a0, 't'
		jal print_char
		li $a0, 'o'
		jal print_char
		li $a0, 'c'
		jal print_char
		li $a0, 'o'
		jal print_char
		li $a0, 'l'
		jal print_char
		li $a0, ':'
		jal print_char
		li $a0, ' '
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		move $ra, $t0
		jr $ra
	
	flags_print:
		move $t0, $ra
		li $a0, 'F'
		jal print_char
		li $a0, 'l'
		jal print_char
		li $a0, 'a'
		jal print_char
		li $a0, 'g'
		jal print_char
		li $a0, 's'
		jal print_char
		li $a0, ':'
		jal print_char
		li $a0, ' '
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		move $ra, $t0
		jr $ra
	
	priority_print:
		move $t0, $ra
		li $a0, 'P'
		jal print_char
		li $a0, 'r'
		jal print_char
		li $a0, 'i'
		jal print_char
		li $a0, 'o'
		jal print_char
		li $a0, 'r'
		jal print_char
		li $a0, 'i'
		jal print_char
		li $a0, 't'
		jal print_char
		li $a0, 'y'
		jal print_char
		li $a0, ':'
		jal print_char
		li $a0, ' '
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		move $ra, $t0
		jr $ra
	
	dest_addr_print:
		move $t0, $ra
		li $a0, 'D'
		jal print_char
		li $a0, 'e'
		jal print_char
		li $a0, 's'
		jal print_char
		li $a0, 't'
		jal print_char
		li $a0, ' '
		jal print_char
		li $a0, 'A'
		jal print_char
		li $a0, 'd'
		jal print_char
		li $a0, 'd'
		jal print_char
		li $a0, 'r'
		jal print_char
		li $a0, 'e'
		jal print_char
		li $a0, 's'
		jal print_char
		li $a0, 's'
		jal print_char
		li $a0, ':'
		jal print_char
		li $a0, ' '
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		move $ra, $t0
		jr $ra
		
	src_addr_print:
		move $t0, $ra
		li $a0, 'S'
		jal print_char
		li $a0, 'o'
		jal print_char
		li $a0, 'u'
		jal print_char
		li $a0, 'r'
		jal print_char
		li $a0, 'c'
		jal print_char
		li $a0, 'e'
		jal print_char
		li $a0, ' '
		jal print_char
		li $a0, 'A'
		jal print_char
		li $a0, 'd'
		jal print_char
		li $a0, 'd'
		jal print_char
		li $a0, 'r'
		jal print_char
		li $a0, 'e'
		jal print_char
		li $a0, 's'
		jal print_char
		li $a0, 's'
		jal print_char
		li $a0, ':'
		jal print_char
		li $a0, ' '
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		move $ra, $t0
		jr $ra
	
	checksum_print:
		move $t0, $ra
		li $a0, 'C'
		jal print_char
		li $a0, 'h'
		jal print_char
		li $a0, 'e'
		jal print_char
		li $a0, 'c'
		jal print_char
		li $a0, 'k'
		jal print_char
		li $a0, 's'
		jal print_char
		li $a0, 'u'
		jal print_char
		li $a0, 'm'
		jal print_char
		li $a0, ':'
		jal print_char
		li $a0, ' '
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		move $ra, $t0
		jr $ra
	
	payload_print:
		move $t0, $ra
		li $a0, 'P'
		jal print_char
		li $a0, 'a'
		jal print_char
		li $a0, 'y'
		jal print_char
		li $a0, 'l'
		jal print_char
		li $a0, 'o'
		jal print_char
		li $a0, 'a'
		jal print_char
		li $a0, 'd'
		jal print_char
		li $a0, ':'
		jal print_char
		li $a0, ' '
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		jal print_char
		move $ra, $t0
		jr $ra

# $a0 - queue address
print_queue:
	addi $sp, $sp, -40
	sw $s0, 0($sp)	# queue modified ($a0 is original)
	sw $s1, 4($sp)	# max queue size
	sw $s2, 8($sp)	# queue word loader
	sw $s3, 12($sp) # $ra saver
	
	move $s3, $ra
	move $s0, $a0
	lh $s1, 2($a0)
	addi $s0, $s0, 4
	
	print_queue_while:
		beqz $s1, print_queue_while_done
		
		
		lw $a0, ($s0)
		jal print_packet
		
		#li $v0, 34
		#syscall
		
		#li $a0, '\n'
		#li $v0, 11
		#syscall
	
	print_queue_while_update:
		addi $s1, $s1, -1
		addi $s0, $s0, 4
		j print_queue_while
	
	
	print_queue_while_done:
		move $ra, $s3
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		addi $sp, $sp, 40
		jr $ra

	



#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
