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
	.org 0x098EFDBC
		li			a1, 0x2

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