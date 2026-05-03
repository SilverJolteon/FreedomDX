FileLoaderSetIndex:
	addi		sp, sp, -4
	sw			s2, 0x0(sp)
	
	la			a0, DEST
	sw			s1, 0x04(a0)
	la			a0, nativePSP
	addi		a0, a0, 0x2D ; HARDCODED to point to XXXX
	
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
	
	lw			s2, 0x0(sp)
	addi		sp, sp, 4
	jr			ra
	nop
	
FileLoader:
	beq			a0, zero, Return
	nop
	; Check chunk position
	lui			t0, 0x2
	beq			t0, s1, Return
	nop
	; Set index
	jal			FileLoaderSetIndex
	lh			s1, 0x2(s0)
	; Open file
	la			a0, nativePSP
	li			a1, 0x1
	jal			sceIoOpen
	li			a2, 0x0
	; Check if file exists
	li			v1, 0x80010002
	beq			v0, v1, FileLoaderReturn
	nop	
	li			v1, 0x0
	move		s0, v0
	; Get file size
	move		a0, s0
	li			a1, 0x0
	li			a2, 0x0
	li			a3, 0x0
	jal			sceIoLseek
	li			t0, 0x2
	beq			v0, zero, FileLoaderReturn
	nop
	move		s1, v0
	; Seek to start of file
	move		a0, s0
	li			a1, 0x0
	li			a2, 0x0
	li			a3, 0x0
	jal			sceIoLseek
	li			t0, 0x0
	; Read file
	move		a0, s0
	la			t0, DEST
	lw			a1, 0x0(t0)
	li			t0, 0
	jal			sceIoRead
	move		a2, s1
	; Close file
	jal			sceIoClose
	move 		a0, s0
	jal			sceKDWIA
	nop
	j			FileLoaderReturn
	nop
		
nativePSP:
	.ascii "ms0:/PSP/SAVEDATA/FDXDAT/NATIVEPSP/ULES00318/XXXX"
	.align 8
	
DEST:
	.dh 0
	.align 4
	.dh 0
	.align 4
	.dh 0
	.align 4