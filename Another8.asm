 ## starting comments here
 .data

 stack_beg        :  .word 0:99 

 
 stack_end:  
     KeyIntpt         :  .word 0:99
    Pointer           :  .word 0
 ColorTable:  ## this should be modified to what panda suggested
                .word 0x000000		# black  0
		.word 0x0000ff		# blue   1
		.word 0x00ff00		# green  2
		.word 0xff0000		# red    3
		.word 0x00ffff		# blue + green = cyan  4
		.word 0xff00ff		# blue + red   = magenta  5
		.word 0xffff00		# green + red  = yellow   6
		.word 0xffffff		# white    7

CircleTable :     
		.byte  0, 8,  4  # top left box, yellow
		.byte -78,88, 6  # top right box, cyan
		.byte 78, 88, 3  # bottom left box, green
		.byte 0, 158 ,2  # bottom right box, red
						
 .word   0 : 40
 
SpacePrompt1  :       .asciiz " \n "
msg           :       .asciiz   "Keyboard polling in progress....."
Prompt2       :       .asciiz   "Now Enter the displayed Sequence: "
Prompt1       :       .asciiz   "Try to remember the Numbers Displayed:  " 
CorrectPrompt :	      .asciiz   "Correct! Get Ready For the next sequence: "
IncorrPrompt  :	      .asciiz   "Sorry,you were not accurate enough!"
LevelMsg      :       .asciiz   "\n You've Passed level : "
SequenceArray :       .word 0,0,0,0,0

  .text 
######################################################
   ## main part of the program
######################################################
      la $sp , stack_end 
MainLoop:
  
     #  initialize your variables   	
       addiu $a0,$0, 1			#  random number id
       addiu $a1,$0, 4			# initialize the maximum  
       addiu $s0,$0, 0			# initialize the loop counter
       addiu $s2,$0, 0			# initialize the array loop counter
     # Do your keyboard interrupts here
        lui $t0,0xFFFF		        # create an exception , a keyboard interrupt
	ori $a0,$0,2		        # enable keyboard interrupt
	sw  $a0,0($t0)		        # write back to 0xFFFF0000;
	la $t0, KeyIntpt	        # get address of que 
	la $t1,Pointer		        # $t1 points to pointer here
	addi $t2,$t0,0			# put the address in a register 
	sw $t2,0($t1)
	li  $t0,0                       # set these to 0
	li $t1,0		
	li $t2,0		 
loop: # prepare the stack to generate another random number
	addi $sp,$sp,-16		# create a space for 4 words in stack
	sw $s0,0($sp)			# stored here is the counter for the main loop 
	sw $a0,4($sp)			# stored here is the reference number of each random number gotten 
	sw $a1,8($sp)			# stored here is the maximum 
	sw $s2,12($sp)			# stored here is the array loop counter
		
initRand : # gets the random number and prepares to pass it into an array	 
	li $v0, 30                      # get system time
	syscall
	move $a1, $a0                   # $a0 has LSW of time
	addi,$a0,$a0,1
			                # set the seed as th[e LSW of time
	li $v0, 40			# syscall for set seed
	syscall	
	addi,$a0,$a0,1			
	jal GenerateRand                # go get a random Number
	                	      	
	sw $s2, 12($sp)	                # when you come back,
	sw $a1, 8($sp)
	sw $a0, 4($sp)
	sw $s0, 0($sp)		
	addi $sp,$sp,16			 # restore the stack frame
		
	addi $sp,$sp,-16		 # create a space to store all the adresses prone to be modified  
	sw $s0, 0($sp)			 # stored here is the main loop counter 
	sw $a0, 4($sp)			 # stored here is the reference number of each random number gotten 
	sw $a1, 8($sp)			 # stored here is the maximum 
	sw $s2, 12($sp)			 # stored here is the array loop counter 
	addiu $a1, $s2,0	         # put total count for array index in al
	jal SetTheArray	                 # set up an array to store the random numbers to compare with user's entries
	lw $s2, 12($sp)	                 # restore all the addresses on returning back  
	lw $a1, 8($sp)
	lw $a0, 4($sp)
	lw $s0, 0($sp)		
	addi $sp, $sp,16	         # restore the stack to its initial position
	addi $s0, $s0,1		         # increment the main loop counter  // this doesn;
	addi $t8,$t8,0                   # initial level number
	addi $t9,$t9,1                   # to check out for number of  correct sequences entered
	addi $s2, $s2,1		         # increase array index
	beq $t9,5,LevelAlert             # if user has entered 5 consecutive sequences
	beq  $s0,4,done
	addi $s0,$s0,1		         # increment overall loop counter
	addi $s2,$s2,1		         # increment array inde
	j loop                           # continue to do this while the user entered the right sequnce 				
