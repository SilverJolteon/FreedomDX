HallSelectWHook			equ 0x08838864
SaveDataOffset			equ 0x09858C20
HallSelectOffset		equ 0x0985929B
RestoreHallOffset		equ 0x1A865B40
StoreHallOffset			equ 0x1AA40DA4
CurrentHall				equ 0x08A25D65

	HallSelectW:
		li			a3, 0x0
		xori		v1, v1, 0x1
		la			t0, SaveDataOffset
		sb			v1, 0x4F(t0)
		la			t0, HallSelectWHook
		addi		t0, t0, 0x8
		jr			t0
		nop
		
	HallSelectR:
		la			a0, SaveDataOffset
		lb			t0, 0x4F(a0)
		la			a0, HallSelectOffset
		sb			t0, 0x0(a0)
		jr			ra
		nop
		
	RestoreHall:
		la			t0, SavedHall
		lb			t1, 0x1(t0)
		beq			t1, zero, RestoreHallReturn
		nop
		sb			zero, 0x1(t0)
		lb			t1, 0x0(t0)
		sb			t1, 0x35(s0)
	RestoreHallReturn:
		jr			ra
		nop
		
	StoreHall:
		addu		v1, a0, v1
		la			t2, CurrentHall
		addi		t3, v1, 0x23
		bne			t2, t3, StoreHallSkip
		nop
		la			t2, SavedHall
		lb			t3, 0x23(v1)
		andi		t3, t3, 0xF
		sb			t3, 0x0(t2)
		li			t3, 0x1
		sb			t3, 0x1(t2)
	StoreHallSkip:
		jr			ra
		sb			s0, 0x23(v1)
		
	SavedHall:
		.word			0