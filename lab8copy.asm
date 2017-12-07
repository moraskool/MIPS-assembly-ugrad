.data
StackTop:    		.word 0:99
StackBot: 

Que: 
		.word 0:99
Que_pointer:	.word 0

ColorTable:
			.word 0x000000		# black 
		.word 0x0000ff		# blue 
		.word 0x00ff00		# green
		.word 0xff0000		# red 
		.word 0x00ffff		# blue + green
		.word 0xff00ff		# blue + red 
		.word 0xffff00		# green + red 
		.word 0xffffff		# white
		
BoxTable: 

		.word 2,3,6		
		.word 19,3,4
		.word 2,20,2
		.word 19,20,3
		.word 0,0,0

DrawCircleTable:
	
		.word 0,8,4		# top circle value == 1 
		.word -78,88,6		# left circle value == 2
		.word 78,88,3		# right circle value == 3 
		.word 0,158,2		# buttom box value == 4

RandSeq:  	.byte 0:5		# will use RandSeq and UserSeq to store each sequence of numbers so they can be compared later 
UserSeq:  	.byte 0:5
askSeq:   	.asciiz     "Enter the numbers one at a time" 

.text 
###############################################################################################################################################
#P1
la $sp,StackBot 	       		# set the pointer of the stack

Main: 

	addiu 	$a0,$0,1			# pass gen id 
	addiu 	$a1,$0,4			# pass limit 
	addiu 	$s0,$0,0			# use this as my count for the loop
	addiu 	$s2,$0,0			# use as count for array loop 
	lui 	$t0,0xFFFF			# $t0 = 0xFFFF0000;
	ori 	$a0,$0,2			# enable keyboard interrupt
	sw 	$a0,0($t0)			# write back to 0xFFFF0000;
	#la      $s7,Que				# gloabal variable never touch but in ktext
	la 	$t0,Que				# get address of que 
	la 	$t1,Que_pointer			# get address of que pointer 
	addi	$t2,$t0,0			# put the address in a register 
	sw 	$t2,0($t1)
	li	$t0,0
	li 	$t1,0		
	li 	$t2,0				# clear both t registers so our code doesnt mess with the address 
	######
	#test:
	
	#j test  
	
loop: 

	addi 	$sp,$sp,-16			# save arguments to stack care about them all since we j back to main and run it five times 
	sw 	$s0,0($sp)			# count for this loop 
	sw 	$a0,4($sp)			# gen id 
	sw 	$a1,8($sp)			# limit
	sw 	$s2,12($sp)			# count array loop
	jal 	RandNumb
	sw 	$s2,12($sp)	
	lw 	$a1,8($sp)
	lw 	$a0,4($sp)
	lw 	$s0,0($sp)		
	addi 	$sp,$sp,16			
	
	addi 	$sp,$sp,-16		
	sw 	$s0,0($sp)			# main count 
	sw 	$a0,4($sp)			# generate ID
	sw 	$a1,8($sp)			# limit 
	sw 	$s2,12($sp)			# array loop count 
	addiu 	$a0,$a2,0			# put rand num in a0 
	addiu 	$a1,$s2,0			# put total count for array index in al 
	jal 	arrayTravs
	lw 	$s2,12($sp)	
	lw 	$a1,8($sp)
	lw 	$a0,4($sp)
	lw 	$s0,0($sp)		
	addi 	$sp,$sp,16	
	
	beq  	$s0,4,done
	addi 	$s0,$s0,1		     # increment overall loop counter
	addi 	$s2,$s2,1		     # increment array inde
	j loop
				
done: 
		
	addiu 	$v0, $0,10
	syscall 	
###############################################################################################################################################
# RandNumb
# inputs 
# $a0	=  id of generator 
# $a1   =  seed for the generator
#Outputs 
# $a2   =  value of number that was printed 
.data 

NumbIs:	    .asciiz "Remember: " 

.text 
RandNumb:
		
	addiu 	$v0,$0,42			# syscall to generate random number 
	syscall 
	move 	$a2,$a0			# store the randNumb in a2 
	addiu 	$v0,$0,30			# get system time for seed 
	syscall 
	move 	$a1,$a0
	addiu 	$a0,$0,0			# set the seed in java with system time  
	addiu 	$v0,$0,40			# syscall for set seed 
	syscall
	
	
	jr 	$ra
	

###################################################################################################################################################
# Pause 
# inputs 
# $a0	= number of miliseconds to wait 
# outputs 
# none 

Pause:
	
	move 	$t0, $a0			# save the time out in a temp
	li 	$v0,30			# get initial time which is now in $a0 and $a1 
	syscall 	
	move 	$t1,$a0			# put low order in $t1
	
