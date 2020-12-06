#####################################################################
#
# CSCB58 Fall 2020 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Bhoomi Patel, 1006142158
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 512
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 4
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. nicer graphics 
# 2. dynamic notifcations
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here).
#
# Any additional information that the TA needs to know:
# - E to end after lost game
#
#####################################################################

.data
	displayAddress:	.word	0x10008000
	screenWidth: .word 64
	screenHeight: .word 64


	#Colors
	backgroundColour: .word	0x7fe5f0 #blue
	platformColour: .word 0xf7347a #pink
	doodlerColour: .word 0x8a2be2 #purple
	limeGreen: .word 0x00ff00  
	body: .word 0x19b092 #turquoise
	black: .word 0x000000
	orange: .word 0xfa9d00
	red: .word 0xff0000
	scoreColour: .word 0x0000ff

	#Doodler
	doodlerPositionX1: .word 32
	doodlerPositionY1: .word 59

	#Platform
	platformPositionX: .word 28
	platformPositionY: .word 60
	platformsEasy: .word 0, 0, 0, 0, 0, 0
	platformCounter: .word 0

  	#Score
  	score: .word 0
	notifThreshold: .word 1
	notifNum: .word 0

  	#End
  	gameEnd: .word 0

  	#levels
  	mode:   .word 0
  

.text
main:
	lw $a0, screenWidth
	lw $a1, backgroundColour
	addi $t1, $t1, 32
	mul $a2, $a0, $a0   #total number of pixels on screen
	mul $a2, $a2, 4   #align addresses
	add $a2, $a2, $gp   #add base of gp
	add $a0, $gp, $zero   #loop counter

	jal fillBackground
	jal promptUser
	pressToStart:
		lw $t1, 0xFFFF0004		# check to see which key has been pressed
		beq $t1, 0x00000031, start # 1 pressed

		li $a0, 250	#
		li $v0, 32	# pause for 250 milisec
		syscall		#

		j pressToStart    # Jump back to the top of the wait loop

start:
	lw $a0, screenWidth
	lw $a1, backgroundColour
	addi $t1, $t1, 32
	mul $a2, $a0, $a0   #total number of pixels on screen
	mul $a2, $a2, 4   #align addresses
	add $a2, $a2, $gp   #add base of gp
	add $a0, $gp, $zero   #loop counter

	jal fillBackground
	#jal DrawPlatformInitial
	jal drawDoodlerInitial

	jal createPlatformsEasy 
	jal createPlatformsEasy 
	jal createPlatformsEasy 
	jal createPlatformsEasy 
	jal createPlatformsEasy 
	jal createPlatformsEasy 
	while2:
		jal moveUp
		jal moveDown
		jal notifications
		j while2


######################################################
# Fill Screen to Green, for reset
######################################################
fillBackground:

	beq $a0, $a2, exit
	sw $a1, 0($a0) #store color
	addiu $a0, $a0, 4 #increment counter

	j fillBackground
exit:
	jr $ra
######################################################
# Initialize Variables
######################################################
######################################################
# Draw Doodler intially
######################################################
drawDoodlerInitial:
	lw $a0, doodlerPositionX1
	lw $a1, doodlerPositionY1

	addi $sp, $sp, -4
	sw $ra, 0($sp)

	jal coordinateToAddress

	move $a0, $v0
	lw $a1, doodlerColour

	jal drawDoodler

	lw $ra 0($sp)
	addi $sp, $sp, 4

	jr $ra
######################################################
# Create Platforms for easy mode
######################################################
createPlatformsEasy:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
		
	la $t1, platformsEasy 
	#generate random x value
	li $v0, 42
	li $a0, 0
	li $a1, 50
	syscall
	#store X position
	sw $a0, platformPositionX
	lw $a1, 20($t1)
	
	bne $a1, 0, createdEasy 
	lw $a2, platformCounter 
	beqz $a2, zero
	beq $a2, 1, one
	beq $a2, 2, two
	beq $a2, 3, three
	beq $a2, 4, four
	beq $a2, 5, five 

zero:
	li $a1, 60
	sw $a1, platformPositionY
	
	jal coordinateToAddress
	move $a0, $v0
	sw $a0, 0($t1)
	
	lw $a1, platformColour
	
	addi $a2, $a2, 1
	sw $a2, platformCounter 

	jal drawPlatform
	
	j createdEasy
	
one:
	li $a1, 50
	sw $a1, platformPositionY
	
	jal coordinateToAddress
	move $a0, $v0
	sw $a0, 4($t1)
	
	lw $a1, platformColour
	jal drawPlatform
	
	addi $a2, $a2, 1
	sw $a2, platformCounter 	
	
	j createdEasy