done: 
	li $v0,10                        # Exit
	syscall
####################################################################################	
    ## native functions
####################################################################################
GenerateRand:#  generate a random number      
        li $a1, 4        		
	addiu $v0,$0,42			 # syscall to generate random number 
	add $a0, $a0, 1
	syscall		
	jr $ra	
Pause:   
	move $t0, $a0			# save the time out in a temp
	li $v0, 30			# get initial time which is now in $a0 and $a1 
	syscall
	add $t1,$a0,$0			# copy $a0 to $t0
  Ploop:
	syscall 
	subu $t2,$a0,$t1		# current time will be in $a0 $t1 suptracts that number from initial time  
	bltu $t2,$t0,Ploop		# loop iwhole timeout lapses  	
	jr $ra 
###########################################################################################################################
# SetTheArray  -- Program gets each generated random number,put it into a initial array the size of the gen numbers,and 
#                 prints them out in a sequence
# $a0	=  id of generator 
# $a1   =  seed for the generator 
# $a2   =  value of number that was printed 
SetTheArray: 
      ### Draw the horizontal line first 
	addi $sp,$sp,-20                # make room to store the following 5 registers to stack
        sw $ra,0($sp)
	sw $a0,4($sp)
	sw $a1,8($sp)
	sw $a2,12($sp)
	sw $a3,16($sp)     
        li $a0, 30                       
        li $a1, 220
        li $a2, 7
        li $a3, 190
        jal DrawDiagonUp                # Draw this line -    # 
        lw $a3,16($sp)                  #                    #    Restore the rsegisters you used
	lw $a2,12($sp)                                       #
	lw $a1,8($sp)                                      #
	lw $a0,4($sp)			                 #
	lw $ra,0($sp)
	addi $sp,$sp,20                # restore the space on the stack
	addi $sp,$sp,-20               # make room to store the following 5 registers to stack
	sw $ra,0($sp)
	sw $a0,4($sp)
	sw $a1,8($sp)
	sw $a2,12($sp)
	sw $a3,16($sp)
        li $a0, 220                     # Draw this line - # 
        li $a1, 220                                          #
        li $a2, 7                                             #
        li $a3, 190                                              #
        jal DrawDiagonDwn                                         #
    	lw $a3,16($sp)                 #  Restore the rsegisters you used
	lw $a2,12($sp)
	lw $a1,8($sp)
	lw $a0,4($sp)			 
	lw $ra,0($sp)
	addi $sp,$sp,20                # restore the space on the stack
	addi $a0,$a0,1                              		    			    		
	la $t0, SequenceArray	       # load the array to store the random numbers
	add $s0,$a1,0		       # move $a1 to $s0 to be the array address
	add $s3,$a1,0			# do this to hopefully fix my one loop error 
	sll $a1, $a1, 2		       # then multiply  $a1 by 4
	add $s1,$a1,$t0		       # this will be the address of the array element
	sw $a0,0($s1)		       # store the random number at the new address for the array
	sub $s1,$s1,$a1		       # subtract that number 		
	addi $sp,$sp,-4
	sw  $s3,0($sp)
