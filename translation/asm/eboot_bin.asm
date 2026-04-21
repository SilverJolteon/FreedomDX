.psp

.open "build/ULJM05066/EBOOT.BIN", 0x0880326C
	.org 0x089125F4 ; Reward, Contract Fee Text Position
		.byte 0x78, 0x00, 0x70, 0x00, 0x78
.close