two:
	li $a1, 41
	sw $a1, platformPositionY
	
	jal coordinateToAddress
	move $a0, $v0
	sw $a0, 8($t1)
	
	lw $a1, platformColour
	jal drawPlatform
	
	addi $a2, $a2, 1
	sw $a2, platformCounter 
	
	j createdEasy	
three:
	li $a1, 30
	sw $a1, platformPositionY
	
	jal coordinateToAddress
	move $a0, $v0
	sw $a0, 12($t1)
	
	lw $a1, platformColour
	jal drawPlatform
	
	addi $a2, $a2, 1
	sw $a2, platformCounter 
	
	j createdEasy	
four:
	li $a1,  21
	sw $a1, platformPositionY
	
	jal coordinateToAddress
	move $a0, $v0
	sw $a0, 16($t1)
	
	lw $a1, platformColour
	jal drawPlatform
	
	addi $a2, $a2, 1
	sw $a2, platformCounter 
	j createdEasy
five:
	li $a1,  10
	sw $a1, platformPositionY
	
	jal coordinateToAddress
	move $a0, $v0
	sw $a0, 20($t1)
	
	lw $a1, platformColour
	jal drawPlatform
	
	li $a2, 5
	sw $a2, platformCounter 
	
createdEasy:	
	lw $ra 0($sp)
	addi $sp, $sp, 4

	jr $ra
######################################################
# Draw Platforms
######################################################
drawPlatform:

	addi $sp, $sp, -4
	sw $ra, 0($sp)
	#a0 is the address
	#a1 is the colour
	#lw $a3, mode
	#beq $a3, 2, smaller
	sw $a1, 0($a0)
	sw $a1, 4($a0)
	sw $a1, 8($a0)
	sw $a1, 12($a0)
	sw $a1, 16($a0)
	sw $a1, 20($a0)
	sw $a1, 24($a0)
	sw $a1, 28($a0)
	sw $a1, 32($a0)
	sw $a1, 36($a0)
	sw $a1, 40($a0)
	sw $a1, 44($a0)
	sw $a1, 48($a0)
	sw $a1, 52($a0)
	sw $a1, 256($a0)
	sw $a1, 260($a0)
	sw $a1, 264($a0)
	sw $a1, 268($a0)
	sw $a1, 272($a0)
	sw $a1, 276($a0)
	sw $a1, 280($a0)
	sw $a1, 284($a0)
	sw $a1, 288($a0)
	sw $a1, 292($a0)
	sw $a1, 296($a0)
	sw $a1, 300($a0)
	sw $a1, 304($a0)
	sw $a1, 308($a0)

	lw $ra 0($sp)
	addi $sp, $sp, 4

	jr $ra

##################################################################
#CoordinatesToAddress Function
# $a0 -> x index of the array
# $a1 -> y index of the array
##################################################################
# returns $v0 -> the address of the indices for bitmap display
##################################################################
coordinateToAddress:
	lw $v0, screenWidth 	#Store screen width into $v0
	mul $v0, $v0, $a1	#multiply by y position
	add $v0, $v0, $a0	#add the x position
	mul $v0, $v0, 4		#multiply by 4
	add $v0, $v0, $gp	#add base address from bitmap display
	jr $ra			# return $v0


##################################################################
# Check Platform Land
##################################################################
# returns $v0:
#	0 - does not hit platform
#	1 - does hit platform
##################################################################
CheckPlatformLand:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lw $a0, doodlerPositionX1
	lw $a1, doodlerPositionY1
  	addi $a1, $a1, 1

 	jal coordinateToAddress

  	lw $t7, 0($v0)
  	lw $t9, 16($v0)
  	lw $t8, platformColour

	beq $t7, $t8, ELSE1
	beq $t9, $t8, ELSE1
       	li $v0, 0
       	j exit1

  	ELSE1:
  		li $v0, 1
		j exit1

  exit1:
 	lw $ra 0($sp)
	addi $sp, $sp, 4

	jr $ra


##################################################################
# move doodler up
##################################################################
moveUp:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	li $t2, 14
	li $t3, 0
	WHILE:
		beq $t2, $t3, return

		addi $sp, $sp, -4
		sw $t3, 0($sp)

		lw $a0, doodlerPositionX1
		lw $a1, doodlerPositionY1
		
		beq $a1, 1, moveDown

		jal coordinateToAddress

		move $a0, $v0
		lw $a1, backgroundColour

		jal drawDoodler

		lw $t0, doodlerPositionX1
		lw $t1, doodlerPositionY1
		addiu $t1, $t1, -1
		move $a0, $t0
		move $a1, $t1
		sw $a0, doodlerPositionX1
		sw $a1, doodlerPositionY1
		jal coordinateToAddress
		move $a0, $v0
		lw $a1, doodlerColour


		jal drawDoodler

		lw $t3 0($sp)
        	addi $sp, $sp, 4

		addi $t3, $t3, 1

		jal redrawPlatforms

		jal sleep

		jal inputCheck

		j WHILE

