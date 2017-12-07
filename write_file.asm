.data
 .word   0 : 40
 stack_end: 

#   ... put your data here ...
RandSeq    :    .byte 0,0,0,0,0			# will use RandSeq and UserSeq to store each sequence of numbers so they can be compared later 
UserSeq    :    .byte 0,0,0,0,0
prompt2    :    .asciiz   "Now Enter the displayed Sequence" 

spacePrompt1  :   .asciiz " \n "
NumbIs        :   .asciiz     "Try to remember the Numbers Displayed: " 
stack_beg     :   .word 0:99

  .text 
     
 MainLoop:
       la $sp, stack_end 	       		# set the pointer of the stack
       	
	addiu $a0,$0,1			# pass gen id 
	addiu $a1,$0,4			# pass limit 
	addiu $s0,$0,0			# use this as my count for the loop
	addiu $s2,$0,0			# use as count for array loop 	
   loop: 
	addi $sp,$sp,-16		# save arguments to stack care about them all since we j back to main and run it five times 
	sw $s0,0($sp)			# count for this loop 
	sw $a0,4($sp)			# gen id 
	sw $a1,8($sp)			# limit
	sw $s2,12($sp)			# count array loop
	
	jal GenRand
	
	sw $s2, 12($sp)	
	lw $a1, 8($sp)
	lw $a0, 4($sp)
	lw $s0, 0($sp)		
	addi $sp,$sp,16			
	
	addi $sp,$sp,-16		
	sw $s0, 0($sp)			# main count 
	sw $a0, 4($sp)			# generate ID
	sw $a1, 8($sp)			# limit 
	sw $s2, 12($sp)			# array loop count 
	addiu $a0, $a2,0		# put rand num in a0 
	addiu $a1, $s2,0	        # put total count for array index in al
	 
	jal arrayTravs
	
	lw $s2, 12($sp)	
	lw $a1, 8($sp)
	lw $a0, 4($sp)
	lw $s0, 0($sp)		
	addi $sp, $sp,16	
	addi $s0, $s0,1		         # increment overall loop counter
	addi $s2, $s2,1		         # increment array inde
	j loop
					
####################################################################################	
    ## native functions
####################################################################################
GenRand:
		
	addiu $v0,$0,42			 # syscall to generate random number 
	syscall  
	move $a2,$a0			 # store the randNumb in a2 
	addiu $v0,$0,30			 # get system time for seed 
	syscall 
	move $a1,$a0
	addiu $a0,$0,0			 # set the seed in java with system time  
	addiu $v0,$0,40			 # syscall for set seed 
	syscall	
	jr $ra
	
#######################################################################################
Pause:
	move $t0, $a0			# save the time out in a temp
	li $v0,30			# get initial time which is now in $a0 and $a1 
	syscall 	
	move $t1,$a0			# put low order in $t1
	
  Ploop:
	syscall 
	subu $t2,$a0,$t1		# current time will be in $a0 $t1 suptracts that number from initial time  
	bltu $t2,$t0,Ploop		# loop if the timeout has lapses 
	jr $ra 
#######################################################################################
.data 
SequenceArray: .word 0,0,0,0,0

.text
arrayTravs:	
	la $t0, SequenceArray	# get the address out of $al
	add $s0,$a1,0		# need to keep the untoched index around so i can loop with it later 
	add $a1,$a1,$a1		# double the number 
	add $a1,$a1,$a1		# double again so we mult by four bam !
	add $s1,$a1,$t0		# this will be the address of the array element
	sw $a0,0($s1)		# store $ao to that address 
	sub $s1,$s1,$a1		# subtract that number so now i print up with +4 	
ArrayLoop:

	lw $a0,0($s1)
	addiu $v0,$0,1
	syscall
	sw $a0,0($s1)
	addi $sp,$sp,-16		# save arguments to stack care about  
	sw $s1,0($sp)			# stack address
	sw $ra,8($sp)			# return address
	sw $s0,12($sp)			# array index
	addiu $a0,$0,3000
	jal Pause			# let the user see the number for only a certain amount of time
	lw $s0,12($sp)
	lw $ra,8($sp)
	lw $s1,0($sp)		
	addi $sp,$sp,16 		# give memory back to the stack
	
	addiu $t1,$0,2		        # hard return 100 times to hide the number after a certain time 
	
	beq $s0, 0,AllowUserInput
	sub $s0, $s0,1	
	addi $s1, $s1,4
	j ArrayLoop 
		
AllowUserInput:
	la $a0, spacePrompt1          # print out a newline
        li $v0, 4
        syscall         
	addu $t1, $t1 ,-1
	addi $sp, $sp,-12
	sw $s0, 0($sp)			# array index 
	sw $s1, 4($sp)			# array address
	sw $ra, 8($sp)			# return address 
	la $ra, return			# if the user entered all 4 numbers get end it and tell them they one 
	add $a0, $s0,0			# ssend index
	add $a1, $s1,0			# send address
	beq $t1, 0,check	       	# when t1 equals 0 go back to return 
	lw $ra, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp,12	
	j AllowUserInput 	        # keep looping utill $t1 goes to 0			
return:	
	lw $ra,8($sp)			# stack didnt get restored so we do it here just incase 
	lw $s1,4($sp)
	lw $s0,0($sp)
	addi $sp,$sp,12	
	jr $ra 	
###############################################################################################

.data
CorrectPrompt:	.asciiz	"Correct! Get Ready Foer the next sequence!"
IncorrPrompt:	.asciiz	"Sorry,you were not fast enough!"

.text 
check:
	addiu $t7,$0,0			# used to mod user input 
	addiu $t2,$0,10			# used to mult t7 by ten
	addiu $v0,$0,5			# get user input 
	syscall 
	move $t5,$v0
Comp:	
	beq $t7,0,cantDiv		# get the first number out of the list
	div $t5,$t7
	mfhi $t4			# get mod from div op 	
afterDiv2:
	lw $t3,0($a1)			# put value of array element in t3
	bne $t4,$t3,Nope		# compare them if equal loop if not go to nope 
	beq $a0,0,jumpOut		# if index equals 0 get out of loop	
	mult $t7,$t2			# do this to mod by factor of 10 next time
	add $a0,$a0,-1			# sub one from index count
	addi $a1,$a1,-4	
	j Comp
jumpOut:
	la $a0,CorrectPrompt
	addiu $v0,$0,4
	syscall
	jr $ra		
cantDiv:	
	addi $t7,$t7,1			# add one to t7 so we can mult 10 to it next time 
	div  $v0,$t2 			# do a special div right here 
	mfhi $t4		        # get mod from div op
	j afterDiv2			
Nope:
	la $a0,IncorrPrompt
	addiu $v0,$0,4
	syscall	
	addiu $v0,$0,10
	syscall 
	