Ploop2:
	
	syscall
	
	subu 	$t2,$a0,$t1		# current time will be in $a0 $t1 suptracts that number from initial time  
	bltu 	$t2,$t0,Ploop2 		# loop if the differance of a0 and t1 < timeout argument passed 
	 
	jr 	$ra 
#####################################################################################################################################################
# arrayTravs
# inputs 
# $a0 = holds rand numb  
# $a1 = holds overall count which will be the index for our arrays 
# outputs  
# none atm
.data 
array1: .word 0,0,0,0,0

.text
arrayTravs:

	# draw first line before anything 
	addi 	$sp,$sp,-20
	sw 	$ra,0($sp)
	sw 	$a0,4($sp)
	sw 	$a1,8($sp)
	sw 	$a2,12($sp)
	sw 	$a3,16($sp)
	addi 	$a0,$0,64			# change x to 0
	addi	$a1,$0,64			# put y in the middle 
	addi 	$a2,$0,5			# color 
	addi 	$a3,$0,128			# how far the line should go 
	jal 	DiagLine			# add back in x line
	lw 	$a3,16($sp)
	lw 	$a2,12($sp)
	lw 	$a1,8($sp)
	lw 	$a0,4($sp)			 
	lw 	$ra,0($sp)
	addi 	$sp,$sp,20
	
	addi 	$sp,$sp,-20 
	sw 	$ra,0($sp)
	sw 	$a0,4($sp)
	sw 	$a1,8($sp)
	sw 	$a2,12($sp)
	sw 	$a3,16($sp)
	addi 	$a0,$0,190			# put x in middle 
	addi 	$a1,$0,64			# set y to zero 
	addi 	$a2,$0,5			# color 
	addi 	$a3,$0,128			# how far the line should go 
	jal 	DiagLine			# add back y line 
	lw 	$a3,16($sp)
	lw 	$a2,12($sp)
	lw 	$a1,8($sp)
	lw 	$a0,4($sp)			 
	lw 	$ra,0($sp)
	addi 	$sp,$sp,20
	
	addi 	$a0,$a0,1
	la 	$t0,array1			# get the address out of $al
	add 	$s0,$a1,0			# need to keep the untoched index around so i can loop with it later 
	add 	$s3,$a1,0			# do this to hopefully fix my one loop error 
	add 	$a1,$a1,$a1			# double the number 
	add 	$a1,$a1,$a1			# double again so we mult by four bam !
	add 	$s1,$a1,$t0			# this will be the address of the array element
	sw 	$a0,0($s1)			# store $ao to that address 
	sub 	$s1,$s1,$a1			# subtract that number so now i print up with +4 
	addi 	$sp,$sp,-4
	sw 	$s3,0($sp)
	
ArrayLoop:

	lw 	$a0,0($s1)
	addi 	$sp,$sp,-12		# save arguments to stack care about  
	sw 	$s1,0($sp)			# array address
	sw 	$ra,4($sp)			# return address
	sw 	$s0,8($sp)			# array index
	jal 	ChooseCircle		# jump to circle now 
	lw 	$s0,8($sp)
	lw 	$ra,4($sp)
	lw 	$s1,0($sp)		
	addi 	$sp,$sp,12 		# give memory back to the stack
	
	addi 	$sp,$sp,-12		# save arguments to stack care about  
	sw 	$s1,0($sp)			# array address
	sw 	$ra,4($sp)			# return address
	sw 	$s0,8($sp)			# array index
	add	 $t0,$s1,0			# copy address to a temp reg
	lw 	$a0,0($t0)
	jal 	Panda			# let the user see the number for only a certain amount of time
	add 	$t0,$0,0			# get address out of there 
	lw 	$s0,8($sp)
	lw	$ra,4($sp)
	lw 	$s1,0($sp)		
	addi 	$sp,$sp,12 		# give memory back to the stack
	
	addi 	$sp,$sp,-12		# save arguments to stack care about  
	sw 	$s1,0($sp)			# array address
	sw 	$ra,4($sp)			# return address
	sw 	$s0,8($sp)			# array index
	addiu 	$a0,$0,2000
	jal 	Pause			# let the user see the number for only a certain amount of time
	lw 	$s0,8($sp)
	lw 	$ra,4($sp)
	lw 	$s1,0($sp)		
	addi 	$sp,$sp,12 		# give memory back to the stack
		
	lw 	$t0,0($s1)
	addi 	$a0,$t0,0			# need to pass array index without overiding 
	sw 	$t0,0($s1)
	addi 	$sp,$sp,-12
	sw 	$s0,0($sp)			# array index 
	sw 	$s1,4($sp)			# array address
	sw 	$ra,8($sp)			# return address )
	jal 	ClearDisp	       		# when t1 equals 0 go back to return 	
	lw 	$ra,8($sp)			# stack didnt get restored so we do it here just incase 
	lw 	$s1,4($sp)
	lw 	$s0,0($sp)
	addi 	$sp,$sp,12
	
	addi 	$sp,$sp,-12			# save arguments to stack care about  
	sw 	$s1,0($sp)			# array address
	sw 	$ra,4($sp)			# return address
	sw 	$s0,8($sp)			# array index
	addiu 	$a0,$0,1000
	jal 	Pause				# let the user see the number for only a certain amount of time
	lw 	$s0,8($sp)
	lw 	$ra,4($sp)
	lw 	$s1,0($sp)		
	addi 	$sp,$sp,12 			# give memory back to the stack

	beq 	$s0,0,HideNumb
	sub 	$s0,$s0,1	
	addi	 $s1,$s1,4
	j 	ArrayLoop 
		
