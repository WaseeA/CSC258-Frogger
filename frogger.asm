
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
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
## Any additional information that the TA needs to know:
# - (write here, if any)
#
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
vehicle_space:	.space	36	# 3x3 = 9 (3x3 vehicles), 9 * 2 = 18 (2 vehicles) 18 *2 = 36 (2 rows)

.text
lw $s7, displayAddress
li $s5, 0x00ff00 # green
li $s4, 0x0000ff # blue
li $s3, 0x686868 # grey
li $s2, 0xffffff # white

add	$t1,	$zero,	$zero
add	$t5,	$zero,	$zero

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
	#beq 	$a1,	$zero,	wrap_handler_vertical
	# increment by 8
	addi	$a0,	$a0,	0
	addi	$a1,	$a1,	-128
	j main

respond_to_A:
	beq 	$a0,	-128,	wrap_handler_horizontal
	beq	$a0,	$zero,	wrap_handler_horizontal
	# increment by 8
	addi	$a0,	$a0,	-8
	addi	$a1,	$a1,	0
	
	j main

respond_to_S:
	beq 	$a1,	3456,	wrap_handler_vertical
	# increment by 8
	addi	$a0,	$a0,	0
	addi	$a1,	$a1,	128
	
	j main
	
respond_to_D:
	beq 	$a0,	128,	wrap_handler_horizontal
	# increment by 8
	addi	$a0,	$a0,	8
	addi	$a1,	$a1,	0
	
	j main

# Main
main:	
	# check for keyboard input
	lw $t8, 0xffff0000
	beq $t8, 1, keyboard_input
	
	### Goal Region
	la	$t0,	i		#load addr of i
	sw	$zero,	0($t0)
	
	lw	$t2,	displayAddress	#reset display addr
	lw	$t9,	displayAddress	#reset display addr
	
	addi 	$t2,	$t2,	0 	
	addi	$t9,	$t9,	192
	add	$a3,	$zero,	$s5
	jal draw_rect_loop
	
	### Water
	la	$t0,	i		#load addr of i
	sw	$zero,	0($t0)
	
	lw	$t2,	displayAddress	#reset display addr
	lw	$t9,	displayAddress	#reset display addr
	
	addi 	$t2,	$t2,	192	
	addi	$t9,	$t9,	384
	add	$a3,	$zero,	$s4
	jal draw_rect_loop
	### Safe
	la	$t0,	i		#load addr of i
	sw	$zero,	0($t0)
	
	lw	$t2,	displayAddress	#reset display addr
	lw	$t9,	displayAddress	#reset display addr
	
	addi 	$t2,	$t2,	384	
	addi	$t9,	$t9,	576
	add	$a3,	$zero,	$s5
	jal draw_rect_loop
	### Road
	la	$t0,	i		#load addr of i
	sw	$zero,	0($t0)
	
	lw	$t2,	displayAddress	#reset display addr
	lw	$t9,	displayAddress	#reset display addr
	
	addi 	$t2,	$t2,	576	
	addi	$t9,	$t9,	768
	add	$a3,	$zero,	$s3
	jal draw_rect_loop
	
	### Start
	la	$t0,	i		#load addr of i
	sw	$zero,	0($t0)
	
	lw	$t2,	displayAddress	#reset display addr
	lw	$t9,	displayAddress	#reset display addr
	
	addi 	$t2,	$t2,	768	
	addi	$t9,	$t9,	960
	add	$a3,	$zero,	$s5
	jal draw_rect_loop
	
	### Draw Vehicles
	lw	$s7,	displayAddress	#reset display addr
	addi 	$s7,	$s7,	768	#increment to the desired spot.
	add	$t1,	$t1,	4
	jal draw_vehicles
	
	lw	$s7,	displayAddress	#reset display addr
	addi 	$s7,	$s7,	1148	#increment to the desired spot.
	add	$t5,	$t5,	-4
	jal draw_vehicles_reverse
	
	### Draw Frog
	lw	$s7,	displayAddress	#reset display addr
	la	$t3,	frogX		#load addr of frog_x
	la	$t4,	frogY		#load addr of frog_y
	
	jal 	draw_frog
	
	### Sleep
	add	$s6,	$a0,	$zero 	# temporarily save a0
	li $v0, 32	
	li $a0, 500			#TODO: use 32 for 60 fps
	syscall
	add	$a0,	$s6,	$zero 	# reset a0
	
	j main

