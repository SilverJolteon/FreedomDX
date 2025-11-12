SeedOffset				equ 0x09853FDA
DosBonusFlags			equ 0x09857748
MonsterInfo				equ 0x09853F68
TimesConnected			equ 0x09857744
GameStateOffset			equ 0x09853020
GetGameState0			equ 0x088450C8
GetGameState1			equ 0x08845334
SetQuestState			equ 0x0884508C
GarugaState				equ 0x098532E1


	CheckGameState:
		addiu		sp, sp, -4
		sw			ra, 0x0(sp)
		la			a0, GameStateOffset
		bne			a2, zero, CheckState1
		nop
		jal			GetGameState0
		nop
		j			ReturnState
		nop
	CheckState1:
		jal			GetGameState1
		nop
	ReturnState:
		lw			ra, 0x0(sp)
		addiu		sp, sp, 4 
		jr			ra
		nop

	DosBonus:
		beq			a0, zero, Return
		nop
		addiu		sp, sp, -0xC
		sw			s2, 0x8(sp)
		sw			s1, 0x4(sp)
		sw			s0, 0x0(sp)
		
		li			s0, 0x3123 ; Bonus Flags
		andi		a0, a0, 0x4
		or			s0, s0, a0 ; Poogie Costume
		
		la			t0, GarugaState
		lb			t0, 0x0(t0)
		andi		t0, t0, 0x2
		beq			t0, zero, SkipYianGaruga1
		
		li			a1, 0x9
		jal			CheckGameState
		li			a2, 0x0
		beq			v0, zero, SkipYianGaruga0
		nop	
		ori			s0, s0, 0x8 ; Yian Garuga (Bit 3)

	SkipYianGaruga0:
		li			a1, 0x9
		jal			CheckGameState
		li			a2, 0x0
		beq			v0, zero, SkipYianGaruga1
		nop	
		li			a1, 0x5
		jal			CheckGameState
		li			a2, 0x0
		beq			v0, zero, SkipYianGaruga1
		nop		
		lui			v0, 0x892
		lw			a0, 0x32A0(v0)
		jal			SetQuestState
		li			a1, 0x5
		ori			s0, s0, 0x10 ; Yian Garuga (Bit 4)

	SkipYianGaruga1:
		li			a1, 0x2905
		jal			CheckGameState
		li			a2, 0x1
		ori			s0, s0, 0x20 ; Low Rank Armory
		beq			v0, zero, SkipHighRankArmory
		nop	
		ori			s0, s0, 0x40 ; High Rank Armory

	SkipHighRankArmory:
		li			a1, 0xBBA
		jal			CheckGameState
		li			a2, 0x1
		beq			v0, zero, SkipGRankArmory
		nop	
		ori			s0, s0, 0x80 ; G Rank Armory

	SkipGRankArmory:
		li			a1, 0x2D
		jal			CheckGameState
		li			a2, 0x0
		beq			v0, zero, SkipBeeHive
		nop	
		ori			s0, s0, 0x100 ; Bee Hive

	SkipBeeHive:
		li			a1, 0x33
		jal			CheckGameState
		li			a2, 0x0
		beql		v0, zero, SkipBarrelCat
		nop
		li			a1,0x27DC
		jal			CheckGameState
		li			a2, 0x1
		bnel		v0, zero, SkipBarrelCat
		ori			s0,s0,0x800
		li			a1,0xBB9
		jal			CheckGameState
		li			a2, 0x1
		beq			v0, zero, SkipBarrelCat
		nop	
		ori			s0,s0,0x800

	SkipBarrelCat:	
		la			a0, SeedOffset
		lh			a0, 0x0(a0)
		; Granny Inventory
		srl			t0, a0, 0x8
		andi		t0, t0, 0xFF
		li			t1, 0x40 ; 0x40 / 0xFF chance (~25%)
		sltu		t1, t0, t1
		li			t2, 0x1600
		mult		t1, t2
		mflo		t1
		nor			t3, zero, t2
		and			s0, s0, t3
		or			s0, s0, t1
		
		; Granny Gift
		srl			t0, a0, 0x8
		andi		t0, t0, 0xFF
		li			t1, 0x19 ; 0x19 / 0xFF chance (~10%)
		sltu		t1, t0, t1
		sll			t1, t1, 0x1
		xori		t1, t1, 0x2
		nor			t1, zero, t1
		and			s0, s0, t1
		
		la			t0, TimesConnected
		lw			t1, 0x0(t0)
		addi		t1, t1, 0x1
		slti		at, t1, 0x1C
		bnel		at, zero, SkipConnectionCounterReset
		nop
		li			t1, 0x0
	SkipConnectionCounterReset:
		sw			t1, 0x0(t0)
		
		; Wandering Chef
		andi		t0, a0, 0xFF
		li			t1, 0x20 ; 0x20 / 0xFF chance (~12.5%)
		sltu		t1, t0, t1
		sll			t1, t1, 0xB
		xori		t1, t1, 0x800
		nor			t1, zero, t1
		and			s0, s0, t1
		
		la			t0, DosBonusFlags
		sh			s0, 0x0(t0)
	
		li			a1, 0xBBA
		jal			CheckGameState
		li			a2, 0x1
		beq			v0, zero, SkipMonsterInfo
		nop	
		la			t0, MonsterInfo
		lui			t1, 0x7FFF
		ori			t1, 0xFFFF
		sw			t1, 0x0(t0)
		
	SkipMonsterInfo:		
		lw			s0, 0x0(sp)
		lw			s1, 0x4(sp)
		lw			s2, 0x8(sp)
		addiu		sp, sp, 0xC

		j			DosBonusReturn
		nop
		