HideNumb:

	lw 	$s3,0($sp)
	addi 	$sp,$sp,4
	
	addi 	$sp,$sp,-12
	sw 	$s0,0($sp)			# array index 
	sw 	$s1,4($sp)			# array address
	sw 	$ra,8($sp)			# return address 
	add	$a0,$s3,0			# send index
	add	$a1,$s1,0			# send address
	la 	$a2,Que				# send que address 
	jal 	check	       			# when t1 equals 0 go back to return 	
	lw 	$ra,8($sp)			# stack didnt get restored so we do it here just incase 
	lw 	$s1,4($sp)
	lw 	$s0,0($sp)
	addi 	$sp,$sp,12
	
	# clear que information 
	la 	$t0,Que				# get address of que 
	la 	$t1,Que_pointer			# get address of que pointer 
	addi	$t2,$t0,0			# put the address in a register 
	sw 	$t2,0($t1)
	li	$t0,0
	li 	$t1,0		
	li 	$t2,0				# clear both t registers so our code doesnt mess with the address 
	jr 	$ra
###############################################################################################################################################################
# check
# inputs 
# a0 = array index 
# a1 = array address 
# a2 = que address 
.data
heyUser: 	.asciiz "Enter the value "
Yeah:		.asciiz	" Next..."
Nah:		.asciiz	"Dang you suck...bye"

.text 

check:
	

 
	addiu 	$sp,$sp,-4
	sw 	$a0,0($sp)
	la 	$a0,heyUser
	addiu 	$v0,$0,4			# print the display prompt
	syscall
	lw 	$a0,0($sp)
	addiu 	$sp,$sp,4
		
	sll 	$a0,$a0,2
	sub 	$a1,$a1,$a0
	srl 	$a0,$a0,2
	
CheckLoop:
	
	#addi 	$sp,$sp,-12
	#sw 	$a0,0($sp)
	#sw 	$a1,4($sp)			# keep this around incase the que thing doesn't work 
	#sw 	$ra,8($sp)	
	#addiu 	$a0,$0,8000		
	#jal 	Pause				# wait around for get user input  
	#lw 	$ra,8($sp)
	#lw 	$a1,4($sp)
	#lw 	$a0,0($sp)
	#addi 	$sp,$sp,12

	li 	$t0,1000000			# loop a shit ton until user enters a value or leave 	
SirLoop:
	
	lw 	$t5,0($a2)			# get first element in que 
	addi	$t1,$0,0			# put zero in t1
	bne	$t5,0,EndSirLoop		# keep looping as long as there is nothing there or until count goes to zero 
	beq	$t0,0,EndSirLoop 
	add 	$t0,$t0,-1			# decrement t0 
	j 	SirLoop
EndSirLoop:

		
	addi 	$t5,$t5,-48		
	lw 	$t3,0($a1)			# put value of array element in t3
	bne	$t5,$t3,Nope			# compare them if equal loop if not go to nope 
	beq 	$a0,0,jumpOut			# if index equals 0 get out of loop
	add 	$a0,$a0,-1			# sub one from index count
	addi 	$a1,$a1,+4			# move to the next element in the array 
	sw 	$t1,0($a2)			# de que 
	addi 	$a2,$a2,+4			# increase que address by 4 to get the next element 
	
	j 	CheckLoop

jumpOut:

	la 	$a0,Yeah
	addiu 	$v0,$0,4
	syscall
	addi 	$a0, $0, 0xA 			# ascii code for LF
	addi 	$v0, $0, 0xB	        	# syscall 11 prints the lower 8 bits of $a0 as an ascii character.
	syscall	
	jr 	$ra

					
Nope:
		
	li 	$t7,0				# this will be our blink counter 
