QuestAddressOffset			 equ 0x08973AD0
LaoShanTimerReturnSkipOffset equ 0x0885A854

	LaoShanTimer:
		la			t0, QuestAddressOffset
		lw			t1, 0x10(t0)
		addi		t1, t1, 8
		add			t1, t0, t1
		lh			t1, 0x2(t1)
		li			t0, 0x7 ; Lao-Shan Lung
		beq			t0, t1, IncreaseTimer
		nop
		li			t0, 0x32 ; Ashen Lao-Shan Lung
		beq			t0, t1, IncreaseTimer
		nop
		b			LaoShanTimerReturn
		li			t0, 0x708
		
	IncreaseTimer:
		li			t0, 0x8CA
		
	LaoShanTimerReturn:
		beql		v0, zero, LaoShanTimerReturnSkip
		nop
		jr			ra
		move		v0, t0
		
	LaoShanTimerReturnSkip:
		j			LaoShanTimerReturnSkipOffset
		move		v0, t0