return:
	lw $ra 0($sp)
        addi $sp, $sp, 4
	jr $ra

##################################################################
# move doodler down
##################################################################
moveDown:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	while:
    		jal checkEndGame
		lw $t1, gameEnd
		beq $t1, 1, loser
		jal CheckPlatformLand
		move $t1, $v0
    	 	beq $t1, 1, scroller
		lw $a0, doodlerPositionX1
		lw $a1, doodlerPositionY1

		jal coordinateToAddress

		move $a0, $v0
		lw $a1, backgroundColour

		jal drawDoodler
		#draw doodler in new position, move Y position down

		lw $t0, doodlerPositionX1
		lw $t3, doodlerPositionY1
		addiu $t3, $t3, 1
		move $a0, $t0
		move $a1, $t3
		sw $a0, doodlerPositionX1
		sw $a1, doodlerPositionY1
		jal coordinateToAddress
		move $a0, $v0
		lw $a1, doodlerColour

		jal drawDoodler

		jal sleep

    		jal inputCheck
    		
		j while
	scroller:
		jal repaint 
		jal createPlatformsEasy
	leave:
		jal redrawPlatforms
		lw $ra 0($sp)
        	addi $sp, $sp, 4
		jr $ra


##################################################################
# Draw doodler (playtpus) Function
##################################################################
drawDoodler:

	sw $a1, 0($a0)
	sw $a1, 4($a0)
	sw $a1, -256($a0)
	sw $a1, -252($a0)

	jr $ra

##################################################################
# Check if they lost game
##################################################################
# 0 if not lost
# 1 if lost
##################################################################
checkEndGame:
	li $t4, 1
	IF:
		lw $t1, doodlerPositionY1
		beq $t1, 63, ELSE
	THEN:
		jr $ra
	ELSE:
		sw $t4, gameEnd
		jr $ra

##################################################################
# sleep function
##################################################################
sleep:
	li $a0, 30
	li $v0, 32
	syscall

	jr $ra

##################################################################
# Check if key was pressed
##################################################################
inputCheck:

	addi $sp, $sp, -4
	sw $ra, 0($sp)

	li $a0, 50
	li $v0, 32
	syscall

	#get the input from the keyboard
	lw $t0, 0xffff0000
	li $t1, 1
	beq $t0, $t1, directionChooser

	lw $ra 0($sp)
	addi $sp, $sp, 4

	jr $ra

directionChooser:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lw $s0, 0xffff0004
	beq $s0, 0x6a, left
	beq $s0, 0x6b, right

	j exit2

right:
	lw $a0, doodlerPositionX1
	lw $a1, doodlerPositionY1

	jal coordinateToAddress

	move $a0, $v0
	lw $a1, backgroundColour


	jal drawDoodler

	lw $t7, doodlerPositionX1
	lw $t8, doodlerPositionY1

	addi $t7, $t7, 1
	move $a0, $t7
	move $a1, $t8
	sw $a0, doodlerPositionX1
	sw $a1, doodlerPositionY1

	jal coordinateToAddress

	move $a0, $v0
	lw $a1, doodlerColour

	jal drawDoodler

	j exit2
left:
	lw $a0, doodlerPositionX1
	lw $a1, doodlerPositionY1

	jal coordinateToAddress
	move $a0, $v0
	lw $a1, backgroundColour


	jal drawDoodler

	lw $t7, doodlerPositionX1
	lw $t8, doodlerPositionY1

	addi $t7, $t7, -1
	move $a0, $t7
	move $a1, $t8
	sw $a0, doodlerPositionX1
	sw $a1, doodlerPositionY1

	jal coordinateToAddress

	move $a0, $v0
	lw $a2, doodlerColour


	jal drawDoodler
	jal redrawPlatforms
	j exit2

exit2:
	lw $ra 0($sp)
	addi $sp, $sp, 4

	jr $ra
##################################################################
# scroll the screen
##################################################################
repaint:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $a2, doodlerPositionY1
	bge $a2, 45, exitEasy
	
	#get platform values
	la $a2, platformsEasy

	lw $t3, 0($a2)
	lw $t1, 4($a2)
	lw $t2, 8($a2)
	lw $t9, 12($a2)
	lw $s5, 16($a2)
	lw $s6, 20($a2)

	li $s0, 0
	li $s1, 256
	li $s2, 0
	li $s4, 0
