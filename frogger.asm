#####################################################################
#
# CSC258H5S Fall 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Wasee Alam, 1007104928
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
# Milestone 4
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Objects like Arcade
# 2. Different log speeds
# 3. Sound
# ... (add more if necessary)
# no more :(
## Any additional information that the TA needs to know:
# - It will be evident in the demo but the frog jumps two units intstead of one.
# This is because it is easier for the player, 1 unit is hard.
# - The black bar on the bottom was intentional, it was space intended to show the score.
#####################################################################

# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.data
displayAddress: .word 0x10008000
i:	.space	4	# random loop var
frogX:	.word	60
frogY:	.word	3456
vehicle_space:	.space	60	# 5x3 = 15 (5x3 vehicles), 15 * 2 = 30 (2 vehicles) 30 *2 = 60 (2 rows)
log_space:	.space	60	# 5x3 = 15 (5x3 vehicles), 15 * 2 = 30 (2 vehicles) 30 *2 = 60 (2 rows)
death_sound:	.byte 	61
game_over:	.byte	95
strings:	.byte   40
win_instrument: .byte   107
win_sound:	.byte   61
move_sound:	.byte   65
move_loudness:  .byte	64
win_length:	.byte	1000
move_instrument: .byte  58

.text
lw $s7, displayAddress

add	$t1,	$zero,	$zero
add	$t5,	$zero,	$zero
add	$t4,	$zero,	$zero
add	$t3,	$zero,	$zero
add	$k1,	$zero,	$zero 	# lives
add	$s4,	$zero,	$zero

# temp variable: $s6
# $t2, $t8: keyboard input
# $a0, $a1 used for moving frog
# 
		
keyboard_input:
	lw $t2, 0xffff0004
	beq $t2, 0x77, respond_to_W
	beq $t2, 0x61, respond_to_A
	beq $t2, 0x64, respond_to_D
	beq $t2, 0x73, respond_to_S
	j main	# if we don't get a valid input go to main again

respond_to_W:
	# increment by 8
	add	$s6,	$a0,	$zero
	add	$t7,	$a1,	$zero
	li   $v0, 31       # system call for collision
	la   $a0, move_sound    
	la   $a2, move_instrument
	la   $a3, move_loudness
	syscall
	
	add	$a0,	$zero,	$s6
	add	$a1,	$zero,	$t7
	
	addi	$a0,	$a0,	0
	addi	$a1,	$a1,	-256
	
	addi     $s4,	$s4 	10
	
	beq 	$a1,	$zero,	wrap_handler_vertical
	j main

respond_to_A:
	add	$s6,	$a0,	$zero
	add	$t7,	$a1,	$zero
	li   $v0, 31       # system call for collision
	la   $a0, move_sound    
	la   $a2, move_instrument
	la   $a3, move_loudness
	syscall
	
	add	$a0,	$zero,	$s6
	add	$a1,	$zero,	$t7
	
	beq 	$a0,	-128,	wrap_handler_horizontal
	# increment by 8
	addi	$a0,	$a0,	-8
	addi	$a1,	$a1,	0
	
	j main

respond_to_S:
	add	$s6,	$a0,	$zero
	add	$t7,	$a1,	$zero
	li   $v0, 31       # system call for collision
	la   $a0, move_sound    
	la   $a2, move_instrument
	la   $a3, move_loudness
	syscall
	
	add	$a0,	$zero,	$s6
	add	$a1,	$zero,	$t7
	
	addi     $s4,	$s4 	-10
	
	beq 	$a1,	3456,	wrap_handler_vertical
	# increment by 8
	addi	$a0,	$a0,	0
	addi	$a1,	$a1,	256
	
	j main
	
respond_to_D:
	add	$s6,	$a0,	$zero
	add	$t7,	$a1,	$zero
	li   $v0, 31       # system call for collision
	la   $a0, move_sound    
	la   $a2, move_instrument
	la   $a3, move_loudness
	syscall
	
	add	$a0,	$zero,	$s6
	add	$a1,	$zero,	$t7
	
	beq 	$a0,	128,	wrap_handler_horizontal
	# increment by 8
	addi	$a0,	$a0,	8
	addi	$a1,	$a1,	0
	
	j main