###########################################################################################################################
# ArrayLoop  -- store each random number to be used as sequence to be printed and used for the displaying of box sequence
# inputs....... 
# $a0	=  random number 
# $s1   =  seed for the generator
# Outputs....... 
# $s0   =  array						
ArrayLoop:
        lw $a0,0($s1)                   # load the value of the rand numb into the this pseudo stack
	addiu $v0,$0,1                  
	syscall  
	sw $a0,0($s1)                   # store back into the pseudo stack 
	lw $a0,0($s1)                   # load the value of the rand numb into the this pseudo stack
	
	addi $sp, $sp,-12               # prepare to save the following 3 registers
	sw $s1,0($sp)			# seed generator  address
	sw $ra,4($sp)			# return address
	sw $s0,8($sp)		        # array index
	jal ChooseCircle                # choose which circle you draw			      
	lw $s0,8($sp)                   # restore your registers
	lw $ra,4($sp)
	lw $s1,0($sp)		
	addi $sp,$sp,12 		# restore the stack frame
	
	addi $sp,$sp,-12		# create a space for 4 words  
	sw $s1,0($sp)			# save the new pseudo stack/address of the array
	sw $ra,4($sp)			# save the return address
	sw $s0,8($sp)                   # save the index of the array for the rabdom number printed to the console
	addi $t0,$s1,0                  # copy from $s1
	lw $a0,($t0)                    # then load into $a0
	jal PandaDigit                  # go here to print the corresponding digit of the circle
	add $t0,$0,0			# re-initialize to 0
	lw $s0,8($sp)                   # restore your registers
	lw $ra,4($sp)                   # this,
	lw $s1,0($sp)                   # and this
	addi $sp,$sp,12                 #  then restore the stack
	
	addi $sp,$sp,-12		# create a space for 4 words  
	sw $s1,0($sp)			# save the new pseudo stack/address of the array
	sw $ra,4($sp)			# save the return address
	sw $s0,8($sp)                   # save the index of the array for the rabdom number printed to the console																		
	addiu $a0,$0,1000               # wait for 1ms
	jal Pause                       # let the user see the number for only a certain amount of time
	lw $s0,8($sp)                   # restoration!
	lw $ra,4($sp)
	lw $s1,0($sp)		
	addi $sp,$sp,12                 # restore the stack frame
	
	#################################################### this is where I made it a sequence-ish
        lw $t0,0($s1)
	addi $a0,$t0,0			# get the appropirate registers for the box displayed
	sw $t0,0($s1)	                # in order to pass it into ClearDisp
        addi $sp,$sp,-12		# create a space for 4 words, before going to clear display 
	sw $s0,0($sp)			# store the index of the array
	sw $s1,4($sp)			# store the address of the array
	sw $ra,8($sp)			# also store your return address,you may not need to do this
        jal ClearDisp	       		# when you show the boxes in the sequence,then hide them from the user 	
	lw $ra,8($sp)			# well,restore all the registers you saved
	lw $s1,4($sp)                   # restore this
	lw $s0,0($sp)                   # and this
	addi $sp,$sp,12                 # restore the stack frame
	addi $sp,$sp,-12		# prepare to jump to another procedure,so save a bunch of registers  
	sw $s0,0($sp)			# store the index of the array
	sw $ra,4($sp)			# also store your return address,you may not need to do this
	sw $s1,8($sp)			# store the address of the array
	addiu $a0,$0,1000               # wait again for 1ms
	jal Pause			# allow the user to see the  box sequence for 3 ms
	lw $s1,8($sp)                   # restore again
	lw $ra,4($sp)                   # restore this too
	lw $s0,0($sp)		        # and this also
	addi $sp,$sp,12 		# give memory back to the stack
        
      #####################################   this is the end of the sequence-ish 			                 		                 		                 		                # restore the spaces used in the stack	        
	beq $s0, 0, AllowUserInput      # if the index starts at 0,then allow for user's entry i.e. user is ready to play
	addi $s0, $s0,-1	        # continue to decrement the index	
	addi $s1, $s1,4                 # and increase the new location for storing the next gen numb in the pseudo stack
	j ArrayLoop                     # generate n number of random numbers for the present sequence	