Blink:
	add  	$a0,$a2,50			# make some noise add both x and y offset to get different tones
	addi 	$a1,$0,1000			# duration of noise 
	addi 	$a2,$0,9			# instroment 
	addi 	$a3,$0,127			# volume 
	li 	$v0,31
	syscall 
	
	lw 	$a0,0($s1)
	addi 	$sp,$sp,-16			# save arguments to stack care about  
	sw 	$s1,0($sp)			# array address
	sw 	$ra,4($sp)			# return address
	sw 	$s0,8($sp)			# array index
	sw	$t7,12($sp)
	jal 	ChooseCircle			# jump to circle now 
	lw 	$t7,12($sp)
	lw 	$s0,8($sp)
	lw 	$ra,4($sp)
	lw 	$s1,0($sp)		
	addi 	$sp,$sp,16 			# give memory back to the stack
	
	addi 	$sp,$sp,-16			# save arguments to stack care about  
	sw 	$s1,0($sp)			# array address
	sw 	$ra,4($sp)			# return address
	sw 	$s0,8($sp)			# array index
	sw 	$t7,12($sp)
	add	$t0,$s1,0			# copy address to a temp reg
	lw 	$a0,0($t0)
	jal 	Panda				# let the user see the number for only a certain amount of time
	add 	$t0,$0,0			# get address out of there 
	lw 	$t7,12($sp)
	lw 	$s0,8($sp)
	lw	$ra,4($sp)
	lw 	$s1,0($sp)		
	addi 	$sp,$sp,16 			# give memory back to the stack
		
	lw 	$t0,0($s1)
	addi 	$a0,$t0,0			# need to pass array index without overiding 
	sw 	$t0,0($s1)
	addi 	$sp,$sp,-16
	sw 	$s0,0($sp)			# array index 
	sw 	$s1,4($sp)			# array address
	sw 	$ra,8($sp)			# return address )
	sw 	$t7,12($sp)
	jal 	ClearDisp	       		# when t1 equals 0 go back to return 
	lw 	$t7,12($sp)	
	lw 	$ra,8($sp)			# stack didnt get restored so we do it here just incase 
	lw 	$s1,4($sp)
	lw 	$s0,0($sp)
	addi 	$sp,$sp,16
	
	beq	$t7,5,DoneDone			# jump at if our counter equals 5 
	add	$t7,$t7,1			# increment the counter 
	j 	Blink 
	
DoneDone:

	# tell em nope 
	# play again 
	la 	$a0,Nah
	addiu 	$v0,$0,4
	syscall
	
	# end it all 
	addiu 	$v0,$0,10
	syscall 
##########################################################################################################################################################
# lab 08 for reals from here on out 
#########################################################################################################################################################
# ChoseCircle
# will determine which box to print based of the rand numbs  
# inputs 
# $a0 = rand generated number 

ChooseCircle:

	la 	$t0,DrawCircleTable
	subu 	$a0,$a0,1
	mul 	$a0,$a0,12			# multiply the value by 12 
	addu 	$t3,$a0,$t0			# get the address 
	
	lw	$a0,0($t3)			# get x offset value
	lw 	$a1,4($t3) 			# get y offset value
	lw 	$a2,8($t3)			# get color 
	addi 	$a3,$0,10
	
	addi 	$sp,$sp,-4			# only need to save ra because a values are stored in other places 
	sw 	$ra,0($sp)
	jal 	DrawCircle
	lw 	$ra,0($sp) 
	addi 	$sp,$sp,4
	
	add  	$a0,$a2,50			# make some noise add both x and y offset to get different tones
	addi 	$a1,$0,1000			# duration of noise 
	addi 	$a2,$0,112			# instroment 
	addi 	$a3,$0,127			# volume 
	li 	$v0,31
	syscall 
	
	jr 	$ra
##########################################################################################################################################################
# CalcAddr 
# $a0 = x coord 
# $a1 = y coord 
# returns 
# $v0 = memory address 

CalcAddr:
	
	sll  $a0,$a0,2 				# mult x by 4 
	sll  $a1,$a1,10				# mult y by 128
	add  $v0,$0,0x10040000			# set v0 to the base 
	add  $v0,$v0,$a0			# add the x coord 
	add  $v0,$v0,$a1			# add the y coord 
	
	jr   $ra 
	
	
##########################################################################################################################################################
# GetColor
# inputs 
# $a2 = color number (0-7)
# returns 
# $v1 = actual number to write to the display  
	
GetColor: 

	la 	$t0, ColorTable
	sll 	$a2,$a2,2			# index x4 is offset 
	addu 	$a2,$a2,$t0			# base offset 
	lw 	$v1,0($a2)			# get actual color word 
	
	jr 	$ra 
	
#########################################################################################################################################################
# DrawDot
# input
# $a0 = x coord
# $a1 = y coord 
# $a2 = color number (0-7)

DrawDot: 
	
	addiu 	$sp,$sp,-8			# give space for 2 
	sw 	$ra,4($sp)
	sw 	$a2,0($sp)
	jal 	CalcAddr
	lw 	$a2,($sp)
	sw 	$v0,($sp)
	jal 	GetColor
	lw 	$v0,0($sp)
	sw 	$v1,($v0)	        	# make the dot 
	lw 	$ra,4($sp)
	addiu 	$sp,$sp,8
	
	jr	$ra 
