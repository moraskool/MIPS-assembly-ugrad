# This is a simple calculator that performs +.-,* and /. on implied decimal umbers
# The program uses several procedure calls to perform the functions of a simple calculator

.data

prompt1          :  .asciiz "Enter Ist Number:  "
prompt2          :  .asciiz "\nEnter 2nd Number:  "
spacePrompt1     :  .asciiz " \n "
resultPrompt     :  .asciiz " Result:  "
charprompt       :  .asciiz " Select Operator:  "
remainderpromp   :  .asciiz " Remainder:"
invalidPrompt    :  .asciiz "Invalid arithemetic operator! Start program again ."
ivalidZero       :  .asciiz "Invalid! Cannot perform division by 0!"

oper             :.word 0
number1          :.word 0
number2          :.word 0
result		 :.word 0
remainder        :.word 0
buffer           :.byte 0:80
.text
       
####################################################################################
loop : 
       
       la $a0, prompt1                # get input from user
       la $a1, number1                # s $a1 points to where number1 is stored
        
       jal GetInput                   # jump to get input procedure
	   
       la $a0, charprompt             # put char prompt in a0
       la $v1, oper                   # s $a1 points to where number1 is stored
       jal GetOperator                # unconditional jump to the GetOperator Function
	    
    # break to print Error character if invalid operator
       la $a0, prompt2                # get input from user
       la $a1, number2                # number is in address t0
       jal GetInput
       lw $s0, 0($v1)                 # $v1 points to the address where the operand is stored  
	   
    # setup a0, a1, a2 pointers
       la $a0, number1                # address $a0 points to number1  --first number
       la $a1, number2                # address $a1 points to number2  --second number
       la $a2, result                 # $a2 points to result
       la $a3, remainder              # address $a1 points remainder  
       la $ra, donemath	              # $ra address  points to the loop done math 
	
   ## branch to various  arithemetic operations
       beq $s0, 0x2B, AddNumb         # Branch to AddNumb if $s0 =' +' --42
       beq $s0, 0x2D, SubNumb         # Branch to AddNumb if $s0 =' -' --45
       beq $s0, 0x2A, MultNumb        # Branch to AddNumb if $s0 =' *' --43
       beq $s0, 0x2F, DivNumb         # Branch to AddNumb if $s0 =' /' --47
       j showInvalid                  # if operaror is invalid,show error message
       
       
 donemath:      
       la $a0, number1               # address $a0 points to number1  --first number
       	la $a1, number2               # address $a1 points to number2  --second number
       	la $a2, result                # $a2 points to result
 	la $a3, remainder             # address $a1 points remainder    
	jal DispNumb      
        # call display num to display remainder IF we did divide   
####################################################################################	   
GetInput: 
       
       li $v0, 4                      # specify the print string service
       syscall                        # print out the string stored in prompt1
       li $v0, 8                      # specify read string service 
       syscall                        # read in first number  
       lw $v0,($a0)                   # $a0 points to buffer to store incoming text
       add $t0,$0,$0                  # accumulate total
       
  loopGet :
       lb $t1, 0($a0)                 # load a byte from 0(Sa0)
       addiu $a0, $a0, 1              # advance the pointer
       addiu $t2, $zero, 0xA          # $t2 = " <cr>"
       beq $t1, $t2, break1           # break if equal to this 
       beq $t1, 0, break1             # or equal to 0 
       addiu $t2, $zero , 0x2e        # $t2 is now = "."
       beq $t1, $t2, break1           # break if equal to this   
       sub $t3, $t1, 0x30             # convert data from ascii 0-9 t0  integer
       mul $t0, $t0, 10               # multiply the current total by 10 and add new value
       add $t0, $t0 ,$t3              # current total of all digits after "."
       j loopGet  
       
  break1 :  
      mul $t0, $t0, 100               # implied decimal
      li $t2, 0x2e                    # $t2 = "."
      bne $t1, $t2, break2            # if last digit is not "." , no decimal number entered, finish    
      lb  $t1, 0($a0)                 # load a byte from 0(Sa0)
      addiu $a0, $a0, 1               # advance the pointer  
      sub $t3, $t1, 0x30              # convert data from ascii 0-9 t0  integer
      mul $t3, $t3, 10                # this is the tens digit,multiply by 10 
      add $t0, $t0, $t3               # add to dollar ammount
      lb  $t1, 0($a0)                 # get the next character from the buffer
      sub $t3, $t1, 0x30              # convert data from ascii 0-9 t0  integer
      add $t0, $t0, $t3               # this is the units digit,add to dollar ammount     
 break2 :      
      sw $t0,($a1)
      jr $ra
