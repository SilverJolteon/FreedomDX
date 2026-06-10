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

TreshiOffset			equ 0x09909E6C
MACAddrOffset			equ 0x09858D30
TaskOffset				equ 0x098D5D20

.open "build/ULES00318/EBOOT.BIN", 0x0880326C
	; Game Init Hook
	.org 0x08844D10
		jal			ReadConfigToMem
		nop

	; Main Hook
	.org 0x08845068
		jal 		0x088C2140
		
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
	
	; Multiplayer Crossplay
	.org 0x0891A0E0
		.ascii		"ULJM05066", 0 
		
	; Sharpness Colors	
	.org 0x0881AB78
		andi		v0, v0, 0x3F
	.org 0x088F12B8
		.word 0xFF3A0FC5
		.word 0xFF1852E8
		.word 0xFF32C8F3
		.word 0xFF00D35E
		.word 0xFFEE6830
		.word 0xFFF0F0F0
		
	; Clock face and HP/Stam fixes
	.org 0x088F08A0 ; Clock face X/Y pos
		.dh   0x8
		.dh   0x6
	.org 0x088F08AC ; Clock hand group X/Y pos
		.dh   0x22
		.dh   0x1E
	.org 0x088F08B4 ; HP bar X/Y pos
		.dh   0x39
		.dh   0xC
	.org 0x088F08C0 ; Stam bar X/Y pos
		.dh   0x39
		.dh   0x15
		
	; Ammo fixes
	.org 0x088F0934 ; Ammo X/Y pos 
		.dh   0x3C
		.dh   0x1E
		
	; Heavy Bowgun Icon Fix
	.org 0x088F2D7A
		.dh   0x88
	.org 0x088F1FD4
		.dw   0x00B000B0
		.dw   0x0010000C
		.dw	  0x000B8000
	
	; Light Bowgun Icon Fix	
	.org 0x088F2D82
		.dh   0x172
	.org 0x088F2ACC
		.dw   0x00C00018
		.dw   0x0010000C
		.dw	  0x000B8000
		
	; Dual Blades Icon Fix
	.org 0x088F2D84
		.dh   0x192
	.org 0x088F2C4C
		.dw   0x00C0003C
		.dw   0x0010000C
		.dw	  0x000B8000
		
	; Display Monster Info
	.org 0x088228C0
		li    v0, 0x1
		nop
	.org 0x08823290
		jal	  CheckMonsterLength
		nop
	.org 0x08823330
		jal	  CheckCrownSize
		nop
		
	; MHG Gabas
	;.org 0x08900440
	;	.dw   0x000000A0
	;	.dw	  0x00000000
	;	.dh   0x00002200
		
	; MHG Black Ruiner Lance
	;.org 0x089008B4
	;	.dw   0x000400FA
	;	.dw   0x002B0000
	;	.dh   0x00000000
		
	; Lao-Shan Timer
	.org 0x0885AFA8
		j			LaoShanTimer
		nop
		
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

	.include "source/ULES00318/Init.asm"
	.include "source/ULES00318/DisplayMonsterInfo.asm"
	.include "source/ULES00318/CarveTimer.asm"			
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
	; Title Screen Version
	.org 0x1A7FF6F8
		jal			TitleScreenVersion
		nop
		
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
		jal			EventMenu
		nop

	.org 0x1a871410
		j			EventLoader
		nop
		
	; Quest Related Init	
	.org 0x1A8BDB00 ; 0x098D6000
		jal			QuestInit
		nop	
	
	; Input Drop Fix	
	.org 0x1A8C4AB4
		.word 0x1060000C
		
	; Drink Buff
	.org 0x1A88A2CC
		j			GHDrinkCheck
		lw			ra, 0xC(sp)
		
	; Visible Felyne Skills
	.org 0x1A85BD34
		j			ShowKCatSkills
		nop		
	.org 0x1A8B3288
		j			ShowGCatSkills
		nop		
		
	; Wandering Chef Generation
	.org 0x1A8B1CF0
		jal			GenerateBarrelCat
		nop
	.org 0x1A8B1CFC
		nop
	.org 0x1A8B1D58
		slti		v1, s2, 0x6
		
	; Forest and Hills Area 9 Camera Fix	
	.org 0x20A91098
		.word 0x43F50000
	.org 0x20A910B8
		.word 0x43F50000	
	.org 0x20A910D8
		.word 0x43E10000
		
	; Remember Hall Cursor Position	
	.org RestoreHallOffset
		jal			RestoreHall
		
	.org StoreHallOffset
		jal			StoreHall
		nop
		
	; Dengeki Ticket
	.org 0x12C4B03A
	.area 11, 0
		.asciiz "DengekiTkt"
	.endarea
		
	; Treshi dummy
	.org 0x1E0A90F4 ; EN
	.area 6, 0
		.asciiz "..."
	.endarea
	.org 0x1E0B311F ; FR
	.area 8, 0
		.asciiz "..."
	.endarea
	.org 0x1E0BD4D2 ; DE
	.area 9, 0
		.asciiz "..."
	.endarea
	.org 0x1E0C712D ; IT
	.area 11, 0
		.asciiz "..."
	.endarea
	.org 0x1E0D083E ; ES
	.area 6, 0
		.asciiz "..."
	.endarea

	; Quest info capitalize zone
	.org 0x12C41E49
	.area 6, 0
		.asciiz "Zone:"
	.endarea
	
	; Changed Muscot to Muscat
	.org 0x1D92C1D4
	.area 7, 0
		.asciiz "Muscat"
	.endarea
		
	; "The Desert Plesioth" Supplies Fix
	.org 0x1DAAD774
		.word 0x00010016
		.word 0x00010016
		.word 0x00010016
		.word 0x00010016
.close