###########################################################################################################################################################
# HorzLine
# inputs
# $a0 = x coord
# $a1 = y coord 
# $a2 = color number 
# $a3 = length of the line 1-32 

HorzLine:
	addi 	$sp,$sp,-4			# save ra 
	sw 	$ra,0($sp)
	
HorzLoop:
	
	addi 	$sp,$sp,-16
	sw 	$a0,0($sp)
	sw 	$a1,4($sp)
	sw 	$a2,8($sp)
	sw 	$a3,12($sp)
	jal 	DrawDot				# draw dots based off a registers
	lw 	$a3,12($sp) 
	lw 	$a2,8($sp)	
	lw 	$a1,4($sp)
	lw 	$a0,0($sp)
	add	 $a0,$a0,1			# increment x 
	addi 	$sp,$sp,16
	addiu 	$a3,$a3,-1
	bne 	$a3,$0,HorzLoop			# keep looping 
	lw 	$ra,0($sp)
	addi 	$sp,$sp,4
	
	jr 	$ra

###########################################################################################################################################################
# VertLine
# inputs 
# $a0 = x coord
# $a1 = y coord 
# $a2 = color number 
# $a3 = size of box 1-32 

VertLine:
	addi 	$sp,$sp,-4			# save ra 
	sw 	$ra,0($sp)
	
VertLoop:
	
	addi 	$sp,$sp,-16
	sw 	$a0,0($sp)
	sw 	$a1,4($sp)
	sw 	$a2,8($sp)
	sw 	$a3,12($sp)
	jal 	DrawDot				# draw dots based off a registers
	lw 	$a3,12($sp) 
	lw 	$a2,8($sp)	
	lw 	$a1,4($sp)
	lw 	$a0,0($sp)
	add 	$a1,$a1,1			# increment x 
	addi 	$sp,$sp,16
	addiu 	$a3,$a3,-1
	bne 	$a3,$0,VertLoop			# keep looping 
	lw 	$ra,0($sp)	
	addi 	$sp,$sp,4
	
	jr 	$ra 
		
###################################################################################################################################################################
ClearDisp:
	
	la 	$t0,DrawCircleTable
	subu 	$a0,$a0,1
	mul 	$a0,$a0,12			# multiply the value by 4 
	addu 	$t3,$a0,$t0			# get the address 
	
	lw 	$a0,0($t3)			# get x value
	lw 	$a1,4($t3)
	addi 	$a2,$0,0
	addi 	$a3,$0,10
	
	addi 	$sp,$sp,-4			# only need to save ra because a values are stored in other places 
	sw 	$ra,0($sp)
	jal 	DrawCircle
	lw 	$ra,0($sp) 
	addi 	$sp,$sp,4
						# after done drawing circle restore ra 
	
	jr 	$ra 
###########################################################################################################################################################
# DiagLine
# inputs 
# $a0 = x coord
# $a1 = y coord 
# $a2 = color number 
# $a3 = size of box 1-32 

ChangeX:					# jump here if x is bigger than 128

	addi 	$t1,$0,-1
	j 	DiagLoop
	
DiagLine:

	addi 	$sp,$sp,-4			# save ra 
	sw 	$ra,0($sp)
	addi 	$t0,$0,128
	addi 	$t1,$0,1
	
	bgt 	$a0,$t0,ChangeX			# if x is greater that 128 draw the line with a positive slope
	 
DiagLoop:
	
	addi 	$sp,$sp,-16
	sw 	$a0,0($sp)
	sw 	$a1,4($sp)
	sw 	$a2,8($sp)
	sw 	$a3,12($sp)
	jal 	DrawDot				# draw dots based off a registers
	lw 	$a3,12($sp) 
	lw 	$a2,8($sp)	
	lw 	$a1,4($sp)
	lw 	$a0,0($sp)
	add 	$a0,$a0,$t1			# increment x by 2  
	add 	$a1,$a1,1			# increment y
	addi 	$sp,$sp,16
	addiu 	$a3,$a3,-1
	bne 	$a3,$0,DiagLoop			# keep looping 
	lw 	$ra,0($sp)
	addi 	$sp,$sp,4
	
	jr 	$ra 
###########################################################################################################################################################
# Draw Circle
# inputs 
# $a0 = x coord offset 
# $a1 = y coord offset 
# x coord starts at 128 with a 0 offset 
# y coord starts at 20 with a 0 offset 
# $a2 = color number 
 	
.data

