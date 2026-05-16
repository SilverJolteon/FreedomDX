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
	
	.org 0x09918850
		.ascii "The Quest", 0x00
		
	.org 0x09918860
		.ascii "will be downloaded.", 0x00

	.org 0x099187E8
		.ascii "Proceed?", 0x00
		
	.org 0x09918810
		.ascii "Confirm", 0x00
		
	.org 0x09918820
		.ascii "Cancel", 0x00
		
	.org 0x099188D0
		.ascii "Downloading...", 0x00
		
	.org 0x09918898
		.ascii "Download completed.", 0x00
		
	.org 0x09918CA8
		.ascii "The Memory Stick Duo"
		.dw 0x00004082 ; TM.
		
	.org 0x09918CC0
		.ascii "is in use.", 0x00
		
	.org 0x09918D10
		.ascii "should not be removed.", 0x00
		
	.org 0x09918C10
		.ascii "Select where you would like to save.", 0x00
		
	.org 0x09918C48
		.ascii "You may save up to three Quests.", 0x00
		
	.org 0x09918C80
		.ascii "Quest Name:", 0x00
		
	.org 0x09918BB8
		.ascii "Data will be saved.", 0x00
		
	.org 0x09918D50
		.ascii "Save completed.", 0x00
		
	.org 0x09918B80
		.ascii "The Quest has", 0x00
		
	.org 0x09918B90
		.ascii "been downloaded.", 0x00
		
	.org 0x09918CE8
		.ascii "Saving...", 0x00
		
	.org 0x09918B28
		.ascii "No Game data found.", 0x00
		
	.org 0x09918B40
		.ascii "Create new Game data", 0x00
		
	.org 0x09918B50
		.ascii "then save?", 0x00
		
	.org 0x09918BE8
		.ascii "Data will be saved.", 0x00
		
	.org 0x09918E08
		.ascii "Delete corrupted", 0x00
		
	.org 0x09918E20
		.ascii "Game data?", 0x00
		
	.org 0x099187B0
		.ascii "Quitting online mode", 0x00
		
	.org 0x099187C8
		.ascii "and returning to the Game Menu.", 0x00
		
	.org 0x09918908
		.ascii "Failed to download.", 0x00
		
	.org 0x09918920
		.ascii "A communication error occurred.", 0x00
		
	.org 0x09918EA8
		.ascii "and returning to the Game Menu.", 0x00

	; MH Oldschool Event Quest Server
	.org 0x09919150	
		.ascii "http://192.168.1.34/psp/MHPSPENG/DL_TOP.PHP", 0x00
	
.close