lives:
	li	$a3,	0xffffff
	sw 	$a3, 	-4($s7)		# draw rect
	sw 	$a3, 	0($s7)		# draw rect
	sw 	$a3, 	4($s7)		# draw rect
	
	sw 	$a3, 	-132($s7)		# draw rect
	sw 	$a3, 	-128($s7)		# draw rect
	sw 	$a3, 	-124($s7)		# draw rect
	
	# sound
	li   $v0, 31       # system call for open file
	la   $a0, death_sound     # output file name  
	syscall
	
	# reset frog
	lw	$s7,	displayAddress	#reset display addr
	la	$k0,	frogX		#load addr of frog_x
	la	$t9,	frogY		#load addr of frog_y
	# reset position of frog movement
	add	$a0,	$zero,	$zero
	add	$a1,	$zero,	$zero
	
	jal 	draw_frog
	addi	$s5,	$s5,	1
	beq	$s5,	3,	death_loop

# Main
main:	
	# check for keyboard input
	lw $t8, 0xffff0000
	beq $t8, 1, keyboard_input
	
	### Goal Region
	
	lw	$t2,	displayAddress	#reset display addr
	lw	$t9,	displayAddress	#reset display addr
	
	addi 	$t2,	$t2,	0 	
	addi	$t9,	$t9,	192
	
	li	$a3,	0x00ff7f
	jal draw_rect_loop
	jal draw_square
	
	### Water
	lw	$t2,	displayAddress	#reset display addr
	lw	$t9,	displayAddress	#reset display addr
	
	addi 	$t2,	$t2,	192	
	addi	$t9,	$t9,	384
	
	li	$a3,	0x0000ff	# blue
	jal draw_rect_loop
	### Safe
	
	lw	$t2,	displayAddress	#reset display addr
	lw	$t9,	displayAddress	#reset display addr
	
	addi 	$t2,	$t2,	384	
	addi	$t9,	$t9,	576
	
	li	$a3,	0x00ff00
	jal draw_rect_loop
	### Road
	lw	$t2,	displayAddress	#reset display addr
	lw	$t9,	displayAddress	#reset display addr
	
	addi 	$t2,	$t2,	576	
	addi	$t9,	$t9,	768
	
	li	$a3,	0x686868	# grey
	jal draw_rect_loop
	
	### Start
	la	$t0,	i		#load addr of i
	sw	$zero,	0($t0)
	
	lw	$t2,	displayAddress	#reset display addr
	lw	$t9,	displayAddress	#reset display addr
	
	addi 	$t2,	$t2,	768	
	addi	$t9,	$t9,	960
	
	li	$a3,	0x00ff00
	jal draw_rect_loop
	
	### Draw logs
	li $a3, 0xd2b48c	# brown
	
	lw	$s7,	displayAddress	#reset display addr
	addi 	$s7,	$s7,	768	#increment to the desired spot.
	add	$t1,	$t1,	4
	jal draw_log
	
	lw	$s7,	displayAddress	#reset display addr
	addi 	$s7,	$s7,	832	#increment to the desired spot.
	add	$t3,	$t3,	4
	jal draw_log_indent
	
	li 	$a3,	0xdeb887 
	
	lw	$s7,	displayAddress	#reset display addr
	addi 	$s7,	$s7,	1148	#increment to the desired spot.
	add	$t5,	$t5,	4
	jal draw_log_reverse
	
	lw	$s7,	displayAddress	#reset display addr
	addi 	$s7,	$s7,	1200	#increment to the desired spot.
	add	$t4,	$t4,	4
	jal draw_log_indent_reverse
	
	### Draw Vehicles
	
	li	$a3,	0x8fce00 # car green
	
	lw	$s7,	displayAddress	#reset display addr
	addi 	$s7,	$s7,	2304	#increment to the desired spot.
	jal draw_vehicles
	
	lw	$s7,	displayAddress	#reset display addr
	addi 	$s7,	$s7,	2368	#increment to the desired spot.
	jal draw_vehicles_indent
	
	lw	$s7,	displayAddress	#reset display addr
	addi 	$s7,	$s7,	2688	#increment to the desired spot.
	add	$t5,	$t5,	4
	jal draw_vehicles_reverse
	
	lw	$s7,	displayAddress	#reset display addr
	addi 	$s7,	$s7,	2752	#increment to the desired spot.
	add	$t4,	$t4,	4
	jal draw_vehicles_indent_reverse
	
	### Draw Frog
	lw	$s7,	displayAddress	#reset display addr
	la	$k0,	frogX		#load addr of frog_x
	la	$t9,	frogY		#load addr of frog_y
	
	jal 	draw_frog

	
	### Sleep
	add	$s6,	$a0,	$zero 	# temporarily save a0
	li $v0, 32	
	li $a0, 32			#TODO: use 32 for 60 fps
	syscall
	add	$a0,	$s6,	$zero 	# reset a0
	
	j main