downEasy:
	beq $s0, 10, doodlerDownEasy
#platform 1
	move $a0, $t3
	add $a0, $a0, $s2
	lw $a1, backgroundColour

	jal drawPlatform
#platform 2
	move $a0, $t1
	add $a0, $a0, $s2
	lw $a1, backgroundColour

	jal drawPlatform
#platform 3
	move $a0, $t2
	add $a0, $a0, $s2
	lw $a1, backgroundColour

	jal drawPlatform
#platform 4
	move $a0, $t9
	add $a0, $a0, $s2
	lw $a1, backgroundColour

	jal drawPlatform
#platform 5
	move $a0, $s5
	add $a0, $a0, $s2
	lw $a1, backgroundColour

	jal drawPlatform
#platform 6
	move $a0, $s6
	add $a0, $a0, $s2
	lw $a1, backgroundColour

	jal drawPlatform

##########Move down###################
#platform 1
	move $a0, $t3
	add $a0, $a0, $s1

	lw $a1, backgroundColour

	jal drawPlatform
#platform 2
	move $a0, $t1
	add $a0, $a0, $s1
	lw $a1, platformColour
	sw $a0, 0($a2)
	jal drawPlatform
#platform 3
	move $a0, $t2
	add $a0, $a0, $s1
	lw $a1, platformColour
	sw $a0, 4($a2)
	jal drawPlatform
#platform 4
	move $a0, $t9
	add $a0, $a0, $s1
	lw $a1, platformColour
	sw $a0, 8($a2)
	jal drawPlatform
#platform 5
	move $a0, $s5
	add $a0, $a0, $s1
	lw $a1, platformColour
	sw $a0, 12($a2)
	jal drawPlatform
#platform 6
	move $a0, $s6
	add $a0, $a0, $s1
	lw $a1, platformColour
	sw $a0, 16($a2)
	jal drawPlatform
	
	sw $zero, 20($a2)

	addi $s0, $s0, 1
	addi $s1, $s1, 256
	addi $s2, $s2, 256

	jal sleep

	j downEasy

doodlerDownEasy:
	beq $s4, 10, create

	lw $a0, doodlerPositionX1
	lw $a1, doodlerPositionY1

	jal coordinateToAddress

	move $a0, $v0
	lw $a1, backgroundColour

	jal drawDoodler


	lw $t0, doodlerPositionX1
	lw $t1, doodlerPositionY1
	addiu $t1, $t1, 1
	move $a0, $t0
	move $a1, $t1
	sw $a0, doodlerPositionX1
	sw $a1, doodlerPositionY1
	jal coordinateToAddress
	move $a0, $v0
	lw $a1, doodlerColour
	jal drawDoodler

	addi $s4, $s4, 1
	jal inputCheck

	j doodlerDownEasy
create:
	lw $a0, score
	addi $a0, $a0, 1
	sw $a0, score
	jal createPlatformsEasy
exitEasy:
	lw $ra 0($sp)
	addi $sp, $sp, 4
	jr $ra

##################################################################
# tells you you lost
##################################################################
loser:

	 li $v0, 1
	 lw $a0, score 
	 syscall
###############################
#testing
##############################
#l
	li $a0, 10
	li $a1, 20
	li $a3, 32
	lw $a2, red	
	jal DrawVerticalLine
	
	li $a0, 11
	li $a1, 20
	li $a3, 32
	lw $a2, red	
	jal DrawVerticalLine
	
	li $a0, 10
	li $a1, 32
	li $a3, 17
	lw $a2, red	
	jal DrawHorizontalLine
	
	li $a0, 10
	li $a1, 31
	li $a3, 17
	lw $a2, red	
	jal DrawHorizontalLine
	
#O 
	li $a0, 19
	li $a1, 20
	li $a3, 32
	lw $a2, red	
	jal DrawVerticalLine
	li $a0, 20	
	jal DrawVerticalLine
	
	li $a0, 25
	li $a1, 20
	li $a3, 32
	lw $a2, red	
	jal DrawVerticalLine
	li $a0, 26	
	jal DrawVerticalLine
	
	li $a0, 19
	li $a1, 20
	li $a3, 26
	lw $a2, red	
	jal DrawHorizontalLine
	li $a1, 21	
	jal DrawHorizontalLine
	
	li $a0, 19
	li $a1, 32
	li $a3, 26
	lw $a2, red	
	jal DrawHorizontalLine
	li $a1, 31
	jal DrawHorizontalLine
