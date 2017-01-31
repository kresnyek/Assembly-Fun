# Binary Search
# By: Cassie Kresnye

#Important notes about documentation------------------------------------------
#----------------------Formatting---------------------------------------------
#    1.) All function labels that start with a capitol letter are the label to
#        call for a function to begin
#    2.) All function labels that start with a lowercase letter will have the name 
#        of the function they are connected to first, followed by what that 
#        specific section does.
	
	.data
        .align  2
        
valueCount: .word 20
#remember to change count of the list, or it will die
values: .word 12, -9, 32, 10, 17, -3, 8, 11, -22, 44 , 34, -2, 13, -8, -7, -6, 20, 16, 4, -13, 
string: .asciiz "Found at index "
string2: .asciiz " (@"
string3: .asciiz ")"
notFound: .asciiz "The value was not found :("
searchValue: .word 12
stringList: .asciiz "The list is as follows: "
space: .asciiz " "
cr: .asciiz "\n"
inputString: .asciiz "Welcome to Cassie's Binary Search program! Please enter a value for me to find (Or enter '0' to quit): "
goodbye: .asciiz "\nHave a great day!"
#------------------------------------------FUNCTIONS-----------------------------
# main - runs everything
# quicksort - sorts the list recusively
#BinarySearch - finds the address of an inputed value recursively in a given list
#PrintOutput - prints the output of the search
 
	.text
	.globl main
	
#-----------------------------Main-----------------------------------------------
# runs everything
#   s0 - The original list
#   s1 - The length of list
#   s2 - The value to find

main:
	#set up stuff for binary search
	la $s0, values
	lw $s1, valueCount

	move $a0, $s0
	move $a1, $s1
	
	jal Quicksort
	
mainLoop:
	la $a0, inputString #prints out this nifty message
	li $v0, 51 #tells system to print out string and grab an int
	syscall
	
	move $s2, $a0 # move user input over
	
	beq $s2, 0, mainDone #check user input
	
	#get parameters set up
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	
	jal BinarySearch
	#grab output	
	move $a0, $s0
	move $a1, $v0
	jal PrintOutput
	j mainLoop
	
mainDone:
	li $v0, 4
	la $a0, goodbye
	syscall
	j done
	
#------------------------------Quicksort----------------------------------------
# This function recusively implements quicksort on the inputted list. 
# NOTE: This function prioritizes using t regs over s regs as to save space in 
# case the list inputed is large, all t regs will be overwritten!
# This algorithm swaps the actual values of the list inputted, so has no return value
#
#  a0 - list to sort
#  a1 - length
#
#  s0 - beginning
#  s1 - length
#  s2 - value of middle
#  s3 - value to compare
#  s4 - end of list
#
#  t0 - smaller address
#  t1 - middle address
#  t2 - greater address/next address to add to
#  t3 - total less than
#  t5 - value to move for swap
#  t6 - value currently moving
#  t7 - value to swap/ also used in shift to hold index

Quicksort:
	# stack stuff
	addi $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $ra, 20($sp)
	
	#get parameters
	move $s0, $a0
	move $s1, $a1
	blt $s1, 2, quicksortDone # if only one item, no need to call again
	
	
	# Get Middle
	div $t1, $s1, 2 #divid list by two
	sll $t1, $t1, 2 #multiply by four
	add $t1, $t1, $s0 #set middle address
	lw $s2, 0($t1) # middle value
	move $t0, $s0 # starting index
	
	#get end
	sll  $s4, $s1, 2
	add $s4, $s0, $s4 # exclusive end
	
	li $t3, 0 # set smaller list
	li $t4, 0 # set greater list
	addi $t2, $t1, 4 #set next address to switch smaller value with

quicksortCheckLesser:
	bge $t0, $t1, quicksortCheckGreater # check if done with first half
	lw $s3, 0($t0) # get value
	bgt $s3, $s2, quicksortSwapLesser # check if need to swap
	
	# else leave it
	addi $t0, $t0, 4 #move to next spot
	addi $t3, $t3, 1 # one more on smaller side
	
	j quicksortCheckLesser