#########################################################
check_collision:
	# collison event
	lw $s6, 0($s7) # load colour into t4
	
	li	$a3,	0x0000ff	# load blue
	beq $s6, $a3, lives # if we touch water exit
	
	# check if we are on a log
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal move_frog_with_log
	lw $ra, 0($sp)
	addi $sp, $sp, 4 
	
	li    $a3,    0x8fce00    # load green
    	beq $s6, $a3, lives #
   	lw $s6, 8($s7) # right corner
   	beq $s6, $a3, lives # if we touch car exit
    	lw $s6, 136($s7) # bottom left corner
    	beq $s6, $a3, lives # if we touch car exit
    	lw $s6, 264($s7) # bottom right corner
    	beq $s6, $a3, lives # if we touch car exitexit
	
	li	$a3,	0x00ff7f	# load red
	beq $s6, $a3, Win # if we touch goal exit
	
	
	jr $ra
#########################################################
draw_rect_loop:	
	# begin the loop
	beq	$t2,	$t9,	draw_rect_exit
	sw 	$a3, 	0($s7)		# draw rect
	addi	$s7,	$s7,	4	# increment address by 4
	addi	$t2,	$t2,	1	# increment the loop condition
	j draw_rect_loop
draw_rect_exit:
	jr	$ra

draw_square:
	addi 	$t2,	$t2,	0 
	addi	$s7,	$s7,	-64
	li	$a3,	0x0000ff
	sw 	$a3, 	-4($s7)		# draw rect
	sw 	$a3, 	0($s7)		# draw rect
	sw 	$a3, 	4($s7)		# draw rect
	addi	$s7,	$s7,	64
	
	addi	$s7,	$s7,	-32
	li	$a3,	0x0000ff
	sw 	$a3, 	-4($s7)		# draw rect
	sw 	$a3, 	0($s7)		# draw rect
	sw 	$a3, 	4($s7)		# draw rect
	addi	$s7,	$s7,	32
	
	addi	$s7,	$s7,	-96
	li	$a3,	0x0000ff
	sw 	$a3, 	-4($s7)		# draw rect
	sw 	$a3, 	0($s7)		# draw rect
	sw 	$a3, 	4($s7)		# draw rect
	addi	$s7,	$s7,	96
	
	jr	$ra

move_frog_with_log:
	# top logs
	li	$a3,	0xd2b48c		# load white
	beq $s6, $a3, move_frog_with_log_right
	# bot logs
	li	$a3,	0xdeb887		# load white
	beq $s6, $a3, move_frog_with_log_left
	jr $ra
move_frog_with_log_right: 
	addi	$a0,	$a0,	4
	jr $ra
move_frog_with_log_left: 
	addi	$a0,	$a0,	-8
	jr $ra

draw_frog:
	# get value of frogX and frogY
	lw	$s0,	0($k0)
	lw	$s1,	0($t9)
	add	$s7,	$s7,	$s0
	add	$s7,	$s7,	$s1
	
	# s7 gets changed
	add	$s7,	$s7,	$a0	
	add	$s7,	$s7,	$a1
	
	# stack nonsense (check for a collision)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal check_collision
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	# draw the frog	
	li $a3,	0x8e7cc3	# purple
	
	sw	$a3,	0($s7)	# source, offset(destination)
	sw	$a3,	4($s7)
	sw	$a3,	8($s7)
