.psp

sceIoOpen				equ	0x088B0004
sceIoLseek				equ	0x088B000C
sceIoRead				equ	0x088AFFD4
sceIoClose				equ	0x088AFFEC
sceKDWIA				equ	0x088B01F4 ; sceKernelDcacheWritebackInvalidateAll
sceWlanGetEtherAddr		equ 0x088B081C

FONT					equ 0x0982B500
drawText				equ 0x08871B50
drawShadowedText		equ 0x08871DCC

HoldToGatherOffset 		equ 0x098FA270
TrueRawOffset			equ 0x088F1D1C
LaoShanLungOffset		equ 0x0990D5A4
MapScaleOffset			equ 0x0881D600
SnSDebuffOffset			equ 0x098D8DB0
KCatSkillsOffset		equ 0x098D9B2C
GCatSkillsOffset		equ 0x09931080
SupplyChestDelayOffset	equ 0x0882CF04
FOVOffset0				equ 0x08816038
FOVOffset1				equ 0x088161D4
FOVOffset2				equ 0x088162E8
FOVOffset3				equ 0x0886AD48
FOVOffset4				equ 0x0886D2D8
CameraPosOffset			equ 0x08816218
TreshiOffset			equ 0x09908E8C
MACAddrOffset			equ 0x09857FB0
YianGarugaSavedHPOffset equ 0x09857FBC

.open "build/ULUS10084/EBOOT.BIN", 0x0880326C
	; Game Init Hook
	.org 0x08844830
		jal			ReadConfigToMem
		nop

	; Main Hook
	.org 0x08844B88
		jal 		0x088C1510

	; Quest Completion Time Hooks	
	.org 0x0885A788
		jal			StoreTime
		nop	
	.org 0x08861C7C
		jal			DrawQuestTime
		move		a0, s1
	.org 0x088649A4
		jal			DrawQuestTime
		move		a0, s2
	
	; Sharpness Colors	
	.org 0x0881A9A8
		andi		v0, v0, 0x3F
	.org 0x088F04C4
		.word 0xFF3A0FC5
		.word 0xFF1852E8
		.word 0xFF32C8F3
		.word 0xFF00D35E
		.word 0xFFEE6830
		.word 0xFFF0F0F0
		
	; Clock face and HP/Stam fixes
	.org 0x088EFAC0 ; Clock face X/Y pos
		.dh   0x8
		.dh   0x6
	.org 0x088EFACC ; Clock hand group X/Y pos
		.dh   0x22
		.dh   0x1E
	.org 0x088EFAD4 ; HP bar X/Y pos
		.dh   0x39
		.dh   0xC
	.org 0x088EFAE0 ; Stam bar X/Y pos
		.dh   0x39
		.dh   0x15
		
	; Ammo fixes
	.org 0x088EFB54 ; Ammo X/Y pos 
		.dh   0x3C
		.dh   0x1E
		
	; Heavy Bowgun Icon Fix
	.org 0x088F1F86
		.dh   0x172
	.org 0x088F1CD8
		.dw   0x00B000B0
		.dw   0x0010000C
		.dw	  0x000B8000
		
	; Dual Blades Icon Fix
	.org 0x088F1F90
		.dh   0x192
	.org 0x088F1E58
		.dw   0x00C0003C
		.dw   0x0010000C
		.dw	  0x000B8000
		
	; MHG Gabas
	;.org 0x088FF658
	;	.dw   0x000000A0
	;	.dw	  0x00000000
	;	.dh   0x00002200
		
	; MHG Black Ruiner Lance
	;.org 0x088FFACC
	;	.dw   0x000400FA
	;	.dw   0x002B0000
	;	.dh   0x00000000		
	
	; Lao-Shan Timer
	.org 0x0885A7E4
		j			LaoShanTimer
		nop
		
	; Main	
	.org 0x088C1510
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
		
	CatSkills:
		beq			a0, zero, Return
		nop	
		la			t0, KCatSkillsOffset
		lw			a0, -0x4(t0)
		li			a1, 0x94471F24
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
		lw			ra, 0x00(sp)
		addiu		sp, sp, 0x4
		jr			ra
		nop
	
	CONFIG_PATH:
		.ascii "ms0:/PSP/SAVEDATA/FDXDAT/CONFIG.BIN"
		.align 0x4
	CONFIG_BIN:
		.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
		.byte 0x00, 0x00, 0x00, 0x64, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x5F, 0x03, 0x00, 0x00, 0x00, 0x00
		.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

	.include "source/ULUS10084/Init.asm"
	.include "source/ULUS10084/LaoShanTimer.asm"	
	.include "source/ULUS10084/QuestTime.asm"	
	.include "source/ULUS10084/HallSelectFix.asm"	
	.include "source/ULUS10084/CatSkills.asm"	
	.include "source/ULUS10084/DrinkBuff.asm"	
	.include "source/ULUS10084/DosBonuses.asm"	
	.include "source/ULUS10084/FileLoader.asm"			
	.include "source/ULUS10084/EventLoader.asm"		
			
	.org HallSelectWHook
		j			HallSelectW
		nop
.close

.open "build/ULUS10084/DATA.BIN", 0
	.org 0x1A244074
		.word 0x24460002
	.org 0x1A288A50
		.word 0x00280198
	.org 0x1A288A68
		.word 0x00100100
	.org 0x1A288A74
		.word 0x00080110
	.org 0x1A288A80
		.word 0x00090118
	.org 0x1A288A8C
		.word 0x00190118
	.org 0x1A288A98
		.word 0x00190198
	.org 0x1A288AA4
		.word 0x00C40118
	.org 0x1A288AB0
		.word 0x00200100
	.org 0x1A288ABC
		.word 0x00180110
	.org 0x1A288AC8
		.word 0x00190118
	.org 0x1A288AD4
		.word 0x00290118
	.org 0x1A288AE0
		.word 0x00290198
	.org 0x1A288AEC
		.word 0x008C0118
		
	.org 0x1A247C94
		jal			EventMenu
		nop

	.org 0x1A2449C0
		j			EventLoader
		nop
		
	; Quest Related Init	
	.org 0x1A290AF4 ; 0x098D5274
		jal			QuestInit
		nop	
	
	; Input Drop Fix	
	.org 0x1A297A3C
		.word 0x1060000C
		
	; Drink Buff
	.org 0x1A25D86C
		j			GHDrinkCheck
		lw			ra, 0xC(sp)
		
	; Forest and Hills Area 9 Camera Fix
	.org 0x2028E098
		.word 0x43F50000
	.org 0x2028E0B8
		.word 0x43F50000	
	.org 0x2028E0D8
		.word 0x43E10000	
		
	; Remember Hall Cursor Position	
	.org RestoreHallOffset
		jal			RestoreHall
		
	.org StoreHallOffset
		jal			StoreHall
		nop
		
	; Dengeki Ticket	
	.org 0x12C4AF25
		.ascii "DengekiTkt", 0
		
	; Treshi dummy
	.org 0x1D9408EF
		.ascii "...", 0
		.byte 0x00, 0x00, 0x00
		
	; Quest info capitalize zone
	.org 0x12C41E3C
		.ascii "Zone:", 0
		
	; "The Desert Plesioth" Supplies Fix
	.org 0x1D3C2A94
		.word 0x00010016
		.word 0x00010016
		.word 0x00010016
		.word 0x00010016
.close