####################################################################################     
GetOperator  :  # display prompt to user and gets a single char input, $a0=text string,$v1 = operator
      li $v0, 4                       # specify print string service
      syscall                         # print out the prompt
      addi $v0, $0 ,12                # specify read character service
      syscall                         # read the character
      sw $v0,0($v1) 
      jr $ra
####################################################################################      
showInvalid: # show an error message and exit if operator is invalid
     la $a0, invalidPrompt            # load the error string into the argument
     li $v0, 4                        # specify print string service
     syscall                          # print out the prompt
     li   $v0, 10                     # system call for exit
     syscall   
####################################################################################                          
 showInvalidZero:  # show an error message and exit if divisor is zero
     la $a0, ivalidZero               # load the error string into the argument
     li $v0, 4                        # specify print string service
     syscall                          # print out the prompt
     li   $v0, 10                     # system call for exit
     syscall                          # Exit!  
####################################################################################      
 
                       
####################################################################################
AddNumb:  # load all addreses used, a2 = a0 + a1,save and jump to DispNumb
     lw $a0, 0($a0)                   # load  contents of number1 into 0 offset in $a0
     lw $a1, 0($a1)                   # load  contents of number1 into 0 offset in $a1
     add $t2, $a0, $a1                # $a2 = $a1 + $a0
     sw $t2, ($a2)                    # address $to points to the result stored in location $a2
     jr $ra                           # jump back to caller
####################################################################################         
SubNumb:  # load all addreses used,a2 = a0 - a1,save and jump to DispNumb
     lw $a0, 0($a0)                   # load  contents of number1 into 0 offset in $a0
     lw $a1, 0($a1)                   # load  contents of number1 into 0 offset in $a1
     sub $t2, $a0, $a1                # $a2 = $a1 - $a0
     sw $t2, ($a2)                    # address $to points to the result stored in location $a2
     jr $ra                           # jump back to caller
####################################################################################
MultNumb:  # load all addreses used, a2 = a0 * a1,save and jump to DispNumb
    lw $a0, 0($a0)                    # load  contents of number1 into 0 offset in $a0
    lw $a1, 0($a1)                    # load  contents of number1 into 0 offset in $a1 
    add $t3, $a1,$0                   # set up counter to second number
    add $t2, $0, $0                   # initialize $t2
 ## Do a loop for adding first number n-times.(n = second number)
      loop_1 :
    add  $t2, $t2, $a0                # $t3 + $a1
    addi $t3, $t3, -1                 # decrement loop counter
    bne  $t3, 0, loop_1               # if $t3 = 1, exit loop / do this loop as long as $t3 is greater than 1     
    sw $t2, ($a2)                     # address $to points to the result stored in location $a2
    jr  $ra                           # call display num to display result
####################################################################################     
DivNumb:  # load all addreses used, a2 = a0 / a1, a3 = a0 % a1 save and jump to DispNumb
    lw $a0, 0($a0)                    # load  contents of number1 into 0 offset in $a0
    lw $a1, 0($a1)                    # load  contents of number1 into 0 offset in $a1                      
    add $t2, $0, $0                   # set up counter to 0
    beqz $a1 , showInvalidZero        # if divisor is 0,show error message
    add $t1 ,$a0 ,$0   
 loop_2 :
    sub  $a0, $a0, $a1                # $a0 = $a0 - $a1
    addi $t2, $t2, 1                  # increment the quotient
    blt  $a0, $a1 remaind
    bgt  $t2, 0, loop_2               # if $t3 = 1, exit loop / do this loop as long as $t2 is greater than 1     
 remaind :  
    sw  $a0, ($a3)                    # address $a0 points to the remainder stored in location $a3  
    sw $t2, ($a2)                     # address $to points to the result stored in location $a2        
    add $a2, $a2, $0                  # result is in $a2 
    jr  $ra                           # call display num to display result
  
