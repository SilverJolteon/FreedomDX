.psp

.open "build/ULJM05066/arcade_task.bin", 0x098D4700

  ; ----------------------------
  ; Text positional changes
  ; ----------------------------
  .org 0x098D6864 ; Dialog box dimensions at the bottom
    li    a1,0x2C
    li    a2,0xC8
    li    a3,0x188
    li    t0,0x40
  .org 0x098D6D0C ; Dialog box dimensions at the bottom
    li    a1,0x2C
    li    a2,0xC8
    li    a3,0x188
    li    t0,0x40
  .org 0x098D7344 ; Dialog box dimensions at the bottom
    li    a1,0x2C
    li    a2,0xC8
    li    a3,0x188
    li    t0,0x40
  .org 0x098D6B58 ; Dialog box text X/Y pos at bottom
    li    a1,0x37
    li    a2,0xD4

.close