#########################################################
check_collision:
	# collison event
	lw $s6, 0($s7) # load colour into t4
	beq $s6, $s4, Exit # if the colour is blue exit
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

draw_frog:
	# get value of frogX and frogY
	lw	$s0,	0($t3)
	lw	$s1,	0($t4)
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
	sw	$s2,	0($s7)	# source, offset(destination)
	sw	$s2,	4($s7)
	sw	$s2,	8($s7)
	sw	$s2,	128($s7)
	sw	$s2,	132($s7)
	sw	$s2,	136($s7)
	sw	$s2,	256($s7)
	sw	$s2,	260($s7)
	sw	$s2,	264($s7)
	
	# reset the display address, since we don't want the bckgrnd to change.
	sub	$s7,	$s7,	$a0
	sub	$s7,	$s7,	$a1
	sub	$s7,	$s7,	$s0
	sub	$s7,	$s7,	$s1
	
	jr $ra

draw_vehicles:
	# draw car
	beq	$t1,	116,	wrap_handler_vehicle # it checks the left corner so we have to adjust for taht
	add	$s7,	$s7,	$t1
	sw	$s2,	0($s7)	
	sw	$s2,	4($s7)	
	sw	$s2,	8($s7)
	sw	$s2,	12($s7)
	sw	$s2,	16($s7)
	sw	$s2,	20($s7)
	sw	$s2,	24($s7)
	sw	$s2,	28($s7)
	sw	$s2,	128($s7)	
	sw	$s2,	132($s7)
	sw	$s2,	136($s7)	
	sw	$s2,	140($s7)
	sw	$s2,	144($s7)
	sw	$s2,	148($s7)
	sw	$s2,	152($s7)
	sw	$s2,	156($s7)
	sw	$s2,	256($s7)	
	sw	$s2,	260($s7)
	sw	$s2,	264($s7)	
	sw	$s2,	268($s7)
	sw	$s2,	272($s7)
	sw	$s2,	276($s7)
	sw	$s2,	280($s7)
	sw	$s2,	284($s7)
	# reset s7
	sub	$s7,	$s7,	$t1
	jr $ra

draw_vehicles_reverse:
	# draw car
	beq	$t5,	-4,	wrap_handler_vehicle_reverse # it checks the left corner so we have to adjust for taht
	add	$s7,	$s7,	$t5
	sw	$s2,	0($s7)	
	sw	$s2,	4($s7)	
	sw	$s2,	8($s7)
	sw	$s2,	12($s7)
	sw	$s2,	16($s7)
	sw	$s2,	20($s7)
	sw	$s2,	24($s7)
	sw	$s2,	28($s7)
	sw	$s2,	128($s7)	
	sw	$s2,	132($s7)
	sw	$s2,	136($s7)	
	sw	$s2,	140($s7)
	sw	$s2,	144($s7)
	sw	$s2,	148($s7)
	sw	$s2,	152($s7)
	sw	$s2,	156($s7)
	sw	$s2,	256($s7)	
	sw	$s2,	260($s7)
	sw	$s2,	264($s7)	
	sw	$s2,	268($s7)
	sw	$s2,	272($s7)
	sw	$s2,	276($s7)
	sw	$s2,	280($s7)
	sw	$s2,	284($s7)
	# reset s7
	sub	$s7,	$s7,	$t5
	jr $ra
########################################################
wrap_handler_vehicle:
	subi	$t1,	$t1,	128
	j draw_vehicles

wrap_handler_vehicle_reverse:
	addi	$t5,	$t5,	128
	j draw_vehicles

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
Exit:
	li 	$v0,	10
	syscall
