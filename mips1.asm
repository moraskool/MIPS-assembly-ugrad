 .data
 stack_beg        :  .word 0:99
 
 stack_end: 
 
 ColorTable:  ## this should be modified to what panda suggested
                .word 0x000000		# black  0
		.word 0x0000ff		# blue   1
		.word 0x00ff00		# green  2
		.word 0xff0000		# red    3
		.word 0x00ffff		# blue + green = cyan  4
		.word 0xff00ff		# blue + red   = magenta  5
		.word 0xffff00		# green + red  = yellow   6
		.word 0xffffff		# white    7

BoxTable :     
		.byte 0, 0, 7  # top left box, yellow
		.byte 0, 0, 4  # top right box, cyan
		.byte 0, 0, 2  # bottom left box, green
		.byte 0, 0, 3  # bottom right box, red						
 .word   0 : 40
 
spacePrompt1  :       .asciiz " \n "
Prompt2       :       .asciiz   "Now Enter the displayed Sequence: "
Prompt1       :       .asciiz  "Try to remember the Numbers Displayed:  " 
CorrectPrompt :	      .asciiz "Correct! Get Ready For the next sequence: "
IncorrPrompt  :	      .asciiz "Sorry,you were not accurate enough!"
SequenceArray :       .word 0,0,0,0,0
  .text 
    
####################################################################################	
    ## main part of the program
####################################################################################    
 MainLoop:
        la $a0, Prompt1                 # print start prompt to user
        li $v0, 4
        syscall 
 #  initialize your variables   	
	addiu $a0,$0, 1			# first random number 
	addiu $a1,$0, 4			# initialize the maximum  
	addiu $s0,$0, 0			# initialize the loop counter
	addiu $s2,$0, 0			# initialize the array loop counter 
			
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
	addi $s0, $s0,1		         # increment the main loop counter
	addi $s2, $s2,1		         # increase array index
	j loop                           # continue to do this while the user entered the right sequnce  					
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
	jal ChooseBox                   # choose which box you draw			      
	lw $s0,8($sp)                   # restore your registers
	lw $ra,4($sp)
	lw $s1,0($sp)		
	addi $sp,$sp,12 		# restore the stack frame
	addi $sp,$sp,-12		# create a space for 4 words  
	sw $s1,0($sp)			# save the new pseudo stack/address of the array
	sw $ra,4($sp)			# save the return address
	sw $s0,8($sp)                   # save the index of the array for the rabdom number printed to the console			
	addiu $a0,$0,1000               # wait for 1ms
	jal Pause                       # let the user see the number for only a certain amount of time
	lw $s0,8($sp)                  
	lw $ra,4($sp)
	lw $s1,0($sp)		
	addi $sp,$sp,12                 # restore the stack frame
	
#################################################### this is where I made it a sequence-ish
	addi $a0,$t1,0			# get the appropirate registers for the box displayed	
#####################################   this is the end of the sequence-ish
	addiu $t1,$0,2		        # a hard return 100 times to hide the number after a certain time 			                 		                 		                 		                # restore the spaces used in the stack	        
	bne  $s0, 0, End                # if the index starts at 0,then allow for user's entry i.e. user is ready to play
	j ArrayLoop                     # generate n number of random numbers for the present sequence
		
End : li $v0,10
      syscall
###############################################################################################		
# ChooseBox  -- Determines which Box to Draw based on the random Number generated
# $a0 = random number
  
 ChooseBox : 
       ### what panda suggested worked!
       la $t1, BoxTable                 # load the address of  yout BoxTable
       subu $a0,$a0,1
       mul $a0,$a0, 3                   # $a0 = 3 x $a0
       addu $t1,$a0,$t1                 # $t1 = $a0 + $t1
       lb $a0,0($t1)			# load the x coordinate
       lb $a1,1($t1) 			# load the y coordinate
       lb $a2,2($t1)			# load the color  
       addiu $a3,$0, 256                # hardcode the length of the box
       addi $sp,$sp,-4			# only need to save ra because a values are stored in other places 
       sw $ra,0($sp)
       jal DrawBox                      # Drwaw a box based on the random number
       lw $ra,0($sp)                    # after jumping,restore the $ra 
       addi $sp,$sp,4                   # and the stack frame
       jr $ra		                # go back to arraayloop

########################### ClearDisp #################################################
 # ClearDisp ---Clear the corresponding box drawn by ChooseBox procedure
 # $a0 = x coordinate (0 - 31)
ClearDisp :   
       
    ### use the same method here 
    ### what panda suggested worked!
       la $t1, BoxTable                 # load the address of  yout BoxTable
       subu $a0,$a0,1
       mul $a0,$a0, 3                   # $a0 = 3 x $a0
       addu $t1,$a0,$t1                 # $t1 = $a0 + $t1
       lb $a0,0($t1)			# load the x coordinate
       lb $a1,1($t1) 			# load the y coordinate
       addi $a2, $0, 0			# Hardcoded color = black  
       addiu $a3,$0, 10                 # hardcode the length of the box
       addi $sp,$sp,-4			# only need to save ra because a values are stored in other places 
       sw $ra,0($sp)
       jal DrawBox                      # Drwaw a box based on the random number
       lw $ra,0($sp)                    # after jumping,restore the $ra 
       addi $sp,$sp,4                   # and the stack frame
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
	sll  $a1,$a1,7			  # $a1 = 128(y)    ---i.e 32 x 4
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
 
 ########################### DrawBox #################################################
 # $a0 = x coordinate (0 - 31)
 # #a1 = y coordiante (0 - 31)
 # $a2 = color number (0 - 7)
 # $a3 = length of the line (1-32)
DrawBox : 
    # create stack frame/save $ra
    addiu $sp, $sp -8
    sw    $ra, 0($sp)
    sw    $s0, 4($sp)
    move $s0, $a3 
 BoxLoop : 
   addiu $sp, $sp -16                     ## set up stack stuff esp for $a0 reg
   sw $a0, 0($sp)                         # store x coord 
   sw $a1, 4($sp)                         # store y coord 
   sw $a2, 8($sp)                         # store color number
   sw $a3, 12($sp)                        # store  length of the line  or max count for drawing a dot
   jal HorzLine
   lw $a3, 12($sp)                        # restore length
   lw $a2, 8($sp)                         # restore color number reg 
   lw $a1, 4($sp)                         # restore y reg
   lw $a0, 0($sp)                         # restore x reg
   addiu $sp, $sp 16   
   addiu, $a1,$a1,1
   addiu,$s0,$s0,-1                       # decrement counter
   bne  $s0,$0,BoxLoop                    # continue as long as not 0
   lw $s0, 4($sp)                         # restore your $s0 from stack
   lw $ra, 0($sp)                         # restore your $ra from stack   
   addiu $sp,$sp,8                        # restore the stack
    jr $ra                                # go home
 
 
 

