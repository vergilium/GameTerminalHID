
UHB_Driver__Buffer_SaveToFlash:

;UHB_Driver.c,159 :: 		static void _Buffer_SaveToFlash() {
;UHB_Driver.c,167 :: 		bCount = Buffer_Count();                        // Get number of bytes in buffer.
	MOVLW       _Buffer+0
	SUBWF       _Buffer+64, 0 
	MOVWF       UHB_Driver__Buffer_SaveToFlash_bCount_L0+0 
	MOVLW       hi_addr(_Buffer+0)
	SUBWFB      _Buffer+65, 0 
	MOVWF       UHB_Driver__Buffer_SaveToFlash_bCount_L0+1 
;UHB_Driver.c,168 :: 		Buffer.fRWPtr = Buffer.fBuffer;                 // Reset buffer pointer.
	MOVLW       _Buffer+0
	MOVWF       _Buffer+64 
	MOVLW       hi_addr(_Buffer+0)
	MOVWF       _Buffer+65 
;UHB_Driver.c,169 :: 		while (bCount > 0) {
L_UHB_Driver__Buffer_SaveToFlash0:
	MOVLW       128
	MOVWF       R0 
	MOVLW       128
	XORWF       UHB_Driver__Buffer_SaveToFlash_bCount_L0+1, 0 
	SUBWF       R0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L_UHB_Driver__Buffer_SaveToFlash37
	MOVF        UHB_Driver__Buffer_SaveToFlash_bCount_L0+0, 0 
	SUBLW       0
L_UHB_Driver__Buffer_SaveToFlash37:
	BTFSC       STATUS+0, 0 
	GOTO        L_UHB_Driver__Buffer_SaveToFlash1
;UHB_Driver.c,170 :: 		FLASH_Write(StartAddress, Buffer.fRWPtr);     // Write chunk (flash write latch size) of buffer data.
	MOVF        _GPAddress+0, 0 
	MOVWF       FARG_FLASH_Write_32_address+0 
	MOVF        _GPAddress+1, 0 
	MOVWF       FARG_FLASH_Write_32_address+1 
	MOVF        _GPAddress+2, 0 
	MOVWF       FARG_FLASH_Write_32_address+2 
	MOVF        _GPAddress+3, 0 
	MOVWF       FARG_FLASH_Write_32_address+3 
	MOVF        _Buffer+64, 0 
	MOVWF       FARG_FLASH_Write_32_data_+0 
	MOVF        _Buffer+65, 0 
	MOVWF       FARG_FLASH_Write_32_data_+1 
	CALL        _FLASH_Write_32+0, 0
;UHB_Driver.c,171 :: 		bCount -= _FLASH_WRITE_LATCH;                 // Decrement bytes count.
	MOVLW       32
	SUBWF       UHB_Driver__Buffer_SaveToFlash_bCount_L0+0, 1 
	MOVLW       0
	SUBWFB      UHB_Driver__Buffer_SaveToFlash_bCount_L0+1, 1 
;UHB_Driver.c,172 :: 		Buffer.fRWPtr += _FLASH_WRITE_LATCH;          // Increment buffer pointer.
	MOVLW       32
	ADDWF       _Buffer+64, 0 
	MOVWF       R0 
	MOVLW       0
	ADDWFC      _Buffer+65, 0 
	MOVWF       R1 
	MOVF        R0, 0 
	MOVWF       _Buffer+64 
	MOVF        R1, 0 
	MOVWF       _Buffer+65 
;UHB_Driver.c,176 :: 		StartAddress += _FLASH_WRITE_LATCH;           // Increment flash address.
	MOVLW       32
	ADDWF       _GPAddress+0, 1 
	MOVLW       0
	ADDWFC      _GPAddress+1, 1 
	ADDWFC      _GPAddress+2, 1 
	ADDWFC      _GPAddress+3, 1 
;UHB_Driver.c,178 :: 		}
	GOTO        L_UHB_Driver__Buffer_SaveToFlash0
L_UHB_Driver__Buffer_SaveToFlash1:
;UHB_Driver.c,179 :: 		}
L_end__Buffer_SaveToFlash:
	RETURN      0