CircleTable:

	.word 128,20,44
	.word 127,20,44
	.word 126,20,44
	.word 125,20,44
	.word 124,21,42
	.word 123,21,42
	.word 122,21,42 ### 3 space 
	.word 121,22,40 
	.word 120,22,40	## left 2 pixels 
	.word 119,23,38
	.word 118,23,38	## left 2 pixels 
	.word 117,24,36 
	.word 116,25,34	
	.word 115,25,34 ## left 2 pixels
	.word 114,26,32 
	.word 113,28,28 ## START of drop 2 y
	.word 112,29,26
	.word 111,31,22 ## drop 2 y 
	.word 110,33,20 ## drop 2 y 
	.word 109,36,14 ## drop 3 y 
	.word 108,38,10 ## drop 2 y 
	
.text 

DrawCircle:

	addi $s4,$a0,0		       		# put x offset in $a0 
	addi $s5, $a1,0				# put y offset in $a1
	addi $s6, $a2,0				# put color in $a2 
	
	addi $s2,$0,0
	
CircleCircle:
	
	la 	$s0,CircleTable			# put the address of the tbale in a register 
	add 	$s1,$s2,$0
	mul 	$s1,$s2,12
	add 	$s0,$s0,$s1
	
	lw 	$a0,0($s0)			# x 
	lw 	$a1,4($s0)			# y
	add 	$a0,$a0,$s4			# add the x offset 
	add 	$a1,$a1,$s5			# add the y offset 
	add 	$a2,$0,$s6			# look up color  
	lw 	$a3,8($s0)			# length
	
	addi 	$sp,$sp,-28
	sw 	$s0,0($sp)
	sw 	$s1,4($sp)
	sw 	$s2,8($sp)
	sw 	$s4,12($sp)
	sw 	$s5,16($sp)
	sw 	$s6,20($sp)
	sw 	$ra,24($sp)
	jal 	VertLine 
	lw 	$ra,24($sp)
	lw 	$s6,20($sp)
	lw 	$s5,16($sp)
	lw 	$s4,12($sp)
	lw 	$s2,8($sp)
	lw 	$s1,4($sp)
	lw 	$s0,0($sp)
	addi 	$sp,$sp,28
	
	addi	$s2,$s2,1			# add one to the loop count 
	beq 	$s2,21,OtherHalf		# after all 21 lines have been draw leave 
	j 	CircleCircle 
	
OtherHalf:
	
	addi 	$s2,$0,0
	addi 	$s3,$0,0			# need this to make the next half 
	
CircleCircle2:

	la 	$s0,CircleTable			# put the address of the tbale in a register 
	add 	$s1,$s2,$0
	mul 	$s1,$s2,12
	add 	$s0,$s0,$s1
	
	lw 	$a0,0($s0)			# x 
	add 	$a0,$a0, $s3			# move the value over to its secound half position 
	lw 	$a1,4($s0)			# y
	add	$a0,$a0,$s4			# add x offset 
	add 	$a1,$a1,$s5			# add y offset 
	add 	$a2,$0,$s6			# look up color 
	lw 	$a3,8($s0)			# length
	
	addi 	$sp,$sp,-32
	sw 	$s0,0($sp)
	sw 	$s1,4($sp)
	sw 	$s2,8($sp)
	sw 	$s3,12($sp)
	sw 	$s4,16($sp)
	sw 	$s5,20($sp)
	sw 	$s6,24($sp)
	sw 	$ra,28($sp)
	jal 	VertLine 
	lw 	$ra,28($sp)
	lw 	$s6,24($sp)
	lw 	$s5,20($sp)
	lw 	$s4,16($sp)
	lw 	$s3,12($sp)
	lw 	$s2,8($sp)
	lw	$s1,4($sp)
	lw 	$s0,0($sp)
	addi 	$sp,$sp,32
	
	addi 	$s3,$s3,2			# add 2 every time 
	addi 	$s2,$s2,1			# add one to the loop count 
	beq 	$s2,21,CircleDone		# after all 21 lines have been draw leave 
	j 	CircleCircle2 
	
CircleDone:

	jr 	$ra 
	
#######################################
# Following Code is not mine its pandas he is one crazy cat
# used to display chars in pixels
# inputs 
# $a0 number you want printed 
# Returns
# nothing 
#######################################################################################################################################################################################
.data

Colors: 

	.word   0x000000        # background color (black)
        .word   0xffffff        # foreground color (white)