# S
	li $a0, 28
	li $a1, 20
	li $a3, 26
	lw $a2, red	
	jal DrawVerticalLine
	li $a0, 29	
	jal DrawVerticalLine
	
	li $a0, 35
	li $a1, 27
	li $a3, 32
	lw $a2, red	
	jal DrawVerticalLine
	li $a0, 34	
	jal DrawVerticalLine
	
	li $a0, 28
	li $a1, 20
	li $a3, 35
	lw $a2, red	
	jal DrawHorizontalLine
	li $a1, 21	
	jal DrawHorizontalLine
				
	li $a0, 28
	li $a1, 32
	li $a3, 35
	lw $a2, red	
	jal DrawHorizontalLine
	li $a1, 31
	jal DrawHorizontalLine	
	
	li $a0, 28
	li $a1, 27
	li $a3, 35
	lw $a2, red	
	jal DrawHorizontalLine
	li $a1, 26
	jal DrawHorizontalLine	
######E
	li $a0, 37
	li $a1, 20
	li $a3, 32
	lw $a2, red	
	jal DrawVerticalLine
	li $a0, 38	
	jal DrawVerticalLine

	
	li $a0, 37
	li $a1, 20
	li $a3, 44
	lw $a2, red	
	jal DrawHorizontalLine
	li $a1, 21	
	jal DrawHorizontalLine
				
	li $a0, 37
	li $a1, 32
	li $a3, 44
	lw $a2, red	
	jal DrawHorizontalLine
	li $a1, 31
	jal DrawHorizontalLine	
	
	li $a0, 37
	li $a1, 27
	li $a3, 44
	lw $a2, red	
	jal DrawHorizontalLine
	li $a1, 26
	jal DrawHorizontalLine	
######R
	li $a0, 46
	li $a1, 20
	li $a3, 32
	lw $a2, red	
	jal DrawVerticalLine
	li $a0, 47	
	jal DrawVerticalLine
	
	li $a0, 52
	li $a1, 20
	li $a3, 32
	lw $a2, red	
	jal DrawVerticalLine
	li $a0, 53	
	jal DrawVerticalLine

	li $a0, 46
	li $a1, 20
	li $a3, 52
	lw $a2, red	
	jal DrawHorizontalLine
	li $a1, 21	
	jal DrawHorizontalLine
				
	li $a0, 46
	li $a1, 27
	li $a3, 52
	lw $a2, red	
	jal DrawHorizontalLine
	li $a1, 26
	jal DrawHorizontalLine	
	
	li $a0, 52
	li $a1, 26
	lw $a2, backgroundColour
	jal DrawPoint
	li $a0, 53
	jal DrawPoint
	li $a1, 27
	jal DrawPoint
	li $a0, 52
	li $a1, 27
	jal DrawPoint
	
	restart:
		lw $t1, 0xFFFF0004		# check to see which key has been pressed
		beq $t1, 0x73, main # s pressed
		beq $t1, 0x65, bye

		li $a0, 250	#
		li $v0, 32	# pause for 250 milisec
		syscall		#

		j restart  # Jump back to the top of the w
bye:
	li $v0, 10
	syscall	
	

##################################################################
# Draw score
#################################################################
drawScore:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lw $t0, score
	li $a0, 1
	li $a1, 1

	jal coordinateToAddress

	move $a0, $v0
	sw $a1, platformColour
	beqz $a0, zer0
	beq $a0, 1, one1
	j leave1
zer0:
	sw $a1 4($a0)
	sw $a1 8($a0)
	sw $a1 256($a0)
	sw $a1 268($a0)
	sw $a1 512($a0)
	sw $a1 520($a0)
	sw $a1 772($a0)
	sw $a1 776($a0)
	
	j leave1
one1:
	sw $a1 0($a0)
	sw $a1 256($a0)
	sw $a1 512($a0)
	sw $a1 768($a0)
leave1:
	#jal notifications
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra

##################################################################
# Tell user what to do to start
#################################################################
promptUser:
		addi $sp, $sp -4
		sw $ra, 0($sp)
##########s		
		li $a0, 15
		li $a1, 14
		li $a3, 18
		lw $a2, platformColour
		jal DrawHorizontalLine

		li $a0, 15
		li $a1, 16
		li $a3, 18
		lw $a2, platformColour
		jal DrawHorizontalLine

		li $a0, 15
		li $a1, 18
		li $a3, 18
		lw $a2, platformColour
		jal DrawHorizontalLine

		li $a0, 15
		li $a1, 15
		jal DrawPoint

		li $a0, 18
		li $a1, 17
		jal DrawPoint
		
