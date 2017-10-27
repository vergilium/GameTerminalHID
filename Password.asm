
_SendPassword:

;Password.c,34 :: 		void SendPassword (uint8_t stAdres){
;Password.c,35 :: 		uint8_t i = 0,
	CLRF        SendPassword_i_L0+0 
	CLRF        SendPassword_bufKey_L0+0 
;Password.c,38 :: 		for(i = 0; i < PASS_BUFF_SIZE; i++){                   //Цикл вывода пароля в USB
	CLRF        SendPassword_i_L0+0 
L_SendPassword0:
	MOVLW       32
	SUBWF       SendPassword_i_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_SendPassword1
;Password.c,39 :: 		bufKey = EEPROM_read(stAdres + i);                 //Считывается байт с EEPROM
	MOVF        SendPassword_i_L0+0, 0 
	ADDWF       FARG_SendPassword_stAdres+0, 0 
	MOVWF       FARG_EEPROM_Read_address+0 
	CALL        _EEPROM_Read+0, 0
	MOVF        R0, 0 
	MOVWF       SendPassword_bufKey_L0+0 
;Password.c,40 :: 		if(bufKey == 0xFF) return;                         //Если нет пароля выходим с под программы
	MOVF        R0, 0 
	XORLW       255
	BTFSS       STATUS+0, 2 
	GOTO        L_SendPassword3
	GOTO        L_end_SendPassword
L_SendPassword3:
;Password.c,41 :: 		else if(bufKey == '\0'){                           //Если обнаружен конец пароля два раза жмякается кнопка ENTER
	MOVF        SendPassword_bufKey_L0+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_SendPassword5
;Password.c,42 :: 		SendKey(KEY_ENTER, 0);
	MOVLW       40
	MOVWF       FARG_SendKey+0 
	CLRF        FARG_SendKey+0 
	CALL        _SendKey+0, 0
;Password.c,43 :: 		delay_ms(100);
	MOVLW       7
	MOVWF       R11, 0
	MOVLW       23
	MOVWF       R12, 0
	MOVLW       106
	MOVWF       R13, 0
L_SendPassword6:
	DECFSZ      R13, 1, 1
	BRA         L_SendPassword6
	DECFSZ      R12, 1, 1
	BRA         L_SendPassword6
	DECFSZ      R11, 1, 1
	BRA         L_SendPassword6
	NOP
;Password.c,44 :: 		SendNoKeys();
	CALL        _SendNoKeys+0, 0
;Password.c,45 :: 		delay_ms(10);
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_SendPassword7:
	DECFSZ      R13, 1, 1
	BRA         L_SendPassword7
	DECFSZ      R12, 1, 1
	BRA         L_SendPassword7
;Password.c,46 :: 		SendKey(KEY_ENTER, 0);
	MOVLW       40
	MOVWF       FARG_SendKey+0 
	CLRF        FARG_SendKey+0 
	CALL        _SendKey+0, 0
;Password.c,47 :: 		delay_ms(100);
	MOVLW       7
	MOVWF       R11, 0
	MOVLW       23
	MOVWF       R12, 0
	MOVLW       106
	MOVWF       R13, 0
L_SendPassword8:
	DECFSZ      R13, 1, 1
	BRA         L_SendPassword8
	DECFSZ      R12, 1, 1
	BRA         L_SendPassword8
	DECFSZ      R11, 1, 1
	BRA         L_SendPassword8
	NOP
;Password.c,48 :: 		break;
	GOTO        L_SendPassword1
;Password.c,49 :: 		} else {                                           //в противном случае происходит вывод пароля
L_SendPassword5:
;Password.c,50 :: 		SendKey((bufKey & 0x7F), ((bufKey & 0x80)>>6));  //Отпрявляется код клавиши и ее модификатор SHIFT
	MOVLW       127
	ANDWF       SendPassword_bufKey_L0+0, 0 
	MOVWF       FARG_SendKey+0 
	MOVLW       128
	ANDWF       SendPassword_bufKey_L0+0, 0 
	MOVWF       FARG_SendKey+0 
	MOVLW       6
	MOVWF       R0 
	MOVF        R0, 0 
L__SendPassword21:
	BZ          L__SendPassword22
	RRCF        FARG_SendKey+0, 1 
	BCF         FARG_SendKey+0, 7 
	ADDLW       255
	GOTO        L__SendPassword21
L__SendPassword22:
	CALL        _SendKey+0, 0
;Password.c,51 :: 		delay_ms(30);
	MOVLW       2
	MOVWF       R11, 0
	MOVLW       212
	MOVWF       R12, 0
	MOVLW       133
	MOVWF       R13, 0
L_SendPassword10:
	DECFSZ      R13, 1, 1
	BRA         L_SendPassword10
	DECFSZ      R12, 1, 1
	BRA         L_SendPassword10
	DECFSZ      R11, 1, 1
	BRA         L_SendPassword10
;Password.c,52 :: 		SendNoKeys();                                    //нужно чтобы система определила отпускание кнопки
	CALL        _SendNoKeys+0, 0
;Password.c,53 :: 		delay_ms(30);
	MOVLW       2
	MOVWF       R11, 0
	MOVLW       212
	MOVWF       R12, 0
	MOVLW       133
	MOVWF       R13, 0
L_SendPassword11:
	DECFSZ      R13, 1, 1
	BRA         L_SendPassword11
	DECFSZ      R12, 1, 1
	BRA         L_SendPassword11
	DECFSZ      R11, 1, 1
	BRA         L_SendPassword11
;Password.c,38 :: 		for(i = 0; i < PASS_BUFF_SIZE; i++){                   //Цикл вывода пароля в USB
	INCF        SendPassword_i_L0+0, 1 
;Password.c,55 :: 		}
	GOTO        L_SendPassword0
L_SendPassword1:
;Password.c,56 :: 		SendNoKeys();
	CALL        _SendNoKeys+0, 0
;Password.c,57 :: 		}
L_end_SendPassword:
	RETURN      0
; end of _SendPassword

_EEPROM_SavePassword:

;Password.c,67 :: 		void EEPROM_SavePassword (uint8_t *pass, uint8_t len, uint8_t stAddr){
;Password.c,70 :: 		for(i=0; i<len; i++){                          //Просто в цикле пишем в EEPROM
	CLRF        EEPROM_SavePassword_i_L0+0 
L_EEPROM_SavePassword12:
	MOVF        FARG_EEPROM_SavePassword_len+0, 0 
	SUBWF       EEPROM_SavePassword_i_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_EEPROM_SavePassword13
;Password.c,71 :: 		EEPROM_write(stAddr+i, pass[i]);            //символы пароля
	MOVF        EEPROM_SavePassword_i_L0+0, 0 
	ADDWF       FARG_EEPROM_SavePassword_stAddr+0, 0 
	MOVWF       FARG_EEPROM_Write_address+0 
	MOVF        EEPROM_SavePassword_i_L0+0, 0 
	ADDWF       FARG_EEPROM_SavePassword_pass+0, 0 
	MOVWF       FSR0 
	MOVLW       0
	ADDWFC      FARG_EEPROM_SavePassword_pass+1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_EEPROM_Write_data_+0 
	CALL        _EEPROM_Write+0, 0
;Password.c,72 :: 		delay_us(100);
	MOVLW       2
	MOVWF       R12, 0
	MOVLW       141
	MOVWF       R13, 0
L_EEPROM_SavePassword15:
	DECFSZ      R13, 1, 1
	BRA         L_EEPROM_SavePassword15
	DECFSZ      R12, 1, 1
	BRA         L_EEPROM_SavePassword15
	NOP
	NOP
;Password.c,70 :: 		for(i=0; i<len; i++){                          //Просто в цикле пишем в EEPROM
	INCF        EEPROM_SavePassword_i_L0+0, 1 
;Password.c,73 :: 		}
	GOTO        L_EEPROM_SavePassword12
L_EEPROM_SavePassword13:
;Password.c,74 :: 		EEPROM_write(stAddr+len, '\0');
	MOVF        FARG_EEPROM_SavePassword_len+0, 0 
	ADDWF       FARG_EEPROM_SavePassword_stAddr+0, 0 
	MOVWF       FARG_EEPROM_Write_address+0 
	CLRF        FARG_EEPROM_Write_data_+0 
	CALL        _EEPROM_Write+0, 0
;Password.c,75 :: 		}
L_end_EEPROM_SavePassword:
	RETURN      0
; end of _EEPROM_SavePassword

_EEPROM_ClearPassword:

;Password.c,82 :: 		void EEPROM_ClearPassword (uint8_t stAddr, uint8_t len){
;Password.c,84 :: 		for(i=0; i<len; i++){                        //Просто в цикле стираем в EEPROM
	CLRF        EEPROM_ClearPassword_i_L0+0 
L_EEPROM_ClearPassword16:
	MOVF        FARG_EEPROM_ClearPassword_len+0, 0 
	SUBWF       EEPROM_ClearPassword_i_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_EEPROM_ClearPassword17
;Password.c,85 :: 		EEPROM_write(stAddr+i, 0xFF);
	MOVF        EEPROM_ClearPassword_i_L0+0, 0 
	ADDWF       FARG_EEPROM_ClearPassword_stAddr+0, 0 
	MOVWF       FARG_EEPROM_Write_address+0 
	MOVLW       255
	MOVWF       FARG_EEPROM_Write_data_+0 
	CALL        _EEPROM_Write+0, 0
;Password.c,86 :: 		delay_us(100);
	MOVLW       2
	MOVWF       R12, 0
	MOVLW       141
	MOVWF       R13, 0
L_EEPROM_ClearPassword19:
	DECFSZ      R13, 1, 1
	BRA         L_EEPROM_ClearPassword19
	DECFSZ      R12, 1, 1
	BRA         L_EEPROM_ClearPassword19
	NOP
	NOP
;Password.c,84 :: 		for(i=0; i<len; i++){                        //Просто в цикле стираем в EEPROM
	INCF        EEPROM_ClearPassword_i_L0+0, 1 
;Password.c,87 :: 		}
	GOTO        L_EEPROM_ClearPassword16
L_EEPROM_ClearPassword17:
;Password.c,88 :: 		}
L_end_EEPROM_ClearPassword:
	RETURN      0
; end of _EEPROM_ClearPassword
