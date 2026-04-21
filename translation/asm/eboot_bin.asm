.psp

.open "build/ULJM05066/EBOOT.BIN", 0x0880326C
	.org 0x089125F4 ; Reward, Contract Fee Text Position
		.byte 0x78, 0x00, 0x70, 0x00, 0x78
  
  ; ----------------------------
  ; Clock face and HP/Stam fixes
  ; ----------------------------
  .org 0x088EF240 ; Clock face X/Y pos
    .dh   0x8
    .dh   0x6
  .org 0x088EF24C ; Clock hand group X/Y pos
    .dh   0x22
    .dh   0x1E
  .org 0x088EF254 ; HP bar X/Y pos
    .dh   0x39
    .dh   0xC
  .org 0x088EF260 ; Stam bar X/Y pos
    .dh   0x39
    .dh   0x15

  ; ----------------------------
  ; Shelling fixes
  ; ----------------------------
    .org 0x088EF2D4 ; Shelling X/Y pos 
      .dh   0x3C
      .dh   0x1E

  ; ----------------------------
  ; Text positional changes
  ; ----------------------------
  .org 0x08917D76 ; In-quest chief's wisdom notes title text pos
    .dh   0x66

.close