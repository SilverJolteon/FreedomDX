.psp

sceIoOpen				equ	0x088AF800
sceIoLseek				equ	0x088AF7C8
sceIoRead				equ	0x088AF7B0
sceIoClose				equ	0x088AF7F8
sceKDWIA				equ	0x088AF9F8 ; sceKernelDcacheWritebackInvalidateAll

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
DrinkBuffOffset			equ 0x09907784

.open "build/ULJM05066/EBOOT.BIN", 0x0880326C
	; Hook
	.org 0x0884481C
		jal 		0x088C0CA0
		
	.org 0x088446C0
		jal			FileLoaderSetIndex

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
		
	ReadConfig:
		; Open config file
		la			a0, CONFIG_PATH
		li			a1, 0x1
		li			a2, 0x0
		li			a3, 0x0
		jal			sceIoOpen
		li			t0, 0x0
		; Check if config exists
		li			v1, 0x80010002
		beq			v0, v1, HookReturn
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
		; Check config flags
		la			v0, CONFIG_BIN
		jal			HoldToGather
		lb			a0, 0x10(v0)
		jal			TrueRaw
		lb			a0, 0x11(v0)
		jal			LaoShanLung
		lb			a0, 0x12(v0)
		jal			MapScale
		lb			a0, 0x13(v0)
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
		j			HookReturn
		nop
		
	HoldToGather:
		beq			a0, zero, DisableHoldToGather
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
		
	DisableHoldToGather:
		la			t0, HoldToGatherOffset
		li			t1, 0x04A0
		lhu			t2, 0x0(t0)
		bne			t2, t1, Return
		nop
		li			t1, 0x04A4
		sh			t1, 0x0(t0)
		j			Return
		nop
			
	TrueRaw:
		beq			a0, zero, Return
		nop
		la			t0, TrueRawOffset
		li			t1, 0x64
		li			t2, 0xA
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
	
	Return:
		jr			ra
		nop
		
	HookReturn:
		lw			ra, 0x0(sp)
		addiu		sp, sp, 4
		jr			ra
	
	CONFIG_PATH:
		.ascii "ms0:/PSP/SAVEDATA/FDXDAT/CONFIG.BIN"
		.align 0x4
	CONFIG_BIN:
		.fill 0x30, 0x00
				
	.include "source/ULJM05066/CatSkills.asm"
	.include "source/ULJM05066/DrinkBuff.asm"	
	.include "source/ULJM05066/DosBonuses.asm"
	.include "source/ULJM05066/FileLoader.asm"
	.include "source/ULJM05066/EventLoader.asm"
	
	.org 0x0882CFA4 ; Supply Chest Delay Fix
		.dh			1
.close

.open "build/ULJM05066/DATA.BIN", 0
	.org 0x1A6AA0F8
		j		EventLoader
		nop
.close