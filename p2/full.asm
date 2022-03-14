.data
symbol: .word 0 : 10
array: .word 0 : 10
space: .asciiz " "
line: .asciiz "\n"
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
    
.text

READINT($s0)        # $s0 = n
la $sp, stack
addi $sp, $sp, 2000     # set $sp
move $a0, $zero         # $a0 = index = 0
jal		FULLARRAY				# jump to FULLARRAY and save position to $ra
li $v0, 10
syscall

FULLARRAY:

move $t1, $a0  # $t1 = index
sge  $t2, $t1, $s0   # $t2 = index >= n
li $t0, 0       # $t0 = i = 0
beq $t2, $zero, dfs     # branch dfs if index < n

# print and exit


output:

sll $t2, $t0, 2         # $t2 = i << 2
lw $t3, array($t2)      # $t3 = array[i]
PRINTINT($t3)           # ATTENTION: change $a0 here
la $a0, space           # print " "
li $v0, 4
syscall
addi $t0, $t0, 1        # increase i
bne $t0, $s0, output    # if i < n

la $a0, line            # print "\n"
li $v0, 4
syscall
jr		$ra					# jump to $ra



li $t0, 0       # $t0 = i = 0

dfs:
sll $t3, $t0, 2     # $t3 = i << 2
lw $t4, symbol($t3)  # $t4 = symbol[i]
bne $t4, $zero, searched       # branch if symbol[i] != 0
sll $t5, $t1, 2     # $t5 = index << 2
addi $t4, $t0, 1    # $t4 = i + 1
sw $t4, array($t5)  # array[index] = i + 1
li $t4, 1           # $t4 = 1
sw $t4, symbol($t3) # symbol[i] = 1
move $a0, $t1
addi $a0, $a0, 1    # $a0 = index + 1
SAVE($t0)
SAVE($t1)
SAVE($t3)
SAVE($ra)
jal		FULLARRAY				# jump to FULLARRAY and save position to $ra
LOAD($ra)
LOAD($t3)
LOAD($t1)
LOAD($t0)
sw $zero, symbol($t3)



searched:

addi $t0, $t0, 1        # increase i
bne $t0, $s0, dfs   # if i < n
jr		$ra					# jump to $ra