AllowUserInput: #  Allow the user to input the sequence.$a0 = 	
	lw $s3,0($sp)                   # loop error fixed
	addi $sp,$sp,4 
	addi $sp,$sp,-12
	sw $s0,0($sp)			# array index 
	sw $s1,4($sp)			# array address
	sw $ra,8($sp)			# return address 
	add $a0,$s3,0			# send index
	add $a1,$s1,0			# send address
	la $a2,KeyIntpt		        # load the keynput address
	jal checkSequence	        # when t1 equals 0 go back to return	
	lw $ra, 8($sp)                  # restore all the addresses
	lw $s1, 4($sp)                  
	lw $s0, 0($sp)
	addi $sp, $sp,12                # and restore the space in the stack/the stack frame
	
	# clear que information 
	la  $t1,KeyIntpt		# get address of que 
	la  $t3,Pointer		        # get address of que pointer 
	addi $t2,$t0,0			# put the address in a register 
	sw  $t2,0($t3)
	li  $t1,0
	li  $t1,0
	li $t3,0	
	jr $ra
	
###############################################################################################
# checkSequence  -- checks if any sequence has been entered and to see if it tallies with the contents 
#                -- of the SequenceArray
# inputs 
# a0 = array index 
# a1 = array address 
checkSequence:   # compare if the numbers entered by the user are correct
	sll 	$a0,$a0,2
	sub 	$a1,$a1,$a0
	srl 	$a0,$a0,2	
CheckLoop:	
	li $t1,1000000		        # wait about thi long for user's entry and after elapsed time,just print the 	                                # answer and exit..user has lost
  
  StartPolling: # start polling the keyboard for user's input	
	lw   $t5,0($a2)			# first, get first element in KeyInput 
	addi $t3,$0,0			# then initialize $t1 to 0
	bne $t5,0,Sentinel		# Sentinel to look out if there is an input 
	beq $t1,0,Sentinel              # or when the count goes to 0 
	add $t1,$t1,-1			# decrement t0 
	j StartPolling	
		
  Sentinel:  # $a1 = one of the random numbers,$t4 = modulus of total user entry
        addi $t5,$t5,-48		
	lw $t4, 0($a1)			# put value of array element in t3
	bne $t5,$t4, Nope		# if incorrect, display message and the sequence to the user
	beq $a0,0, Correct       	# if index equals 0 , we assume that all the numbers entered were the correct sequence	
	add $a0,$a0,-1			# sub one from index count
	addi $a1,$a1,-4	                # point to the next element in the array
	sw $t3,0($a2)	                # de que 
	j CheckLoop            	
####################################################
LevelAlert :
           addi $t8,$t8,1                # add 1 for each 5 entry entered
           addiu $sp, $sp,-4             
           sw $a0, 0($sp)
           la $a0, LevelMsg              # Tell user he has reached level  x
           li $v0, 4
           syscall
           la $a0, ($t8)                 # load the level number
           li $v0, 1	
           syscall			 # print the level number
           lw $a0, 0($sp)                # restore a0
           addiu $sp,$sp,4	         # restore stack
           jr $ra         
 Nope :    li $t7, 0		        # this will be our blink counter                 			
 Burst:
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
	add	$t1,$s1,0			# copy address to a temp reg
	lw 	$a0,0($t1)
	jal 	PandaDigit		        # let the user see the number for only a certain amount of time
	add 	$t1,$0,0			# get address out of there 
	lw 	$t7,12($sp)
	lw 	$s0,8($sp)
	lw	$ra,4($sp)
	lw 	$s1,0($sp)		
	addi 	$sp,$sp,16 			# give memory back to the stack	
	lw 	$t1,0($s1)
	addi 	$a0,$t1,0			# need to pass array index without overiding 
	sw 	$t1,0($s1)
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
	beq	$t7,5,Incorrect			# jump at if our counter equals 5 
	add	$t7,$t7,1			# increment the counter 
	j 	Burst 	
	
