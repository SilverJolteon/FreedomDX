FixF1QuestsHook		equ 0x1A6AF8DC
Q4912_ToC			equ 0x08A3DE40
FixF1QuestIDCheck	equ 0x098F3A34

CheckLoadedQuest:
	addi		sp, sp, -0x14
	sw			ra, 0x10(sp)
	sw			a3, 0x0C(sp)
	sw			a2, 0x08(sp)
	sw			a1, 0x04(sp)
	sw			a0, 0x00(sp)

	; v1 = id
	andi		v1, v1, 0xFFFF
	
	; init
	la			t0, FixF1QuestsInit
	lw			t1, 0x4(t0)
	bne			t1, zero, CheckLoadedQuestCont
	nop
	la			t1, Q4912_ToC
	lw			t1, 0x0(t1)
	sw			t1, 0x0(t0)
	li			t2, 0x1
	sw			t2, 0x4(t0)
	
CheckLoadedQuestCont:	
	li			t0, 0x3FD ; The Illusion of Kut-Ku
	beq			v1, t0, CopyQuestData
	li			a0, 0x00
	
	li			t0, 0x3FE ; Revenge of the BBQ!
	beq			v1, t0, CopyQuestData
	li			a0, 0x01
	
	li			t0, 0x7E0 ; Legendary Black Dragon
	beq			v1, t0, CopyQuestData
	li			a0, 0x02
	
	li			t0, 0x7E1 ; Treasure Hunting!
	beq			v1, t0, CopyQuestData
	li			a0, 0x03
	
	li			t0, 0xBC0 ; The Plate of Calamity
	beq			v1, t0, CopyQuestData
	li			a0, 0x04
	
	li			t0, 0xBC1 ; The Rage of Yian Garuga
	beq			v1, t0, CopyQuestData
	li			a0, 0x05
	
	li			t0, 0xBC2 ; Thunder and Lightning
	beq			v1, t0, CopyQuestData
	li			a0, 0x06
	
	
	la			t0, Q4912_ToC
	la			t1, FixF1QuestsInit
	lw			t2, 0x0(t1)
	sw			t2, 0x0(t0)
	la			t1, FixF1QuestIDCheck
	li			t2, 0x1062000B
	sw			t2, 0x0(t1)
	j			FixF1QuestsReturn
	nop

CopyQuestData:	
	la			t0, FixF1QuestsInit
	lw			t1, 0x0(t0)
	
	li			t2, 0x6
	mult		a0, t2
	mflo		t2 ; i * 0x6
	add			t1, t1, t2 ; ToC[4912] + i * 0x6
	la			t0, Q4912_ToC
	sw			t1, 0x0(t0)
	addi		t0, t0, 0x4
	addi		t1, t1, 0x6
	sw			t1, 0x0(t0)
	
	; Replace ID
	li			t0, 0x03FD
	sh			t0, 0x4(s0)
	la			t1, FixF1QuestIDCheck
	li			t2, 0x1000000B
	sw			t2, 0x0(t1)

FixF1QuestsReturn:
	lw			a0, 0x00(sp)
	lw			a1, 0x04(sp)
	lw			a2, 0x08(sp)
	lw			a3, 0x0C(sp)
	
	jal			0x098E8B50
	nop	
	
	lw			ra, 0x10(sp)
	addi		sp, sp, 0x14
	jr			ra
	nop
	
FixF1QuestsInit:
	.word		0, 0