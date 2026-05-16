.psp

.open "build/ULJM05066/gallery_task.bin", 0x098D4700
	; Gallery Titles Positions
	.org 0x098D7006 ; MHF Trailer
		.dh 0x0B
	.org 0x098D7014 ; MH2 Special Trailer
		.dh 0x13
	.org 0x098D7022 ; Opening
		.dh 0x07
	.org 0x098D7030 ; The Lone Black Wolf
		.dh 0x13
	.org 0x098D703E ; Gravios Ecology
		.dh 0x0F
	.org 0x098D704C ; Plesioth Ecology
		.dh 0x10
	.org 0x098D705A ; Khezu Ecology
		.dh 0x0D
	.org 0x098D7068 ; Diablos Ecology
		.dh 0x0F
	.org 0x098D7076 ; Rathian Ecology
		.dh 0x0F
		
	.org 0x098D7084 ; Blue Hunter
		.dh 0x0B
	.org 0x098D7092 ; Shepherd
		.dh 0x08
	.org 0x098D70A0 ; King of the Heavens
		.dh 0x13
	.org 0x098D70AE ; Divine Providence
		.dh 0x11
	.org 0x098D70BC ; AvianMasterofJungle
		.dh 0x13
	.org 0x098D70CA ; Menace in the Sand
		.dh 0x12
	.org 0x098D70D8 ; CorneredMonoblos
		.dh 0x10
	.org 0x098D70E6 ; TheAncientPiscine
		.dh 0x10
	.org 0x098D70F4 ; Poison of the Swamp
		.dh 0x13
		
	.org 0x098D7102 ; SupremeRulerInferno
		.dh 0x13
	.org 0x098D711E ; Lao-Shan Lung
		.dh 0x0D
	.org 0x098D712C ; WhiteShadowDarkness
		.dh 0x13
	.org 0x098D713A ; Advent of Disaster
		.dh 0x12
	.org 0x098D7148 ; DragonofJaggedRocks
		.dh 0x13
	.org 0x098D7156 ; The Phantom Beast
		.dh 0x11
	.org 0x098D7172 ; LegendofBlackDragon
		.dh 0x13
		
	.org 0x098D7180 ; Town of Hunters
		.dh 0x0F
	.org 0x098D719C ; MH Opening Movie
		.dh 0x10
	.org 0x098D71AA ; Hunter's Guild
		.dh 0x0E
	.org 0x098D71B8 ; A Hero's Proof F
		.dh 0x10
	.org 0x098D71C6 ; MHG Opening Movie
		.dh 0x11
	.org 0x098D71D4 ; TGS Trailer
		.dh 0x0B
	.org 0x098D71F0 ; MHG Presentation
		.dh 0x10
.close