#########T
		li $a0, 20
		li $a1, 14
		li $a3, 24
		lw $a2, platformColour
		jal DrawHorizontalLine
		
		li $a0, 22
		li $a1, 14
		li $a3, 18
		lw $a2, platformColour
		jal DrawVerticalLine
####A		
		li $a0, 26
		li $a1, 14
		li $a3, 18
		lw $a2, platformColour
		jal DrawVerticalLine
		
		li $a0, 29
		li $a1, 14
		li $a3, 18
		lw $a2, platformColour
		jal DrawVerticalLine
		
		li $a0, 26
		li $a1, 14
		li $a3, 29
		lw $a2, platformColour
		jal DrawHorizontalLine
		
		li $a0, 26
		li $a1, 16
		li $a3, 29
		lw $a2, platformColour
		jal DrawHorizontalLine
#############R
		li $a0, 31
		li $a1, 14
		li $a3, 18
		lw $a2, platformColour
		jal DrawVerticalLine
		
		li $a0, 34
		li $a1, 14
		li $a3, 18
		lw $a2, platformColour
		jal DrawVerticalLine
		
		li $a0, 31
		li $a1, 14
		li $a3, 34
		lw $a2, platformColour
		jal DrawHorizontalLine
		
		li $a0, 31
		li $a1, 16
		li $a3, 34
		lw $a2, platformColour
		jal DrawHorizontalLine
		
		li $a0, 34
		li $a1, 16
		lw $a2, backgroundColour
		jal DrawPoint
##########T
		li $a0, 36
		li $a1, 14
		li $a3, 40
		lw $a2, platformColour
		jal DrawHorizontalLine
		
		li $a0, 38
		li $a1, 14
		li $a3, 18
		lw $a2, platformColour
		jal DrawVerticalLine
############P
		li $a0, 15
		li $a1, 21
		li $a3, 27
		lw $a2, doodlerColour
		jal DrawVerticalLine
		
		li $a0, 18
		li $a1, 21
		li $a3, 24
		lw $a2, doodlerColour
		jal DrawVerticalLine
		
		li $a0, 15
		li $a1, 21
		li $a3, 18
		lw $a2, doodlerColour
		jal DrawHorizontalLine
		
		li $a0, 15
		li $a1, 24
		li $a3, 18
		lw $a2, doodlerColour
		jal DrawHorizontalLine
		
##########R
		li $a0, 20
		li $a1, 21
		li $a3, 27
		lw $a2, doodlerColour
		jal DrawVerticalLine
		
		li $a0, 23
		li $a1, 21
		li $a3, 27
		lw $a2, doodlerColour
		jal DrawVerticalLine
		
		li $a0, 20
		li $a1, 21
		li $a3, 23
		lw $a2, doodlerColour
		jal DrawHorizontalLine
		
		li $a0, 20
		li $a1, 24
		li $a3, 23
		lw $a2, doodlerColour
		jal DrawHorizontalLine
		
		li $a0, 23
		li $a1, 24
		lw $a2, backgroundColour
		jal DrawPoint		
##############E
		li $a0, 25
		li $a1, 21
		li $a3, 27
		lw $a2, doodlerColour
		jal DrawVerticalLine
		
		li $a0, 25
		li $a1, 21
		li $a3, 28
		lw $a2, doodlerColour
		jal DrawHorizontalLine
		
		li $a0, 25
		li $a1, 24
		li $a3, 28
		lw $a2, doodlerColour
		jal DrawHorizontalLine
		
		li $a0, 25
		li $a1, 27
		li $a3, 28
		lw $a2, doodlerColour
		jal DrawHorizontalLine
##############S
		li $a0, 30
		li $a1, 21
		li $a3, 24
		lw $a2, doodlerColour
		jal DrawVerticalLine
		
		li $a0, 33
		li $a1, 24
		li $a3, 27
		lw $a2, doodlerColour
		jal DrawVerticalLine
		
		li $a0, 30
		li $a1, 21
		li $a3, 33
		lw $a2, doodlerColour
		jal DrawHorizontalLine
		
		li $a0, 30
		li $a1, 24
		li $a3, 33
		lw $a2, doodlerColour
		jal DrawHorizontalLine
		
		li $a0, 30
		li $a1, 27
		li $a3, 33
		lw $a2, doodlerColour
		jal DrawHorizontalLine
