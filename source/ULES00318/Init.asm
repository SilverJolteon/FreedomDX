FDX_VERSION				equ "v1.8.5"
HoldToGatherOffset 		equ 0x098FB068
TrueRawOffset			equ 0x088F2B10
LaoShanLungOffset		equ 0x0990E3A4
MapScaleOffset			equ 0x0881D7D0
SnSDebuffOffset			equ 0x098D9B70
SupplyChestDelayOffset	equ 0x0882D2B0
FOVOffset0				equ 0x08816038
FOVOffset1				equ 0x088161D4
FOVOffset2				equ 0x088162E8
FOVOffset3				equ 0x0886B50C
FOVOffset4				equ 0x0886DA9C
CameraPosOffset			equ 0x08816218

	TitleScreenVersion:
		addi		sp, sp, -0x8
		sw			ra, 0x4(sp)
		sw			v0, 0x0(sp)
		
		li			a0, FONT
		li			a1, 350 ; Text X Coordinate
		li			a2, 215 ; Text Y Coordinate
		li			t0, 0 ; Color
		la			t1, VERSION
		jal			drawShadowedText
		li			a3, 0x1
		
		lw			v0, 0x0(sp)
		lw			ra, 0x4(sp)
		addi		sp, sp, 0x8
		addiu		v0, v0, 0x1
		jr			ra
		sw			v0, 0x20(s0)
		
	VERSION:
		.asciiz FDX_VERSION
		.align 4
		
; On Game Start
	ReadConfigToMem:
		addi		sp, sp, -0xC
		sw			ra, 0x8(sp)
		sw			s0, 0x4(sp)
		sw			a0, 0x0(sp)
		; Open config file
		la			a0, CONFIG_PATH
		li			a1, 0x1
		li			a2, 0x0
		li			a3, 0x0
		jal			sceIoOpen
		li			t0, 0x0
		; Check if config exists
		li			v1, 0x80010002
		beq			v0, v1, ReadConfigToMenReturn
		nop
		li			v1, 0x0
		move		s0, v0	
		; Read config
		move		a0, s0
		li			a1, CONFIG_BIN
		jal			sceIoRead
		li			a2, 0x30
		; Close quests file
		jal			sceIoClose
		move		a0, s0
		jal			sceKDWIA
		nop	
	ReadConfigToMenReturn:	
		; Check config flags
		la			v0, CONFIG_BIN
		
	TrueRaw:
		lb			a0, 0x11(v0)
		beq			a0, zero, TrueRawReturn
		nop
		la			t0, TrueRawOffset
		li			t1, 0x64
		li			t2, 0x6
		sw			t1, 0x0(t0)
		addiu		t0, t0, 0x4
		bne			t2, zero, . - 0x8
		addiu		t2, t2, -0x1
	TrueRawReturn:
		
	MapScale:
		lb			a0, 0x13(v0)
		li			t0, 0x32
		blt 		a0, t0, MapScaleReturn
		nop
		li			t0, 0x64
		bgt			a0, t0, MapScaleReturn
		nop
		; Check
		la			t0, MapScaleOffset
		lw			t1, 0x0(t0)
		li			t2, 0x3C023F80
		bne			t1, t2, Return
		nop
		; Scale
		li			t0, 0x100
		mult		a0, t0
		mflo		t1
		addi		t1, t1, -0x3200
		li			t0, 0x64
		div			t1, t0
		mflo		t1
		la			t0, MapScaleOffset
		sb			t1, 0x0(t0)
		; X Coordinate
		li			t2, 0x64
		sub			t1, t2, a0 
		li			t0, 0x4C
		mult		t0, t1
		mflo		t1
		div			t1, t2
		mflo		t1
		la			t0, MapScaleOffset
		lui			t2, 0x2405
		ori			t2, t2, 0x0144
		add			t2, t2, t1
		sw			t2, 0xC(t0)
		lui			t2, 0x2406
		ori			t2, t2, 0x0024
		add			t2, t2, t1
		sw			t2, 0x14(t0)	
	MapScaleReturn:
		
	SupplyChestDelay:
		lb			a0, 0x19(v0)
		beq			a0, zero, SupplyChestDelayReturn
		nop
		la			t0, SupplyChestDelayOffset
		li			t1, 0x1E
		lb			t2, 0x0(t0)
		bne			t1, t2, SupplyChestDelayReturn
		nop
		li			t1, 0x1
		sb			t1, 0x0(t0)
	SupplyChestDelayReturn:
		
	FOV:		
		lb			a0, 0x1A(v0)
		la			t0, FOVOffset0
		sb			a0, 0x0(t0)
		la			t0, FOVOffset1
		sb			a0, 0x0(t0)
		la			t0, FOVOffset2
		sb			a0, 0x0(t0)
		la			t0, FOVOffset3
		sb			a0, 0x0(t0)
		la			t0, FOVOffset4
		sb			a0, 0x0(t0)
	FOVReturn:	
		
	CameraPos:		
		lb			a0, 0x1B(v0)
		la			t0, CameraPosOffset
		lui			t1, 0x2403
		or			t1, t1, a0
		sw			t1, 0x0(t0)
	CameraPosReturn:

		; Return
		lw			a0, 0x0(sp)
		lw			s0, 0x4(sp)
		li			a1, 0x1
		jal			sceIoOpen
		li			a2, 0
		lw			ra, 0x8(sp)
		addi		sp, sp, 0xC
		jr			ra
		nop
	
; On Quest Init
	QuestInit:
		addi		sp, sp, -4
		sw			a0, 0x0(sp)
		
		; Config
		la			v0, CONFIG_BIN
		
	HoldToGather:
		lb			a0, 0x10(v0)
		beq			a0, zero, HoldToGatherReturn
		nop
		la			t0, HoldToGatherOffset
		li			t1, 0x04A4
		lhu			t2, 0x0(t0)
		bne			t2, t1, HoldToGatherReturn
		nop
		li			t1, 0x04A0
		sh			t1, 0x0(t0)
	HoldToGatherReturn:
		
	LaoShanLung:
		lb			a0, 0x12(v0)
		beq			a0, zero, LaoShanLungReturn
		nop
		la			t0, LaoShanLungOffset
		li			t1, 0x284103E8
		lw			t2, 0x0(t0)
		bne			t2, t1, LaoShanLungReturn
		nop
		sw			zero, 0x0(t0)
		sw			zero, 0x4(t0)
		sw			zero, 0x8(t0)
		sw			zero, 0xC(t0)
	LaoShanLungReturn:
	
	SnSDebuff:
		lb			a0, 0x14(v0)
		beq			a0, zero, SnSDebuffReturn
		nop
		la			t0, SnSDebuffOffset
		lui			t1, 0x2402
		ori			t1, 0x0096
		lw			t2, 0x0(t0)
		bne			t2, t1, SnSDebuffReturn
		nop
		li			t1, 0x78
		sb			t1, 0x0(t0)
	SnSDebuffReturn:

		; Reset Stored Quest Time
		la				a0, QuestCompleteTime
		sw				zero, 0x0(a0)

	QuestInitReturn:
		lw			a0, 0x0(sp)
		addi		sp, sp, 4
		sw			zero, 0x4C(s3)
		lui			v0, 0x892
		jr			ra
		nop