quicksortCheckGreater:
	addi $t0, $t1, 4 #move to first passed the middle
	
quicksortCheckGreaterLoop:
	bge $t0, $s4, quicksortCallAgain #check if more values to check
	lw $s3, 0($t0) # get next value
	move $t5, $t0 #get this ready if branch is taken (since branch will loop)
	ble $s3, $s2, quicksortGreaterShift # will have to shift no matter what for each one lesser. swap is called then from here
	#else leave it
	addi $t0, $t0, 4 # move to next place
	j quicksortCheckGreaterLoop
	
quicksortSwapLesser:
	move $t5, $t0 #this is set up incase of branch being taken
	addi $t7, $s4, -4 # also incase of branch
	bge $t2, $s4, quicksortLesserShift #check if spot open
	lw $t7, 0($t2) #get new value
	sw $s3, 0($t2) #store current value in the new values place
	sw $t7, 0($t0) #store new value in current values spot
	addi $t2, $t2, 4 #next spot to add a value
	j quicksortCheckLesser
	
quicksortLesserShift:
	beq $t5, $t7, quicksortLesserShiftDone #check if done
	lw $t6, 4($t5)#else flip the two
	sw $t6, 0($t5)
	addi $t5, $t5, 4
	j quicksortLesserShift

quicksortLesserShiftDone:
	sw $s3, 0($t5)
	addi $t1, $t1, -4 #move middle over one
	addi $t2, $t2, 4 #next spot to add a value
	j quicksortCheckLesser
	
quicksortGreaterShift:
	beq $t5, $t1, quicksortGreaterShiftDone # check if done
	lw $t6, -4($t5)# flip the two
	sw $t6, 0($t5)
	addi $t5, $t5, -4
	j quicksortGreaterShift
	
quicksortGreaterShiftDone:
	sw $s3, 0($t5)
	addi $t1, $t1, 4 # move over one
	addi $t3, $t3, 1
	j quicksortCheckGreater

quicksortCallAgain:
	#first half
	sub $s4, $s1, $t3 # get number in other list
	addi $s4, $s4, -1 #take out middle value
	move $s2, $t1 #saving value
	
	move $a0, $s0
	move $a1, $t3
	jal Quicksort
	
	#second half
	addi $s2, $s2, 4
	move $a0, $s2
	move $a1, $s4
	jal Quicksort

quicksortDone: 
	#stack stuff
	lw $ra, 20($sp)
	lw $s4, 16($sp)
	lw $s3, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	
	addi $sp, $sp, 24
	jr $ra

#-------------------------Binary Search------------------------------------------
#This is a resursive implementation of binary seach
#   a0 - parameter of the list
#   a1 - length of list
#   a2 - value to find
#
#   s0 - paramtere of list
#   s1 - current length of list
#   s2 - value to find
#   s3 - current middle address
#   s4 - current middle value
#   s5 - new list length
	
BinarySearch:
	addi $sp, $sp, -28
	sw $s0, 0($sp) #store the variables
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $ra, 24($sp) #store the return address on top
	
	#grab parameters
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2

binarySearchLoop:	
	#get current middle
	move $a0, $s0
	move $a1, $s1
	jal GetMiddleValue
	move $s3, $v0
	lw $s4, 0($s3)
	
	beq $s2, $s4, binarySearchFound #will branch if the values match each other
	
	#cut list in half length wise
	div $s5, $s1, 2
	ble $s5, 0, binarySearchNotFound
	
	move $a1, $s5
	#set up value to find
	move $a3, $s2
	
	bge $s2, $s4, binarySearchGreaterThan
	#else it is less than
	move $a0, $s0 #give front part of list
	jal BinarySearch
	j binarySearchDone
	
binarySearchGreaterThan:
	addi $s3, $s3, 4 #move to new beginning to send back
	move $a0, $s3
	
	jal BinarySearch
	#parameter for return value same as what is returned here
	j binarySearchDone
	
