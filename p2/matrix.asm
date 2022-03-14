.data
m1: .word 0 : 100
m2: .word 0 : 100
space: .asciiz " "
line: .asciiz "\n"

.macro calc_addr(%dst, %row, %column, %rank)
	# dst: the register to save the calculated address
	# row: the row that element is in
	# column: the column that element is in
	# rank: the number of lines(rows) in the matrix
	multu %row, %rank
	mflo %dst
	addu %dst, %dst, %column
	sll %dst, %dst, 2
.end_macro

.text

li $v0, 5
syscall
move $s0, $v0	# $s0 = n

# read m1
li $t0, 0	# $t0 for i
li $t1, 0	# $t1 for j

read1:

	li $v0, 5
	syscall
	move $t3, $v0 	# $t3 = read int
	calc_addr($t2, $t0, $t1, $s0)
	sw $t3, m1($t2) 	# store read int in m1[i][j]
	addi $t1, $t1, 1 	# increase j
	bne $t1, $s0, read1 	# if j != n

li $t1, 0 	# reset j
addi $t0, $t0, 1 # increase i
bne $t0, $s0, read1 	# if i != n

# read m2
li $t0, 0	# $t0 for i
li $t1, 0	# $t1 for j

read2:

	li $v0, 5
	syscall
	move $t3, $v0 	# $t3 = read int
	calc_addr($t2, $t0, $t1, $s0)
	sw $t3, m2($t2) 	# store read int in m1[i][j]
	addi $t1, $t1, 1 	# increase j
	bne $t1, $s0, read2 	# if j != n

li $t1, 0 	# reset j
addi $t0, $t0, 1 	# increase i
bne $t0, $s0, read2 	# if i != n

# output

li $t0, 0	# $t0 for mul[i][j]
li $t1, 0	# $t1 for i
li $t2, 0	# $t2 for j
li $t3, 0	# $t3 for loop var k
li $t4, 0	# $t2 for temp address


output:
		calc_addr($t4, $t1, $t3, $s0)
		lw $t5, m1($t4) 	# $t5 = m1[i][k]
		calc_addr($t4, $t3, $t2, $s0)
		lw $t6, m2($t4)		# $t6 = m2[k][j]
		multu $t5, $t6
		mflo $t7
		addu $t0, $t0, $t7 	# $t0 += m1[i][k] * m2[k][j]
		addi $t3, $t3, 1 	# increase k
		bne $t3, $s0, output 	# if k != n
	move $a0, $t0
	li $v0, 1
	syscall
	la $a0, space
	li $v0, 4
	syscall
	li $t0, 0 	# reset $t0
	li $t3, 0 	# reset k
	addi $t2, $t2, 1 	# increase j
	bne $t2, $s0, output 	# if j != n
la $a0, line
li $v0, 4
syscall
li $t2, 0 	# reset j
addi $t1, $t1, 1 	# increase i
bne $t1, $s0, output 	# if i != n

li $v0,10
syscall
        



