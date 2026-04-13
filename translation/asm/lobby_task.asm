.psp

.open "build/ULJM05066/lobby_task.bin", 0x098D4700
	.org 0x98E86E8 ; 4959 memsize
		lui			a2, 0x2
		
	.org 0x98E87E4 ; 4673 memsize
		ori			a2, v0, 0xD800
.close