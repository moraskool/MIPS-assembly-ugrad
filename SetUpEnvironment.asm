

.data

msg0          :       .asciiz   "Welcome to the ARITH GAME.....\n"
msg1          :       .asciiz   "Use Bitmap Display to View the game interface and Keyboard Simulator tool to enter your answers.....\n"
msg2          :       .asciiz   "Configure Bitmap Display to[2, 2],[512, 512] and base address to 0x100400000\n"
msg3          :       .asciiz   "If you have, you can play the game now.\n"

.text
        la $a0, msg0                 # print start prompt to user
        li $v0, 4
        syscall 
        
        la $a0, msg1                 # print start prompt to user
        li $v0, 4
        syscall
         
        la $a0, msg2                 # print start prompt to user
        li $v0, 4
        syscall 
        
        la $a0, msg3                 # print start prompt to user
        li $v0, 4
        syscall 
        
        li $v0, 10
        syscall
        