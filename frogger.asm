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

# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)

.data
displayAddress:	.word 0x10008000
RESULT_FROG:	.word 0
gr:	.space	4
wr:	.space 	4
sr:	.space	4
rr:	.space	4
s:	.space	4

.text
lw $t0, displayAddress  # $t0 stores the base address for display
li $t1, 0xff0000 	# $t1 stores the red colour code
li $t2, 0x00ff00 	# $t2 stores the green colour code
li $t3, 0x0000ff 	# $t3 stores the blue colour code
li $t7, 0xffffff	# $t7 stores the white colour code
li $t8, 0x00ffff	# $t4 stores aqua colour code

sw $t1, 0($t0)		# paint the first (top-left) unit red. (store t1 in t0 with offset 0)
sw $t2, 4($t0)		# paint the second unit on the first row green. Why $t0+4?
sw $t3, 128($t0)	# paint the first unit on the second row blue. Why +128?

########################
# DRAWING SCENE REGION #
########################

#Goal Region Draw Loop (gr)
init_gr:	
	la	$t4,	gr 	# load addr of i into t4
	sw	$zero,	0($t4)	# set reg i to 0
	add	$t6,	$zero,	$zero	# set mem i to 0
	addi	$t9,	$zero,	512	# set end = 512

draw_loop_gr:	
	beq	$t6,	$t9,	init_wr	# i == 248?
	addi	$t6,	$t6,	4	# i = i + 4
	sw	$t6,	0($t4)		# store t4 in temp
	sw 	$t2, 	0($t0)		# draw green box at location
	addi	$t0,	$t0,	4	# increment display addr by 4
	j draw_loop_gr

#Water Region Draw Loop (wr)
init_wr:	
	la	$t4,	wr 	# load addr of i into t4
	sw	$zero,	0($t4)	# set reg i to 512
	add	$t6,	$zero,	512	# set mem i to 512
	addi	$t9,	$zero,	1536	# set end = 1536

draw_loop_wr:	
	beq	$t6,	$t9,	init_sr	# i == 1024?
	addi	$t6,	$t6,	4	# i = i + 4
	sw	$t6,	0($t4)		# store t4 in temp
	sw 	$t3, 	0($t0)		# draw blue box at location
	addi	$t0,	$t0,	4	# increment display addr by 4
	j draw_loop_wr

#Safe Region Draw Loop
init_sr:	
	la	$t4,	sr	# load addr of i into t4
	sw	$zero,	0($t4)	# set reg i to 0
	add	$t6,	$zero,	1536	# set mem i to 1536
	addi	$t9,	$zero,	2560	# set end = 2560

draw_loop_sr:	
	beq	$t6,	$t9,	init_rr	# i == 248?
	addi	$t6,	$t6,	4	# i = i + 4
	sw	$t6,	0($t4)		# store t4 in temp
	sw 	$t1, 	0($t0)		# draw red box
	addi	$t0,	$t0,	4	# increment display addr by 4
	j draw_loop_sr

#Road Region Draw Loop
# no drawing! included to be explicit
init_rr:	
	la	$t4,	sr	# load addr of i into t4
	sw	$zero,	0($t4)	# set reg i to 0
	add	$t6,	$zero,	2560	# set mem i to 2560
	addi	$t9,	$zero,	3584	# set end = 3584

draw_loop_rr:	
	beq	$t6,	$t9,	init_s	# i == 248?
	addi	$t6,	$t6,	4	# i = i + 4
	sw	$t6,	0($t4)		# store t4 in temp
#	sw 	$t1, 	0($t0)		# draw green box
	addi	$t0,	$t0,	4	# increment display addr by 4
	j draw_loop_rr

#Start Region Draw Loop (s)
# no drawing! included to be explicit
init_s:	
	la	$t4,	s	# load addr of i into t4
	sw	$zero,	0($t4)	# set reg i to 0
	add	$t6,	$zero,	3584	# set mem i to 0
	addi	$t9,	$zero,	4096	# set end = 4096 (bottom)

draw_loop_s:	
	beq	$t6,	$t9,	main	# i == 248?
	addi	$t6,	$t6,	4	# i = i + 4
	sw	$t6,	0($t4)		# store t4 in temp
	sw 	$t2, 	0($t0)		# draw green box
	addi	$t0,	$t0,	4	# increment display addr by 4
	j draw_loop_s

