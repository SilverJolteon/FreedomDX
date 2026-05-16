.psp

.open "build/ULJM05066/connect_task.bin", 0x098D4700
	; "Press the ○ button" Position	
	.org 0x098D54CC
		li			a0, 0xAE
	.org 0x098D5558
		li			a0, 0xAE
.close