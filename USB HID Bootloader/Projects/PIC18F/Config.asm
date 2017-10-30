
_Config:

;Config.c,137 :: 		void Config() {
;Config.c,138 :: 		ConfigMem(); // allocate memory
	MOVLW       0
	MOVWF       R0 
	MOVLW       4
	MOVWF       R1 
	MOVF        R0, 0 
	IORWF       R1, 0 
	BTFSC       STATUS+0, 2 
	GOTO        L_Config0
L_Config0:
;Config.c,139 :: 		}
L_end_Config:
	RETURN      0
; end of _Config