Incorrect: # Play a burst of tones depending on the counter $t7	
         la $a0,IncorrPrompt
	 addiu $v0,$0,4
	 syscall
	 addiu 	$v0,$0,10
	 syscall 	
Correct:  # print a message to the user indicating they have entered the right sequence
	la $a0,CorrectPrompt
	addiu $v0,$0,4
	syscall
	jr $ra
	
###############################################################################################		
# ChooseCircle  -- ChooseBox modified to Draw based on the random Number generated
# $a0 = random number 
 ChooseCircle : 
       ### what panda suggested worked!
       la $t0, CircleTable              # load the address of  yout CircleTable
       subu $a0,$a0,1
       mul $a0,$a0, 3                   # $a0 = 3 x $a0
       addu $t0,$a0,$t0                 # $t0 = $a0 + $t0
       lb $a0,0($t0)			# load the x coordinate
       lb $a1,1($t0) 			# load the y coordinate
       lb $a2,2($t0)			# load the color  
       addiu $a3,$0, 15                 # hardcode the length of the box
       addi $sp,$sp,-4			# only need to save ra because a values are stored in other places 
       sw $ra,0($sp)
       jal DrawCircle                   # Drwaw a circle based on the random number
       lw $ra,0($sp)                    # after jumping,restore the $ra 
       addi $sp,$sp,4                   # and the stack frame
       add  $a0,$a2,50		        # make some noise add both x and y offset to get different tones
       addi $a1,$0,1000		        # duration of noise 
       addi $a2,$0,1			# instroment 
       addi $a3,$0,1000			# volume 
       li $v0,31
       syscall 	
       jr $ra		                # go back to arraayloop
########################### ClearDisp #################################################
 # ClearDisp ---Clear the corresponding box drawn by ChooseBox procedure
 # $a0 = x coordinate (0 - 31)
ClearDisp :       
    ### use the same method here 
        la $t0, CircleTable             # load the address of  yout CircleTable
	subu $a0,$a0,1
	mul $a0,$a0, 3                  # $a0 = 3 x $a0
        addu $t0,$a0,$t0                # $t1 = $a0 + $t1
	lb $a0,0($t0)			# load the x coordinate
        lb $a1,1($t0) 			# load the y coordinate
        addi $a2, $0, 0			# Hardcoded color = black  
        addiu $a3,$0, 15                # hardcode the radius of the circle
        addi $sp,$sp,-4			# only need to save ra because a values are stored in other places 
        sw $ra,0($sp)
        jal DrawCircle                  # Drwaw a box based on the random number
        lw $ra,0($sp)                   # after jumping,restore the $ra 
        addi $sp,$sp,4                  # and the stack frame
        jr $ra		
####################################################################################	
    ## P2
####################################################################################  
############################## CalcAddress ###########################################
#  $a0 = x coord
#  $a1 = y coord
#  $v0 = result which is  memory address where the coordinates are  
CalcAddress : 
        sll  $a0,$a0, 2 	          # $a0 = 4(x)      ---i.e  4
	sll  $a1,$a1,10			  # $a1 = 128(y)    ---i.e 32 x 4
	add  $v0,$0, 0x10040000		  # set v0 to the base address for bitmap display
	add  $v0,$v0,$a0		  # add the x coord 
	add  $v0,$v0,$a1		  # add the y coord 
     jr $ra 
