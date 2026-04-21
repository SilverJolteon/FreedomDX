.psp

strcpy      equ 0x088112E8

.open "build/ULJM05066/lobby_task.bin", 0x098D4700
	.org 0x98E86E8 ; 4959 memsize
		lui			a2, 0x2
		
	.org 0x98E87E4 ; 4673 memsize
		ori			a2, v0, 0xD800

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