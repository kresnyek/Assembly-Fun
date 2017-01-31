	#Selection sort
	#By Cassie Kresnye
	#sorts a stored list and prints the result
	
	
#-------------------------------------------------------------------
#                                NOTES
# 1. Functions will begin with a capital letter (for the label). this is to distinquish from labels (such as loops) in the function.
	.data
        .align  2
        
valueCount: .word 4
#remember to change count of the list, or it will die
values: .word 41, 32, -9, 0
string: .asciiz "The list is as follows: "
space: .asciiz " "
string2: .asciiz "Smallest found: "
cr: .asciiz "\n"
#------------------------------------------FUNCTIONS-----------------------------
	.text
	.globl main
#--------------------------------------MAIN--------------------------------------
# IMPORTANT VARIABLES
# $s0 - holds the main list
# $s1 - length of list left to sort
# $s2 - address of number to be swapped
# $s3 - holds original address of list
main:
	jal Setup
	#get parameters ready for printlist
	move $a0, $s0
	move $a1, $s1
	#print out the list before doing fun stuff
	jal PrintList
	
mainLoop:
	ble $s1, 1, mainFirstDone #as long as there is more to sort
	
	#set up parameter for FindSmallest
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	
	jal FindSmallest
	
	
	move $s2, $v0 #Get what was returned by findSmallest (it will be the address of the numnber!)
	
	#set up parameters for Swap
	move $a0, $s0
	move $a1, $s2
	
	jal Swap
	#Nothing is returned from this
	#Now, I'll adjust the list
	addi $s0, $s0, 4
	addi $s1, $s1, -1 #Since one 
	
	j mainLoop
	
mainFirstDone:
	#Now, reset the list to have the front be as it was before.
	move $s0, $s3
	
	#parameters for PrintList
	move $a0, $s0
	lw $s1, valueCount
	
	move $a1, $s1
	jal PrintList
	
	jal binarySearch
	j done
#----------------------------------------------------------------SETUP----------------------------------------
#This function just gets the values all loaded and ready for the main	
Setup:
	#sets stuff up for the program
	la $s0, values
	move $s3, $s0
	lw $s1, valueCount
	jr $ra
#ENDSETUP-------------------------------------------------------------------------------------------------------
	
#----------------------------------------------------------------PRINTLIST----------------------------------------
#This function will print out the current list stored in $a0. This will print it out to the console, and
#returns nothing.

#VARIABLES
#a0 - passed list
#a1 - length of list
#t0 - list
#t1 - current index

PrintList:
	move $t0, $a0 #load the current main list into temporary space to play with
	li $t1, 0 # setting the index to be 0
	
	li $v0, 4 #This prints out a nice little message
	la $a0, string
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


#----------------------------------------------------------------FINDSMALLEST---------------------------------------------------------
#This will return the index of the smallest int in the list

#TEMPORARY VALUES
# $v0 - what will be returned
# $t0 - stored current list
# $t1 - current index
# $t2 - current smallest
# $t3 - current int to compare to
# $a0 - passed list
# $a1 - length of list

FindSmallest:
	move $t0, $a0 # this will now hold the list to mess with
	li $t1, 1
	lw $t2, 0($t0)
	move $v0, $t0 # store as smallest so far
	addi $t0, $t0, 4 #shift over
	
findSmallestLoop:
	bge $t1, $a1, findSmallestLoopDone #while current index is less than length
	lw $t3, 0($t0) #grab next number to compare
	
	bge $t3, $t2, findSmallestElse #if current is bigger, get next and try again
	move $t2, $t3 #store as new smallest
	move $v0, $t0 #store address to return
	
findSmallestElse: 
	addi $t0, $t0, 4 #shift for next number
	addi $t1, $t1, 1 #index++
	j findSmallestLoop

findSmallestLoopDone:
	jr $ra

#END FINDSMALLEST---------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------SWAP-------------------------------------------------------------------------
#This functions takes in 2 parameters
# a0 - the list (with the item in the first place ready to be swapped)
# a1 - address of what will be swapped
#    VARIABLES
# t0 - will hold list
# t1 - will hold address of what will be swapped
# t2 - value of the front value
# t3 - value of what is being swapped into front

Swap:
	#grabbing parameters
	move $t0, $a0
	move $t1, $a1
	
	#getting what is in the first place
	lw $t2, 0($t0)
	lw $t3, 0($t1)
	sw $t2, 0($t1)
	sw $t3, 0($t0)
	
	jr $ra
#ENDSWAP----------------------------------------------------------------------------------------------------------------------------
	
done:
	li $v0, 10
	syscall
