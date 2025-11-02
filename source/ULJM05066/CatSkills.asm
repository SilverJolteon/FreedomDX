KCatMenuBox 		equ 0x099317E6
GCatMenuBox 		equ 0x0993968E
KCats 				equ 0x098540DF
GCats 				equ 0x09857811
KCatsPointer 		equ 0x099417BB
GCatsPointer 		equ 0x09941731
KCatReturn			equ 0x098D92B4
GCatReturn			equ 0x099308C8
GCatMenuToggle		equ 0x09941730
BarrelCatToggle		equ 0x0994174F

GetCatSkill:
	li			t0, 0x1F
	bgt			a0, t0, GetCatSkillNoSkills
	nop
	li			t0, 0x3
	mult		a0, t0
	mflo		a0
	addu		a0, a0, a1
	la			t0, SkillMap
	add			t0, a0, t0
	lb			a0, 0x0(t0)
	la			t0, SkillNames
	
	move		t1, t0
	move		t2, a0
	li			t3, 0x0
GetCatSkillNextString:	
	beq			t3, t2, FoundSkill
	nop
	
GetCatSkillLoop:
	lbu			t4, 0x0(t1)
	beq			t4, zero, CatSkillStringEnd
	nop
	addiu		t1, t1, 0x1
	j			GetCatSkillLoop
	nop
	
CatSkillStringEnd:
	addiu		t3, t3, 0x1
	addiu		t1, t1, 0x1
	j			GetCatSkillNextString
	nop
	
FoundSkill:
	move		v0, t1	
	j			GetCatSkillReturn
	nop
	
GetCatSkillNoSkills:
	li			v0, 0
	
GetCatSkillReturn:
	jr			ra
	nop
	
ShowGCatSkills:
	addiu		sp, sp, -0x14
	sw			a3, 0x10(sp)
	sw			a2, 0xC(sp)
	sw			a1, 0x8(sp)
	sw			a0, 0x4(sp)
	sw			ra, 0x0(sp)
	la			t0, GCatMenuBox
	li			t1, 0xD8
	sb			t1, 0x0(t0)
	la			t0, GCatMenuToggle
	lb			t0, 0x0(t0)
	bne			t0, zero, DismissCat
	nop
	la			a0, GCats
	j			LoadCatInfo
	nop
	
DismissCat:
	la			a0, KCats
	j			LoadCatInfo
	nop
	
LoadCatInfo:	
	la			t0, BarrelCatToggle
	lb			t0, 0x0(t0)
	bne			t0, zero, BarrelCat
	nop
	la			a1, GCatsPointer
	lb			a1, 0x0(a1)
	j			BarrelCatEnd
	nop
	
BarrelCat:
	li			a1, 0x5
	
BarrelCatEnd:
	li			a3, 0x00B80108
	jal			ShowCatSkills
	nop
	lui			v0, 0x994
	lhu			t0, -0x6972(v0)
	lw			ra, 0x0(sp)
	lw			a0, 0x4(sp)
	lw			a1, 0x8(sp)
	lw			a2, 0xC(sp)
	lw			a3, 0x10(sp)
	addiu		sp, sp, 0x14
	j			GCatReturn
	nop
	
ShowKCatSkills:
	addiu		sp, sp, -0x14
	sw			a3, 0x10(sp)
	sw			a2, 0xC(sp)
	sw			a1, 0x8(sp)
	sw			a0, 0x4(sp)
	sw			ra, 0x0(sp)
	la			t0, KCatMenuBox
	li			t1, 0xD8
	sb			t1, 0x0(t0)
	la			a0, KCats
	la			a1, KCatsPointer
	lb			a1, 0x0(a1)
	li			a3, 0x00A80020
	jal			ShowCatSkills
	nop
	lui			v0, 0x993
	lhu			t0, 0x17E6(v0)
	lw			ra, 0x0(sp)
	lw			a0, 0x4(sp)
	lw			a1, 0x8(sp)
	lw			a2, 0xC(sp)
	lw			a3, 0x10(sp)
	addiu		sp, sp, 0x14
	j			KCatReturn
	nop

