.data
array: .word 0 : 100

.macro  READINT(%dst)
    li		$v0,  5		# $v0 = 1 
    syscall
    move    %dst, $v0
.end_macro

.macro  PRINTINT(%src)
    li		$v0,  1		# $v0 = 1 
    move    $a0, %src
    syscall
.end_macro


.text
READINT($s0)        # $s0 = n
addi	$s1, $s0, -1			# $s1 = $s0 + -1
li		$t0, 0		# $t0 = 0

readArray:
    sll		$t1, $t0, 2		# $t1 = $t0 << 2
    READINT($t2)
    sw		$t2, 0($t1)		# array[i] = read int
addi	$t0, $t0, 1			# $t0 = $t0 + 1
bne		$t0, $s0, readArray	# if $t0 != $s0 then readArray


li		$t0, 0		# $t0 = i = 0
li		$t1, 0		# $t1 = j = 0 
sort:
    sub		$t2, $s1, $t0		# $t2 = n - 1 - i
    sll		$t3, $t1, 2			# $t3 = j << 2
    addi	$t4, $t3, 4		# $t4 = $t3 + 4
    lw		$t5, 0($t3)		# 
    lw		$t6, 0($t4)		# 
    ble		$t5, $t6, not_swap	# if $t5 <= $t6 then not_swap
    sw		$t5, 0($t4)		# 
    sw		$t6, 0($t3)		#
    not_swap:

    addi	$t1, $t1, 1			# increase j
    bne		$t2, $t1, sort	# if $t2 != $t1 then sort
li		$t1, 0		# reset j
addi	$t0, $t0, 1			# increase i
bne		$t0, $s1, sort	# if $t0 != $s1 then sort



li		$t0, 0		# $t0 = 0

printArray:
    sll		$t1, $t0, 2		# $t1 = $t0 << 2
    lw		$t2, 0($t1)		# $t2 = array[i]
    PRINTINT($t2)
addi	$t0, $t0, 1			# $t0 = $t0 + 1
bne		$t0, $s0, printArray	# if $t0 != $s0 then printArray