DigitTable:
        .byte   ' ', 0,0,0,0,0,0,0,0,0,0,0,0
        .byte   '0', 0x7e,0xff,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xff,0x7e
        .byte   '1', 0x38,0x78,0xf8,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18
        .byte   '2', 0x7e,0xff,0x83,0x06,0x0c,0x18,0x30,0x60,0xc0,0xc1,0xff,0x7e
        .byte   '3', 0x7e,0xff,0x83,0x03,0x03,0x1e,0x1e,0x03,0x03,0x83,0xff,0x7e
        .byte   '4', 0xc3,0xc3,0xc3,0xc3,0xc3,0xff,0x7f,0x03,0x03,0x03,0x03,0x03
        .byte   '5', 0xff,0xff,0xc0,0xc0,0xc0,0xfe,0x7f,0x03,0x03,0x83,0xff,0x7f
        .byte   '6', 0xc0,0xc0,0xc0,0xc0,0xc0,0xfe,0xfe,0xc3,0xc3,0xc3,0xff,0x7e
        .byte   '7', 0x7e,0xff,0x03,0x06,0x06,0x0c,0x0c,0x18,0x18,0x30,0x30,0x60
        .byte   '8', 0x7e,0xff,0xc3,0xc3,0xc3,0x7e,0x7e,0xc3,0xc3,0xc3,0xff,0x7e
        .byte   '9', 0x7e,0xff,0xc3,0xc3,0xc3,0x7f,0x7f,0x03,0x03,0x03,0x03,0x03
        .byte   '+', 0x00,0x00,0x00,0x18,0x18,0x7e,0x7e,0x18,0x18,0x00,0x00,0x00
        .byte   '-', 0x00,0x00,0x00,0x00,0x00,0x7e,0x7e,0x00,0x00,0x00,0x00,0x00
        .byte   '*', 0x00,0x00,0x00,0x66,0x3c,0x18,0x18,0x3c,0x66,0x00,0x00,0x00
        .byte   '/', 0x00,0x00,0x18,0x18,0x00,0x7e,0x7e,0x00,0x18,0x18,0x00,0x00
        .byte   '=', 0x00,0x00,0x00,0x00,0x7e,0x00,0x7e,0x00,0x00,0x00,0x00,0x00
        .byte   'A', 0x18,0x3c,0x66,0xc3,0xc3,0xc3,0xff,0xff,0xc3,0xc3,0xc3,0xc3
        .byte   'B', 0xfc,0xfe,0xc3,0xc3,0xc3,0xfe,0xfe,0xc3,0xc3,0xc3,0xfe,0xfc
        .byte   'C', 0x7e,0xff,0xc1,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc1,0xff,0x7e
        .byte   'D', 0xfc,0xfe,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xfe,0xfc
        .byte   'E', 0xff,0xff,0xc0,0xc0,0xc0,0xfe,0xfe,0xc0,0xc0,0xc0,0xff,0xff
        .byte   'F', 0xff,0xff,0xc0,0xc0,0xc0,0xfe,0xfe,0xc0,0xc0,0xc0,0xc0,0xc0
# add additional characters here....
# first byte is the ascii character
# next 12 bytes are the pixels that are "on" for each of the 12 lines
        .byte    0, 0,0,0,0,0,0,0,0,0,0,0,0




#  0x80----  ----0x08
#  0x40--- || ---0x04
#  0x20-- |||| --0x02
#  0x10- |||||| -0x01
#       ||||||||
#       84218421

#   1   ...xx...      0x18
#   2   ..xxxx..      0x3c
#   3   .xx..xx.      0x66
#   4   xx....xx      0xc3
#   5   xx....xx      0xc3
#   6   xx....xx      0xc3
#   7   xxxxxxxx      0xff
#   8   xxxxxxxx      0xff
#   9   xx....xx      0xc3
#  10   xx....xx      0xc3
#  11   xx....xx      0xc3
#  12   xx....xx      0xc3


 
Test1:  .asciiz "0123456789"
Test2:  .asciiz "+ - * / ="
Test3:  .asciiz "ABCDEF"
Dig1:	.asciiz "1"
Dig2:	.asciiz "2"
Dig3:	.asciiz "3"
Dig4:	.asciiz "4"


.text
Panda:
 	addi 	$sp,$sp,-4
 	sw 	$ra,0($sp)
 	# compare random number to 1,2,3,4 and display the right number 
        beq 	$a0,1,Digit1
        beq 	$a0,2,Digit2
        beq 	$a0,3,Digit3
        beq 	$a0,4,Digit4
        
        j badInput 
               
Digit1:

        li      $a0, 123        
        li      $a1, 45
        la      $a2, Dig1
        jal     OutText
        
        j badInput
        
Digit2:

        li      $a0, 45
        li      $a1, 122
        la      $a2, Dig2
        jal     OutText
        
	j badInput
	
Digit3:

        li      $a0, 200
        li      $a1, 125
        la      $a2, Dig3
        jal     OutText
        
	j badInput
	
Digit4:
	
	li      $a0, 123
        li      $a1, 194
        la      $a2, Dig4
        jal     OutText
        
        j badInput

badInput:

      lw 	$ra,0($sp)
      addi 	$sp,$sp,4
      
      jr 	$ra

# OutText: display ascii characters on the bit mapped display
# $a0 = horizontal pixel co-ordinate (0-255)
# $a1 = vertical pixel co-ordinate (0-255)
# $a2 = pointer to asciiz text (to be displayed)
OutText:
        addiu   $sp, $sp, -24
        sw      $ra, 20($sp)

        li      $t8, 1          # line number in the digit array (1-12)
