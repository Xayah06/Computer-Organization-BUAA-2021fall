.data
long: .word 0 : 500
low: .word 1

.text
li      $v0, 5
syscall
move    $s0, $v0        # $s0 = n

la      $t0, low       # $t0 = initial address
li      $t1, 1          # $t1 = i = 1
li	$t3, 0		# t3 = cin
la      $s1, low       # $s1 = lowest address


loop:
    lw      $t2, 0($t0)         # $t2 = now
    mult	$t2, $t1	# $t2 * $t1 = Hi and Lo registers
    mflo	$t2		# copy Lo to $t2
    add		$t2, $t2, $t3	# $t2 = mult now + cin
    li     	$t4, 1000
    div		$t2, $t4
    mflo	$t3
    mfhi	$t2		# $t2 %= 1000
    sw      $t2, 0($t0)         # now = $t2
    addi	$t0, $t0, -4	# decrease $t0
    bne		$t3, $zero, loop	# if cin > 0
    bge		$t0, $s1, loop		# if $t0 >= $s1
    
    addi	$t0, $t0, 4
    slt		$t4, $t0, $s1	# $t4 = $t0 < $s1
    beq		$t4, $zero, not_update	# if $t0 >= $s1
    move	$s1, $t0
    not_update:
    

   
la      $t0, low       # reset $t0
li	$t3, 0	 	# reset $t3
addi    $t1, $t1, 1     # increase i
ble     $t1, $s0, loop  # if i <= n






move      $t0, $s1
la        $t1, low
lw      $a0, 0($t0)	# print the highest
li      $v0, 1
syscall
addi 	$t0, $t0, 4
li	$t2, 100
li	$t3, 10


output:
bgt	$t0, $t1, end
lw	$t4, 0($t0)
blt	$t4, $t3, tenminus
blt	$t4, $t2, hunminus
j	origin

tenminus:
li	$a0, 0
li	$v0, 1
syscall
hunminus:
li	$a0, 0
li	$v0, 1
syscall
origin:
move	$a0, $t4
li	$v0, 1
syscall

addi	$t0, $t0, 4
j output



end:
li      $v0, 10
syscall
