SLOT_1			equ	0x09509FE0
SLOT_SIZE		equ	0x6800

SLTI_V0_S3		equ	0x098EEFF4
SLTI_V0_S1		equ 0x098F01AC

RETURN_VALID	equ	0x098F0124
RETURN_INVALID	equ 0x098F0118

drawTexture		equ 0x088318E4
CURSOR_POS		equ 0x09942100
FONT			equ 0x0982C280
drawText		equ 0x08872660
EVENT_TXT_EN	equ 0x094CD33A
EVENT_TXT_FR	equ 0x094CD7AD
EVENT_TXT_DE	equ 0x094CD6E0
EVENT_TXT_ES	equ 0x094CD72C
EVENT_TXT_IT	equ 0x094CD533

	EventLoader:
		; Backup registers v0 and s0
		addiu	sp, sp, -8
		sw		s0, 0x4(sp)
		sw		v0, 0x0(sp)
		; Open quests file
		la		a0, QUESTS_BIN
		li		a1, 0x1
		li		a2, 0x0
		li		a3, 0x0
		jal		sceIoOpen
		li		t0, 0x0
		; Check if file exists
		li		v1, 0x80010002
		beq		v0, v1, NoFile ; Return - no event quests found
		nop
		li 		v1, 0x0
		move	s0, v0	
		; Get number of pages
		move 	a0, s0
		li		a1, 0x0
		li		a2, 0x0
		li		a3, 0x0
		jal		sceIoLseek ; Get file size
		li		t0, 0x2
		beq		v0, zero, NoFile ; Return - empty file 
		li		a0, 0x6800
		div		v0, a0
		mflo	a0 ; Page num
		li		t0, 0x2A620000
		addu	t0, t0, a0
		sw		t0, SLTI_V0_S3 ; slti v0,s3,pages
		li		t0, 0x2A220000
		addu	t0, t0, a0
		sw		t0, SLTI_V0_S1 ; slti v0,s1,pages
		; Correct offset to load quest
		lw		a2, 0x0(sp)
		li		t0, SLOT_1
		sub	a2, a2, t0
		li		t0, 0x6810
		div	a2, t0
		mflo	a2
		li		t0, 0x6800
		mult	a2, t0
		mflo	a2
		; Seek to offset in file
		move 	a0, s0
		li		a1, 0x0
		li		a3, 0x0
		jal		sceIoLseek
		li		t0, 0x0
		; Read from offset into quest slot
		move	a0, s0
		li		a1, SLOT_1
		jal		sceIoRead
		li		a2, SLOT_SIZE
		; Close quests file
		jal		sceIoClose
		move 	a0, s0
		jal		sceKDWIA
		nop
		; Restore registers backup and return
		jal		Restore
		nop
		j		RETURN_VALID ; Jump back
		sw		v0, 0x7C(s0)
		
		Restore:
			; Restore s0 and set v0 to Quest Slot 1
			li		v0, SLOT_1
			lw		s0, 0x4(sp)
			addiu	sp, sp, 8
			jr		ra
			nop
		
		NoFile:
			jal		Restore
			nop
			j		RETURN_INVALID;
			nop
			
		EventMenu:
			addiu	sp, sp, -20
			sw		t0, 0x10(sp)
			sw		v0, 0xC(sp)
			sw		t2, 0x8(sp)
			sw		a0, 0x4(sp)
			sw		ra, 0x0(sp)
			jal		drawTexture
			andi	a2,v0,0xFFFF
			li		at, 0x1
			lw		v0, 0xC(sp)
			addi	v0, v0, 0x24
			li		v1, 0xD8	
					
			; Check cursor pos
			lw		t7, CURSOR_POS
			add		t7, t7, v0
			li		t0, 0x600E0
			beq		t7, t0, lr_menu
			li		t0, 0x400A8
			beq		t7, t0, gr_menu
			nop
			li		t7, 0x110
			j		endif
			nop

		lr_menu:
			li		t7, 0x108
			li		s1, 0x6
			j		endif
			nop

		gr_menu:
			li		t7, 0x108
			li		s1, 0x4
			j		endif
			nop
		
		endif:
			li		t0, 0xF8
			beq		v0, t0, EventReturn
		
			; Get Language
			li		t0, EVENT_TXT_EN
			lwr		t1, 0x0(t0)
			lwl		t1, 0x3(t0)
			li		t0, 0x6E657645
			
			beq		t0, t1, LANG_EN
			
			li		t0, 0x756F7620
			beq		t0, t1, LANG_FR
			
			li		t0, 0x6544002E
			beq		t0, t1, LANG_DE
			
			li		t0, 0x6520616E
			beq		t0, t1, LANG_ES
			
			li		t0, 0x7453003A
			beq		t0, t1, LANG_IT
			
		LANG_EN:
			li		t1, EVENT_TXT_EN
			j		endlang
			addi	a1, t7, 0x38
		
		LANG_FR:
			li		t1, EVENT_TXT_FR
			j		endlang
			addi	a1, t7, 0x28
		
		LANG_DE:
			li		t1, EVENT_TXT_DE
			j		endlang
			addi	a1, t7, 0x38	
			
		LANG_ES:
			li		t1, EVENT_TXT_ES
			j		endlang
			addi	a1, t7, 0x24	
		
		LANG_IT:
			li		t1, EVENT_TXT_IT
			j		endlang
			addi	a1, t7, 0x28	
			
		endlang:
		
			; Draw Text
			li		a0, FONT
			;addi	a1, t7, 0x38 ; Text X Coordinate
			addi	a2, v0, 0x8 ; Text Y Coordinate
			li		t0, 0x05 ; Color
			;li		t1, EVENT_TXT_FR
			jal		drawText
			li		a3, 0x1		
			lw		v0, 0xC(sp)
			addi	v0, v0, 0x24
			li		v1, 0xD8
			lw		a0, 0x4(sp)
		
			; Draw Event Quest Menu
			move	a1, t7
			li		a3, 0xC8
			li		t0, 0x20
			li		t1, 0xAE		
			jal		drawTexture
			andi	a2,v0,0xFFFF

		EventReturn:
			lw		ra, 0x0(sp)
			lw		v0, 0xC(sp)
			lw		t0, 0x10(sp)
			addiu	sp, sp, 20
			jr		ra
			nop
		
			QUESTS_BIN:
				.ascii "ms0:/PSP/SAVEDATA/ULES00318QST/MHPSP.bin"
				.align 0x4