####################################################################################    
DispNumb: # load the result from the procedures and make syscall to display number,go back to GetInput
     add $t0, $0, $0   
     la $a0,resultPrompt
     li $v0, 4
     syscall
    # beq $s0, 0x2A, PrintMult       # Branch to AddNumb if $s0 =' *' --43
      j printout
      lw $a3, 0($a3)
      beqz $a3, remPrompt 
                                
     la $a0, remainderpromp
     li $v0, 4
     syscall  
     la $a0, ($a3)               # load  remainder points into $a3
     li $v0, 1                   # specify Print Integer service
     syscall  
     
  printout: 
     lw $t0, 0($a2)               # load  result points into $a0
     li $t1,100
     div $t2,$t0,$t1             #  $t2 = whole number part
     rem $t3,$t0,$t1             #  $t3 = decimal part   
     la $a0, ($t2)               # print out whole number part
     li $v0, 1                   # specify Print Integer service
     syscall   
     la $a0, 0x2e 
     li $v0, 11                   # print "."
     syscall
     la $a0, ($t3)                # print out decimal part
     li $v0, 1                    # specify Print Integer service  
     
     li $t1,10
     div $t4,$t3,$t1              # $t4= tenths digit
     rem $t5,$t3,$t1              # $t5  uiniths digit
     
     la $a0, ($t4)                # print out decimal part
     li $v0, 1                    # specify Print Integer service  
     syscall
     
     la $a0, ($t5)                # print out decimal part
     li $v0, 1                    # specify Print Integer service  
     syscall  
                               
 remPrompt :    
     la $a0, spacePrompt1        # print out a newline
     li $v0, 4  
     syscall
     
     la $a0, ($t2)                # print out whole part of result
     li $v0, 1  
     syscall  
     la $a0, 0x2e 
     li $v0, 11                   # print "."
     syscall
     la $a0, ($t4)                # print out tenth digit of result
     li $v0, 1                   
     syscall
     la $a0, ($t5)                # print out uniths digit of result
     li $v0, 1                  
     syscall  
     
     la $a0, 0x20                 # print out a space
     li $v0, 11  
     syscall
     
     la $a0, 0x3D                 # print out a '='
     li $v0, 11  
     syscall
     
     la $a0, 0x20                 # print out a space
     li $v0, 11  
     syscall
     
  printFirstNumb: 
     lw $t0, number1               # load  result points into $a0
     li $t1,100
     div $t2,$t0,$t1             #  $t2 = whole number part
     rem $t3,$t0,$t1             #  $t3 = decimal part   
     la $a0, ($t2)               # print out whole number part
     li $v0, 1                   # specify Print Integer service
     syscall   
     la $a0, 0x2e 
     li $v0, 11                   # print "."
     syscall
     la $a0, ($t3)                # print out decimal part
     li $v0, 1                    # specify Print Integer service  
     
     li $t1,10
     div $t4,$t3,$t1              # $t4= tenths digit
     rem $t5,$t3,$t1              # $t5  uiniths digit
     
     la $a0, ($t4)                # print out decimal part
     li $v0, 1                    # specify Print Integer service  
     syscall
     
     la $a0, ($t5)                # print out decimal part
     li $v0, 1                    # specify Print Integer service  
     syscall  

     
     la $a0, 0x20                  # print out a space
     li $v0, 11  
     syscall
     
     la $a0, ($s0)                # print out the  operator
     li $v0,  11
     syscall
     
     la $a0, 0x20                 # print out a space
     li $v0, 11  
     syscall
     
  prinSecondNumb: 
     lw $t0, number2               # load  result points into $a0
     li $t1,100
     div $t2,$t0,$t1             #  $t2 = whole number part
     rem $t3,$t0,$t1             #  $t3 = decimal part   
     la $a0, ($t2)               # print out whole number part
     li $v0, 1                   # specify Print Integer service
     syscall   
     la $a0, 0x2e 
     li $v0, 11                   # print "."
     syscall
     la $a0, ($t3)                # print out decimal part
     li $v0, 1                    # specify Print Integer service  
     
     li $t1,10
     div $t4,$t3,$t1              # $t4= tenths digit
     rem $t5,$t3,$t1              # $t5  uiniths digit
     
     la $a0, ($t4)                # print out decimal part
     li $v0, 1                    # specify Print Integer service  
     syscall
     
     la $a0, ($t5)                # print out decimal part
     li $v0, 1                    # specify Print Integer service  
     syscall  
    
     la $a0, spacePrompt1         # print out a newline
     li $v0, 4
     syscall
     
     la $a0, spacePrompt1         # print out a newline
     li $v0, 4
     syscall
     
    add $t2, $0, $0               # clear the result register
      b  loop                     # do loop until $s1 = 0
     
     
	   
            
        
        
	   