##############S
		li $a0, 35
		li $a1, 21
		li $a3, 24
		lw $a2, doodlerColour
		jal DrawVerticalLine
		
		li $a0, 38
		li $a1, 24
		li $a3, 27
		lw $a2, doodlerColour
		jal DrawVerticalLine
		
		li $a0, 35
		li $a1, 21
		li $a3, 38
		lw $a2, doodlerColour
		jal DrawHorizontalLine
		
		li $a0, 35
		li $a1, 24
		li $a3, 38
		lw $a2, doodlerColour
		jal DrawHorizontalLine
		
		li $a0, 35
		li $a1, 27
		li $a3, 38
		lw $a2, doodlerColour
		jal DrawHorizontalLine
				
########## 1
		li $a0, 43
		li $a1, 21
		li $a3, 27
		lw $a2, doodlerColour
		jal DrawVerticalLine
		
		li $a0, 42
		li $a1, 22
		jal DrawPoint
					
		lw $ra 0($sp)
		addi $sp, $sp, 4
		jr $ra
##################################################################
# Draw a single point
#################################################################
DrawPoint:
		sll $t0, $a1, 6   # multiply y-coordinate by 64 (length of the field)
		addu $v0, $a0, $t0
		sll $v0, $v0, 2
		addu $v0, $v0, $gp
		sw $a2, ($v0)		# draw the color to the location

		jr $ra

##################################################################
# Draw a line horizonatal
#################################################################
# $a0 the x starting coordinate
# $a1 the y coordinate
# $a2 the color
# $a3 the x ending coordinate
DrawHorizontalLine:

		addi $sp, $sp, -4
   		sw $ra, 0($sp)

		sub $t9, $a3, $a0
		move $t1, $a0

	HorizontalLoop:

		add $a0, $t1, $t9
		jal DrawPoint
		addi $t9, $t9, -1

		bge $t9, 0, HorizontalLoop

		lw $ra, 0($sp)		# put return back
   		addi $sp, $sp, 4


		jr $ra
##################################################################
# Draw a line vertical
#################################################################
# $a0 the x coordinate
# $a1 the y starting coordinate
# $a2 the color
# $a3 the y ending coordinate
DrawVerticalLine:


		addi $sp, $sp, -4
   		sw $ra, 0($sp)

		sub $t9, $a3, $a1
		move $t1, $a1

	VerticalLoop:

		add $a1, $t1, $t9
		jal DrawPoint
		addi $t9, $t9, -1

		bge $t9, 0, VerticalLoop

		lw $ra, 0($sp)		# put return back
   		addi $sp, $sp, 4

		jr $ra

##################################################################
# check if its a platform
#################################################################
redrawPlatforms:
	addi $sp, $sp, -4
   	sw $ra, 0($sp)

	la $s1, platformsEasy
	lw $a0, 0($s1)
	lw $a1, platformColour
	jal drawPlatform
	lw $a0, 4($s1)
	jal drawPlatform
	lw $a0, 8($s1)
	jal drawPlatform
	lw $a0, 12($s1)
	jal drawPlatform
	lw $a0, 16($s1)
	jal drawPlatform
	lw $a0, 20($s1)
	beq $a0, $zero, exit6
	jal drawPlatform
exit6:
	lw $ra, 0($sp)
   	addi $sp, $sp, 4

	jr $ra
##################################################################
# dynamic notifications
#################################################################
notifications:
	addi $sp, $sp, -4
   	sw $ra, 0($sp)
   	
	lw $s5, score
	lw $s6, notifThreshold
	bge $s5, $s6, notif
	j leave4
	# $a0 the x coordinate
# $a1 the y starting coordinate
# $a2 the color
# $a3 the y ending coordinate
notif:
	lw $t0, notifNum 
	beq $t0, 0, cool 
	beq $t0, 1, notbad 
	#beq $t0, 2, udontsuck 
	#beq $t0, 2, pog
