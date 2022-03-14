.data
buf: .word 0 : 10

.text
li $v0, 5
syscall
move $s0, $v0		# $s0 = n
srl $s1, $s0, 1		# $s1 = n / 2

# read the 1st half
li $t0, 0		# $t0 for i
beq $s1, $zero, checkOdd
read:
li $v0, 12
syscall
move $t1, $v0		# $t1 = read char
sll $t2, $t0, 2		# $t2 = i * 4
sw $t1, buf($t2)	# buf[i] = read char
addi $t0, $t0, 1	# increase i
bne $t0, $s1, read	# if i != n/2

checkOdd:
sll $t0, $s1, 1		# $t0 = {n[31:1], 0}
beq $t0, $s0, even	# if n[0] == 0
li $v0, 12
syscall

even:

# check
li $t5, 0
beq $s1, $zero, out
move $t0, $s1		# $t0 for i  = n / 2
check:
li $v0, 12
syscall
move $t1, $v0		# $t1 = read char
addi $t0, $t0, -1	# decrease i
sll $t2, $t0, 2		# $t2 = i * 4
lw $t3, buf($t2)	# buf[i] = check char
seq $t4, $t3, $t1	# $t4 = read == check
add $t5, $t5, $t4	# $t5 += $t4
bne $t0, $zero, check	# if i != 0

out:
seq $a0, $s1, $t5
li $v0, 1
syscall

li $v0, 10
syscall