############################## GetColor ###########################################
#  $a2 = color number (0 - 7) 
# returns $v1 = actual number to write to the display
GetColor : 
         la $t0,ColorTable                # load the address of the ColorTable
         sll  $a2, $a2, 2                 # index is offset from the DrawDot procedure,rectify by mul by 4
         addu $a2,$a2, $t0                # base + the offset
         lw $v1,0 ($a2)                   # loads the actual value of the color word
      jr $ra    
 ########################### DrawDot #################################################
 # $a0 = x coordinate (0 - 31)
 # #a1 = y coordiante (0 - 31)
 # $a2 = colornumber (0 - 7)
 DrawDot :
           addiu $sp, $sp, -8             #create a space for two words
           sw    $ra, 4($sp)              # store the return address
           sw    $a2, 0($sp)              # and store the color number
           jal  CalcAddress                # get the address for x and y coordinates
           lw  $a2,  ($sp)                # empty this space int the stack
           sw  $v0,  ($sp)                # and use it to store the value at $v0
           jal GetColor                   # then get the color word 
           lw  $v0 ,($sp)                 # and store it in the stack so v0 can be used
           sw  $v1, ($v0)                 # ok make a dot
           lw  $ra, 4($sp)                # restore the return add
           addiu $sp,$sp,8                # and also the stack
        jr $ra
########################### DrawDiagonUp #################################################
 # $a0 = x coordinate (0 - 31)
 # #a1 = y coordiante (0 - 31)
 # $a2 = color number (0 - 7)
 # $a3 = length of the line (1-32)
DrawDiagonUp :
       # create stack frame/save $ra
         addiu $sp, $sp -4
         sw   $ra, 0($sp) 
DiagonUpLoop :
    addiu $sp, $sp -16                   ## set up stack stuff esp for $a0 reg
    sw $a0, 0($sp)                       # store x coord 
    sw $a1, 4($sp)                       # store y coord 
    sw $a2, 8($sp)                       # store color number
    sw $a3, 12($sp)                      # store  length of the line  or max count for drawing a dot
    jal DrawDot
    lw $a3, 12($sp)                      # restore length
    lw $a2, 8($sp)                       # restore color number reg 
    lw $a1, 4($sp)                       # restore y reg
    lw $a0, 0($sp)                       # restore x reg
    addiu $sp, $sp 16   
    add $a0,$a0,1	                 # increment x coord
    add $a1,$a1,-1	                 # decrease y coord
    addiu $a3,$a3,-1                     # make sure that the dot doesn't exceed the length
    bne  $a3,$0, DiagonUpLoop            # continue to drawthe dot as long not 0
    lw $ra, 0($sp)                       # restore your $ra from stack
    addiu $sp,$sp,4                      # restore the stack
    jr $ra
    
 ########################### DrawDiagonDwn #################################################
 # $a0 = x coordinate (0 - 31)
 # #a1 = y coordiante (0 - 31)
 # $a2 = color number (0 - 7)
 # $a3 = length of the line (1-32)
DrawDiagonDwn :
       # create stack frame/save $ra
         addiu $sp, $sp -4
         sw   $ra, 0($sp) 
DiagonDwnLoop :
    addiu $sp, $sp -16                   ## set up stack stuff esp for $a0 reg
    sw $a0, 0($sp)                       # store x coord 
    sw $a1, 4($sp)                       # store y coord 
    sw $a2, 8($sp)                       # store color number
    sw $a3, 12($sp)                      # store  length of the line  or max count for drawing a dot
    jal DrawDot
    lw $a3, 12($sp)                      # restore length
    lw $a2, 8($sp)                       # restore color number reg 
    lw $a1, 4($sp)                       # restore y reg
    lw $a0, 0($sp)                       # restore x reg
    addiu $sp, $sp 16   
    add $a0, $a0,-1	                 # decrease  x coord
    add $a1, $a1,-1	                 # increment y coord
    addiu $a3,$a3,-1                     # make sure that the dot doesn't exceed the length
    bne  $a3,$0, DiagonDwnLoop           # continue to drawthe dot as long not 0
    lw $ra, 0($sp)                       # restore your $ra from stack
    addiu $sp,$sp,4                      # restore the stack
    jr $ra
########################### HorzLine #################################################
 # $a0 = x coordinate (0 - 31)
 # #a1 = y coordiante (0 - 31)
 # $a2 = color number (0 - 7)
 # $a3 = length of the line (1-32)
HorzLine :
       # create stack frame/save $ra
         addiu $sp, $sp -4
         sw   $ra, 0($sp) 
