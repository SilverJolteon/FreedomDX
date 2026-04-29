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
.close