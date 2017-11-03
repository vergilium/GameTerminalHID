
_USB_StateInit:

;usb.c,13 :: 		void USB_StateInit (void){
;usb.c,23 :: 		if(USBDev_GetDeviceState() == _USB_DEV_STATE_CONFIGURED){
	CALL        _USBDev_GetDeviceState+0, 0
	MOVF        R0, 0 
	XORLW       16
	BTFSS       STATUS+0, 2 
	GOTO        L_USB_StateInit0
;usb.c,24 :: 		USBFlags.if_conf = 1;                   //Если USB сконфигурирован устанавливаем флаг нормальной работы
	BSF         ADRESL+0, 1 
;usb.c,25 :: 		USBDev_SetReceiveBuffer(1, readbuff);   //Переинициализация буффера приема данных HID
	MOVLW       1
	MOVWF       FARG_USBDev_SetReceiveBuffer_epNum+0 
	MOVLW       _readbuff+0
	MOVWF       FARG_USBDev_SetReceiveBuffer_dataBuffer+0 
	MOVLW       hi_addr(_readbuff+0)
	MOVWF       FARG_USBDev_SetReceiveBuffer_dataBuffer+1 
	CALL        _USBDev_SetReceiveBuffer+0, 0
;usb.c,26 :: 		} else {
	GOTO        L_USB_StateInit1
L_USB_StateInit0:
;usb.c,27 :: 		USBFlags.if_conf = 0;                   //Если USB в режиме приостановлен - сбрасываем флаг работы USB
	BCF         ADRESL+0, 1 
;usb.c,28 :: 		delay_ms(10);                           //Ждем 10мс чтобы точно определить все ли устаканилось
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_USB_StateInit2:
	DECFSZ      R13, 1, 1
	BRA         L_USB_StateInit2
	DECFSZ      R12, 1, 1
	BRA         L_USB_StateInit2
;usb.c,29 :: 		}
L_USB_StateInit1:
;usb.c,30 :: 		}
L_end_USB_StateInit:
	RETURN      0
; end of _USB_StateInit

_USB_ReceiveBuffSet:

;usb.c,36 :: 		void USB_ReceiveBuffSet (void){
;usb.c,37 :: 		USBDev_SetReceiveBuffer(1, readbuff);
	MOVLW       1
	MOVWF       FARG_USBDev_SetReceiveBuffer_epNum+0 
	MOVLW       _readbuff+0
	MOVWF       FARG_USBDev_SetReceiveBuffer_dataBuffer+0 
	MOVLW       hi_addr(_readbuff+0)
	MOVWF       FARG_USBDev_SetReceiveBuffer_dataBuffer+1 
	CALL        _USBDev_SetReceiveBuffer+0, 0
;usb.c,38 :: 		}
L_end_USB_ReceiveBuffSet:
	RETURN      0
; end of _USB_ReceiveBuffSet

_SendKeys:

;usb.c,44 :: 		uint8_t SendKeys (uint8_t *keys, uint8_t modifier){
;usb.c,45 :: 		uint8_t i = 0,
	CLRF        SendKeys_i_L0+0 
	CLRF        SendKeys_cnt_L0+0 
;usb.c,47 :: 		writebuff[0] = modifier;
	MOVF        FARG_SendKeys_modifier+0, 0 
	MOVWF       1344 
;usb.c,48 :: 		writebuff[1] = reserved;
	MOVF        _reserved+0, 0 
	MOVWF       1345 
;usb.c,49 :: 		for(i=0; i<=5; i++){
	CLRF        SendKeys_i_L0+0 
L_SendKeys3:
	MOVF        SendKeys_i_L0+0, 0 
	SUBLW       5
	BTFSS       STATUS+0, 0 
	GOTO        L_SendKeys4
;usb.c,50 :: 		if(keys[i] != 0) cnt++;
	MOVF        SendKeys_i_L0+0, 0 
	ADDWF       FARG_SendKeys_keys+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      FARG_SendKeys_keys+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_SendKeys6
	INCF        SendKeys_cnt_L0+0, 1 
L_SendKeys6:
;usb.c,51 :: 		writebuff[i+2]=keys[i];
	MOVLW       2
	ADDWF       SendKeys_i_L0+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVLW       _writebuff+0
	ADDWF       R0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_writebuff+0)
	ADDWFC      R1, 0 
	MOVWF       FSR1H 
	MOVF        SendKeys_i_L0+0, 0 
	ADDWF       FARG_SendKeys_keys+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      FARG_SendKeys_keys+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;usb.c,49 :: 		for(i=0; i<=5; i++){
	INCF        SendKeys_i_L0+0, 1 
;usb.c,52 :: 		}
	GOTO        L_SendKeys3
L_SendKeys4:
;usb.c,53 :: 		USBDev_HIDWrite(1,writebuff,8);
	MOVLW       1
	MOVWF       FARG_USBDev_HIDWrite_epNum+0 
	MOVLW       _writebuff+0
	MOVWF       FARG_USBDev_HIDWrite_buffer+0 
	MOVLW       hi_addr(_writebuff+0)
	MOVWF       FARG_USBDev_HIDWrite_buffer+1 
	MOVLW       8
	MOVWF       FARG_USBDev_HIDWrite_size+0 
	MOVLW       0
	MOVWF       FARG_USBDev_HIDWrite_size+1 
	CALL        _USBDev_HIDWrite+0, 0
;usb.c,54 :: 		return cnt;
	MOVF        SendKeys_cnt_L0+0, 0 
	MOVWF       R0 
;usb.c,55 :: 		}
L_end_SendKeys:
	RETURN      0
