.psp

.open "build/ULJM05066/demo_task.bin", 0x098D4700
	.org 0x098D55D0 ; Press Start Position
		li			a1, 0x1A	
		
	.org 0x098D5C04 ; Title Menu Position
		li			a1, 0x28
		jal			0x088714E0
		li			a2, 0x14
.close