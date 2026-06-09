.psp

.open "build/ULJM05066/EBOOT.BIN", 0x0880326C
  ; ----------------------------
  ; Text positional changes
  ; ----------------------------
  .org 0x089125F4 ; Reward, Contract Fee Text Position
    .byte 0x78, 0x00, 0x70, 0x00, 0x78

  .org 0x08917D76 ; In-quest chief's wisdom notes title text pos
    .dh	0x66

  .org 0x08823E94 ; Quest Status Name Position
    move s0, v1
    
  .org 0x0889C508 ; Character Select "Yes" Position
    li a0, 0x15C
  .org 0x0889AA38 ; Character Select "No" Position
    addiu v1, s4, 0x50
	
  .org 0x0889B6C0 ; "Press the ○ button" Position
    li a0, 0xAE
  .org 0x0889B738
    li a0, 0xAE
  .org 0x0889BF2C
    li a0, 0xAE
  .org 0x0889C7CC
    li a0, 0xAE
  .org 0x0889CFC0
    li a0, 0xAE
  .org 0x0889D26C
    li a0, 0xAE	
  .org 0x0889D5C8
    li a0, 0xAE

  .org 0x088EFA00 ; Take reward Text Box
    .dh 0xD0	
  .org 0x088EFA1C ; Take Reward Highlight
    .dh 0xC4
  .org 0x088EFA28 ; Time Remaining Text Box
    .dh 0xD0


  ; --------------------------------------
  ; Lang set for system level messages
  ; --------------------------------------
  .org 0x0888CB50 ; Network connect message (Guildhall)
    li t0,0x1 ; English
    sw t0,-0x4E34(v0)
  
  ; These next 2 will need to be rewritten to support other language ID's
  .org 0x0889D6DC ; Savedata init set
    sw s4,0x1C(s1)

  .org 0x0889DA5C ; No savedata found / Savedata corrupt
    sw s4,0x68C(s1)
	
  ; --------------------------------------
  ; ~C02%s Formatted Strings - Copied from Freedom [USA]
  ; --------------------------------------
  .org 0x0884B360
    lh			a0, 0xA(s0)
	li			v1, 0x08915D18
	sll			a0, a0, 0x1
	addu		v1, v1, a0
	lui			v0, 0x892
	lhu			a1, 0x0(v1)
	jal			0x088461DC
	lw			a0, 0x32A0(v0)
	move		s1, v0
	lui			v0, 0x892
	lw			a0, 0x32A0(v0)
	jal			0x088461E8
	lhu			a1, 0x8(s0)
	move		a1, s1
	move		a2, v0
	jal			0x08810E9C
	addiu		a0, sp, 0x30
	nop
	nop
  .org 0x0884B910
	li			a1, 0
	lh			a0, 0xA(s1)
	li			v1, 0x08915D18
	sll			a0, a0, 0x1
	addu		v1, v1, a0
	lui			v0, 0x892
	lhu			a1, 0x0(v1)
	jal			0x088461DC
	lw			a0, 0x32A0(v0)
	move		s0, v0
	lui			v0, 0x892
	lw			a0, 0x32A0(v0)
	jal			0x088461E8
	lhu			a1, 0x8(s1)
	lui			v1, 0x0898
	lh			a1, 0x28(sp)
	lh			a2, 0x2A(sp)
	lw			a0, -0x5CD8(v1)
	move		a3, s0
	j			ParseText
	nop
  .org 0x0880CCA4
  ParseText:
	jal			0x08872364
	move		t0, v0
	j			0x0884BCB4
	nop
  .org 0x0884B574
	jal			0x08871548
  ; --------------------------------------
	
.close