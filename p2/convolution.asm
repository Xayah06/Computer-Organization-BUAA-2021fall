.data
mt1: .word 0 : 200
mt2: .word 0 : 200
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

# read m1, n1, m2, n2
li $v0, 5
syscall
move $s0, $v0	# $s0 = m1
li $v0, 5
syscall
move $s1, $v0	# $s1 = n1
li $v0, 5
syscall
move $s2, $v0	# $s2 = m2
li $v0, 5
syscall
move $s3, $v0	# $s3 = n2

# read mt1
li $t0, 0	# $t0 for i
li $t1, 0	# $t1 for j

read1:

	li $v0, 5
	syscall
	move $t3, $v0 	# $t3 = read int
	calc_addr($t2, $t0, $t1, $s1)
	sw $t3, mt1($t2) 	# store read int in mt1[i][j]
	addi $t1, $t1, 1 	# increase j
	bne $t1, $s1, read1 	# if j != n1

li $t1, 0 	# reset j
addi $t0, $t0, 1 # increase i
bne $t0, $s0, read1 	# if i != m1

# read m2
li $t0, 0	# $t0 for i
li $t1, 0	# $t1 for j

read2:

	li $v0, 5
	syscall
	move $t3, $v0 	# $t3 = read int
	calc_addr($t2, $t0, $t1, $s3)
	sw $t3, mt2($t2) 	# store read int in mt1[i][j]
	addi $t1, $t1, 1 	# increase j
	bne $t1, $s3, read2 	# if j != n2

li $t1, 0 	# reset j
addi $t0, $t0, 1 # increase i
bne $t0, $s2, read2	# if i != m2

# output

li $t0, 0	# $t0 for g[i][j]
li $t1, 0	# $t1 for i
li $t2, 0	# $t2 for j
li $t3, 0	# $t3 for loop var k
li $t4, 0	# $t4 for loop var l
li $t5, 0	# $t5 for temp address

sub $s4, $s0, $s2
addi $s4, $s4, 1       # $s4 = m1 - m2 + 1
sub $s5, $s1, $s3
addi $s5, $s5, 1       # $s5 = n1 - n2 + 1


output:     
            addu $t6, $t1, $t3  # $t6 = i + k
            addu $t7, $t2, $t4  # $t7 = j + l
            calc_addr($t5, $t6, $t7, $s1)
            lw $t7, mt1($t5) 	# $t7 = mt1[i+k][j+l]
            calc_addr($t5, $t3, $t4, $s3)
            lw $t6, mt2($t5)		# $t6 = mt2[k][l]
            multu $t7, $t6
            mflo $t7
            addu $t0, $t0, $t7 	# $t0 += mt1[i+k][j+l]* mt2[k][l]
            addi $t4, $t4, 1        # increase l
            bne $t4, $s3, output    # if l != n2
        li $t4, 0 	# reset l
		addi $t3, $t3, 1 	# increase k
		bne $t3, $s2, output 	# if k != m2
	move $a0, $t0
	li $v0, 1
	syscall
	la $a0, space
	li $v0, 4
	syscall
	li $t0, 0 	# reset $t0
	li $t3, 0 	# reset k
	addi $t2, $t2, 1 	# increase j
	bne $t2, $s5, output 	# if j != n1 - n2 + 1
la $a0, line
li $v0, 4
syscall
li $t2, 0 	# reset j
addi $t1, $t1, 1 	# increase i
bne $t1, $s4, output 	# if i != m1 - m2 + 1

li $v0,10
syscall