HorzLoop :
    addiu $sp, $sp -16                   ## set up stack stuff esp for $a0 reg
    sw $a0, 0($sp)                       # store x coord 
    sw $a1, 4($sp)                       # store y coord 
    sw $a2, 8($sp)                       # store color number
    sw $a3, 12($sp)                      # store  length of the line  or max count for drawing a dot
    jal DrawDot
    lw $a3, 12($sp)                      # restore length
    lw $a2, 8($sp)                       # restore color number reg 
    lw $a1, 4($sp)                       # restore y reg
    lw $a0, 0($sp)                       # restore x reg
    addiu $sp, $sp 16   
    add $a0,$a0,1	                 # increment x coord
    addiu $a3,$a3,-1                     # make sure that the dot doesn't exceed the length
    bne  $a3,$0, HorzLoop                # continue to drawthe dot as long not 0
    lw $ra, 0($sp)                       # restore your $ra from stack
    addiu $sp,$sp,4                      # restore the stack
    jr $ra
    
########################### VertLine #################################################
 # $a0 = x coordinate (0 - 31)
 # #a1 = y coordiante (0 - 31)
 # $a2 = color number (0 - 7)
 # $a3 = length of the line (1-32)
VertLine :
       # create stack frame/save $ra
    addiu $sp, $sp -4
    sw   $ra, 0($sp) 
VertLoop :
    addiu $sp, $sp -16                   ## set up stack stuff esp for $a0 reg
    sw $a0, 0($sp)                       # store x coord 
    sw $a1, 4($sp)                       # store y coord 
    sw $a2, 8($sp)                       # store color number
    sw $a3, 12($sp)                      # store  length of the line  or max count for drawing a dot
    jal DrawDot
    lw $a3, 12($sp)                      # restore length
    lw $a2, 8($sp)                       # restore color number reg 
    lw $a1, 4($sp)                       # restore y reg
    lw $a0, 0($sp)                       # restore x reg
    addiu $sp, $sp 16   
    add $a1,$a1,1	                 # increment y coord
    addiu $a3,$a3,-1                     # make sure that the dot doesn't exceed the length
    bne  $a3,$0, VertLoop                # continue to drawthe dot as long not 0
    lw $ra, 0($sp)                       # restore your $ra from stack
    addiu $sp,$sp,4                      # restore the stack
    jr $ra
 ########################### DrawCircle #################################################
 # $a0 = x coordinate (0 - 31)
 # #a1 = y coordiante (0 - 31)
 # $a2 = color number (0 - 7)
 # $a3 = length of the line (1-32)
  
   #  put CircleTable Data here so program is neat
.data
# make a table of sine
CircleTable2:
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
	addi $s4,$a0,0		       	# put x coordinate in $a0 
	addi $s5, $a1,0			# put y coordinate in $a1
	addi $s6, $a2,0			# put color in $a2 	
	addi $s2,$0,  0	
FirstHalf:	
	la $s0,CircleTable2		# put the address of the tbale in a register 
	add $s1,$s2,$0
	mul $s1,$s2, 12
	add $s0,$s0,$s1	
	lw $a0,0($s0)			# x 
	lw $a1,4($s0)			# y
	add $a0,$a0,$s4			# add the x offset 
	add $a1,$a1,$s5			# add the y offset 
	add $a2,$0,$s6			# look up color  
	lw $a3,8($s0)			# length	
	addi $sp,$sp,-28
	sw $s0,0($sp)
	sw $s1,4($sp)
	sw $s2,8($sp)
	sw $s4,12($sp)
	sw $s5,16($sp)
	sw $s6,20($sp)
	sw $ra,24($sp)
	jal VertLine 
	lw $ra,24($sp)
	lw $s6,20($sp)
	lw $s5,16($sp)
	lw $s4,12($sp)
	lw $s2,8($sp)
	lw $s1,4($sp)
	lw $s0,0($sp)
	addi $sp,$sp,28
	addi $s2,$s2,1			# add one to the loop count 
	beq $s2,21,ReInitialize		# after first half of circle is drawn,reinitialize registers 
	j FirstHalf 
	