#	sw	$a3,	128($s7)
	sw	$a3,	132($s7)
#	sw	$a3,	136($s7)
	sw	$a3,	256($s7)
	sw	$a3,	260($s7)
	sw	$a3,	264($s7)
	
	# reset the display address, since we don't want the bckgrnd to change.
	sub	$s7,	$s7,	$a0
	sub	$s7,	$s7,	$a1
	sub	$s7,	$s7,	$s0
	sub	$s7,	$s7,	$s1
	
	jr $ra

draw_vehicles:
	# draw car
	beq	$t1,	128,	wrap_handler_vehicle # it checks the left corner so we have to adjust for taht
	add	$s7,	$s7,	$t1
	sw	$a3,	0($s7)	
#	sw	$a3,	4($s7)	
	sw	$a3,	8($s7)
	sw	$a3,	12($s7)
#	sw	$a3,	16($s7)
	sw	$a3,	20($s7)
	sw	$a3,	128($s7)	
	sw	$a3,	132($s7)
	sw	$a3,	136($s7)	
	sw	$a3,	140($s7)
	sw	$a3,	144($s7)
	sw	$a3,	148($s7)
	sw	$a3,	256($s7)	
#	sw	$a3,	260($s7)
	sw	$a3,	264($s7)	
	sw	$a3,	268($s7)
#	sw	$a3,	272($s7)
	sw	$a3,	276($s7)
	# reset s7
	sub	$s7,	$s7,	$t1
	jr $ra

draw_vehicles_reverse:
	# draw car
	beq	$t5,	4,	wrap_handler_vehicle_reverse # it checks the left corner so we have to adjust for taht
	sub	$s7,	$s7,	$t5
	sw	$a3,	0($s7)	
#	sw	$a3,	4($s7)	
	sw	$a3,	8($s7)
	sw	$a3,	12($s7)
#	sw	$a3,	16($s7)
	sw	$a3,	20($s7)
	sw	$a3,	128($s7)	
	sw	$a3,	132($s7)
	sw	$a3,	136($s7)	
	sw	$a3,	140($s7)
	sw	$a3,	144($s7)
	sw	$a3,	148($s7)
	sw	$a3,	256($s7)	
#	sw	$a3,	260($s7)
	sw	$a3,	264($s7)	
	sw	$a3,	268($s7)
#	sw	$a3,	272($s7)
	sw	$a3,	276($s7)
	# reset s7
	add	$s7,	$s7,	$t5
	jr $ra
	
draw_vehicles_indent:
	# draw car
	beq	$t3,	60,	wrap_handler_vehicle_indent # it checks the left corner so we have to adjust for taht
	add	$s7,	$s7,	$t3
	sw	$a3,	0($s7)	
#	sw	$a3,	4($s7)	
	sw	$a3,	8($s7)
	sw	$a3,	12($s7)
#	sw	$a3,	16($s7)
	sw	$a3,	20($s7)
	sw	$a3,	128($s7)	
	sw	$a3,	132($s7)
	sw	$a3,	136($s7)	
	sw	$a3,	140($s7)
	sw	$a3,	144($s7)
	sw	$a3,	148($s7)
	sw	$a3,	256($s7)	
#	sw	$a3,	260($s7)
	sw	$a3,	264($s7)	
	sw	$a3,	268($s7)
#	sw	$a3,	272($s7)
	sw	$a3,	276($s7)
	# reset s7
	sub	$s7,	$s7,	$t3
	jr $ra

draw_vehicles_indent_reverse:
	# draw car
	beq	$t4,	72,	wrap_handler_vehicle_indent_reverse # it checks the left corner so we have to adjust for taht
	sub	$s7,	$s7,	$t4
	sw	$a3,	0($s7)	
