.data
matrix: .word 0 : 50
stack: .space 2000

.macro READINT(%dst)
    li $v0, 5
    syscall
    move %dst, $v0
.end_macro

.macro PRINTINT(%src)       # change $a0, required saving $a0
    move $a0, %src
    li $v0, 1
    syscall
.end_macro

.macro SAVE(%var)
    addi $sp, $sp, -4
    sw %var, 0($sp)
.end_macro

.macro LOAD(%var)
    lw %var, 0($sp)
    addi $sp, $sp, 4
.end_macro

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

READINT($s0)       # $s0 = n
READINT($s1)       # $s1 = m
la $sp, stack
addi $sp, $sp, 2000     # set $sp


li      $t0, 0       # $t0 = i = 0
li      $t1, 0       # $t1 = j = 0
read:
    READINT($t2)       # $t2 = read int
    calc_addr($t3, $t0, $t1, $s1)
    sw      $t2, matrix($t3)    # matrix[i][j] = read int
    addi    $t1, $t1, 1    # increase j
    bne		$t1, $s1, read	# if j != m then read
li      $t1, 0         # reset j
addi    $t0, $t0, 1    # increase i
bne		$t0, $s0, read	# if i != n then read

READINT($s2)        
READINT($s3)
READINT($s4)
READINT($s5)
addi    $s2, $s2, -1        # $s2 = src_i
addi    $s3, $s3, -1        # $s3 = src_j
addi    $s4, $s4, -1        # $s4 = dst_i
addi    $s5, $s5, -1        # $s5 = dst_j
li      $s6, 0      # $s6 for ans

move    $a0, $s2        # $a0 = src_i
move    $a1, $s3        # $a1 = src_j
jal		dfs				# jump to dfs and save position to $ra
PRINTINT($s6)           # print ans
li $v0, 10
syscall


dfs:
move    $t0, $a0        # $t0 = now_i
move 	$t1, $a1		# $t1 = now_j
seq     $t3, $t0, $s0       # $t3 = now_i == n
slt		$t4, $t0, $zero		# $t4 = now_i < 0
seq     $t5, $t1, $s1       # $t3 = now_j == m
slt		$t6, $t1, $zero		# $t4 = now_j < 0
or      $t3, $t3, $t4
or      $t5, $t5, $t6
or      $t3, $t3, $t5       # $t3 = out of matrix
bne		$t3, $zero, searched	# branch searched if out

calc_addr($t3, $t0, $t1, $s1)
lw	$t2, matrix($t3)	# $t2 = matrix[now_i][now_j] 
bne     $t2, $zero, searched    # branch serached if matrix[now_i][now_j] = 1
seq     $t3, $t0, $s4       # $t3 = now_i == dst_i
seq     $t4, $t1, $s5       # $t4 = now_j =  dst_j
and     $t5, $t3, $t4       # $t5 = now == dst
bne     $t5, $zero, find    # branch find if find dst

li 	$t2, 1
calc_addr($t3, $t0, $t1, $s1)
sw	$t2, matrix($t3)	# matrix[now_i][now_j]  = 1

SAVE($t0)
SAVE($t1)
SAVE($ra)

addi    $a0, $t0, 1         # $a0 = now_i + 1
addi    $a1, $t1, 0         # $a1 = now_j
jal     dfs                 # dfs(now_i + 1, now_j)

LOAD($ra)
LOAD($t1)
LOAD($t0)

SAVE($t0)
SAVE($t1)
SAVE($ra)

addi    $a0, $t0, -1         # $a0 = now_i - 1
addi    $a1, $t1, 0         # $a1 = now_j
jal     dfs                 # dfs(now_i - 1, now_j)

LOAD($ra)
LOAD($t1)
LOAD($t0)

SAVE($t0)
SAVE($t1)
SAVE($ra)

addi    $a0, $t0, 0         # $a0 = now_i 
addi    $a1, $t1, 1         # $a1 = now_j + 1
jal     dfs                 # dfs(now_i, now_j + 1)

LOAD($ra)
LOAD($t1)
LOAD($t0)

SAVE($t0)
SAVE($t1)
SAVE($ra)

addi    $a0, $t0, 0         # $a0 = now_i 
addi    $a1, $t1, -1         # $a1 = now_j - 1
jal     dfs                 # dfs(now_i, now_j - 1)

LOAD($ra)
LOAD($t1)
LOAD($t0)

li 	$t2, 0
calc_addr($t3, $t0, $t1, $s1)
sw	$t2, matrix($t3)	# matrix[now_i][now_j]  = 0


j		searched				# jump to searched


find:
addi        $s6, $s6, 1      # ans += 1
searched:
jr		$ra					# jump to $ra






