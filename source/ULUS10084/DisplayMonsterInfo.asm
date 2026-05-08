CheckMonsterLength:
	divu			t0, v1
	mfhi			t1
	trunc.w.s		f2, f1
	mfc1			t0, f2
	beq				t0, zero, CheckMonsterLengthCont
	nop
	jr				ra
	nop
	
CheckMonsterLengthCont:
	addi			ra, ra, 8
	jr				ra
	nop
	
CheckCrownSize:
	li				v1, 0xFFFFFFFF
	beq				v0, v1, CheckCrownSizeReturn
	nop
	seh				v1, t0
	slt				at, v1, v0
	jr				ra
	nop
CheckCrownSizeReturn:
	addi			ra, ra, 0x4C
	jr				ra
	nop