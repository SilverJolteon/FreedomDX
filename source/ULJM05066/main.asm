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

TreshiOffset			equ 0x09908624
MACAddrOffset			equ 0x09857730

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
		.dh   0x88
	.org 0x088F0954
		.dw   0x00B000B0
		.dw   0x0010000C
		.dw	  0x000B8000
	
	; Light Bowgun Icon Fix	
	.org 0x088F1702
		.dh   0x172
	.org 0x088F144C
		.dw   0x00C00018
		.dw   0x0010000C
		.dw	  0x000B8000
		
	; Dual Blades Icon Fix
	.org 0x088F1704
		.dh   0x192
	.org 0x088F15CC
		.dw   0x00C0003C
		.dw   0x0010000C
		.dw	  0x000B8000
		
	; Display Monster Info
	.org 0x088225E4	
		li    v0, 0x1
		nop
	.org 0x08822FB4
		jal	  CheckMonsterLength
		nop
	.org 0x08823054
		jal	  CheckCrownSize
		nop
		
	; MHG Gabas	
	;.org 0x088FEDD4
	;	.dw   0x000000A0
	;	.dw	  0x00000000
	;	.dh   0x00002200

	; MHG Black Ruiner Lance
	;.org 0x088FF248
	;	.dw   0x000400FA
	;	.dw   0x002B0000
	;	.dh   0x00000000
		
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
		jal			FileLoader
		lb			a0, 0x15(v0)
	FileLoaderReturn:
		la			v0, CONFIG_BIN
		jal			DosBonus
		lb			a0, 0x18(v0)
	DosBonusReturn:
		la			v0, CONFIG_BIN
		jal			Treshi
		lb			a0, 0x1C(v0)
		j			HookReturn
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
	
	CONFIG_PATH:
		.ascii "ms0:/PSP/SAVEDATA/FDXDAT/CONFIG.BIN"
		.align 0x4
	CONFIG_BIN:
		.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
		.byte 0x00, 0x00, 0x00, 0x64, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x5F, 0x03, 0x00, 0x00, 0x00, 0x00
		.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	
	.include "source/ULJM05066/Init.asm"
	.include "source/ULJM05066/DisplayMonsterInfo.asm"
	.include "source/ULJM05066/CarveTimer.asm"
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
		
	; Quest Related Init	
	.org 0x1A6F6AF4 ; 0x098D49F4
		jal			QuestInit
		nop	
	
	; Input Drop Fix
	.org 0x1A6FD9CC
		.word 0x1060000C
		
	; Drink Buff
	.org 0x1A6C3084
		j			GHDrinkCheck
		lw			ra, 0xC(sp)
		
	; Visible Felyne Skills
	.org 0x1A694BAC
		j			ShowKCatSkills
		nop		
	.org 0x1A6EC1C0
		j			ShowGCatSkills
		nop		
		
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
		
	; MH Oldschool Event Quest Server
	.org 0x1A68EA50
	.area 56, 0
		.asciiz "http://psp.mholdschool.com/psp/MHPSP/DL_TOP.PHP"
	.endarea
.close