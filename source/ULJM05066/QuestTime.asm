QuestTimer				equ 0x098583E0
TotalQuestTime			equ 0x089732FC


	StoreTime:
		la			t0, QuestCompleteTime
		la			t1, QuestTimer
		lw			t1, 0x0(t1)
		sw			t1, 0x0(t0)
		
		sb			v0, 0x1(s2)
		jr			ra
		li			v0, 0x96
	
	DrawQuestTime:
		addi		sp, sp, -8
		sw			ra, 0x4(sp)
		sw			a0, 0x0(sp)
	
		la			a0, QuestCompleteTime
		lw			a0, 0x0(a0) ; frames
		beq			a0, zero, DrawQuestTimeReturn
		nop
		
		la			a1, TotalQuestTime
		lw			a1, 0x0(a1)
		sub			a0, a1, a0
		
		; min = frames // 1800
		li			a1, 1800
		divu		a0, a1
		mflo		t0
		; frames -= min * 1800
		mult		t0, a1
		mflo		a1
		sub			a0, a0, a1
		; sec = frames // 30
		li			a1, 30
		divu		a0, a1
		mflo		t1
		; frames -= sec * 30
		mult		t1, a1
		mflo		a1
		sub			a0, a0, a1
		; ms = frames * 1000 // 300
		li			a1, 1000
		mult		a0, a1
		mflo		t2
		li			a1, 300
		divu		t2, a1
		mflo		t2
		
		li			a0, FONT
		li			a1, 0xD0 ; Text X Coordinate
		li			a2, 0xD2 ; Text Y Coordinate
		la			a3, QuestCompleteTimeText		
		jal			drawText
		nop
	
	DrawQuestTimeReturn:
		lw			a0, 0x0(sp)
		lw			ra, 0x4(sp)
		addi		sp, sp, 8
		jr			ra
		li			a1, 0xB2
		
	QuestCompleteTime:
		.word		0x0
	
	QuestCompleteTimeText:
		.ascii		"%02d'%02d\"%02d"
		.align 4		