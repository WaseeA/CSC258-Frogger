
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
vehicle_space:	.space	36

.text
lw $s7, displayAddress
li $s6, 0xff0000 # red
li $s5, 0x00ff00 # green
li $s4, 0x0000ff # blue
li $s3, 0x686868 # grey
li $s2, 0xffffff # white
			
# Main
main:	
	### Goal Region
	la	$t0,	i		#load addr of i
	sw	$zero,	0($t0)
	addi 	$t2,	$zero,	0 	
	addi	$t9,	$zero,	192
	add	$a3,	$zero,	$s5
	jal draw_rect_loop
	### Water
	la	$t0,	i		#load addr of i
	sw	$zero,	0($t0)
	addi 	$t2,	$zero,	192	
	addi	$t9,	$zero,	384
	add	$a3,	$zero,	$s4
	jal draw_rect_loop
	### Safe
	la	$t0,	i		#load addr of i
	sw	$zero,	0($t0)
	addi 	$t2,	$zero,	384	
	addi	$t9,	$zero,	576
	add	$a3,	$zero,	$s5
	jal draw_rect_loop
	### Road
	#Vehicles
	
	# The Road itself
	la	$t0,	i		#load addr of i
	sw	$zero,	0($t0)
	addi 	$t2,	$zero,	576	
	addi	$t9,	$zero,	768
	add	$a3,	$zero,	$s3
	jal draw_rect_loop
	### Start
	la	$t0,	i		#load addr of i
	sw	$zero,	0($t0)
	addi 	$t2,	$zero,	768	
	addi	$t9,	$zero,	960
	add	$a3,	$zero,	$s5
	jal draw_rect_loop
	
	### Draw Frog

	
	lw	$s7,	displayAddress	#reset display addr
	la	$t3,	frogX		#load addr of frog_x
	la	$t4,	frogY		#load addr of frog_y
	
	jal 	draw_frog
	
	li $v0, 32
	li $a0, 2000
	syscall
	
	j main

#########################################################
draw_rect_loop:	
	beq	$t2,	$t9,	draw_rect_exit
	sw 	$a3, 	0($s7)		# draw rect
	addi	$s7,	$s7,	4	# increment address by 4
	addi	$t2,	$t2,	1
	j draw_rect_loop

draw_rect_exit:
	jr	$ra

draw_frog:
	# get value of frogX and frogY
	lw	$s0,	0($t3)
	lw	$s1,	0($t4)
	# increment by 20
	addi	$a0,	$a0,	20
	addi	$a1,	$a1,	20
	
	add	$s7,	$s7,	$a0	# s7 cgets changed)
	add	$s7,	$s7,	$a1
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
	
	jr $ra

########################################################



########################################################
# Exit Function	
Exit:
	li 	$v0,	10
	syscall