_text1:
        la      $t9, 0x10040000 # get the memory start address
        sll     $t0, $a0, 2     # assumes mars was configured as 256 x 256
        addu    $t9, $t9, $t0   # and 1 pixel width, 1 pixel height
        sll     $t0, $a1, 10    # (a0 * 4) + (a1 * 4 * 256)
        addu    $t9, $t9, $t0   # t9 = memory address for this pixel

        move    $t2, $a2        # t2 = pointer to the text string
_text2:
        lb      $t0, 0($t2)     # character to be displayed
        addiu   $t2, $t2, 1     # last character is a null
        beq     $t0, $zero, _text9

        la      $t3, DigitTable # find the character in the table
_text3:
        lb      $t4, 0($t3)     # get an entry from the table
        beq     $t4, $t0, _text4
        beq     $t4, $zero, _text4
        addiu   $t3, $t3, 13    # go to the next entry in the table
        j       _text3
_text4:
        addu    $t3, $t3, $t8   # t8 is the line number
        lb      $t4, 0($t3)     # bit map to be displayed

        sw      $zero, 0($t9)   # first pixel is black
        addiu   $t9, $t9, 4

        li      $t5, 8          # 8 bits to go out
_text5:
        la      $t7, Colors
        lw      $t7, 0($t7)     # assume black
        andi    $t6, $t4, 0x80  # mask out the bit (0=black, 1=white)
        beq     $t6, $zero, _text6
        la      $t7, Colors     # else it is white
        lw      $t7, 4($t7)
_text6:
        sw      $t7, 0($t9)     # write the pixel color
        addiu   $t9, $t9, 4     # go to the next memory position
        sll     $t4, $t4, 1     # and line number
        addiu   $t5, $t5, -1    # and decrement down (8,7,...0)
        bne     $t5, $zero, _text5

        sw      $zero, 0($t9)   # last pixel is black
        addiu   $t9, $t9, 4
        j       _text2          # go get another character

_text9:
        addiu   $a1, $a1, 1     # advance to the next line
        addiu   $t8, $t8, 1     # increment the digit array offset (1-12)
        bne     $t8, 13, _text1

        lw      $ra, 20($sp)
        addiu   $sp, $sp, 24
        jr      $ra
############################################################################################################################################################################
# keyboard interupt 
# goes here when a person hits a key

.ktext 0x80000180

	addi    $sp,$sp,-16		# store everything you mess with in the stack before you jump out 
	sw 	$ra,0($sp)
	sw 	$v0,4($sp)
	sw 	$t0,8($sp)
	sw 	$t1,12($sp)
	
	mfc0 	$k0,$13			# cause register 
	mfc0 	$k1,$14			# EOC
	andi 	$k0,$k0,0x003c		# and ko and 0x003c 
	bne 	$k0,$0,NotI0		# if this is zero well then IDK what it is but leave
	
	jal 	GetChar			# get char if code is 0 

	mtc0 	$0, $13			# Clear Cause register
	mfc0 	$k0, $12			# Set Status register
	andi 	$k0, 0xfffd		# clear EXL bit
	ori  	$k0, 0x11			# Interrupts enabled
	mtc0 	$k0, $12			# write back to status

NotI0:

	lw 	$t1,12($sp)
	lw 	$t0,8($sp)
	lw 	$v0,4($sp)		# restore everything before leaveing 	
	lw 	$ra,0($sp)
	addi 	$sp,$sp,16
	eret 
	
	

# interupt tester
#############################################################################################################################################
# key board polling 
# CharThere
# erutrns 
# $v0

IsCharThere: 
	
	lui 	$t0,0xffff			# status register 
	lw 	$t1,0($t0)			# get control 
	andi 	$v0,$t1,1			# mask all but read bit 
	jr 	$ra
#############################################################################################################################################
# key board polling 
# GetChar 
# rutrns 
# $v0 = ascci character 

GetChar: 

	addi 	$sp,$sp,-4
	sw 	$ra,0($sp)
	j 	GoCheck
Cloop:
	
GoCheck: 
	
	jal 	IsCharThere
	beq 	$v0,$0,Cloop		# if nothing is there 
	lui	$t0,0xffff		
	lw 	$v0,4($t0)		# char in oxffff0004
	la	$t0,Que_pointer
	lw 	$t1,0($t0)		# put value from que pointer in t1
	sw      $v0,0($t1)		# save to que
	addi    $t1,$t1,4		# increment que address 
	sw 	$t1,0($t0)		# update que pointer 
	lw 	$ra,0($sp)
	addi 	$sp,$sp,4 
	
	jr 	$ra
################################################################################################################
###################################################################################################################################	