; end of UHB_Driver__Buffer_SaveToFlash

UHB_Driver_SendBootInfo:

;UHB_Driver.c,203 :: 		static void SendBootInfo() {
;UHB_Driver.c,210 :: 		*(TBootInfoArray *)(void *)HidWriteBuff = BootInfo; // Copy boot info record into transmit buffer.
	MOVLW       43
	MOVWF       R1 
	MOVLW       _HidWriteBuff+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_HidWriteBuff+0)
	MOVWF       FSR1H 
	MOVLW       _BootInfo+0
	MOVWF       TBLPTRL 
	MOVLW       hi_addr(_BootInfo+0)
	MOVWF       TBLPTRH 
	MOVLW       higher_addr(_BootInfo+0)
	MOVWF       TBLPTRU 
L_UHB_Driver_SendBootInfo2:
	TBLRD*+
	MOVFF       TABLAT+0, R0
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
	DECF        R1, 1 
	BTFSS       STATUS+0, 2 
	GOTO        L_UHB_Driver_SendBootInfo2
;UHB_Driver.c,211 :: 		HID_Write(HidWriteBuff, 64);                        // Send boot info.
	MOVLW       _HidWriteBuff+0
	MOVWF       FARG_HID_Write_writebuff+0 
	MOVLW       hi_addr(_HidWriteBuff+0)
	MOVWF       FARG_HID_Write_writebuff+1 
	MOVLW       64
	MOVWF       FARG_HID_Write_len+0 
	CALL        _HID_Write+0, 0
;UHB_Driver.c,212 :: 		}
L_end_SendBootInfo:
	RETURN      0
; end of UHB_Driver_SendBootInfo

UHB_Driver_Check4Cmd:

;UHB_Driver.c,236 :: 		static void Check4Cmd() {
;UHB_Driver.c,237 :: 		if (CmdCode == cmdNON) {               // Are we in 'Idle' mode?
	MOVF        _CmdCode+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_UHB_Driver_Check4Cmd3
;UHB_Driver.c,239 :: 		if (HidReadBuff[0] != STX)           // Do we have an 'STX' at start?
	MOVLW       0
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_UHB_Driver_Check4Cmd40
	MOVLW       15
	XORWF       _HidReadBuff+0, 0 
L_UHB_Driver_Check4Cmd40:
	BTFSC       STATUS+0, 2 
	GOTO        L_UHB_Driver_Check4Cmd4
;UHB_Driver.c,241 :: 		return ;                           // No, then exit.
	GOTO        L_end_Check4Cmd
L_UHB_Driver_Check4Cmd4:
;UHB_Driver.c,244 :: 		CmdCode = HidReadBuff[1];            // Get command code.
	MOVF        _HidReadBuff+1, 0 
	MOVWF       _CmdCode+0 
;UHB_Driver.c,245 :: 		Lo(GPAddress) = HidReadBuff[2];      // Get address lo byte.
	MOVF        _HidReadBuff+2, 0 
	MOVWF       _GPAddress+0 
;UHB_Driver.c,246 :: 		Hi(GPAddress) = HidReadBuff[3];      // Get address hi byte.
	MOVF        _HidReadBuff+3, 0 
	MOVWF       _GPAddress+1 
;UHB_Driver.c,247 :: 		Higher(GPAddress) = HidReadBuff[4];  // Get address higher byte.
	MOVF        _HidReadBuff+4, 0 
	MOVWF       _GPAddress+2 
;UHB_Driver.c,248 :: 		Highest(GPAddress) = HidReadBuff[5]; // Get address highest byte.
	MOVF        _HidReadBuff+5, 0 
	MOVWF       _GPAddress+3 
;UHB_Driver.c,249 :: 		Lo(GPCounter) = HidReadBuff[6];      // Get counter lo byte.
	MOVF        _HidReadBuff+6, 0 
	MOVWF       _GPCounter+0 
;UHB_Driver.c,250 :: 		Hi(GPCounter) = HidReadBuff[7];      // Get counter hi byte.
	MOVF        _HidReadBuff+7, 0 
	MOVWF       _GPCounter+1 
;UHB_Driver.c,251 :: 		}
	GOTO        L_UHB_Driver_Check4Cmd5
L_UHB_Driver_Check4Cmd3:
;UHB_Driver.c,254 :: 		}
L_UHB_Driver_Check4Cmd5:
;UHB_Driver.c,255 :: 		}
L_end_Check4Cmd:
	RETURN      0