ReInitialize:   # reinitialization of registers
	addi $s2,$0,0
	addi $s3,$0,0			
SecondHalf:
	la $s0,CircleTable2		# put the address of the tbale in a register 
	add $s1,$s2,$0
	mul $s1,$s2,12
	add $s0,$s0,$s1
	lw $a0,0($s0)			# x coordinate
	add $a0, $a0, $s3		# move the value over to its secound half position 
	lw $a1,4($s0)			# y coordinate
	add $a0,$a0,$s4			# add x offset 
	add $a1,$a1,$s5			# add y offset 
	add $a2,$0,$s6			# look up color 
	lw $a3,8($s0)			# length
	addi $sp,$sp,-32
	sw $s0,0($sp)
	sw $s1,4($sp)
	sw $s2,8($sp)
	sw $s3,12($sp)
	sw $s4,16($sp)
	sw $s5,20($sp)
	sw $s6,24($sp)
	sw $ra,28($sp)
	jal VertLine 
	lw $ra,28($sp)
	lw $s6,24($sp)
	lw $s5,20($sp)
	lw $s4,16($sp)
	lw $s3,12($sp)
	lw $s2,8($sp)
	lw $s1,4($sp)
	lw $s0,0($sp)
	addi $sp,$sp,32
	addi $s3,$s3,2			# add 2 every time 
	addi $s2,$s2,1			# add one to the loop count 
	beq $s2,21,CircleDone		# if $s2 = 21, exit loop 
	j SecondHalf 	                #  else, continue drawing
CircleDone:
	jr $ra 

############################################  KEYBOARD INTERRUPT HANDLER   #################################
##     interrupts the program when a person hits a key  in the keyboard interface                                                                     #
##     a0 = number you want displayed                                                                      #
############################################################################################################ 

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
############################################################################################
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
	la	$t0,Pointer
	lw 	$t1,0($t0)		# put value from que pointer in t1
	sw      $v0,0($t1)		# save to que
	addi    $t1,$t1,4		# increment que address 
	sw 	$t1,0($t0)		# update que pointer 
	lw 	$ra,0($sp)
	addi 	$sp,$sp,4 
	
	jr 	$ra
################################################################################################################
	



###########################################  PANDA CODEX   ##################################################
#     to display the digits in pixels                                                                       #
#    a0 = number you want displayed                                                                         #
#############################################################################################################  
        .data
        .word   0 : 40
Stack:

Colors: .word   0x000000        # background color (black)
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
digit1:  .asciiz "1"
digit2: .asciiz "2"
digit3: .asciiz "3"
digit4: .asciiz "4"

        .text
PandaDigit :       
        la      $sp, Stack

    #    li      $a0, 1          # some test cases
    #    li      $a1, 2
    #    la      $a2, Test1
    #    jal     OutText

        addi $sp,$sp,-4                   # space on stack frame to store a word
 	sw $ra,0($sp)                     # store the return address to go back to ArrayLoop
   # branches to compare the random numbers and assign them to the coressponding digits
        beq $a0, 1, One
        beq $a0, 2, Two
        beq $a0, 3, Three
        beq $a0, 4, Four
        
        j badInput 
               
One:  # prints out a '1'
        li      $a0, 123        
        li      $a1, 45
        la      $a2, digit1
        jal     OutText      
        j badInput
        
Two: # prints out a '2'

        li      $a0, 45
        li      $a1, 122
        la      $a2, digit2
        jal     OutText    
	j badInput
	
Three: # prints out a '3'

        li      $a0, 200
        li      $a1, 125
        la      $a2, digit3
        jal     OutText       
	j badInput
	
Four: # prints out a '4'
	
	li      $a0, 123
        li      $a1, 194
        la      $a2, digit4
        jal     OutText      
        j badInput

badInput:
      lw $ra,0($sp)
      addi $sp,$sp,4    
      jr $ra



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