; end of _SendKeys

_SendNoKeys:

;usb.c,61 :: 		void SendNoKeys (void){
;usb.c,62 :: 		memset(writebuff, 0, 8);
	MOVLW       _writebuff+0
	MOVWF       FARG_memset_p1+0 
	MOVLW       hi_addr(_writebuff+0)
	MOVWF       FARG_memset_p1+1 
	CLRF        FARG_memset_character+0 
	MOVLW       8
	MOVWF       FARG_memset_n+0 
	MOVLW       0
	MOVWF       FARG_memset_n+1 
	CALL        _memset+0, 0
;usb.c,63 :: 		USBDev_HIDWrite(1,writebuff,8);
	MOVLW       1
	MOVWF       FARG_USBDev_HIDWrite_epNum+0 
	MOVLW       _writebuff+0
	MOVWF       FARG_USBDev_HIDWrite_buffer+0 
	MOVLW       hi_addr(_writebuff+0)
	MOVWF       FARG_USBDev_HIDWrite_buffer+1 
	MOVLW       8
	MOVWF       FARG_USBDev_HIDWrite_size+0 
	MOVLW       0
	MOVWF       FARG_USBDev_HIDWrite_size+1 
	CALL        _USBDev_HIDWrite+0, 0
;usb.c,64 :: 		}
L_end_SendNoKeys:
	RETURN      0
; end of _SendNoKeys

_SendKey:

;usb.c,71 :: 		void SendKey (uint8_t key, uint8_t modifier){
;usb.c,72 :: 		writebuff[0] = modifier;
	MOVF        FARG_SendKey_modifier+0, 0 
	MOVWF       1344 
;usb.c,73 :: 		writebuff[1] = reserved;
	MOVF        _reserved+0, 0 
	MOVWF       1345 
;usb.c,74 :: 		writebuff[2] = key;
	MOVF        FARG_SendKey_key+0, 0 
	MOVWF       1346 
;usb.c,75 :: 		memset(writebuff+3, 0, 5);
	MOVLW       _writebuff+3
	MOVWF       FARG_memset_p1+0 
	MOVLW       hi_addr(_writebuff+3)
	MOVWF       FARG_memset_p1+1 
	CLRF        FARG_memset_character+0 
	MOVLW       5
	MOVWF       FARG_memset_n+0 
	MOVLW       0
	MOVWF       FARG_memset_n+1 
	CALL        _memset+0, 0
;usb.c,76 :: 		USBDev_HIDWrite(1,writebuff,8);       //Непосредственно сама передача
	MOVLW       1
	MOVWF       FARG_USBDev_HIDWrite_epNum+0 
	MOVLW       _writebuff+0
	MOVWF       FARG_USBDev_HIDWrite_buffer+0 
	MOVLW       hi_addr(_writebuff+0)
	MOVWF       FARG_USBDev_HIDWrite_buffer+1 
	MOVLW       8
	MOVWF       FARG_USBDev_HIDWrite_size+0 
	MOVLW       0
	MOVWF       FARG_USBDev_HIDWrite_size+1 
	CALL        _USBDev_HIDWrite+0, 0
;usb.c,77 :: 		}
L_end_SendKey:
	RETURN      0
; end of _SendKey

_USB_GetLEDs:

;usb.c,83 :: 		uint8_t USB_GetLEDs (void){
;usb.c,85 :: 		leds = (readbuff[0] & 0x07)<<1;
	MOVLW       7
	ANDWF       1280, 0 
	MOVWF       R2 
	MOVF        R2, 0 
	MOVWF       R0 
	RLCF        R0, 1 
	BCF         R0, 0 
	MOVF        R0, 0 
	MOVWF       R3 
;usb.c,86 :: 		if((leds & 0x08) == 8) leds = (leds & 0x07)|0x01;
	MOVLW       8
	ANDWF       R0, 0 
	MOVWF       R1 
	MOVF        R1, 0 
	XORLW       8
	BTFSS       STATUS+0, 2 
	GOTO        L_USB_GetLEDs7
	MOVLW       7
	ANDWF       R3, 1 
	BSF         R3, 0 
L_USB_GetLEDs7:
;usb.c,88 :: 		return leds;
	MOVF        R3, 0 
	MOVWF       R0 
;usb.c,89 :: 		}
L_end_USB_GetLEDs:
	RETURN      0
; end of _USB_GetLEDs