; end of UHB_Driver_Check4Cmd

UHB_Driver_GetData:

;UHB_Driver.c,284 :: 		static char GetData() {
;UHB_Driver.c,289 :: 		sPtr = HidReadBuff;                    // Set local pointer to HID read buffer.
	MOVLW       _HidReadBuff+0
	MOVWF       R4 
	MOVLW       hi_addr(_HidReadBuff+0)
	MOVWF       R5 
;UHB_Driver.c,290 :: 		i = 0;                                 // Clear HID read buffer byte counter.
	CLRF        R3 
;UHB_Driver.c,291 :: 		while (1) {
L_UHB_Driver_GetData6:
;UHB_Driver.c,292 :: 		if (!BytesToGet)                     // Did we get it all?
	MOVF        _GPCounter+0, 0 
	IORWF       _GPCounter+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L_UHB_Driver_GetData8
;UHB_Driver.c,293 :: 		return 1;                          //   Yes, return with all done.
	MOVLW       1
	MOVWF       R0 
	GOTO        L_end_GetData
L_UHB_Driver_GetData8:
;UHB_Driver.c,294 :: 		if (Buffer_Count() == Buffer_Size()) // Is data buffer full?
	MOVLW       _Buffer+0
	SUBWF       _Buffer+64, 0 
	MOVWF       R1 
	MOVLW       hi_addr(_Buffer+0)
	SUBWFB      _Buffer+65, 0 
	MOVWF       R2 
	MOVLW       0
	XORWF       R2, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L_UHB_Driver_GetData42
	MOVLW       64
	XORWF       R1, 0 
L_UHB_Driver_GetData42:
	BTFSS       STATUS+0, 2 
	GOTO        L_UHB_Driver_GetData9
;UHB_Driver.c,295 :: 		return 1;                          //   Yes, return with buffer full.
	MOVLW       1
	MOVWF       R0 
	GOTO        L_end_GetData
L_UHB_Driver_GetData9:
;UHB_Driver.c,296 :: 		if (i == sizeof(HidReadBuff))        // End of received packet?
	MOVF        R3, 0 
	XORLW       64
	BTFSS       STATUS+0, 2 
	GOTO        L_UHB_Driver_GetData10
;UHB_Driver.c,297 :: 		return 0;                          //   Yes, return with more to get.
	CLRF        R0 
	GOTO        L_end_GetData
L_UHB_Driver_GetData10:
;UHB_Driver.c,298 :: 		Buffer_WriteByte(*sPtr++);           // Copy to buffer.
	MOVFF       R4, FSR0
	MOVFF       R5, FSR0H
	MOVFF       _Buffer+64, FSR1
	MOVFF       _Buffer+65, FSR1H
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
	MOVLW       1
	ADDWF       _Buffer+64, 0 
	MOVWF       R0 
	MOVLW       0
	ADDWFC      _Buffer+65, 0 
	MOVWF       R1 
	MOVF        R0, 0 
	MOVWF       _Buffer+64 
	MOVF        R1, 0 
	MOVWF       _Buffer+65 
	INFSNZ      R4, 1 
	INCF        R5, 1 
;UHB_Driver.c,299 :: 		BytesToGet--;                        // Decrement data buffer counter.
	MOVLW       1
	SUBWF       _GPCounter+0, 1 
	MOVLW       0
	SUBWFB      _GPCounter+1, 1 
;UHB_Driver.c,300 :: 		i++;                                 // Increment HID read buffer byte counter
	INCF        R3, 1 
;UHB_Driver.c,301 :: 		}
	GOTO        L_UHB_Driver_GetData6
;UHB_Driver.c,303 :: 		}
L_end_GetData:
	RETURN      0
