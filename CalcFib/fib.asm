	#Fibbinacci sequence
	#By Cassie Kresnye
	#calculates a fibbinacci sequence for a user input number
	
	
#-------------------------------------------------------------------
#                                NOTES
# 1. Functions will begin with a capital letter (for the label). this is to distinquish from labels (such as loops) in the function.
	.data
        .align  2
inputString: .asciiz "Please enter an integer 0-20 >> "
inputBadString: .asciiz "Please try again  >> "
inputTooManyString: .asciiz "Really? it's taken 10 tries to get an integer between 0-20? And humans wonder why computers will take over the world... sigh... try again >> "
outputString1: .asciiz "For the integer "
outputString2: .asciiz " the value computed was: "

#degubbing strings
#------------------------------------------FUNCTIONS-----------------------------
	.text
	.globl main
#--------------------------------------MAIN--------------------------------------
# IMPORTANT STUFFS
# s0 - what is being caluclated
# s1 - what is returned

main:
	jal Input
	move $s0, $v0 #grab returned value
	
	#parameters for calcfib
	move $a0, $s0
	jal CalcFib
	move $s1, $v0 # grab returned value returned
	
	#parameters for output
	move $a0, $s0
	move $a1, $s1
	jal Output
	#no returned values
	
	j Done
	

#ENDMAIN--------------------------------------------------------------------------

#---------------------------------------INPUT--------------------------------------
#IMPORTANT STUFFS
# no parameters
# v0 - return value inputed
# t0 - current input attempt
Input:
	li $t0, 1 #current attempt
	
	la $a0, inputString #prints out this nifty message
	li $v0, 51 #tells system to print out string and grab an int
	syscall
	
	#Now check user input

inputLoop:
	bge $a0, 0, inputCheckOne #branch when the input is clear
	beq $t0, 10, inputTooManyTries
	j inputNotEnoughTries
	
inputTooManyTries:
	la $a0, inputTooManyString
	j inputLoopCall
	
inputNotEnoughTries:
	la $a0, inputBadString #yell at user for being silly
	
inputLoopCall:	
	li $v0, 51 #tells system to print out string and grab an int
	syscall
	
	addi $t0, $t0, 1 # add one to tries
	j inputLoop
	
inputCheckOne:
	bge $a0, 20, inputLoop
	
	
inputDone:
	move $v0, $a0
	jr $ra #int grabbed is already in v0
	

#ENDINPUT--------------------------------------------------------------------------

#-----------------------------------calcFib---------------------------------------
# IMPORTANT STUFFS
# a0 - number to calculate
# t0 - number to calculate
# t1 - holds value of first recursive call
# t2 - holds value of the second recursive call
# v0 - value to be returned
CalcFib:
	#First save the stack so far
	addi $sp, $sp, -16
	sw $t0, 0($sp) #store the variables
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $ra, 12($sp) #store the return address on top
	
	#now grab the parameters
	move $t0, $a0
	ble $t0, 1, calcFibIsLessThanTwo #if n <= 1
	#If it makes it here, time to be recursive
	addi $t0, $t0, -1 # n = n-1
	
	move $a0, $t0 # set up parameters
	jal CalcFib # recursive call on n-1
	move $t1, $v0 # grab the returned value
	
	addi $t0, $t0, -1 # n = n-1 again (so n-2 as a whole)
	
	move $a0, $t0 # set up parameters
	jal CalcFib #recursive call on n-2
	move $t2, $v0 # grab returned value
	mul $t2, $t2, 4 
	add $v0, $t1, $t2 # move answer to return value
	j calcFibDone
	
calcFibIsLessThanTwo: #This is a catch all for values 1 and less
	# n is zero
	li $v0, 1
 
calcFibDone:
 	#unpack all the fun stuff for whatever called this
 	lw $ra, 12($sp)
 	lw $t2, 8($sp)
 	lw $t1, 4($sp)
 	lw $t0, 0($sp)
 	addi $sp, $sp, 16 #set the sp back to where Ioriginally had it
 	
 	jr $ra #return
 	
#------------------------------------OUTPUT---------------------------------------
#IMPORTANT STUFFS
# a0 - original value
# a1 - calculated value
# t0 - temporary place to store the original value
# t1 - temporary place to store the computed value
Output:
	move $t0, $a0
	move $t1, $a1
	
	la $a0, outputString1
	li $v0, 4
	syscall #prints first part of output
	
	move $a0, $t0
	li $v0, 1
	syscall # prints out original integer
	
	la $a0, outputString2
	li $v0, 4
	syscall # prints out second part of string
	
	move $a0, $t1
	li $v0, 1
	syscall # prints out the calculated value
	
	jr $ra
	
#ENDOUTPUT------------------------------------------------------------------------
 Done:
 	#do stuff when done
 	li      $v0, 10 #get things set up to end program
        syscall                 # TTFN
	
