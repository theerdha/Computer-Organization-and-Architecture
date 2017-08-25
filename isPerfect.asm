## isPerfect.asm takes in a positive integer - num and prints out if the number is perfect(or not)
## Registers Used :
##		$t0 for storing num
##		$t1 for storing k
##		$t2 for storing sum
## 		$t3 for storing num % k

.text

main:
	la $a0 , num_msg				#loads address of entering number msg in $a0
	li $v0 , 4						#loads print string syscall command
	syscall							#makes a system call

	li $v0 , 5						#loads read int syscall command
	syscall							#makes a system call
	move $t0 , $v0					#store the value in $t0

	li $t1 , 1						#initialize k with 1
	li $t2 , 0						#initialize sum with 0

loop:
	bge $t1 , $t0 , endloop			#if K >= num then we are done
	rem $t3 , $t0 , $t1				#load the remainder , num % k into $t3
	beqz $t3 , adder 				#branch to adder
lab:
	add $t1 , $t1 , 1 				#increment the value of k by 1 i.e k++
	b loop 							#unconditional branching to loop

adder:
	add $t2 , $t2 , $t1 			#add the value of k to the sum
	b lab 							#unconditional branching to lab

endloop:
	beq $t2 , $t0 , perfect 		#after the loop, if the value of sum = number entered, the number is a perfect number
	bne $t2 , $t0 , notperfect 		#if the value of sum is not equal to the number , the number is not a perfect number

perfect:
	la $a0 , success_msg 			#loads address of success msg in $a0
	li $v0 , 4						#loads print string syscall command
	syscall							#makes a system call
	b exit							#unconditional branching to exit label

notperfect:
	la $a0 , failure_msg			#loads address of failure msg in $a0
	li $v0 , 4						#loads print string syscall command
	syscall							#makes a system call
	b exit 							#unconditional branching to exit label

exit: 								#### exit the program ####
	li $v0 , 10 					#load exit command into $v0
	syscall 						#makes a system call

.data 								#####  data for storing strings ######
	num_msg:		.asciiz "Enter a positive Integer\n"
	success_msg:	.asciiz "Entered number is a perfect number\n"
	failure_msg:	.asciiz "Entered number is not a perfect number\n"