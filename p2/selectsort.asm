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
li		$t1, 1		# $t1 = 1
lw		$t3, 0($t0)		# $t3 = min = array[i]
sll		$t5, $t0, 2		# $t5 = i << 2

sort:
    sll		$t2, $t1, 2		# $t2 = j << 2
    lw		$t4, 0($t2)		# $t4 = array[j]
    ble		$t3, $t4, not_update	# if $t3 < $t4 then not_update
    move 	$t5, $t2		# $t5 = $t2, update lowest's address
    move 	$t3, $t4		# $t3 = $t4, update lowest's value
    not_update:

    addi	$t1, $t1, 1			# $t1 = $t1 + 1
    bne		$t1, $s0, sort	# if $t1 != $s0 then sort
    sll		$t4, $t0, 2		# $t4 = i << 2
    lw		$t6, 0($t4)		# $t6 = array[i]
    sw		$t3, 0($t4)		# array[i] = array[lowest]
    sw		$t6, 0($t5)		# array[lowest] = array[i]
addi	$t0, $t0, 1			# increase i
addi	$t1, $t0, 1			# j = i + 1
sll		$t5, $t0, 2		# $t5 = i << 2
lw		$t3, 0($t5)		# $t3 = min = array[i]
bne		$t0, $s1, sort	# if i != n - 1 then sort


li		$t0, 0		# $t0 = 0

printArray:
    sll		$t1, $t0, 2		# $t1 = $t0 << 2
    lw		$t2, 0($t1)		# $t2 = array[i]
    PRINTINT($t2)
addi	$t0, $t0, 1			# $t0 = $t0 + 1
bne		$t0, $s0, printArray	# if $t0 != $s0 then printArray