; end of UHB_Driver_GetData

UHB_Driver_SendACK:

;UHB_Driver.c,326 :: 		static void SendACK(enum TCmd cmd) {
;UHB_Driver.c,328 :: 		HidWriteBuff[0] = STX;       // Start of packet indetifier.
	MOVLW       15
	MOVWF       _HidWriteBuff+0 
;UHB_Driver.c,329 :: 		HidWriteBuff[1] = cmd;       // Command code to acknowledge.
	MOVF        FARG_UHB_Driver_SendACK_cmd+0, 0 
	MOVWF       _HidWriteBuff+1 
;UHB_Driver.c,330 :: 		HID_Write(HidWriteBuff, 64); // Send acknowledgement packet.
	MOVLW       _HidWriteBuff+0
	MOVWF       FARG_HID_Write_writebuff+0 
	MOVLW       hi_addr(_HidWriteBuff+0)
	MOVWF       FARG_HID_Write_writebuff+1 
	MOVLW       64
	MOVWF       FARG_HID_Write_len+0 
	CALL        _HID_Write+0, 0
;UHB_Driver.c,331 :: 		}
L_end_SendACK:
	RETURN      0
; end of UHB_Driver_SendACK

_StartBootloader:

;UHB_Driver.c,354 :: 		void StartBootloader() {
;UHB_Driver.c,356 :: 		char writeData = 0;    // Write command execution flag.
	CLRF        StartBootloader_writeData_L0+0 
;UHB_Driver.c,362 :: 		Buffer_Reset();        // Reset data buffer.
	MOVLW       _Buffer+0
	MOVWF       _Buffer+64 
	MOVLW       hi_addr(_Buffer+0)
	MOVWF       _Buffer+65 
;UHB_Driver.c,363 :: 		EEPROM_Write(0xFF,0x01);           //Флаг выхода с режима загрузчика
	MOVLW       255
	MOVWF       FARG_EEPROM_Write_address+0 
	MOVLW       1
	MOVWF       FARG_EEPROM_Write_data_+0 
	CALL        _EEPROM_Write+0, 0
;UHB_Driver.c,365 :: 		while(1) {
L_StartBootloader11:
;UHB_Driver.c,366 :: 		USB_Polling_Proc();  // Check USB.
	CALL        _USB_Polling_Proc+0, 0
;UHB_Driver.c,367 :: 		dataRx = HID_Read(); // Read received USB packet, if any.
	CALL        _HID_Read+0, 0
;UHB_Driver.c,368 :: 		if (dataRx) {        // Do we have an incoming?
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_StartBootloader13
;UHB_Driver.c,370 :: 		Check4Cmd();       // Check received packet for new command.
	CALL        UHB_Driver_Check4Cmd+0, 0
;UHB_Driver.c,371 :: 		switch(CmdCode) {  // Process command.
	GOTO        L_StartBootloader14
;UHB_Driver.c,372 :: 		case cmdWRITE: { // Cmd: Write data to flash.
L_StartBootloader16:
;UHB_Driver.c,373 :: 		if (writeData) {   // Are we already executing an write command?
	MOVF        StartBootloader_writeData_L0+0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_StartBootloader17
;UHB_Driver.c,374 :: 		if (GetData()) { // Yes, then do we have some data to write?
	CALL        UHB_Driver_GetData+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_StartBootloader18
;UHB_Driver.c,380 :: 		if (StartAddress < BOOTLOADER_START) // Are we out of bootloader area?
	MOVLW       _BOOTLOADER_START+3
	SUBWF       _GPAddress+3, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__StartBootloader45
	MOVLW       _BOOTLOADER_START+2
	SUBWF       _GPAddress+2, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__StartBootloader45
	MOVLW       _BOOTLOADER_START+1
	SUBWF       _GPAddress+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__StartBootloader45
	MOVLW       _BOOTLOADER_START
	SUBWF       _GPAddress+0, 0 
L__StartBootloader45:
	BTFSC       STATUS+0, 0 
	GOTO        L_StartBootloader19
;UHB_Driver.c,382 :: 		Buffer_SaveToFlash();              //   Yes, write data buffer to flash.
	CALL        UHB_Driver__Buffer_SaveToFlash+0, 0
L_StartBootloader19:
;UHB_Driver.c,383 :: 		SendACK(CmdCode);                    // Acknowledge data write and ask for more if any.
	MOVF        _CmdCode+0, 0 
	MOVWF       FARG_UHB_Driver_SendACK_cmd+0 
	CALL        UHB_Driver_SendACK+0, 0
;UHB_Driver.c,384 :: 		Buffer_Reset();                      // Reset data buffer.
	MOVLW       _Buffer+0
	MOVWF       _Buffer+64 
	MOVLW       hi_addr(_Buffer+0)
	MOVWF       _Buffer+65 
;UHB_Driver.c,385 :: 		if (BytesToWrite == 0) {             // Are there more data to write?
	MOVLW       0
	XORWF       _GPCounter+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__StartBootloader46
	MOVLW       0
	XORWF       _GPCounter+0, 0 
L__StartBootloader46:
	BTFSS       STATUS+0, 2 
	GOTO        L_StartBootloader20
;UHB_Driver.c,386 :: 		writeData = 0;                     //   No, reset executing write command flag.
	CLRF        StartBootloader_writeData_L0+0 
;UHB_Driver.c,387 :: 		CmdCode = cmdNON;                  //   Set 'Idle' command code.
	CLRF        _CmdCode+0 
;UHB_Driver.c,388 :: 		}
L_StartBootloader20:
;UHB_Driver.c,389 :: 		}
L_StartBootloader18:
;UHB_Driver.c,390 :: 		}
	GOTO        L_StartBootloader21
L_StartBootloader17:
;UHB_Driver.c,392 :: 		writeData = 1; // Set executing write command flag.
	MOVLW       1
	MOVWF       StartBootloader_writeData_L0+0 
;UHB_Driver.c,393 :: 		}
L_StartBootloader21:
;UHB_Driver.c,394 :: 		break;
	GOTO        L_StartBootloader15
;UHB_Driver.c,396 :: 		case cmdERASE: { // Cmd: Erase flash.
L_StartBootloader22:
;UHB_Driver.c,397 :: 		while (BlocksToErase--) {                   // More to erase?
L_StartBootloader23:
	MOVF        _GPCounter+0, 0 
	MOVWF       R0 
	MOVF        _GPCounter+1, 0 
	MOVWF       R1 
	MOVLW       1
	SUBWF       _GPCounter+0, 1 
	MOVLW       0
	SUBWFB      _GPCounter+1, 1 
	MOVF        R0, 0 
	IORWF       R1, 0 
	BTFSC       STATUS+0, 2 
	GOTO        L_StartBootloader24
;UHB_Driver.c,403 :: 		if (StartAddress < BOOTLOADER_START)      // Are we out of bootloader area?
	MOVLW       _BOOTLOADER_START+3
	SUBWF       _GPAddress+3, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__StartBootloader47
	MOVLW       _BOOTLOADER_START+2
	SUBWF       _GPAddress+2, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__StartBootloader47
	MOVLW       _BOOTLOADER_START+1
	SUBWF       _GPAddress+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__StartBootloader47
	MOVLW       _BOOTLOADER_START
	SUBWF       _GPAddress+0, 0 
L__StartBootloader47:
	BTFSC       STATUS+0, 0 
	GOTO        L_StartBootloader25
;UHB_Driver.c,405 :: 		FLASH_Erase(StartAddress);              //   Yes, erase flash block.
	MOVF        _GPAddress+0, 0 
	MOVWF       FARG_FLASH_Erase_64_address+0 
	MOVF        _GPAddress+1, 0 
	MOVWF       FARG_FLASH_Erase_64_address+1 
	MOVF        _GPAddress+2, 0 
	MOVWF       FARG_FLASH_Erase_64_address+2 
	MOVF        _GPAddress+3, 0 
	MOVWF       FARG_FLASH_Erase_64_address+3 
	CALL        _FLASH_Erase_64+0, 0
L_StartBootloader25:
;UHB_Driver.c,413 :: 		StartAddress -= _FLASH_ERASE;           //   Increment flash address.
	MOVLW       64
	SUBWF       _GPAddress+0, 1 
	MOVLW       0
	SUBWFB      _GPAddress+1, 1 
	SUBWFB      _GPAddress+2, 1 
	SUBWFB      _GPAddress+3, 1 
;UHB_Driver.c,416 :: 		}
	GOTO        L_StartBootloader23
L_StartBootloader24:
;UHB_Driver.c,417 :: 		SendACK(CmdCode);                           // Acknowledge flash erase command.
	MOVF        _CmdCode+0, 0 
	MOVWF       FARG_UHB_Driver_SendACK_cmd+0 
	CALL        UHB_Driver_SendACK+0, 0
;UHB_Driver.c,418 :: 		CmdCode = cmdNON;                           // Set 'Idle' command code.
	CLRF        _CmdCode+0 
;UHB_Driver.c,419 :: 		break;
	GOTO        L_StartBootloader15
;UHB_Driver.c,421 :: 		case cmdSYNC: { // Cmd: Synchronize bootloader and PC app.
L_StartBootloader26:
;UHB_Driver.c,422 :: 		SendACK(CmdCode); // Acknowledge SYNC command.
	MOVF        _CmdCode+0, 0 
	MOVWF       FARG_UHB_Driver_SendACK_cmd+0 
	CALL        UHB_Driver_SendACK+0, 0
;UHB_Driver.c,423 :: 		CmdCode = cmdNON; // Set 'Idle' command code.
	CLRF        _CmdCode+0 
;UHB_Driver.c,424 :: 		break;
	GOTO        L_StartBootloader15
;UHB_Driver.c,426 :: 		case cmdREBOOT: {
L_StartBootloader27:
;UHB_Driver.c,429 :: 		asm RESET; // Reset MCU.
	RESET
;UHB_Driver.c,440 :: 		CmdCode = cmdNON; // Set 'Idle' command code.
	CLRF        _CmdCode+0 
;UHB_Driver.c,441 :: 		break;
	GOTO        L_StartBootloader15
;UHB_Driver.c,443 :: 		}
L_StartBootloader14:
	MOVF        _CmdCode+0, 0 
	XORLW       11
	BTFSC       STATUS+0, 2 
	GOTO        L_StartBootloader16
	MOVF        _CmdCode+0, 0 
	XORLW       21
	BTFSC       STATUS+0, 2 
	GOTO        L_StartBootloader22
	MOVF        _CmdCode+0, 0 
	XORLW       1
	BTFSC       STATUS+0, 2 
	GOTO        L_StartBootloader26
	MOVF        _CmdCode+0, 0 
	XORLW       4
	BTFSC       STATUS+0, 2 
	GOTO        L_StartBootloader27
L_StartBootloader15:
;UHB_Driver.c,444 :: 		}
L_StartBootloader13:
;UHB_Driver.c,445 :: 		}
	GOTO        L_StartBootloader11
;UHB_Driver.c,446 :: 		}
L_end_StartBootloader:
	RETURN      0
; end of _StartBootloader

_EnterBootloaderMode:

;UHB_Driver.c,473 :: 		char EnterBootloaderMode() {
;UHB_Driver.c,475 :: 		unsigned timer = 10000;   // 5sec timer = 10000 * 1ms.
	MOVLW       16
	MOVWF       EnterBootloaderMode_timer_L0+0 
	MOVLW       39
	MOVWF       EnterBootloaderMode_timer_L0+1 
;UHB_Driver.c,478 :: 		while (1) {
L_EnterBootloaderMode28:
;UHB_Driver.c,479 :: 		USB_Polling_Proc();  // Check USB.
	CALL        _USB_Polling_Proc+0, 0
;UHB_Driver.c,480 :: 		dataRx = HID_Read(); // Read received USB packet, if any.
	CALL        _HID_Read+0, 0
;UHB_Driver.c,481 :: 		if (dataRx) {        // Do we have an incoming?
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_EnterBootloaderMode30
;UHB_Driver.c,483 :: 		Check4Cmd();       // Check received packet for new command.
	CALL        UHB_Driver_Check4Cmd+0, 0
;UHB_Driver.c,484 :: 		switch (cmdCode) { // Process command.
	GOTO        L_EnterBootloaderMode31
;UHB_Driver.c,485 :: 		case cmdBOOT: {  // Cmd: Enter bootloader mode.
L_EnterBootloaderMode33:
;UHB_Driver.c,486 :: 		SendACK(CmdCode);   // Acknowledge enter bootloader mode command.
	MOVF        _CmdCode+0, 0 
	MOVWF       FARG_UHB_Driver_SendACK_cmd+0 
	CALL        UHB_Driver_SendACK+0, 0
;UHB_Driver.c,487 :: 		CmdCode = cmdNON;   // Set 'Idle' command code.
	CLRF        _CmdCode+0 
;UHB_Driver.c,488 :: 		Delay_10ms();
	CALL        _Delay_10ms+0, 0
;UHB_Driver.c,489 :: 		return 1;           // Return with do bootloader code.
	MOVLW       1
	MOVWF       R0 
	GOTO        L_end_EnterBootloaderMode
;UHB_Driver.c,491 :: 		case cmdINFO: { // Cmd: Get bootloader info.
L_EnterBootloaderMode34:
;UHB_Driver.c,492 :: 		SendBootInfo();   // Send bootloader info record.
	CALL        UHB_Driver_SendBootInfo+0, 0
;UHB_Driver.c,493 :: 		CmdCode = cmdNON; // Set 'Idle' command code.
	CLRF        _CmdCode+0 
;UHB_Driver.c,494 :: 		break;
	GOTO        L_EnterBootloaderMode32
;UHB_Driver.c,496 :: 		}
L_EnterBootloaderMode31:
	MOVF        _CmdCode+0, 0 
	XORLW       3
	BTFSC       STATUS+0, 2 
	GOTO        L_EnterBootloaderMode33
	MOVF        _CmdCode+0, 0 
	XORLW       2
	BTFSC       STATUS+0, 2 
	GOTO        L_EnterBootloaderMode34
L_EnterBootloaderMode32:
;UHB_Driver.c,497 :: 		}
L_EnterBootloaderMode30:
;UHB_Driver.c,499 :: 		Delay_1ms();
	CALL        _Delay_1ms+0, 0
;UHB_Driver.c,500 :: 		if (!(timer--)) // Do we have a timeout?
	MOVF        EnterBootloaderMode_timer_L0+0, 0 
	MOVWF       R0 
	MOVF        EnterBootloaderMode_timer_L0+1, 0 
	MOVWF       R1 
	MOVLW       1
	SUBWF       EnterBootloaderMode_timer_L0+0, 1 
	MOVLW       0
	SUBWFB      EnterBootloaderMode_timer_L0+1, 1 
	MOVF        R0, 0 
	IORWF       R1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L_EnterBootloaderMode35
;UHB_Driver.c,501 :: 		return 0;     //   Yes, return with do application code.
	CLRF        R0 
	GOTO        L_end_EnterBootloaderMode
L_EnterBootloaderMode35:
;UHB_Driver.c,502 :: 		}
	GOTO        L_EnterBootloaderMode28
;UHB_Driver.c,503 :: 		}
L_end_EnterBootloaderMode:
	RETURN      0
; end of _EnterBootloaderMode

_StartProgram:

;UHB_Driver.c,529 :: 		void StartProgram() {
;UHB_Driver.c,531 :: 		asm nop;
	NOP
;UHB_Driver.c,545 :: 		}
L_end_StartProgram:
	RETURN      0
; end of _StartProgram
