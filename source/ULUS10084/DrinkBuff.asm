DrinkBuffPlayerMem		equ 0x08F78E40
DrinkBuffPlayerStatus	equ 0x09853AA0
DrinkBuffEffect			equ 0x09A86428

GHDrinkCheck:
    ; First lets backup these registers
    addiu   sp,sp,-0x20
    sw      a3,0x18(sp)
    sw      a2,0x14(sp)
    sw      a1,0x10(sp)
    sw      a0,0xC(sp)
    sw      v1,0x8(sp)
    sw      v0,0x4(sp)
    ; Check if its player state mem we are writing to
    la      a1,DrinkBuffPlayerMem
    bne     a0,a1,GHDrinkRRestore
    nop
    ; Check if we've eaten at kitchen
    la      v0,DrinkBuffPlayerStatus
    lb      a0,0x10(v0)
    bne     zero,a0,GHDrinkRRestore
    li      a0,0x3

    ; Check to see how many chefs we have
    move    v1,v0
	li		t0, 0x0
    li      t1, 0x5
	li		t2, 0x3
	li		a2, 0x0
GHDrinkCatCounter:
    lb      a1, 0xEB8(v1)
	bne		a1, t2, SkipChef
	nop
	addiu	a2, a2, 0x1
	
SkipChef:
    addiu   v1, v1, 0x10
    addiu	t0, t0, 0x1
	slt		t3, t0, t1
	bne		t3, zero, GHDrinkCatCounter
	nop    

GHDrinkBoostChk:
    ; a2 contains num of cats
    ; Based on how many chefs we have will set the value
    beq     zero,a2,GHDrinkRRestore   ; 0 chefs
    li      a1,0x4
    slt     at,a1,a2
    beq     at,zero,GHDrinkBoostStam1 ; 1-4 chefs
    nop
    b       GHDrinkBoostStam2 ; 5 chefs
    nop

GHDrinkBoostStam1:
    li      a1,0x4B ; 25 Stamina
    b       GHDrinkBoostHP
    nop

GHDrinkBoostStam2:
    li      a1,0x96 ; 50 Stamina
    b       GHDrinkBoostHP
    nop

GHDrinkBoostHP: ; a0 for hp
    li      a0,0xA
    mult    a2,a0
    mflo    a0

GHDrinkWRBoost:
    li      a2,0x1
    sb      a2,0x10(v0)
    sb      a1,0x00(v0)
    sb      a0,0x04(v0)

GHDrinkEFX:
    lw      v1,0x8(sp)
    lui     v0,0x4080   ; Scale
    mtc1    v0,f12
    move    a0,s0
    li      a1,0x0  ; EFX type
    li      a2,0x0  ; Color
	li		a3,0xA
	jal		DrinkBuffEffect
	li		t0,0x0

GHDrinkRRestore:
    lw      a3,0x18(sp)
    lw      a2,0x14(sp)
    lw      a1,0x10(sp)
    lw      a0,0xC(sp)
    lw      v1,0x8(sp)
    lw      v0,0x4(sp)
	la		t0, DrinkBuffOffset
	addiu	t0, t0, 0x8
	jr		t0
    addiu   sp,sp,0x20
	