#	sw	$a3,	4($s7)	
	sw	$a3,	8($s7)
	sw	$a3,	12($s7)
#	sw	$a3,	16($s7)
	sw	$a3,	20($s7)
	sw	$a3,	128($s7)	
	sw	$a3,	132($s7)
	sw	$a3,	136($s7)	
	sw	$a3,	140($s7)
	sw	$a3,	144($s7)
	sw	$a3,	148($s7)
	sw	$a3,	256($s7)	
#	sw	$a3,	260($s7)
	sw	$a3,	264($s7)	
	sw	$a3,	268($s7)
#	sw	$a3,	272($s7)
	sw	$a3,	276($s7)
	# reset s7
	add	$s7,	$s7,	$t4
	jr $ra

draw_log:
	# draw car
	beq	$t1,	128,	wrap_handler_vehicle # it checks the left corner so we have to adjust for taht
	add	$s7,	$s7,	$t1
	sw	$a3,	0($s7)	
	sw	$a3,	4($s7)	
	sw	$a3,	8($s7)
	sw	$a3,	12($s7)
	sw	$a3,	16($s7)
	sw	$a3,	20($s7)
	sw	$a3,	128($s7)	
	sw	$a3,	132($s7)
	sw	$a3,	136($s7)	
	sw	$a3,	140($s7)
	sw	$a3,	144($s7)
	sw	$a3,	148($s7)
	sw	$a3,	256($s7)	
	sw	$a3,	260($s7)
	sw	$a3,	264($s7)	
	sw	$a3,	268($s7)
	sw	$a3,	272($s7)
	sw	$a3,	276($s7)
	# reset s7
	sub	$s7,	$s7,	$t1
	jr $ra

draw_log_reverse:
	# draw car
	beq	$t5,	4,	wrap_handler_vehicle_reverse # it checks the left corner so we have to adjust for taht
	sub	$s7,	$s7,	$t5
	sw	$a3,	0($s7)	
	sw	$a3,	4($s7)	
	sw	$a3,	8($s7)
	sw	$a3,	12($s7)
	sw	$a3,	16($s7)
	sw	$a3,	20($s7)
	sw	$a3,	128($s7)	
	sw	$a3,	132($s7)
	sw	$a3,	136($s7)	
	sw	$a3,	140($s7)
	sw	$a3,	144($s7)
	sw	$a3,	148($s7)
	sw	$a3,	256($s7)	
	sw	$a3,	260($s7)
	sw	$a3,	264($s7)	
	sw	$a3,	268($s7)
	sw	$a3,	272($s7)
	sw	$a3,	276($s7)
	# reset s7
	add	$s7,	$s7,	$t5
	jr $ra
	
draw_log_indent:
	# draw car
	beq	$t3,	60,	wrap_handler_vehicle_indent # it checks the left corner so we have to adjust for taht
	add	$s7,	$s7,	$t3
	sw	$a3,	0($s7)	
	sw	$a3,	4($s7)	
	sw	$a3,	8($s7)
	sw	$a3,	12($s7)
	sw	$a3,	16($s7)
	sw	$a3,	20($s7)
	sw	$a3,	128($s7)	
	sw	$a3,	132($s7)
	sw	$a3,	136($s7)	
	sw	$a3,	140($s7)
	sw	$a3,	144($s7)
	sw	$a3,	148($s7)
	sw	$a3,	256($s7)	
	sw	$a3,	260($s7)
	sw	$a3,	264($s7)	
	sw	$a3,	268($s7)
	sw	$a3,	272($s7)
	sw	$a3,	276($s7)
	# reset s7
	sub	$s7,	$s7,	$t3
	jr $ra

