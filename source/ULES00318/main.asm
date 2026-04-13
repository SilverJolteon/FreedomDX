.psp

sceIoOpen				equ	0x088B0C2C
sceIoLseek				equ	0x088B0C34
sceIoRead				equ	0x088B0BFC
sceIoClose				equ	0x088B0C14
sceKDWIA				equ	0x088B0E0C ; sceKernelDcacheWritebackInvalidateAll
sceWlanGetEtherAddr		equ 0x088B1444

FONT					equ 0x0982C280
drawText				equ 0x088723E4
drawShadowedText		equ 0x08872660

HoldToGatherOffset 		equ 0x098FB068
TrueRawOffset			equ 0x088F2B10
LaoShanLungOffset		equ 0x0990E3A4
MapScaleOffset			equ 0x0881D7D0
SnSDebuffOffset			equ 0x098D9B70
KCatSkillsOffset		equ 0x098DAA34
GCatSkillsOffset		equ 0x09931F88
DrinkBuffOffset			equ 0x09908FCC
SupplyChestDelayOffset	equ 0x0882D2B0
FOVOffset0				equ 0x08816038
FOVOffset1				equ 0x088161D4
FOVOffset2				equ 0x088162E8
FOVOffset3				equ 0x0886B50C
FOVOffset4				equ 0x0886DA9C
CameraPosOffset			equ 0x08816218
TreshiOffset			equ 0x09909E6C
MACAddrOffset			equ 0x09858D30

.open "build/ULES00318/EBOOT.BIN", 0x0880326C
	; Game Init Hook
	.org 0x08844D10
		jal			ReadConfigToMem
		nop

	; Main Hook
	.org 0x08845068
		jal 		0x088C2140
		
	.org 0x08844F0C
		jal			FileLoaderSetIndex
		
	; Quest Completion Time Hooks	
	.org 0x0885AF4C
		jal			StoreTime
		nop
	.org 0x08862440
		jal			DrawQuestTime
		move		a0, s1
	.org 0x08865168
		jal			DrawQuestTime
		move		a0, s2
	
	; Main	
	.org 0x088C2140
		addiu		sp, sp, -0x4
		sw			ra, 0x00(sp)
		la			t0, DEST
		; Check ID
		lw			t1, 0x4(t0)
		lw			t2, 0x8(t0)
		beq			t1, t2, Init
		nop
		sw			v0, 0x0(t0)
		sw			t1, 0x8(t0)
		
	Init:
		jal 		sceKDWIA
		nop
		
		jal			HallSelectR
		nop	
	
		; Set MAC Address
		la			a0, MACAddrOffset
		lw			t0, 0x0(a0)
		beq			t0, zero, EndSetMACAddr
		nop
		jal			sceWlanGetEtherAddr
		nop
	EndSetMACAddr:
	
	ReadConfig:
		; Check config flags
		la			v0, CONFIG_BIN
		jal			HoldToGather
		lb			a0, 0x10(v0)
		jal			LaoShanLung
		lb			a0, 0x12(v0)
		jal			SnSDebuff
		lb			a0, 0x14(v0)
		jal			FileLoader
		lb			a0, 0x15(v0)
	FileLoaderReturn:
		la			v0, CONFIG_BIN
		jal			CatSkills
		lb			a0, 0x16(v0)
		jal			DrinkBuff
		lb			a0, 0x17(v0)
		jal			DosBonus
		lb			a0, 0x18(v0)
	DosBonusReturn:
		la			v0, CONFIG_BIN
		jal			Treshi
		lb			a0, 0x1C(v0)
		j			HookReturn
		nop
		
	HoldToGather:
		beq			a0, zero, Return
		nop
		la			t0, HoldToGatherOffset
		li			t1, 0x04A4
		lhu			t2, 0x0(t0)
		bne			t2, t1, Return
		nop
		li			t1, 0x04A0
		sh			t1, 0x0(t0)
		j			Return
		nop	
		
	TrueRaw:
		beq			a0, zero, Return
		nop
		la			t0, TrueRawOffset
		li			t1, 0x64
		li			t2, 0x6
		sw			t1, 0x0(t0)
		addiu		t0, t0, 0x4
		bne			t2, zero, . - 0x8
		addiu		t2, t2, -0x1
		j			Return
		nop
		
	LaoShanLung:
		beq			a0, zero, Return
		nop
		la			t0, LaoShanLungOffset
		li			t1, 0x284103E8
		lw			t2, 0x0(t0)
		bne			t2, t1, Return
		nop
		sw			zero, 0x0(t0)
		sw			zero, 0x4(t0)
		sw			zero, 0x8(t0)
		sw			zero, 0xC(t0)
		j			Return
		nop
		
	MapScale:
		li			t0, 0x32
		blt 		a0, t0, Return
		nop
		li			t0, 0x64
		bgt			a0, t0, Return
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
		
		j			Return
		nop
		
		SnSDebuff:
		beq			a0, zero, Return
		nop
		la			t0, SnSDebuffOffset
		lui			t1, 0x2402
		ori			t1, 0x0096
		lw			t2, 0x0(t0)
		bne			t2, t1, Return
		nop
		li			t1, 0x78
		sb			t1, 0x0(t0)
		j			Return
		nop
		
	FileLoader:
		beq			a0, zero, Return
		nop
		; Check chunk position
		lui			t0, 0x2
		beq			t0, s1, Return
		nop
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
		
	CatSkills:
		beq			a0, zero, Return
		nop	
		la			t0, KCatSkillsOffset
		lw			a0, -0x4(t0)
		li			a1, 0x94462EB2
		bne			a0, a1, Return
		nop
		la			a0, ShowKCatSkills
		srl			a0, a0, 0x2
		lui			a1, 0x0800
		addu		a0, a1, a0
		sw			a0, 0x0(t0)
		li			a0, 0x0
		sw			a0, 0x4(t0)
		
		la			t0, GCatSkillsOffset
		la			a0, ShowGCatSkills
		srl			a0, a0, 0x2
		lui			a1, 0x0800
		addu		a0, a1, a0
		sw			a0, 0x0(t0)
		li			a0, 0x0
		sw			a0, 0x4(t0)
		j			Return
		nop		
		
	DrinkBuff:
		beq			a0, zero, Return
		nop	
		la			t0, DrinkBuffOffset
		lw			a0, -0x4(t0)
		li			a1, 0x00003821
		bne			a0, a1, Return
		nop
		la			a0, GHDrinkCheck
		srl			a0, a0, 0x2
		lui			a1, 0x0800
		addu		a0, a1, a0
		sw			a0, 0x0(t0)
		li			a0, 0x8FBF000C ; lw ra, 0xC(sp)
		sw			a0, 0x4(t0)
		j			Return
		nop
		
	SupplyChestDelay:
		beq			a0, zero, Return
		nop
		la			t0, SupplyChestDelayOffset
		li			t1, 0x1E
		lb			t2, 0x0(t0)
		bne			t1, t2, SupplyChestDelayReturn
		nop
		li			t1, 0x1
		sb			t1, 0x0(t0)
	SupplyChestDelayReturn:
		j			Return
		nop
		
	FOV:
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
		j			Return
		nop
		
	CameraPos:
		la			t0, CameraPosOffset
		lui			t1, 0x2403
		or			t1, t1, a0
		sw			t1, 0x0(t0)
		j			Return
		nop
		
	Treshi:
		la			t0, TreshiOffset
		li			t1, 0x14400005
		lw			t2, 0x0(t0)
		bne			t2, t1, Return
		nop
		beq			a0, zero, Return
		nop
		li			t1, 0x1000
		sh			t1, 0x2(t0)
		j			Return
		nop
	
	Return:
		jr			ra
		nop
		
	HookReturn:
		lw			ra, 0x0(sp)
		addiu		sp, sp, 4
		jr			ra
		nop
		
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
		jal			HoldToGather
		lb			a0, 0x10(v0)
		jal			TrueRaw
		lb			a0, 0x11(v0)
		jal			MapScale
		lb			a0, 0x13(v0)
		jal			SupplyChestDelay
		lb			a0, 0x19(v0)
		jal			FOV
		lb			a0, 0x1A(v0)
		jal			CameraPos
		lb			a0, 0x1B(v0)
		
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
	
	CONFIG_PATH:
		.ascii "ms0:/PSP/SAVEDATA/FDXDAT/CONFIG.BIN"
		.align 0x4
	CONFIG_BIN:
		.fill 0x30, 0x00
		
	.include "source/ULES00318/QuestTime.asm"		
	.include "source/ULES00318/HallSelectFix.asm"	
	.include "source/ULES00318/CatSkills.asm"	
	.include "source/ULES00318/DrinkBuff.asm"
	.include "source/ULES00318/DosBonuses.asm"
	.include "source/ULES00318/FileLoader.asm"	
	.include "source/ULES00318/EventLoader.asm"
		
	.org HallSelectWHook
		j			HallSelectW
		nop