ShowCatSkills:	
	addiu		sp, sp, -0x10
	sw			s2, 0xC(sp)
	sw			s1, 0x8(sp)
	sw			s0, 0x4(sp)
	sw			ra, 0x0(sp)
	move		t0, a0
	move		t1, a1
	sll			t1, t1, 4
	add			t0, t0, t1
	lb			s0, 0x0(t0) ; Skill Set
	li			s1, 0 ; Skill Set Cursor
	srl			s2, a3, 0x10 ; Text Y Coordinate
	andi		s2, s2, 0xFFFF
	andi		s3, a3, 0xFFFF ; Text X Coordinate
KSkillDrawLoop:
	move		a1, s1
	jal			GetCatSkill
	move		a0, s0
	; Draw Skill
	li			a0, FONT
	move		a1, s3 ; Text X Coordinate
	move		a2, s2 ; Text Y Coordinate
	li			t0, 0x0 ; Color
	move		t1, v0
	jal			drawText
	li			a3, 0x1
	; Increment
	addi		s1, 0x1
	addi		s2, 0x10
	li			t0, 0x3
	blt			s1, t0, KSkillDrawLoop
	nop
	
	lw			ra, 0x0(sp)
	lw			s0, 0x4(sp)
	lw			s1, 0x8(sp)
	lw			s2, 0xC(sp)
	addiu		sp, sp, 0x10
	jr			ra
	nop
	
SkillMap:
	.byte 0x18, 0x0A, 0x13, 0x15, 0x13, 0x06, 0x16, 0x0C, 0x06, 0x0D, 0x0A, 0x01, 0x0B, 0x0C, 0x01, 0x0C, 0x0A, 0x1B, 0x16, 0x09, 0x08, 0x06, 0x02, 0x09, 0x0B, 0x0F, 0x00, 0x15, 0x0C, 0x1A, 0x18, 0x14, 0x12, 0x0F, 0x07, 0x04, 0x0D, 0x09, 0x00, 0x02, 0x0F, 0x19, 0x16, 0x10, 0x04, 0x0B, 0x05, 0x0E, 0x18, 0x11, 0x12, 0x16, 0x07, 0x05, 0x0A, 0x11, 0x17, 0x14, 0x03, 0x19, 0x06, 0x02, 0x03, 0x17, 0x08, 0x04, 0x0D, 0x10, 0x00, 0x01, 0x07, 0x1A, 0x17, 0x08, 0x05, 0x15, 0x11, 0x0E, 0x14, 0x03, 0x10, 0x0B, 0x1B, 0x1A, 0x13, 0x13, 0x12, 0x16, 0x1B, 0x0E, 0x18, 0x19, 0x00, 0x0D, 0x15, 0x18
	.align 4
	
SkillNames:
	.ascii "FelyneDismantle[Hi]", 0
    .ascii "FelyneDismantle[Lo]", 0
    .ascii "Felyne Negotiations", 0
    .ascii "Felyne Culinary Arts", 0
    .ascii "Felyne Medicine", 0
    .ascii "FelyneMartialArts[H]", 0
    .ascii "FelyneMartialArts[L]", 0
    .ascii "Felyne Gunpowder", 0
    .ascii "FelyneSpecialAttack", 0
    .ascii "Felyne Defense[Hi]", 0
    .ascii "Felyne Defense[Lo]", 0
    .ascii "Felyne Woodwinds", 0
    .ascii "Felyne Frugality", 0
    .ascii "Felyne Charisma", 0
    .ascii "Felyne Combine[Hi]", 0
    .ascii "Felyne Combine[Lo]", 0
    .ascii "Felyne Gathering", 0
    .ascii "Felyne Aim", 0
    .ascii "Mega Lucky Cat", 0
    .ascii "Ultra Lucky Cat", 0
    .ascii "Felyne Heroics", 0
    .ascii "Felyne Blunt Force", 0
    .ascii "Felyne Great Break", 0
    .ascii "Felyne Escape", 0
    .ascii "Felyne Throw", 0
    .ascii "Felyne Courage", 0
    .ascii "Felyne Supercat", 0
    .ascii "Felyne Strongcat", 0
	.align 4