draw_log_indent_reverse:
	# draw car
	beq	$t4,	72,	wrap_handler_vehicle_indent_reverse # it checks the left corner so we have to adjust for taht
	sub	$s7,	$s7,	$t4
	sw	$a3,	0($s7)	
	sw	$a3,	4($s7)	
	sw	$a3,	8($s7)
	sw	$a3,	12($s7)
	sw	$a3,	16($s7)
	sw	$a3,	20($s7)
	sw	$a3,	128($s7)	
	sw	$a3,	132($s7)
	sw	$a3,	136($s7)	
	sw	$a3,	140($s7)
	sw	$a3,	144($s7)
	sw	$a3,	148($s7)
	sw	$a3,	256($s7)	
	sw	$a3,	260($s7)
	sw	$a3,	264($s7)	
	sw	$a3,	268($s7)
	sw	$a3,	272($s7)
	sw	$a3,	276($s7)
	# reset s7
	add	$s7,	$s7,	$t4
	jr $ra

########################################################
wrap_handler_vehicle:
	subi	$t1,	$t1, 	128
	j draw_vehicles

wrap_handler_vehicle_indent:
	subi	$t3,	$t3,	128
	j draw_vehicles_indent

wrap_handler_vehicle_reverse:
	subi	$t5,	$t5,	128
	j draw_vehicles_reverse

wrap_handler_vehicle_indent_reverse:
	subi	$t4,	$t4,	128
	j draw_vehicles_indent_reverse


wrap_handler_horizontal:
	# this will not loop infinitely, since when we jump to frog a0 has changed.
	add	$a0,	$zero,	$zero
	addi	$a0,	$zero,	-8
	addi	$a1,	$zero,	128
	j draw_frog

wrap_handler_vertical:
	# do not move if we are trying to escape the bounds
	addi	$a0,	$a0,	0
	addi	$a1,	$a1,	0
	j draw_frog

########################################################
# Exit Function	
death_loop:
	# sleep
	li $v0, 32	
	li $a0, 500			#TODO: use 32 for 60 fps
	syscall
	
	# sound
	li   $v0, 31       # system call for file
	la   $a0, game_over     # output file name  
	la   $a2, strings
	syscall
	j Exit

Win:
	li $v0, 32	
	li $a0, 500			#TODO: use 32 for 60 fps
	syscall
	
	li   $v0, 31       # system call for collision
	la   $a0, win_sound     # output file name 
	la   $a1, win_length 
	la   $a2, win_instrument
	syscall
	j Exit

Exit:
	lw $s7, displayAddress
	### Goal Region
	la	$t0,	i		#load addr of i
	sw	$zero,	0($t0)
	
	lw	$t2,	displayAddress	#reset display addr
	lw	$t9,	displayAddress	#reset display addr
	
	addi 	$t2,	$t2,	0 	
	addi	$t9,	$t9,	192
	
	li	$a3,	0x00ff7f
	jal draw_rect_loop
	jal draw_square
	
	### Water
	la	$t0,	i		#load addr of i
	sw	$zero,	0($t0)
	
	lw	$t2,	displayAddress	#reset display addr
	lw	$t9,	displayAddress	#reset display addr
	
	addi 	$t2,	$t2,	192	
	addi	$t9,	$t9,	384
	
	li	$a3,	0x0000ff	# blue
	jal draw_rect_loop
	### Safe
	la	$t0,	i		#load addr of i
	sw	$zero,	0($t0)
	
	lw	$t2,	displayAddress	#reset display addr
	lw	$t9,	displayAddress	#reset display addr
	
	addi 	$t2,	$t2,	384	
	addi	$t9,	$t9,	576
	
	li	$a3,	0x00ff00
	jal draw_rect_loop
	### Road
	la	$t0,	i		#load addr of i
	sw	$zero,	0($t0)
	
	lw	$t2,	displayAddress	#reset display addr
	lw	$t9,	displayAddress	#reset display addr
	
	addi 	$t2,	$t2,	576	
	addi	$t9,	$t9,	768
	
	li	$a3,	0x686868	# grey
	jal draw_rect_loop
	
	### Start
	la	$t0,	i		#load addr of i
	sw	$zero,	0($t0)
	
	lw	$t2,	displayAddress	#reset display addr
	lw	$t9,	displayAddress	#reset display addr
	
	addi 	$t2,	$t2,	768	
	addi	$t9,	$t9,	960
	
	li	$a3,	0x00ff00
	jal draw_rect_loop
	
	li 	$v0,	10
	syscall
