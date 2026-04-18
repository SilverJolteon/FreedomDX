SLOT_1			equ 0x095079E0 ; EN
SLOT_SIZE		equ	0x6800

SLTI_V0_S3		equ	0x098ED6B4
SLTI_V0_S1		equ 0x098EE894

RETURN_VALID	equ	0x098EE80C
RETURN_INVALID	equ 0x098EE804

SP_EVENT_PAGE	equ 0x099409F8

	EventLoader:
		; Backup registers v0 and s0
		addiu	sp, sp, -8
		sw		s0, 0x4(sp)
		sw		v0, 0x0(sp)
		; Check if init
		lui		t0, 0x0800
		bgt		s1, t0, OPEN_EVENT_BIN
		nop
		j		CHECK_PAGE
		nop
		
	CHECK_PAGE:
		la		t0, SP_EVENT_PAGE
		lh		a0, 0x0(t0)
		addi	a0, a0, -0xEA61
		andi	a0, a0, 0xFFFF
		beq		a0, a1, OPEN_EVENT_BIN
		nop
		j		RESTORE_VALID
		nop		
		
	OPEN_EVENT_BIN:
		; Open quests file
		la		a0, QUESTS_BIN
		li		a1, 0x1
		jal		sceIoOpen
		li		a2, 0x0
		; Check if file exists
		li		v1, 0x80010002
		beq		v0, v1, NoFile ; Return - no event quests found
		nop
		la		a0, QUESTS_BIN_EXIST
		li		a1, 1
		sw		a1, 0x0(a0)
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
		li		t0, 0x32 ; Max 50 pages
		bge		a0, t0, clamp_pages
		nop
		j		end_clamp_pages
		nop
	clamp_pages:
		move	a0, t0
	end_clamp_pages:
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
	RESTORE_VALID:
		jal		Restore
		nop
		j		RETURN_VALID ; Jump back
		sw		v0, 0x7C(s0)
		
		Restore:
			; Restore s0 and set v0 to Quest Slot 1
			la		v0, QUESTS_BIN_EXIST
			lw		v0, 0x0(v0)
			beq		v0, zero, SET_QUEST_SLOT
			lw		v0, 0x0(sp)
			li		v0, SLOT_1
		SET_QUEST_SLOT:	
			lw		s0, 0x4(sp)
			addiu	sp, sp, 8
			jr		ra
			nop
		
		NoFile:
			li		t0, 0x2A620003
			sw		t0, SLTI_V0_S3
			li		t0, 0x2A220003
			sw		t0, SLTI_V0_S1
			la		a0, QUESTS_BIN_EXIST
			sw		zero, 0x0(a0)
			jal		Restore
			nop
			lw		v1, 0x0(v0)
			bnel	v1, zero, NoFileValid
			sw		v0, 0x7C(s0)
			j		RETURN_INVALID;
			nop
			
		NoFileValid:
			j		RETURN_VALID;
			nop
		
		QUESTS_BIN:
			.ascii "ms0:/PSP/SAVEDATA/FDXDAT/EVENT.BIN"
			.align 0x4
			
		QUESTS_BIN_EXIST:
			.word 0