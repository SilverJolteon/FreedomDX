.psp

strcpy      equ 0x088112E8

.open "build/ULJM05066/lobby_task.bin", 0x098D4700
	; 4959 memsize
	.org 0x98E86E8
		lui			a2, 0x2
	
	; 4673 memsize	
	.org 0x98E87E4
		ori			a2, v0, 0xD800
	
	; Monster Log N/3 'N' Position	
	.org 0x098DE548
		li			a1, 0x73
	
	; Guild Card English Keyboard	
	.org 0x098DA47C
		li			a1, 0x2
		
	; Fix guildcard intro text width and position	
	.org 0x098DCBD8 
		andi		v1, s1, 0x1F
	.org 0x098DCBF0 
		sllv		v0, v0, zero
	.org 0x098DCC00
		sra			v0, s1, 0x5

	; Recruiting Note English Keyboard	
	.org 0x098EFDAC
		move		s1, a1
		li			a1, 0x2
		beq			v1, a1, 0x098EFE30
		move		s0, a0
		li			t2, 0x1
		beq			v1, t2, 0x098EFE08
		
	; Guild Card :Times Hunted Position
	.org 0x098DD68C
		li			a1, 0x57
		
	; Guild Card Received Menu
	.org 0x098DBB64 ; Name
		li			a2, 0x68 
	.org 0x098DBBB8 ; Received Guild Card from
		li			a2, 0x58
		
	; Unable to send guild card
	.org 0x098DF608
		li			a2, 0x80
	.org 0x098DF65C
		li			a2, 0x70
	.org 0x098DF670
		li			a1, 0x90
	
	; "Press the ○ button" Position	
	.org 0x098DBDF8
		li			a1, 0xAE
	.org 0x098DF678
		li			a0, 0xAE
	.org 0x098DA084
		li			a0, 0xAE
		
	; Quest Board Positioning
	.org 0x098F25D0 ; Navigation Rectangle
		li			v0, 0x80
	.org 0x098F25E8
		li			a3, 0x38
	.org 0x098F262C ; Navigation Arrows
		li			a3, 0x3C
	.org 0x09932DC0 ; Reward
		.dh 0x15C
	.org 0x09932EC4 ; Contract Fee
		.dh 0x15C
	.org 0x09932FC8 ; Time Limit
		.dh 0x15C
	.org 0x099330CC ; Location
		.dh 0x15C
	
	; Quest Board Positioning (Joining)
	.org 0x09933F08 ; Players
		.dh 0x19A
	.org 0x09934214 ; Reward
		.dh 0x15C
	.org 0x09934318 ; Contract Fee
		.dh 0x15C
	.org 0x0993441C ; Time Limit
		.dh 0x15C
	.org 0x09934520 ; Location
		.dh 0x15C
		
		
	.org 0x0993939A ; Equipment Sets Resistances
		.dh 0x48

  ; ----------------------------
  ; Full-width text fixes (SJIS)
  ; ----------------------------
  ; Quest details (at quest giver)
  .org 0x98EE238 ; Time Limit
    addiu   a1,sp,0xA0
  
  .org 0x098E9160 ; Reward/Contract
    lw      a1,0x10(a0)
    move    a0,s1
    jal     strcpy
    nop
    b       0x098E91A0
    nop
.close