binarySearchFound: #an match was found!
	move $v0, $s3 #send back the address of where the item is
	j binarySearchDone
binarySearchNotFound:
	li $v0, -1 #value not found
	

binarySearchDone:
	lw $ra, 24($sp)
	lw $s5, 20($sp)
	lw $s4, 16($sp)
	lw $s3,12($sp)
 	lw $s2, 8($sp)
 	lw $s1, 4($sp)
 	lw $s0, 0($sp)
 	addi $sp, $sp, 28 #set the sp back to where Ioriginally had it
 	
 	jr $ra #return


#------------------------------GetMiddleValue-----------------------------------
#assumes the list is greater than 1 element, returns address of value
#   a0-parameter for the list
#   a1-paramter for te length of the list
#   t0 - temp reg to do the math in
#   v0 - address of value

GetMiddleValue:
	#stack stuff
	addi $sp, $sp, -4
	sw $ra, 0($sp) #store the return address on top

	div $t0, $a1, 2
	sll $t0, $t0, 2 #mulitply by 4
	add $v0, $t0, $a0

	lw $ra, 0($sp)
 	addi $sp, $sp, 4 #set the sp back to where Ioriginally had it
 	
 	jr $ra #return
 	
 #--------------------PRINTOUTPUT--------------------------------------------------------------------
 #   a0 - address of total list
 #   a1 -  address of value found
 #   s0 - address of list
 #   s1 - address of value found
 #   s2 - holds value of the index
 
 PrintOutput:
 	#stack stuff
 	addi $sp, $sp, -16
 	sw $s0, 0($sp)
 	sw $s1, 4($sp)
 	sw $s2, 8($sp)
 	sw $ra, 12($sp)
 
 	move $s0, $a0
 	move $s1, $a1
 	
	
	li $v0, 1
	bne $s1, -1, printOutputFound #if not, then must grab value
	
	la $a0, notFound
	li $v0, 4
	syscall
	j printOutputDone
	
printOutputFound:
	la $a0, string
	li $v0, 4
	syscall #prints first part of output
	
	sub $s2, $s1, $s0
	div $s2, $s2, 4 #each index is worth 4
	move $a0, $s2
	li $v0, 1
	syscall # prints out index of number
	
	
	la $a0, string2
	li $v0, 4
	syscall #prints first parantheses
	
	move $a0, $s1
	li $v0, 1
	syscall # prints out address of number
	
	la $a0, string3
	li $v0, 4
	syscall #prints second parantheses
	
printOutputDone:

	li $v0, 4
	la $a0, cr
	syscall
	
	#stack stuff
	lw $ra, 12($sp)
 	lw $s2, 8($sp)
 	lw $s1, 4($sp)
 	lw $s0, 0($sp)
 	addi $sp, $sp, 16
 	
	jr $ra
	
#----------------------------------------------------------------PRINTLIST----------------------------------------
#This function will print out the current list stored in $a0. This will print it out to the console, and
#returns nothing.
# not this is only used for debugging purposes

#VARIABLES
#a0 - passed list
#a1 - length of list
#t0 - list
#t1 - current index

PrintList:
	move $t0, $a0 #load the current main list into temporary space to play with
	li $t1, 0 # setting the index to be 0
	
	li $v0, 4 #This prints out a nice little message
	la $a0, stringList
	syscall
	
printListLoop:
	bge $t1, $s1, printListDone #print until all is printed in the list
	 #This adds a space
	li $v0, 4
	la $a0, space
	syscall
	
	#This prints out the next value
	li $v0, 1
	lw $a0, 0($t0)
	
	addi $t0, $t0, 4 #shift to the next one
	addi $t1, $t1, 1 # index++
	syscall
	
	j printListLoop
	
printListDone:
	li $v0, 4
	la $a0, cr
	syscall
	jr $ra
#END PRINT LIST ----------------------------------------------------------------------------------------------------------------------

done:
	li $v0, 10
	syscall

	
