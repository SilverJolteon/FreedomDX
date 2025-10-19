.psp

sceIoOpen	equ	0x088B0004
sceIoLseek	equ	0x088B000C
sceIoRead	equ	0x088AFFD4
sceIoClose	equ	0x088AFFEC
sceKDWIA	equ	0x088B01FC ; sceKernelDcacheWritebackInvalidateAll

HoldToGatherOffset 		equ 0x098FA270
TrueRawOffset			equ 0x088F1D1C
LaoShanLungOffset		equ 0x0990D5A4
MapScaleOffset			equ 0x0881D600

.open "build/ULUS10084/EBOOT.BIN", 0x0880326C
	; Hook
	.org 0x08844B88
		jal 		0x088C0CA0

	.org 0x088C0CA0
		addiu		sp, sp, -0x4
		sw			ra, 0x00(sp)
		jal 		sceKDWIA
		nop
		
	ReadConfig:
		; Open config file
		la		a0, CONFIG_PATH
		li		a1, 0x1
		li		a2, 0x0
		li		a3, 0x0
		jal		sceIoOpen
		li		t0, 0x0
		; Check if config exists
		li		v1, 0x80010002
		beq		v0, v1, HookReturn
		nop
		li		v1, 0x0
		move	s0, v0	
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
	
	Return:
		jr			ra
		nop
		
	HookReturn:
		lw			ra, 0x00(sp)
		addiu		sp, sp, 0x4
		jr			ra
	
	CONFIG_PATH:
		.ascii "ms0:/PSP/SAVEDATA/FDXDAT/CONFIG.BIN"
		.align 0x4
	CONFIG_BIN:
		.fill 0x30, 0x00
				
	.include "source/ULUS10084/EventLoader.asm"
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
		jal		EventMenu
		nop

	.org 0x1A2449C0
		j		EventLoader
		nop
.close