cool:

	lw $a2, orange
	li $a0, 7
	li $a1, 2
	li $a3, 6
	jal DrawVerticalLine 
	
	li $a0, 8
	jal DrawPoint
	
	li $a0, 11
	jal DrawVerticalLine 
	li $a0, 12
	jal DrawPoint	
	
	li $a0, 13
	jal DrawVerticalLine 
	
	li $a0, 16
	jal DrawVerticalLine 
	li $a0, 17
	jal DrawPoint
	
	li $a0, 18
	jal DrawVerticalLine 

	li $a0, 21
	jal DrawVerticalLine 

	li $a0, 8
	li $a1, 6
	jal DrawPoint
	
	li $a0, 12
	li $a1, 6
	jal DrawPoint
	
	li $a0, 17
	li $a1, 6
	jal DrawPoint
	
	li $a0, 22
	li $a1, 6
	jal DrawPoint
	
	li $v0 32
	li $a0, 500
	syscall
	li $v0 32
	li $a0, 500
	
	lw $a2, backgroundColour
	li $a0, 7
	li $a1, 2
	li $a3, 6
	jal DrawVerticalLine 
	
	li $a0, 8
	jal DrawPoint
	
	li $a0, 11
	jal DrawVerticalLine 
	li $a0, 12
	jal DrawPoint	
	
	li $a0, 13
	jal DrawVerticalLine 
	
	li $a0, 16
	jal DrawVerticalLine 
	li $a0, 17
	jal DrawPoint
	
	li $a0, 18
	jal DrawVerticalLine 

	li $a0, 21
	jal DrawVerticalLine 

	li $a0, 8
	li $a1, 6
	jal DrawPoint
	
	li $a0, 12
	li $a1, 6
	jal DrawPoint
	
	li $a0, 17
	li $a1, 6
	jal DrawPoint
	
	li $a0, 22
	li $a1, 6
	jal DrawPoint
	
	addi $t0, $t0, 1
	sw $t0, notifNum 
notbad:
	lw $a2, orange
	li $a0, 7
	li $a1, 2
	li $a3, 28
	jal DrawHorizontalLine 
	li $a0, 10
	lw $a2, backgroundColour
	jal DrawPoint
	li $a0, 14
	jal DrawPoint
	li $a0, 18
	jal DrawPoint
	li $a0, 22
	jal DrawPoint
	li $a0, 26
	jal DrawPoint
	
	lw $a2, orange
	li $a0, 7
	li $a1, 2
	li $a3, 6
	jal DrawVerticalLine 
	li $a0, 9
	jal DrawVerticalLine 
	li $a0, 11
	jal DrawVerticalLine 
	li $a0, 13
	jal DrawVerticalLine 
	li $a0, 16
	jal DrawVerticalLine 
	li $a0, 19
	jal DrawVerticalLine
	li $a0, 21
	jal DrawVerticalLine 
	li $a0, 23
	jal DrawVerticalLine 
	li $a0, 25
	jal DrawVerticalLine  
	li $a0, 27
	jal DrawVerticalLine 
	
	lw $a2, orange
	li $a0, 29
	li $a1, 3
	li $a3, 5
	jal DrawVerticalLine 
	
	lw $a2, orange
	li $a0, 19
	li $a1, 4
	li $a3, 24
	jal DrawHorizontalLine
	li $a0, 22 
	lw $a2, backgroundColour
	jal DrawPoint
	li $a1, 6
	lw $a2, orange
	jal DrawPoint
	
	li $a0, 12
	li $a1, 6
	jal DrawPoint
	li $a0, 28
	jal DrawPoint
	li $a1, 2
	jal DrawPoint
	
	li $v0 32
	li $a0, 500
	syscall
	li $v0 32
	li $a0, 500
	
	lw $a2, backgroundColour
	li $a0, 7
	li $a1, 2
	li $a3, 28
	jal DrawHorizontalLine 
	li $a0, 10

	
	lw $a2, backgroundColour
	li $a0, 7
	li $a1, 2
	li $a3, 6
	jal DrawVerticalLine 
	li $a0, 9
	jal DrawVerticalLine 
	li $a0, 11
	jal DrawVerticalLine 
	li $a0, 13
	jal DrawVerticalLine 
	li $a0, 16
	jal DrawVerticalLine 
	li $a0, 19
	jal DrawVerticalLine
	li $a0, 21
	jal DrawVerticalLine 
	li $a0, 23
	jal DrawVerticalLine 
	li $a0, 25
	jal DrawVerticalLine  
	li $a0, 27
	jal DrawVerticalLine 
	
	lw $a2, backgroundColour
	li $a0, 29
	li $a1, 3
	li $a3, 5
	jal DrawVerticalLine 
	
	lw $a2, backgroundColour
	li $a0, 19
	li $a1, 4
	li $a3, 24
	jal DrawHorizontalLine
	li $a1, 6
	lw $a2, backgroundColour
	jal DrawPoint
	
	li $a0, 12
	li $a1, 6
	jal DrawPoint
	li $a0, 28
	jal DrawPoint
	li $a1, 2
	jal DrawPoint
	
	addi $t0, $t0, 1
	sw $t0, notifNum 
				
#udontsuck:
#pog:	


	
leave4:	
	addi $s6, $s6, 5
	sw $s6, notifThreshold
	
	
	lw $ra, 0($sp)
   	addi $sp, $sp, 4
   	
   	jr $ra
##################################################################
# ended
#################################################################
