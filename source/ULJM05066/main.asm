.psp

sceIoOpen				equ	0x088AF800
sceIoLseek				equ	0x088AF7C8
sceIoRead				equ	0x088AF7B0
sceIoClose				equ	0x088AF7F8
sceKDWIA				equ	0x088AF9F8 ; sceKernelDcacheWritebackInvalidateAll
sceWlanGetEtherAddr		equ 0x088B0008

FONT					equ 0x0982AC80
drawText				equ 0x08871920
drawShadowedText		equ 0x08871B9C

HoldToGatherOffset 		equ 0x098F9988
TrueRawOffset			equ 0x088F1490
LaoShanLungOffset		equ 0x0990CCBC
MapScaleOffset			equ 0x0881D54C
SnSDebuffOffset			equ 0x098D84C0
KCatSkillsOffset		equ 0x098D92AC
GCatSkillsOffset		equ 0x099308C0
SupplyChestDelayOffset	equ 0x0882CFA4
FOVOffset0				equ 0x08816038
FOVOffset1				equ 0x088161D4
FOVOffset2				equ 0x088162E8
FOVOffset3				equ 0x0886AC1C
FOVOffset4				equ 0x0886D1AC
CameraPosOffset			equ 0x08816218
TreshiOffset			equ 0x09908624
MACAddrOffset			equ 0x09857730
YianGarugaSavedHPOffset equ 0x0985773C

.open "build/ULJM05066/EBOOT.BIN", 0x0880326C
	; Game Init Hook
	.org 0x088444C4
		jal			ReadConfigToMem
		nop

	; Main Hook
	.org 0x0884481C
		jal 		0x088C0CA0

	; F1 Quest Fix	
	.org 0x08911E2E
		.byte	0x30, 0x13
	
	; Quest Completion Time Hooks	
	.org 0x0885A484
		jal			StoreTime
		nop
	.org 0x088619D0
		jal			DrawQuestTime
		move		a0, s1
	.org 0x088646F8
		jal			DrawQuestTime
		move		a0, s2
		
	; Sharpness Colors	
	.org 0x0881A9A8
		andi		v0, v0, 0x3F
	.org 0x088EFC38
		.word 0xFF3A0FC5
		.word 0xFF1852E8
		.word 0xFF32C8F3
		.word 0xFF00D35E
		.word 0xFFEE6830
		.word 0xFFF0F0F0
		
	; Clock face and HP/Stam fixes
	.org 0x088EF240 ; Clock face X/Y pos
		.dh   0x8
		.dh   0x6
	.org 0x088EF24C ; Clock hand group X/Y pos
		.dh   0x22
		.dh   0x1E
	.org 0x088EF254 ; HP bar X/Y pos
		.dh   0x39
		.dh   0xC
	.org 0x088EF260 ; Stam bar X/Y pos
		.dh   0x39
		.dh   0x15
		
	; Ammo fixes
	.org 0x088EF2D4 ; Ammo X/Y pos 
		.dh   0x3C
		.dh   0x1E
		
	; Heavy Bowgun Icon Fix
	.org 0x088F16FA
		.dh   0x172
	.org 0x088F144C
		.dw   0x00B000B0
		.dw   0x0010000C
		.dw	  0x000B8000
		
	; Dual Blades Icon Fix
	.org 0x088F1704
		.dh   0x192
	.org 0x088F15CC
		.dw   0x00C0003C
		.dw   0x0010000C
		.dw	  0x000B8000
		
	; Gabas DB Fix	
	.org 0x088FEDD4
		.dw   0x000000A0
		.dw	  0x00000000
		.dw   0x002B2200
		
	; Lao-Shan Timer
	.org 0x0885A4E0
		j			LaoShanTimer
		nop
		
	; Main	
	.org 0x088C0CA0
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
		
		; Yian Garuga Glitch
		la			t0, YianGarugaSavedHPOffset
		lh			t1, 0x0(t0)
		andi		t1, t1, 0xFFFF
		li			t2, 0xF000
		ble			t1, t2, EndYianGarugaGlitch
		nop
		li			t1, 0x1
		sh			t1, 0x0(t0)
		
	EndYianGarugaGlitch:
			
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
		
	CatSkills:
		beq			a0, zero, Return
		nop	
		la			t0, KCatSkillsOffset
		lw			a0, -0x4(t0)
		li			a1, 0x944717E4
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
		.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
		.byte 0x00, 0x00, 0x00, 0x64, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x5F, 0x03, 0x00, 0x00, 0x00, 0x00
		.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	
	.include "source/ULJM05066/LaoShanTimer.asm"
	.include "source/ULJM05066/QuestTime.asm"
	.include "source/ULJM05066/FixF1Quests.asm"
	.include "source/ULJM05066/HallSelectFix.asm"		
	.include "source/ULJM05066/CatSkills.asm"
	.include "source/ULJM05066/DrinkBuff.asm"	
	.include "source/ULJM05066/DosBonuses.asm"
	.include "source/ULJM05066/FileLoader.asm"
	.include "source/ULJM05066/EventLoader.asm"
		
	.org HallSelectWHook
		j			HallSelectW
		nop
.close

.open "build/ULJM05066/DATA.BIN", 0
	.org 0x1A6AA0F8
		j			EventLoader
		nop
		
	; Input Drop Fix
	.org 0x1A6FD9CC
		.word 0x1060000C
		
	; Drink Buff
	.org 0x1A6C3084
		j			GHDrinkCheck
		lw			ra, 0xC(sp)
		
	; Forest and Hills Area 9 Camera Fix	
	.org 0x206DC098
		.word 0x43F50000
	.org 0x206DC0B8
		.word 0x43F50000	
	.org 0x206DC0D8
		.word 0x43E10000	
		
	; Remember Hall Cursor Position	
	.org RestoreHallOffset
		jal			RestoreHall
		
	.org StoreHallOffset
		jal			StoreHall
		nop
	
	; Fix F1 Exclusive Quests
	.org FixF1QuestsHook
		jal			CheckLoadedQuest
		nop
		
	; Treshi dummy
	.org 0x1DD936BB
		.ascii "...", 0
		.byte 0x00, 0x00, 0x00
		
	; "The Desert Plesioth" Supplies Fix
	.org 0x1D81CA98
		.word 0x00010016
		.word 0x00010016
		.word 0x00010016
		.word 0x00010016
.close