 .data
 stack_beg        :  .word 0:99
 
 stack_end: 
 
 ColorTable:  ## this should be modified to what panda suggested
                .word 0x000000		# black  0
		.word 0x0000ff		# blue   1
		.word 0x00ff00		# green  2
		.word 0xfff0f0		# red    3
		.word 0x00ffff		# blue + green = cyan  4
		.word 0xff00ff		# blue + red   = magenta  5
		.word 0xffff00		# green + red  = yellow   6
		.word 0xffffff		# white    7

FrameTable :     
		.byte 9, 10, 4          # top left box, yellow
		.byte 89, 89, 4         # top right box, cyan
		.byte 89, 89, 2         # bottom left box, green
		.byte 0, 0, 3           # bottom right box, red	
BoxTable :     
		.byte 200, 100, 7       # top left box, yellow
		.byte 89, 89, 4         # top right box, cyan
		.byte 89, 89, 2         # bottom left box, green
		.byte 0, 0, 3           # bottom right box, red						
 .word   0 : 40
 
spacePrompt1  :       .asciiz " \n "
Prompt2       :       .asciiz   "Now Enter the displayed Sequence: "
Prompt1       :       .asciiz   "Try to remember the Numbers Displayed:  " 
CorrectPrompt :	      .asciiz   "Correct! Get Ready For the next sequence: "
IncorrPrompt  :	      .asciiz   "Sorry,you were not accurate enough!"
SequenceArray :       .word 0,0,0,0,0
  .text 
    
####################################################################################	
    ## main part of the program
####################################################################################    
 MainLoop:
      
      la  $t4, 	FrameTable
      mul $a0, $a0, 4                     # $a0 = 4 x $a0
     addu $t4, $a0, $t4                   # $t1 = $a0 + $t1
      lb  $a0 , 0($t4)
      lb  $a1 , 1($t4)
      lb  $a2 , 2($t4)
      li  $a3 , 240
      jal DrawFrame
      
     
        

     
     
  
     
     
       la  $t5, 	BoxTable
      mul $a0,$a0, 4                   # $a0 = 3 x $a0
      addu $t5,$a0,$t5                 # $t1 = $a0 + $t1
      lb  $a0 , 0($t5)
      lb  $a1 , 1($t5)
      lb  $a2 , 2($t5)
      li  $a3 , 40
      jal DrawBox

      li  $a0,2
      jal PandaDigit
      li  $a0,3
      jal PandaDigit
      li  $a0,1
      jal PandaDigit
      

      li $v0,10
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
       addiu $a3,$0, 20                # hardcode the length of the box
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
           jal  CalcAddress               # get the address for x and y coordinates
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
DrawRect : 
    # create stack frame/save $ra
    addiu $sp, $sp -8
    sw    $ra, 0($sp)
    sw    $s0, 4($sp)
    move $s0, $a3 
 RectLoop : 
   addiu $sp, $sp -16                     ## set up stack stuff esp for $a0 reg
   sw $a0, 0($sp)                         # store x coord 
   sw $a1, 4($sp)                         # store y coord 
   sw $a2, 8($sp)                         # store color number
   sw $a3, 12($sp)                        # store  length of the line  or max count for drawing a dot
   jal DrawDot
   lw $a3, 12($sp)                        # restore length
   lw $a2, 8($sp)                         # restore color number reg 
   lw $a1, 4($sp)                         # restore y reg
   lw $a0, 0($sp)                         # restore x reg
   addiu $sp, $sp 16 
   addi, $a0,$a0,1
   addi, $a1,$a1,1 
   addiu,$s0,$s0,-1                       # decrement counter
   bne  $s0,$0,RectLoop                   # continue as long as not 0
   lw $s0, 4($sp)                         # restore your $s0 from stack
   lw $ra, 0($sp)                         # restore your $ra from stack   
   addiu $sp,$sp,8                        # restore the stack
    jr $ra                                # go home
    
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
 
 
 
 ########################### DrawFrame #################################################
 # $a0 = x coordinate (0 - 31)
 # #a1 = y coordiante (0 - 31)
 # $a2 = color number (0 - 7)
 # $a3 = length of the line (1-32)
DrawFrame : 
    # create stack frame/save $ra
    addiu $sp, $sp -8
    sw    $ra, 0($sp)
    sw    $s0, 4($sp)
    move $s0, $a3 
 FrameLoop : 
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
   bne  $s0,$a1,FrameLoop                 # continue as long as not 0
   lw $s0, 4($sp)                         # restore your $s0 from stack
   lw $ra, 0($sp)                         # restore your $ra from stack   
   addiu $sp,$sp,8                        # restore the stack
    jr $ra                                # go home
 ########################### DrawCircle #################################################
 # $a0 = x coordinate (0 - 31)
 # #a1 = y coordiante (0 - 31)
 # $a2 = color number (0 - 7)
 # $a3 = length of the line (1-32)
  
   #  put CircleTable Data here so program is neat
.data
# a sine table -- reducing at some interval
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
FirstHalf:  # first draw the left side,then the right side to make it easier
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
	addi $s3,$s3,2			# add two every time 
	addi $s2,$s2,1			# add one to the loop count 
	beq $s2,21,CircleDone		# if $s2 = 21, exit loop 
	j SecondHalf 	                #  else, continue drawing
CircleDone:
	jr $ra 

               # return
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
digit1:  .asciiz "="
digit2: .asciiz "2"
digit3: .asciiz "3"
digit4: .asciiz "4"

        .text
PandaDigit :       

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
        
        j Error 
               
One:  # prints out a '1'
        li      $a0, 170        
        li      $a1, 110
        la      $a2, digit1
        jal     OutText      
        j Error
        
Two: # prints out a '2'

        li      $a0, 100
        li      $a1, 110
        la      $a2, digit2
        jal     OutText    
	j Error
	
Three: # prints out a '3'

        li      $a0, 140
        li      $a1, 110
        la      $a2, digit3
        jal     OutText       
	j Error
	
Four: # prints out a '4'
	
	li      $a0, 123
        li      $a1, 166
        la      $a2, digit4
        jal     OutText      
        j Error

Error:
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


 