#########################
# DRAWING OBJECT REGION #
#########################
draw_car:	
	# first row
	sw 	$t8, 	0($s0)		# draw aqua box
	sw 	$t8, 	4($s0)		# draw aqua box
	sw 	$t8, 	8($s0)		# draw aqua box
	sw 	$t8, 	12($s0)		# draw aqua box
	# second row
	sw 	$t8, 	128($s0)	# draw aqua box
	sw 	$t8, 	132($s0)	# draw aqua box
	sw 	$t8, 	136($s0)	# draw aqua box
	sw 	$t8, 	140($s0)	# draw aqua box
	# third row
	sw 	$t8, 	256($s0)	# draw red box
	sw 	$t8, 	260($s0)	# draw red box
	sw 	$t8, 	264($s0)	# draw red box
	sw 	$t8, 	268($s0)	# draw red box
	# fourth row
	sw 	$t8, 	384($s0)	# draw red box
	sw 	$t8, 	388($s0)	# draw red box
	sw 	$t8, 	392($s0)	# draw red box
	sw 	$t8, 	396($s0)	# draw red box
	
	# return to line of code
	jr $ra

draw_log:	
	# first row
	# first row
	sw 	$t1, 	0($s1)		# draw aqua box
	sw 	$t1, 	4($s1)		# draw aqua box
	sw 	$t1, 	8($s1)		# draw aqua box
	sw 	$t1, 	12($s1)		# draw aqua box
	# second row
	sw 	$t1, 	128($s1)	# draw aqua box
	sw 	$t1, 	132($s1)	# draw aqua box
	sw 	$t1, 	136($s1)	# draw aqua box
	sw 	$t1, 	140($s1)	# draw aqua box
	# third row
	sw 	$t1, 	256($s1)	# draw red box
	sw 	$t1, 	260($s1)	# draw red box
	sw 	$t1, 	264($s1)	# draw red box
	sw 	$t1, 	268($s1)	# draw red box
	# fourth row
	sw 	$t1, 	384($s1)	# draw red box
	sw 	$t1, 	388($s1)	# draw red box
	sw 	$t1, 	392($s1)	# draw red box
	sw 	$t1, 	396($s1)	# draw red box
	jr $ra

draw_frog:	
	# first row
	sw 	$t7, 	0($t0)	# draw white box
	sw 	$t7, 	4($t0)	# draw white box
	sw 	$t7	8($t0)
	sw 	$t7, 	12($t0)
	# second row
	sw 	$t7, 	128($t0)	# draw white box
	sw 	$t7, 	132($t0)	# draw white box
	sw 	$t7	136($t0)
	sw 	$t7, 	140($t0)	
	# third row
	sw 	$t7, 	256($t0)	# draw white box
	sw 	$t7, 	260($t0)	# draw white box
	sw 	$t7	264($t0)
	sw 	$t7, 	268($t0)
	# fourth row
	sw 	$t7, 	384($t0)	# draw white box
	sw 	$t7, 	388($t0)	# draw white box
	sw 	$t7	392($t0)
	sw 	$t7, 	396($t0)
	
	# return to line of code
	jr $ra

############
# Movement #
############
move_frog_down:
	subi,	$t0,	$t0,	20	# move the frog up 20 units
	jal	init_gr			# draw the background
	jal	draw_frog		# call the draw frog function

########
# Main #
########
main:
	### Init Draw Objects
	# frog
	lw	$t0,	displayAddress 		# reset the display address
	addi,	$t0,	$t0,	3584		# increment to bottom row
	addi,	$t0,	$t0,	60		# increment frog to starting position
	jal 	draw_frog			# call the draw frog function
	
	# car 1
	lw	$s0,	displayAddress 		# reset the display address
	addi	$s0,	$s0,	2560		# increment to the second last row
	addi,	$s0,	$s0,	100		# increment car to starting position
	jal 	draw_car			# call the draw car function
	# car 2
	lw	$s0,	displayAddress 		# reset the display address
	addi	$s0,	$s0,	2816		# increment to the 2nd last row
	addi,	$s0,	$s0,	300		# increment car to starting position
	jal 	draw_car			# call the draw car function
	# log 1
	lw	$s1,	displayAddress 		# reset the display address
	addi	$s1,	$s1,	512		# increment to the third row
	addi,	$s1,	$s1,	100		# increment car to starting position
	jal 	draw_log			# call the draw car function
	#log 2
	lw	$s1,	displayAddress 		# reset the display address
	addi	$s1,	$s1,	768		# increment to the third row
	addi,	$s1,	$s1,	300		# increment car to starting position
	jal 	draw_log			# call the draw car function
	
	### Check for input			# $s7 = key press input
	lw 	$s7, 	0xffff0004		# check if a is pressed
	
	# Frame rate
	addi	$v0,	$zero,	32	# Syscall sleep
	addi	$a0,	$zero,	16	# 16ms gives us 60fps
	syscall
	
	beq	$s7,	1,	move_frog_down	# move the frog down
	

Exit:
li $v0, 10 # terminate the program gracefully
syscall