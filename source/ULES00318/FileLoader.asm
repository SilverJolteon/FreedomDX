sceIoLseekAsync equ 0x088B0C04
strlen			equ 0x08811380

FileLoaderSetIndex:
	addiu		sp, sp, -0x20
	sw			s2, 0x1C(sp)
	sw			s1, 0x18(sp)
	sw			s0, 0x14(sp)
	sw			a3, 0x10(sp)
	sw			a2, 0xC(sp)
	sw			a1, 0x8(sp)
	sw			a0, 0x4(sp)
	sw			ra, 0x0(sp)
	move		s1, a1
	la			a0, DEST
	sw			s1, 0x04(a0)
	la			a0, nativePSP
	jal			strlen
	move		s0, a0
	addi		a0, a0, -5
	
	li			t2, 1000
	move		t3, zero
	move		s2, s1
SetDigit:
	divu		s2, t2
	mflo		t0
	mfhi		s2
	addi		t0, t0, 0x30
	sb			t0, 0x0(a0)
	addiu		a0, a0, 1
	addiu		t3, t3, 1
	
	li			t4, 10
	divu		t2, t4
	mflo		t2
	blt			t3, 4, SetDigit
	nop
	
	lw			a0, 0x4(sp)
	lw			a1, 0x8(sp)
	lw			a2, 0xC(sp)
	lw			a3, 0x10(sp)
	lw			s0, 0x14(sp)
	lw			s1, 0x18(sp)
	lw			s2, 0x1C(sp)
	jal			sceIoLseekAsync
	li			t0, 0x0
	lw			ra, 0x0(sp)
	addiu		sp, sp, 0x20
	jr			ra
	nop
		
nativePSP:
	.ascii "ms0:/PSP/SAVEDATA/FDXDAT/NATIVEPSP/ULLES00318/XXXX"
	.align 8
	
DEST:
	.dh 0
	.align 4
	.dh 0
	.align 4
	.dh 0
	.align 4