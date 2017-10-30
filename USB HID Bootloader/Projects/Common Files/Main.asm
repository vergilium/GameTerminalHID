
_main:

;Main.c,74 :: 		void main(void) {
;Main.c,76 :: 		ADCON1 = 0x0F;  // Configure all PORT pins as digital
	MOVLW       15
	MOVWF       ADCON1+0 
;Main.c,77 :: 		TRISA= 0b00010000;
	MOVLW       16
	MOVWF       TRISA+0 
;Main.c,78 :: 		TRISB= 0b00000011;
	MOVLW       3
	MOVWF       TRISB+0 
;Main.c,79 :: 		TRISC= 0b10111000;
	MOVLW       184
	MOVWF       TRISC+0 
;Main.c,80 :: 		PORTA= 0;
	CLRF        PORTA+0 
;Main.c,81 :: 		PORTB= 0;
	CLRF        PORTB+0 
;Main.c,82 :: 		PORTC= 0;
	CLRF        PORTC+0 
;Main.c,83 :: 		INTCON2.RBPU = 0;
	BCF         INTCON2+0, 7 
;Main.c,85 :: 		if(button(&PORTC, RC7, 200, 0)) EEPROM_Write(0xFF,0xFF);
	MOVLW       PORTC+0
	MOVWF       FARG_Button_port+0 
	MOVLW       hi_addr(PORTC+0)
	MOVWF       FARG_Button_port+1 
	MOVLW       7
	MOVWF       FARG_Button_pin+0 
	MOVLW       200
	MOVWF       FARG_Button_time_ms+0 
	CLRF        FARG_Button_active_state+0 
	CALL        _Button+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main0
	MOVLW       255
	MOVWF       FARG_EEPROM_Write_address+0 
	MOVLW       255
	MOVWF       FARG_EEPROM_Write_data_+0 
	CALL        _EEPROM_Write+0, 0
L_main0:
;Main.c,86 :: 		if(EEPROM_Read(0xFF) == 0xFF){
	MOVLW       255
	MOVWF       FARG_EEPROM_Read_address+0 
	CALL        _EEPROM_Read+0, 0
	MOVF        R0, 0 
	XORLW       255
	BTFSS       STATUS+0, 2 
	GOTO        L_main1
;Main.c,87 :: 		Config(); // Configure device and memory allocation.
	CALL        _Config+0, 0
;Main.c,88 :: 		HID_Enable(&HidReadBuff, &HidWriteBuff); // Enable USB HID communication.
	MOVLW       _HidReadBuff+0
	MOVWF       FARG_HID_Enable_readbuff+0 
	MOVLW       hi_addr(_HidReadBuff+0)
	MOVWF       FARG_HID_Enable_readbuff+1 
	MOVLW       _HidWriteBuff+0
	MOVWF       FARG_HID_Enable_writebuff+0 
	MOVLW       hi_addr(_HidWriteBuff+0)
	MOVWF       FARG_HID_Enable_writebuff+1 
	CALL        _HID_Enable+0, 0
;Main.c,91 :: 		if (!EnterBootloaderMode()) { // Should we enter bootloader mode?
	CALL        _EnterBootloaderMode+0, 0
	MOVF        R0, 1 
	BTFSS       STATUS+0, 2 
	GOTO        L_main2
;Main.c,92 :: 		HID_Disable();              // No, disable USB HID module.
	CALL        _HID_Disable+0, 0
;Main.c,93 :: 		Delay_10ms();               // Wait a little bit.
	CALL        _Delay_10ms+0, 0
;Main.c,95 :: 		StartProgram();             // Start already loaded application.
	CALL        _StartProgram+0, 0
;Main.c,96 :: 		} else
	GOTO        L_main3
L_main2:
;Main.c,97 :: 		StartBootloader();          // Yes, enter bootloader mode.
	CALL        _StartBootloader+0, 0
L_main3:
;Main.c,98 :: 		} else StartProgram();
	GOTO        L_main4
L_main1:
	CALL        _StartProgram+0, 0
L_main4:
;Main.c,99 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
