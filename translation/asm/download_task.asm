.psp

.open "build/ULJM05066/download_task.bin", 0x098D4700
	; Fix quest title placement in memory
	.org 0x098EC994
		addiu		a0, a0, 0x1050
	.org 0x098E73E0
		addiu		v0, v0, 0x1050
	.org 0x098EC9A8
		addiu		a0, a0, 0x1070
	.org 0x098E73F4
		addiu		v0, v0, 0x1070
	.org 0x098EC9B0
		addiu		a0, a0, 0x1090
	.org 0x098E73FC
		addiu		v0, v0, 0x1090
	
	; "Press the ○ button" Position	
	.org 0x0990F060
		li			a0, 0xAE	
	.org 0x0990F098
		li			a0, 0xAE
	
	; English Text
	.org 0x099187B0
	.area 24, 0
		.asciiz "Quitting online mode"
	.endarea
		
	.org 0x099187C8
	.area 32, 0
		.asciiz "and returning to the Game Menu."
	.endarea
		
	.org 0x099187E8
	.area 24, 0
		.asciiz "Proceed?"
	.endarea
		
	.org 0x09918810
	.area 8, 0
		.asciiz "Confirm"
	.endarea

	.org 0x09918820
	.area 8, 0
		.asciiz "Cancel"
	.endarea
		
	.org 0x09918850
	.area 16, 0
		.asciiz "The Quest"
	.endarea
		
	.org 0x09918860
	.area 24, 0
		.asciiz "will be downloaded."
	.endarea
		
	.org 0x09918898
	.area 32, 0
		.asciiz "Download completed."
	.endarea
		
	.org 0x099188D0
	.area 32, 0
		.asciiz "Downloading..."
	.endarea
		
	.org 0x09918908
	.area 24, 0
		.asciiz "Failed to download."
	.endarea
		
	.org 0x09918920
	.area 32, 0
		.asciiz "A communication error occurred."
	.endarea
		
	.org 0x09918B28
	.area 24, 0
		.asciiz "No Game data found."
	.endarea
		
	.org 0x09918B40
	.area 16, 0
		.asciiz "Create new data"
	.endarea
		
	.org 0x09918B50
	.area 24, 0
		.asciiz "then save?"
	.endarea
		
	.org 0x09918B80
	.area 16, 0
		.asciiz "The Quest has"
	.endarea
		
	.org 0x09918B90
	.area 24, 0
		.asciiz "been downloaded."
	.endarea
		
	.org 0x09918BB8
	.area 24, 0
		.asciiz "Data will be saved."
	.endarea

	.org 0x09918BE8
	.area 24, 0
		.asciiz "Data will be saved."
	.endarea	
		
	.org 0x09918C10
	.area 40, 0
		.asciiz "Select where you would like to save."
	.endarea
		
	.org 0x09918C48
	.area 40, 0
		.asciiz "You may save up to three Quests."
	.endarea
		
	.org 0x09918C80
	.area 16, 0
		.asciiz "Quest Name:"
	.endarea
	
	.org 0x09918CA8
	.area 24, 0
		.asciiz "The Memory Stick Duo"
		.dh 0x4082 ; TM
	.endarea
		
	.org 0x09918CC0
	.area 24, 0
		.asciiz "is in use."
	.endarea
		
	.org 0x09918CE8
	.area 24, 0
		.asciiz "Saving..."
	.endarea		
		
	.org 0x09918D10
	.area 32, 0
		.asciiz "should not be removed."
	.endarea
		
	.org 0x09918D50
	.area 24, 0
		.asciiz "Save completed."
	.endarea
		
	.org 0x09918E08
	.area 24, 0
		.asciiz "Delete corrupted"
	.endarea
		
	.org 0x09918E20
	.area 16, 0
		.asciiz "Game data?"
	.endarea
		
	.org 0x09918EA8
	.area 32, 0
		.asciiz "and returning to the Game Menu."
	.endarea

	; MH Oldschool Event Quest Server
	.org 0x09919150
	.area 56, 0
		.asciiz "http://psp.mholdschool.com/psp/MHPSPENG/DL_TOP.PHP"
	.endarea
	
.close