.close

.open "build/ULES00318/DATA.BIN", 0
	.org 0x1a870ac4
		.word 0x24460002
	.org 0x1a8b54a8
		.word 0x00280198
	.org 0x1a8b54c0
		.word 0x00100100
	.org 0x1a8b54cc
		.word 0x00080110
	.org 0x1a8b54d8
		.word 0x00090118
	.org 0x1a8b54e4
		.word 0x00190118
	.org 0x1a8b54f0
		.word 0x00190198
	.org 0x1a8b54fc
		.word 0x00C40118
	.org 0x1a8b5508
		.word 0x00200100
	.org 0x1a8b5514
		.word 0x00180110
	.org 0x1a8b5520
		.word 0x00190118
	.org 0x1a8b552c
		.word 0x00290118
	.org 0x1a8b5538
		.word 0x00290198
	.org 0x1a8b5544
		.word 0x008C0118

	.org 0x1a8746e4
		jal		EventMenu
		nop

	.org 0x1a871410
		j		EventLoader
		nop
		
	; Input Drop Fix	
	.org 0x1A8C4AB4
		.word 0x1060000C
		
	; Forest and Hills Area 9 Camera Fix	
	.org 0x20A91098
		.word 0x43F50000
	.org 0x20A910B8
		.word 0x43F50000	
	.org 0x20A910D8
		.word 0x43E10000
		
	; Remember Hall Cursor Position	
	.org RestoreHallOffset
		jal		RestoreHall
		
	.org StoreHallOffset
		jal		StoreHall
		nop
		
	; Dengeki Ticket	
	.org 0x12C4B03A
		.ascii "DengekiTck", 0
		
	; "The Desert Plesioth" Supplies Fix
	.org 0x1DAAD774
		.word 0x00010016
		.word 0x00010016
		.word 0x00010016
		.word 0x00010016
.close