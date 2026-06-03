.psp

.open "build/ULJM05066/game_sub_task.bin", 0x09A5A180
	; --------------------------------------
	; Remove quest completion text character limit
	; --------------------------------------
	.org 0x09AC38A4
		j			EndScreenFormat
		nop		
	
	.org 0x09AC7C3C
	EndScreenFormat:
		lui			v1, 0x0897
		ori			v1, v1, 0xA328
		lw			a0, 0x0(v1)
		jal			0x08871540
		move		a1, v0
		seh			s0, v0
		bgez		s0, ESFBranch0
		andi		v0, s0, 0x1
		beq			v0, zero, ESFBranch0
		nop
		addiu		v0, v0, -0x2
	ESFBranch0:
		beq			v0, zero, ESFBranch1
		nop
		addiu		v0, s0, 0x1
		seh			s0, v0
	ESFBranch1:
		j			0x09AC38B0
		nop
	; --------------------------------------
.close