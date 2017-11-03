
_interrupt:

;GameTerminal_PS2_HID.c,34 :: 		void interrupt(){
;GameTerminal_PS2_HID.c,35 :: 		if(sysFlags.usb_on == 0)
	BTFSC       CVRCON+0, 1 
	GOTO        L_interrupt0
;GameTerminal_PS2_HID.c,36 :: 		USBDev_IntHandler();      // USB servicing is done inside the interrupt
	CALL        _USBDev_IntHandler+0, 0
L_interrupt0:
;GameTerminal_PS2_HID.c,37 :: 		PS2_interrupt();             //Прерывание по INT1 при поступлении данных с PS2
	CALL        _PS2_interrupt+0, 0
;GameTerminal_PS2_HID.c,38 :: 		PS2_Timeout_Interrupt();     //Прерывание по timer0 через 1мс в случае ошибочных данных по PS2
	CALL        _PS2_Timeout_Interrupt+0, 0
;GameTerminal_PS2_HID.c,39 :: 		}
L_end_interrupt:
L__interrupt95:
	RETFIE      1
; end of _interrupt

_USBDev_EventHandler:

;GameTerminal_PS2_HID.c,44 :: 		void USBDev_EventHandler(uint8_t event) {
;GameTerminal_PS2_HID.c,45 :: 		switch(event){
	GOTO        L_USBDev_EventHandler1
;GameTerminal_PS2_HID.c,46 :: 		case _USB_DEV_EVENT_CONFIGURED : USBFlags.if_conf = 1; break;
L_USBDev_EventHandler3:
	BSF         ADRESL+0, 1 
	GOTO        L_USBDev_EventHandler2
;GameTerminal_PS2_HID.c,50 :: 		case _USB_DEV_EVENT_SUSPENDED  : USBFlags.if_conf = 0; break;
L_USBDev_EventHandler4:
	BCF         ADRESL+0, 1 
	GOTO        L_USBDev_EventHandler2
;GameTerminal_PS2_HID.c,51 :: 		case _USB_DEV_EVENT_DISCONNECTED: USBFlags.if_conf = 0; break;
L_USBDev_EventHandler5:
	BCF         ADRESL+0, 1 
	GOTO        L_USBDev_EventHandler2
;GameTerminal_PS2_HID.c,53 :: 		default : break;
L_USBDev_EventHandler6:
	GOTO        L_USBDev_EventHandler2
;GameTerminal_PS2_HID.c,54 :: 		}
L_USBDev_EventHandler1:
	MOVF        FARG_USBDev_EventHandler_event+0, 0 
	XORLW       5
	BTFSC       STATUS+0, 2 
	GOTO        L_USBDev_EventHandler3
	MOVF        FARG_USBDev_EventHandler_event+0, 0 
	XORLW       6
	BTFSC       STATUS+0, 2 
	GOTO        L_USBDev_EventHandler4
	MOVF        FARG_USBDev_EventHandler_event+0, 0 
	XORLW       7
	BTFSC       STATUS+0, 2 
	GOTO        L_USBDev_EventHandler5
	GOTO        L_USBDev_EventHandler6
L_USBDev_EventHandler2:
;GameTerminal_PS2_HID.c,55 :: 		}
L_end_USBDev_EventHandler:
	RETURN      0
; end of _USBDev_EventHandler

_USBDev_DataReceivedHandler:

;GameTerminal_PS2_HID.c,58 :: 		void USBDev_DataReceivedHandler(uint8_t ep, uint16_t size) {
;GameTerminal_PS2_HID.c,59 :: 		USBFlags.hid_rec = 1;
	BSF         ADRESL+0, 2 
;GameTerminal_PS2_HID.c,60 :: 		}
L_end_USBDev_DataReceivedHandler:
	RETURN      0
; end of _USBDev_DataReceivedHandler

_USBDev_DataSentHandler:

;GameTerminal_PS2_HID.c,63 :: 		void USBDev_DataSentHandler(uint8_t ep) {
;GameTerminal_PS2_HID.c,65 :: 		}
L_end_USBDev_DataSentHandler:
	RETURN      0
; end of _USBDev_DataSentHandler

_Led_Indicate:

;GameTerminal_PS2_HID.c,72 :: 		void Led_Indicate(uint8_t blink){
;GameTerminal_PS2_HID.c,74 :: 		for(i=0; i<=blink; i++){
	CLRF        R1 
L_Led_Indicate7:
	MOVF        R1, 0 
	SUBWF       FARG_Led_Indicate_blink+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_Led_Indicate8
;GameTerminal_PS2_HID.c,75 :: 		LED_PIN = ~LED_PIN;
	BTG         PORTC+0, 2 
;GameTerminal_PS2_HID.c,76 :: 		delay_ms(100);
	MOVLW       7
	MOVWF       R11, 0
	MOVLW       23
	MOVWF       R12, 0
	MOVLW       106
	MOVWF       R13, 0
L_Led_Indicate10:
	DECFSZ      R13, 1, 1
	BRA         L_Led_Indicate10
	DECFSZ      R12, 1, 1
	BRA         L_Led_Indicate10
	DECFSZ      R11, 1, 1
	BRA         L_Led_Indicate10
	NOP
;GameTerminal_PS2_HID.c,74 :: 		for(i=0; i<=blink; i++){
	INCF        R1, 1 
;GameTerminal_PS2_HID.c,77 :: 		}
	GOTO        L_Led_Indicate7
L_Led_Indicate8:
;GameTerminal_PS2_HID.c,78 :: 		LED_PIN = 0;
	BCF         PORTC+0, 2 
;GameTerminal_PS2_HID.c,79 :: 		}
L_end_Led_Indicate:
	RETURN      0
; end of _Led_Indicate

_ArrCmp:

;GameTerminal_PS2_HID.c,88 :: 		uint8_t ArrCmp(uint8_t *arr1, const uint8_t *arr2, uint8_t pos, uint8_t ln){
;GameTerminal_PS2_HID.c,90 :: 		for (i=0; i<ln; i++){                                  //В цикле идет сравнение
	CLRF        R3 
L_ArrCmp11:
	MOVF        FARG_ArrCmp_ln+0, 0 
	SUBWF       R3, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_ArrCmp12
;GameTerminal_PS2_HID.c,91 :: 		if((arr1[i+pos] & 0x7F) != arr2[i]) return 0;       //массивов. 0х7F - маска, так как старший бит
	MOVF        FARG_ArrCmp_pos+0, 0 
	ADDWF       R3, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVF        R0, 0 
	ADDWF       FARG_ArrCmp_arr1+0, 0 
	MOVWF       FSR0 
	MOVF        R1, 0 
	ADDWFC      FARG_ArrCmp_arr1+1, 0 
	MOVWF       FSR0H 
	MOVLW       127
	ANDWF       POSTINC0+0, 0 
	MOVWF       R2 
	MOVF        R3, 0 
	ADDWF       FARG_ArrCmp_arr2+0, 0 
	MOVWF       TBLPTRL 
	MOVLW       0
	ADDWFC      FARG_ArrCmp_arr2+1, 0 
	MOVWF       TBLPTRH 
	MOVLW       0
	ADDWFC      FARG_ArrCmp_arr2+2, 0 
	MOVWF       TBLPTRU 
	TBLRD*+
	MOVFF       TABLAT+0, R1
	MOVF        R2, 0 
	XORWF       R1, 0 
	BTFSC       STATUS+0, 2 
	GOTO        L_ArrCmp14
	CLRF        R0 
	GOTO        L_end_ArrCmp
L_ArrCmp14:
;GameTerminal_PS2_HID.c,90 :: 		for (i=0; i<ln; i++){                                  //В цикле идет сравнение
	INCF        R3, 1 
;GameTerminal_PS2_HID.c,92 :: 		}                                                      //использоется для указания модификатора SHIFT
	GOTO        L_ArrCmp11
L_ArrCmp12:
;GameTerminal_PS2_HID.c,93 :: 		return 1;
	MOVLW       1
	MOVWF       R0 
;GameTerminal_PS2_HID.c,94 :: 		}
L_end_ArrCmp:
	RETURN      0
; end of _ArrCmp

_main:

;GameTerminal_PS2_HID.c,99 :: 		void main(){
;GameTerminal_PS2_HID.c,101 :: 		INTCON = 0;     //Запрещаются все прерывания
	CLRF        INTCON+0 
;GameTerminal_PS2_HID.c,103 :: 		ADCON1 = 0x0F;  //Сконфигурировать все порты нак цифровые
	MOVLW       15
	MOVWF       ADCON1+0 
;GameTerminal_PS2_HID.c,104 :: 		TRISA= 0b00010000;
	MOVLW       16
	MOVWF       TRISA+0 
;GameTerminal_PS2_HID.c,105 :: 		TRISB= 0b00000011;
	MOVLW       3
	MOVWF       TRISB+0 
;GameTerminal_PS2_HID.c,106 :: 		TRISC= 0b10111000;
	MOVLW       184
	MOVWF       TRISC+0 
;GameTerminal_PS2_HID.c,107 :: 		PORTA= 0;
	CLRF        PORTA+0 
;GameTerminal_PS2_HID.c,108 :: 		PORTB= 0;
	CLRF        PORTB+0 
;GameTerminal_PS2_HID.c,109 :: 		PORTC= 0;
	CLRF        PORTC+0 
;GameTerminal_PS2_HID.c,110 :: 		INTCON2.RBPU = 0;                      //Вклучить подтяжку
	BCF         INTCON2+0, 7 
;GameTerminal_PS2_HID.c,113 :: 		CVRCON = 0;                            //Сброс регистров флагов
	CLRF        CVRCON+0 
;GameTerminal_PS2_HID.c,114 :: 		ADRESL = 0;                            //переназначеных
	CLRF        ADRESL+0 
;GameTerminal_PS2_HID.c,115 :: 		Init_PS2();                            //Инициализация клавиатуры PS2
	CALL        _Init_PS2+0, 0
;GameTerminal_PS2_HID.c,116 :: 		UART1_Init(9600);                      //инициализация UART на 9600 bps
	BSF         BAUDCON+0, 3, 0
	MOVLW       4
	MOVWF       SPBRGH+0 
	MOVLW       225
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;GameTerminal_PS2_HID.c,118 :: 		sysConfig = EEPROM_Read(SYS_CONF_ADDR);
	CLRF        FARG_EEPROM_Read_address+0 
	CALL        _EEPROM_Read+0, 0
	MOVF        R0, 0 
	MOVWF       _sysConfig+0 
;GameTerminal_PS2_HID.c,119 :: 		if(sysConfig == 0xFF) EEPROM_Write(SYS_CONF_ADDR,0);      //Если ячейка не инициализирована то прошить режим по умолчанию
	MOVF        R0, 0 
	XORLW       255
	BTFSS       STATUS+0, 2 
	GOTO        L_main15
	CLRF        FARG_EEPROM_Write_address+0 
	CLRF        FARG_EEPROM_Write_data_+0 
	CALL        _EEPROM_Write+0, 0
L_main15:
;GameTerminal_PS2_HID.c,120 :: 		sysFlags.kb_mode = sysConfig & 0x01;
	MOVLW       1
	ANDWF       _sysConfig+0, 0 
	MOVWF       R0 
	BTFSC       R0, 0 
	GOTO        L__main102
	BCF         CVRCON+0, 0 
	GOTO        L__main103
L__main102:
	BSF         CVRCON+0, 0 
L__main103:
;GameTerminal_PS2_HID.c,121 :: 		sysFlags.usb_on = (sysConfig & 0x02)>>1;
	MOVLW       2
	ANDWF       _sysConfig+0, 0 
	MOVWF       R2 
	MOVF        R2, 0 
	MOVWF       R0 
	RRCF        R0, 1 
	BCF         R0, 7 
	BTFSC       R0, 0 
	GOTO        L__main104
	BCF         CVRCON+0, 1 
	GOTO        L__main105
L__main104:
	BSF         CVRCON+0, 1 
L__main105:
;GameTerminal_PS2_HID.c,122 :: 		sysFlags.kbBtn_mode = (sysConfig & 0x04)>>2;
	MOVLW       4
	ANDWF       _sysConfig+0, 0 
	MOVWF       R2 
	MOVF        R2, 0 
	MOVWF       R0 
	RRCF        R0, 1 
	BCF         R0, 7 
	RRCF        R0, 1 
	BCF         R0, 7 
	BTFSC       R0, 0 
	GOTO        L__main106
	BCF         CVRCON+0, 2 
	GOTO        L__main107
L__main106:
	BSF         CVRCON+0, 2 
L__main107:
;GameTerminal_PS2_HID.c,124 :: 		PWR12 = 1;                             //Включение питания 12В на плату
	BSF         PORTB+0, 3 
;GameTerminal_PS2_HID.c,127 :: 		if(sysFlags.usb_on == 0){
	BTFSC       CVRCON+0, 1 
	GOTO        L_main16
;GameTerminal_PS2_HID.c,128 :: 		USBDev_Init();
	CALL        _USBDev_Init+0, 0
;GameTerminal_PS2_HID.c,129 :: 		USBFlags.hid_rec = 0;
	BCF         ADRESL+0, 2 
;GameTerminal_PS2_HID.c,130 :: 		}
L_main16:
;GameTerminal_PS2_HID.c,131 :: 		IPEN_bit = 1;
	BSF         IPEN_bit+0, BitPos(IPEN_bit+0) 
;GameTerminal_PS2_HID.c,132 :: 		USBIP_bit = 1;
	BSF         USBIP_bit+0, BitPos(USBIP_bit+0) 
;GameTerminal_PS2_HID.c,133 :: 		USBIE_bit = 1;
	BSF         USBIE_bit+0, BitPos(USBIE_bit+0) 
;GameTerminal_PS2_HID.c,134 :: 		GIEH_bit = 1;
	BSF         GIEH_bit+0, BitPos(GIEH_bit+0) 
;GameTerminal_PS2_HID.c,136 :: 		GIE_bit = 1;
	BSF         GIE_bit+0, BitPos(GIE_bit+0) 
;GameTerminal_PS2_HID.c,137 :: 		PEIE_bit = 1;
	BSF         PEIE_bit+0, BitPos(PEIE_bit+0) 
;GameTerminal_PS2_HID.c,138 :: 		delay_ms(100);
	MOVLW       7
	MOVWF       R11, 0
	MOVLW       23
	MOVWF       R12, 0
	MOVLW       106
	MOVWF       R13, 0
L_main17:
	DECFSZ      R13, 1, 1
	BRA         L_main17
	DECFSZ      R12, 1, 1
	BRA         L_main17
	DECFSZ      R11, 1, 1
	BRA         L_main17
	NOP
;GameTerminal_PS2_HID.c,139 :: 		Reset_PS2();
	CALL        _Reset_PS2+0, 0
;GameTerminal_PS2_HID.c,140 :: 		Led_Indicate(2);                       //Индикация готовности
	MOVLW       2
	MOVWF       FARG_Led_Indicate_blink+0 
	CALL        _Led_Indicate+0, 0
;GameTerminal_PS2_HID.c,142 :: 		while(1) {
L_main18:
;GameTerminal_PS2_HID.c,143 :: 		asm clrwdt;                    //Сброс сторожевого таймера
	CLRWDT
;GameTerminal_PS2_HID.c,144 :: 		if(sysFlags.usb_on == ON)
	BTFSS       CVRCON+0, 1 
	GOTO        L_main20
;GameTerminal_PS2_HID.c,145 :: 		USB_StateInit();               //Определение состояние USB
	CALL        _USB_StateInit+0, 0
L_main20:
;GameTerminal_PS2_HID.c,148 :: 		if(button(&PORTC, RC7, 200, 0)){          //Если включение сработало
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
	GOTO        L_main21
;GameTerminal_PS2_HID.c,149 :: 		if(sysFlags.kbBtn_mode == KBBTN_10) LED_PIN = 1;
	BTFSC       CVRCON+0, 2 
	GOTO        L_main22
	BSF         PORTC+0, 2 
L_main22:
;GameTerminal_PS2_HID.c,150 :: 		if(keycode[0] == KEY_L_CTRL){         //Если зажат левый CTRL и при этом сработал ключ
	MOVF        _keycode+0, 0 
	XORLW       224
	BTFSS       STATUS+0, 2 
	GOTO        L_main23
;GameTerminal_PS2_HID.c,151 :: 		SendPassword(PASS_START_ADDR);     //Запускается функция введения сохраненного пароля
	MOVLW       1
	MOVWF       FARG_SendPassword+0 
	CALL        _SendPassword+0, 0
;GameTerminal_PS2_HID.c,152 :: 		delay_ms(9000);
	MOVLW       3
	MOVWF       R10, 0
	MOVLW       36
	MOVWF       R11, 0
	MOVLW       227
	MOVWF       R12, 0
	MOVLW       76
	MOVWF       R13, 0
L_main24:
	DECFSZ      R13, 1, 1
	BRA         L_main24
	DECFSZ      R12, 1, 1
	BRA         L_main24
	DECFSZ      R11, 1, 1
	BRA         L_main24
	DECFSZ      R10, 1, 1
	BRA         L_main24
	NOP
;GameTerminal_PS2_HID.c,153 :: 		} else {                              //Если левый CTRL не нажат то выполняется переход на плату
	GOTO        L_main25
L_main23:
;GameTerminal_PS2_HID.c,154 :: 		Reset_PS2();                       //Сброс клавиатуры
	CALL        _Reset_PS2+0, 0
;GameTerminal_PS2_HID.c,155 :: 		PWR5 = 1;                          //Включить 5В питание платы
	BSF         PORTB+0, 2 
;GameTerminal_PS2_HID.c,156 :: 		VIDEO_PIN = 1;                     //Переключить монитор на плату
	BSF         PORTB+0, 7 
;GameTerminal_PS2_HID.c,157 :: 		sysFlags.if_pc = 1;                //Запоминаем что мы на плате
	BSF         CVRCON+0, 4 
;GameTerminal_PS2_HID.c,158 :: 		}
L_main25:
;GameTerminal_PS2_HID.c,159 :: 		delay_ms(1000);
	MOVLW       61
	MOVWF       R11, 0
	MOVLW       225
	MOVWF       R12, 0
	MOVLW       63
	MOVWF       R13, 0
L_main26:
	DECFSZ      R13, 1, 1
	BRA         L_main26
	DECFSZ      R12, 1, 1
	BRA         L_main26
	DECFSZ      R11, 1, 1
	BRA         L_main26
	NOP
	NOP
;GameTerminal_PS2_HID.c,160 :: 		LED_PIN = 0;
	BCF         PORTC+0, 2 
;GameTerminal_PS2_HID.c,161 :: 		}
L_main21:
;GameTerminal_PS2_HID.c,164 :: 		if(USBFlags.hid_rec == 1){
	BTFSS       ADRESL+0, 2 
	GOTO        L_main27
;GameTerminal_PS2_HID.c,165 :: 		USBFlags.hid_rec = 0;
	BCF         ADRESL+0, 2 
;GameTerminal_PS2_HID.c,166 :: 		PS2_Send(SET_KEYB_INDICATORS);
	MOVLW       237
	MOVWF       FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;GameTerminal_PS2_HID.c,167 :: 		delay_ms(10);
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_main28:
	DECFSZ      R13, 1, 1
	BRA         L_main28
	DECFSZ      R12, 1, 1
	BRA         L_main28
;GameTerminal_PS2_HID.c,168 :: 		PS2_Send(USB_GetLEDs());
	CALL        _USB_GetLEDs+0, 0
	MOVF        R0, 0 
	MOVWF       FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;GameTerminal_PS2_HID.c,169 :: 		USB_ReceiveBuffSet();             // Prepere buffer for reception of next packet
	CALL        _USB_ReceiveBuffSet+0, 0
;GameTerminal_PS2_HID.c,170 :: 		}
L_main27:
;GameTerminal_PS2_HID.c,177 :: 		if(sysFlags.if_pc == 1){                         //Если на плате
	BTFSS       CVRCON+0, 4 
	GOTO        L_main29
;GameTerminal_PS2_HID.c,178 :: 		switch(keycode[0]){
	GOTO        L_main30
;GameTerminal_PS2_HID.c,179 :: 		case KEY_F12: if(sysFlags.kb_mode == 0)                         //Обработка нажатия кнопки F12 (выход из программирования)
L_main32:
	BTFSC       CVRCON+0, 0 
	GOTO        L_main33
;GameTerminal_PS2_HID.c,180 :: 		uart_write(RDR_PRG_END);
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
L_main33:
;GameTerminal_PS2_HID.c,181 :: 		break;
	GOTO        L_main31
;GameTerminal_PS2_HID.c,182 :: 		case KEY_F5 : if(sysFlags.kb_mode == 0){                        //Обработка переключения на консоль
L_main34:
	BTFSC       CVRCON+0, 0 
	GOTO        L_main35
;GameTerminal_PS2_HID.c,183 :: 		if(--kybCnt == 0){
	DECF        _kybCnt+0, 1 
	MOVF        _kybCnt+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main36
;GameTerminal_PS2_HID.c,184 :: 		sysConfig |= 1;
	MOVLW       1
	IORWF       _sysConfig+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       _sysConfig+0 
;GameTerminal_PS2_HID.c,185 :: 		EEPROM_Write(SYS_CONF_ADDR,sysConfig);
	CLRF        FARG_EEPROM_Write_address+0 
	MOVF        R0, 0 
	MOVWF       FARG_EEPROM_Write_data_+0 
	CALL        _EEPROM_Write+0, 0
;GameTerminal_PS2_HID.c,186 :: 		sysFlags.kb_mode = 1;
	BSF         CVRCON+0, 0 
;GameTerminal_PS2_HID.c,188 :: 		kybCnt = KYBCNT_DELAY;
	MOVLW       50
	MOVWF       _kybCnt+0 
;GameTerminal_PS2_HID.c,189 :: 		uart_write(RDR_PRG_END);
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
;GameTerminal_PS2_HID.c,190 :: 		}
L_main36:
;GameTerminal_PS2_HID.c,191 :: 		} break;
L_main35:
	GOTO        L_main31
;GameTerminal_PS2_HID.c,192 :: 		case KEY_NUM_ENTR : if(sysFlags.kb_mode == 1){                  //Обработка переключения на клавиатуру
L_main37:
	BTFSS       CVRCON+0, 0 
	GOTO        L_main38
;GameTerminal_PS2_HID.c,193 :: 		if(--kybCnt == 0){
	DECF        _kybCnt+0, 1 
	MOVF        _kybCnt+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main39
;GameTerminal_PS2_HID.c,194 :: 		sysConfig &= ~1;
	MOVLW       254
	ANDWF       _sysConfig+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       _sysConfig+0 
;GameTerminal_PS2_HID.c,195 :: 		EEPROM_Write(SYS_CONF_ADDR,sysConfig);
	CLRF        FARG_EEPROM_Write_address+0 
	MOVF        R0, 0 
	MOVWF       FARG_EEPROM_Write_data_+0 
	CALL        _EEPROM_Write+0, 0
;GameTerminal_PS2_HID.c,196 :: 		sysFlags.kb_mode = 0;
	BCF         CVRCON+0, 0 
;GameTerminal_PS2_HID.c,198 :: 		kybCnt = KYBCNT_DELAY;
	MOVLW       50
	MOVWF       _kybCnt+0 
;GameTerminal_PS2_HID.c,199 :: 		uart_write(RDR_PRG_END);
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
;GameTerminal_PS2_HID.c,200 :: 		}
L_main39:
;GameTerminal_PS2_HID.c,201 :: 		} break;
L_main38:
	GOTO        L_main31
;GameTerminal_PS2_HID.c,202 :: 		default : kybCnt = KYBCNT_DELAY; break;                       //Сброс счетчика если кнопка отпущена или нажата другая кнопка
L_main40:
	MOVLW       50
	MOVWF       _kybCnt+0 
	GOTO        L_main31
;GameTerminal_PS2_HID.c,203 :: 		}
L_main30:
	MOVF        _keycode+0, 0 
	XORLW       69
	BTFSC       STATUS+0, 2 
	GOTO        L_main32
	MOVF        _keycode+0, 0 
	XORLW       62
	BTFSC       STATUS+0, 2 
	GOTO        L_main34
	MOVF        _keycode+0, 0 
	XORLW       88
	BTFSC       STATUS+0, 2 
	GOTO        L_main37
	GOTO        L_main40
L_main31:
;GameTerminal_PS2_HID.c,207 :: 		if(ArrCmp(&progPass, &progStr, (PASS_BUFF_SIZE - (sizeof(progStr)+1)), sizeof(progStr))){
	MOVLW       _progPass+0
	MOVWF       FARG_ArrCmp_arr1+0 
	MOVLW       hi_addr(_progPass+0)
	MOVWF       FARG_ArrCmp_arr1+1 
	MOVLW       _progStr+0
	MOVWF       FARG_ArrCmp_arr2+0 
	MOVLW       hi_addr(_progStr+0)
	MOVWF       FARG_ArrCmp_arr2+1 
	MOVLW       higher_addr(_progStr+0)
	MOVWF       FARG_ArrCmp_arr2+2 
	MOVLW       15
	MOVWF       FARG_ArrCmp_pos+0 
	MOVLW       16
	MOVWF       FARG_ArrCmp_ln+0 
	CALL        _ArrCmp+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main41
;GameTerminal_PS2_HID.c,208 :: 		switch(progPass[PASS_BUFF_SIZE-1]){
	GOTO        L_main42
;GameTerminal_PS2_HID.c,209 :: 		case KEY_1: UART1_Write(RDR_PRG_CH1); break;   //программирование1 - кредитный
L_main44:
	MOVLW       201
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main43
;GameTerminal_PS2_HID.c,210 :: 		case KEY_2: UART1_Write(RDR_PRG_CH2); break;   //программирование2 - сьемный
L_main45:
	MOVLW       202
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main43
;GameTerminal_PS2_HID.c,211 :: 		case KEY_3: UART1_Write(RDR_PRG_CH3); break;   //программирование3 - овнер
L_main46:
	MOVLW       203
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main43
;GameTerminal_PS2_HID.c,212 :: 		case KEY_4: UART1_Write(RDR_PRG_CH4); break;   //программирование4 - админ
L_main47:
	MOVLW       204
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main43
;GameTerminal_PS2_HID.c,213 :: 		case KEY_0: EEPROM_Write(0xFF,0xFF);           //Переход в режим бутлодера
L_main48:
	MOVLW       255
	MOVWF       FARG_EEPROM_Write_address+0 
	MOVLW       255
	MOVWF       FARG_EEPROM_Write_data_+0 
	CALL        _EEPROM_Write+0, 0
;GameTerminal_PS2_HID.c,214 :: 		USBEN_bit = 0;                     //Выключение HID устройства
	BCF         USBEN_bit+0, BitPos(USBEN_bit+0) 
;GameTerminal_PS2_HID.c,215 :: 		delay_ms(10);                      //Задержка для ПК, чтобы успел отключить
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_main49:
	DECFSZ      R13, 1, 1
	BRA         L_main49
	DECFSZ      R12, 1, 1
	BRA         L_main49
;GameTerminal_PS2_HID.c,216 :: 		asm RESET; break;                  //Сброс МК
	RESET
	GOTO        L_main43
;GameTerminal_PS2_HID.c,217 :: 		case KEY_P: uart_write(RDR_PRG_END);           //Вход в режим программирования пароля, пикаем разок
L_main50:
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
;GameTerminal_PS2_HID.c,218 :: 		sysFlags.wr_pass = 1;              //устанавливаем соответствующий флаг
	BSF         CVRCON+0, 3 
;GameTerminal_PS2_HID.c,219 :: 		memset(progPass, 0, PASS_BUFF_SIZE);//очищаем массив ввода пароля
	MOVLW       _progPass+0
	MOVWF       FARG_memset_p1+0 
	MOVLW       hi_addr(_progPass+0)
	MOVWF       FARG_memset_p1+1 
	CLRF        FARG_memset_character+0 
	MOVLW       32
	MOVWF       FARG_memset_n+0 
	MOVLW       0
	MOVWF       FARG_memset_n+1 
	CALL        _memset+0, 0
;GameTerminal_PS2_HID.c,220 :: 		PS2_Send(SET_KEYB_INDICATORS);     //Зажигаем на клавиатуре светодиод SCR LOCK
	MOVLW       237
	MOVWF       FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;GameTerminal_PS2_HID.c,221 :: 		delay_ms(10);
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_main51:
	DECFSZ      R13, 1, 1
	BRA         L_main51
	DECFSZ      R12, 1, 1
	BRA         L_main51
;GameTerminal_PS2_HID.c,222 :: 		PS2_Send(SET_SCRL_LED);
	MOVLW       1
	MOVWF       FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;GameTerminal_PS2_HID.c,223 :: 		break;
	GOTO        L_main43
;GameTerminal_PS2_HID.c,224 :: 		case KEY_U: uart_write(RDR_PRG_END);
L_main52:
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
;GameTerminal_PS2_HID.c,225 :: 		sysConfig &= ~(1<<1);
	MOVLW       253
	ANDWF       _sysConfig+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       _sysConfig+0 
;GameTerminal_PS2_HID.c,226 :: 		EEPROM_write(SYS_CONF_ADDR,sysConfig);
	CLRF        FARG_EEPROM_Write_address+0 
	MOVF        R0, 0 
	MOVWF       FARG_EEPROM_Write_data_+0 
	CALL        _EEPROM_Write+0, 0
;GameTerminal_PS2_HID.c,227 :: 		delay_ms(10);
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_main53:
	DECFSZ      R13, 1, 1
	BRA         L_main53
	DECFSZ      R12, 1, 1
	BRA         L_main53
;GameTerminal_PS2_HID.c,228 :: 		asm RESET;
	RESET
;GameTerminal_PS2_HID.c,229 :: 		break;
	GOTO        L_main43
;GameTerminal_PS2_HID.c,230 :: 		case KEY_E: sysConfig |= (1<<2);
L_main54:
	MOVLW       4
	IORWF       _sysConfig+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       _sysConfig+0 
;GameTerminal_PS2_HID.c,231 :: 		EEPROM_write(SYS_CONF_ADDR, sysConfig);
	CLRF        FARG_EEPROM_Write_address+0 
	MOVF        R0, 0 
	MOVWF       FARG_EEPROM_Write_data_+0 
	CALL        _EEPROM_Write+0, 0
;GameTerminal_PS2_HID.c,232 :: 		sysFlags.kbBtn_mode = 1;
	BSF         CVRCON+0, 2 
;GameTerminal_PS2_HID.c,233 :: 		uart_write(RDR_PRG_END);
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
;GameTerminal_PS2_HID.c,234 :: 		break;
	GOTO        L_main43
;GameTerminal_PS2_HID.c,235 :: 		default: break;
L_main55:
	GOTO        L_main43
;GameTerminal_PS2_HID.c,236 :: 		}
L_main42:
	MOVF        _progPass+31, 0 
	XORLW       30
	BTFSC       STATUS+0, 2 
	GOTO        L_main44
	MOVF        _progPass+31, 0 
	XORLW       31
	BTFSC       STATUS+0, 2 
	GOTO        L_main45
	MOVF        _progPass+31, 0 
	XORLW       32
	BTFSC       STATUS+0, 2 
	GOTO        L_main46
	MOVF        _progPass+31, 0 
	XORLW       33
	BTFSC       STATUS+0, 2 
	GOTO        L_main47
	MOVF        _progPass+31, 0 
	XORLW       39
	BTFSC       STATUS+0, 2 
	GOTO        L_main48
	MOVF        _progPass+31, 0 
	XORLW       19
	BTFSC       STATUS+0, 2 
	GOTO        L_main50
	MOVF        _progPass+31, 0 
	XORLW       24
	BTFSC       STATUS+0, 2 
	GOTO        L_main52
	MOVF        _progPass+31, 0 
	XORLW       8
	BTFSC       STATUS+0, 2 
	GOTO        L_main54
	GOTO        L_main55
L_main43:
;GameTerminal_PS2_HID.c,237 :: 		progPass[PASS_BUFF_SIZE-2] = 0;                  //Сброс ввода фразы
	CLRF        _progPass+30 
;GameTerminal_PS2_HID.c,238 :: 		}
	GOTO        L_main56
L_main41:
;GameTerminal_PS2_HID.c,242 :: 		else if(ArrCmp(&progPass, &delStr, PASS_BUFF_SIZE - sizeof(delStr) - 1, sizeof(delStr))){
	MOVLW       _progPass+0
	MOVWF       FARG_ArrCmp_arr1+0 
	MOVLW       hi_addr(_progPass+0)
	MOVWF       FARG_ArrCmp_arr1+1 
	MOVLW       _delStr+0
	MOVWF       FARG_ArrCmp_arr2+0 
	MOVLW       hi_addr(_delStr+0)
	MOVWF       FARG_ArrCmp_arr2+1 
	MOVLW       higher_addr(_delStr+0)
	MOVWF       FARG_ArrCmp_arr2+2 
	MOVLW       23
	MOVWF       FARG_ArrCmp_pos+0 
	MOVLW       8
	MOVWF       FARG_ArrCmp_ln+0 
	CALL        _ArrCmp+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main57
;GameTerminal_PS2_HID.c,243 :: 		switch(progPass[PASS_BUFF_SIZE-1]){
	GOTO        L_main58
;GameTerminal_PS2_HID.c,244 :: 		case KEY_1: UART1_Write(RDR_CLR_CH1); break;   //Удаление1 - кредитный
L_main60:
	MOVLW       205
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main59
;GameTerminal_PS2_HID.c,245 :: 		case KEY_2: UART1_Write(RDR_CLR_CH2); break;   //Удаление2 - сьемный
L_main61:
	MOVLW       206
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main59
;GameTerminal_PS2_HID.c,246 :: 		case KEY_3: UART1_Write(RDR_CLR_CH3); break;   //Удаление3 - овнер
L_main62:
	MOVLW       207
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main59
;GameTerminal_PS2_HID.c,247 :: 		case KEY_4: UART1_Write(RDR_CLR_CH4); break;   //Удаление4 - админ
L_main63:
	MOVLW       208
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main59
;GameTerminal_PS2_HID.c,248 :: 		case KEY_5: UART1_Write(RDR_CLR_ALL); break;   //Удаление5 - всех ключей
L_main64:
	MOVLW       209
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main59
;GameTerminal_PS2_HID.c,249 :: 		case KEY_P: EEPROM_ClearPassword(PASS_START_ADDR, PASS_BUFF_SIZE); //Удаление пароля ввода
L_main65:
	MOVLW       1
	MOVWF       FARG_EEPROM_ClearPassword+0 
	MOVLW       32
	MOVWF       FARG_EEPROM_ClearPassword+0 
	CALL        _EEPROM_ClearPassword+0, 0
;GameTerminal_PS2_HID.c,250 :: 		uart_write(RDR_PRG_END);            //Пикаем по завершении
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
;GameTerminal_PS2_HID.c,251 :: 		break;
	GOTO        L_main59
;GameTerminal_PS2_HID.c,252 :: 		case KEY_U: uart_write(RDR_PRG_END);
L_main66:
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
;GameTerminal_PS2_HID.c,253 :: 		sysConfig |= (1<<1);
	MOVLW       2
	IORWF       _sysConfig+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       _sysConfig+0 
;GameTerminal_PS2_HID.c,254 :: 		EEPROM_write(SYS_CONF_ADDR, sysConfig);
	CLRF        FARG_EEPROM_Write_address+0 
	MOVF        R0, 0 
	MOVWF       FARG_EEPROM_Write_data_+0 
	CALL        _EEPROM_Write+0, 0
;GameTerminal_PS2_HID.c,255 :: 		USBEN_bit = 0;                     //Выключение HID устройства
	BCF         USBEN_bit+0, BitPos(USBEN_bit+0) 
;GameTerminal_PS2_HID.c,256 :: 		delay_ms(10);
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_main67:
	DECFSZ      R13, 1, 1
	BRA         L_main67
	DECFSZ      R12, 1, 1
	BRA         L_main67
;GameTerminal_PS2_HID.c,257 :: 		asm RESET;
	RESET
;GameTerminal_PS2_HID.c,258 :: 		break;
	GOTO        L_main59
;GameTerminal_PS2_HID.c,259 :: 		case KEY_E: sysConfig &= ~(1<<2);
L_main68:
	MOVLW       251
	ANDWF       _sysConfig+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       _sysConfig+0 
;GameTerminal_PS2_HID.c,260 :: 		EEPROM_write(SYS_CONF_ADDR, sysConfig);
	CLRF        FARG_EEPROM_Write_address+0 
	MOVF        R0, 0 
	MOVWF       FARG_EEPROM_Write_data_+0 
	CALL        _EEPROM_Write+0, 0
;GameTerminal_PS2_HID.c,261 :: 		sysFlags.kbBtn_mode = 0;
	BCF         CVRCON+0, 2 
;GameTerminal_PS2_HID.c,262 :: 		uart_write(RDR_PRG_END);
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
;GameTerminal_PS2_HID.c,263 :: 		break;
	GOTO        L_main59
;GameTerminal_PS2_HID.c,264 :: 		default: break;
L_main69:
	GOTO        L_main59
;GameTerminal_PS2_HID.c,265 :: 		}
L_main58:
	MOVF        _progPass+31, 0 
	XORLW       30
	BTFSC       STATUS+0, 2 
	GOTO        L_main60
	MOVF        _progPass+31, 0 
	XORLW       31
	BTFSC       STATUS+0, 2 
	GOTO        L_main61
	MOVF        _progPass+31, 0 
	XORLW       32
	BTFSC       STATUS+0, 2 
	GOTO        L_main62
	MOVF        _progPass+31, 0 
	XORLW       33
	BTFSC       STATUS+0, 2 
	GOTO        L_main63
	MOVF        _progPass+31, 0 
	XORLW       34
	BTFSC       STATUS+0, 2 
	GOTO        L_main64
	MOVF        _progPass+31, 0 
	XORLW       19
	BTFSC       STATUS+0, 2 
	GOTO        L_main65
	MOVF        _progPass+31, 0 
	XORLW       24
	BTFSC       STATUS+0, 2 
	GOTO        L_main66
	MOVF        _progPass+31, 0 
	XORLW       8
	BTFSC       STATUS+0, 2 
	GOTO        L_main68
	GOTO        L_main69
L_main59:
;GameTerminal_PS2_HID.c,266 :: 		progPass[PASS_BUFF_SIZE-2] = 0;                    //Сброс ввода фразы
	CLRF        _progPass+30 
;GameTerminal_PS2_HID.c,267 :: 		}
L_main57:
L_main56:
;GameTerminal_PS2_HID.c,271 :: 		if(sysFlags.wr_pass == 1 && keycode[0] == KEY_ENTER){            //Если установлен флаг записи пароля и нажата кнопка ENTER
	BTFSS       CVRCON+0, 3 
	GOTO        L_main72
	MOVF        _keycode+0, 0 
	XORLW       40
	BTFSS       STATUS+0, 2 
	GOTO        L_main72
L__main93:
;GameTerminal_PS2_HID.c,273 :: 		passCnt = PASS_BUFF_SIZE-1;                                   //Счетчику символов присваевается максимальное колличество символов
	MOVLW       31
	MOVWF       _passCnt+0 
;GameTerminal_PS2_HID.c,274 :: 		while(progPass[passCnt] != 0 && passCnt >= 0) passCnt--;      //Определяется сколько символов введено (вернее сколько осталось пустых ячеек)
L_main73:
	MOVLW       _progPass+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_progPass+0)
	MOVWF       FSR0H 
	MOVF        _passCnt+0, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_main74
	MOVLW       0
	SUBWF       _passCnt+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_main74
L__main92:
	DECF        _passCnt+0, 1 
	GOTO        L_main73
L_main74:
;GameTerminal_PS2_HID.c,275 :: 		if(passCnt != PASS_BUFF_SIZE-1){                              //Если введен хотябы один символ происходит сохранение его в память
	MOVF        _passCnt+0, 0 
	XORLW       31
	BTFSC       STATUS+0, 2 
	GOTO        L_main77
;GameTerminal_PS2_HID.c,276 :: 		EEPROM_ClearPassword(PASS_START_ADDR, PASS_BUFF_SIZE);     //Выполняется очистка старого пароля
	MOVLW       1
	MOVWF       FARG_EEPROM_ClearPassword+0 
	MOVLW       32
	MOVWF       FARG_EEPROM_ClearPassword+0 
	CALL        _EEPROM_ClearPassword+0, 0
;GameTerminal_PS2_HID.c,277 :: 		EEPROM_SavePassword(&progPass+(passCnt+1), PASS_BUFF_SIZE - (passCnt+1), PASS_START_ADDR);//Сохраняется новый пароль
	MOVF        _passCnt+0, 0 
	ADDLW       1
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVLW       _progPass+0
	ADDWF       R0, 0 
	MOVWF       FARG_EEPROM_SavePassword+0 
	MOVLW       hi_addr(_progPass+0)
	ADDWFC      R1, 0 
	MOVWF       FARG_EEPROM_SavePassword+1 
	MOVF        R0, 0 
	SUBLW       32
	MOVWF       FARG_EEPROM_SavePassword+0 
	MOVLW       1
	MOVWF       FARG_EEPROM_SavePassword+0 
	CALL        _EEPROM_SavePassword+0, 0
;GameTerminal_PS2_HID.c,278 :: 		PS2_Send(SET_KEYB_INDICATORS);                             //Гасим светодиоды клавиатуры
	MOVLW       237
	MOVWF       FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;GameTerminal_PS2_HID.c,279 :: 		delay_ms(10);
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_main78:
	DECFSZ      R13, 1, 1
	BRA         L_main78
	DECFSZ      R12, 1, 1
	BRA         L_main78
;GameTerminal_PS2_HID.c,280 :: 		PS2_Send(SET_OFF_LED);
	CLRF        FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;GameTerminal_PS2_HID.c,281 :: 		uart_write(RDR_PRG_END);                                   //Разок пикаем
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
;GameTerminal_PS2_HID.c,282 :: 		} else {                                                      //Если не введено ни одного символа
	GOTO        L_main79
L_main77:
;GameTerminal_PS2_HID.c,283 :: 		PS2_Send(SET_KEYB_INDICATORS);                             //Включаем все светодиоды
	MOVLW       237
	MOVWF       FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;GameTerminal_PS2_HID.c,284 :: 		delay_ms(10);
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_main80:
	DECFSZ      R13, 1, 1
	BRA         L_main80
	DECFSZ      R12, 1, 1
	BRA         L_main80
;GameTerminal_PS2_HID.c,285 :: 		PS2_Send(SET_NUM_LED | SET_CAPS_LED | SET_SCRL_LED);
	MOVLW       7
	MOVWF       FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;GameTerminal_PS2_HID.c,286 :: 		delay_ms(1000);                                            //ждем секунду
	MOVLW       61
	MOVWF       R11, 0
	MOVLW       225
	MOVWF       R12, 0
	MOVLW       63
	MOVWF       R13, 0
L_main81:
	DECFSZ      R13, 1, 1
	BRA         L_main81
	DECFSZ      R12, 1, 1
	BRA         L_main81
	DECFSZ      R11, 1, 1
	BRA         L_main81
	NOP
	NOP
;GameTerminal_PS2_HID.c,287 :: 		PS2_Send(SET_KEYB_INDICATORS);                             //Гасим все светодиоды
	MOVLW       237
	MOVWF       FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;GameTerminal_PS2_HID.c,288 :: 		delay_ms(10);
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_main82:
	DECFSZ      R13, 1, 1
	BRA         L_main82
	DECFSZ      R12, 1, 1
	BRA         L_main82
;GameTerminal_PS2_HID.c,289 :: 		PS2_Send(SET_OFF_LED);
	CLRF        FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;GameTerminal_PS2_HID.c,290 :: 		uart_write(RDR_PRG_END);                                   //Пикаем два раза
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
;GameTerminal_PS2_HID.c,291 :: 		delay_ms(600);
	MOVLW       37
	MOVWF       R11, 0
	MOVLW       135
	MOVWF       R12, 0
	MOVLW       139
	MOVWF       R13, 0
L_main83:
	DECFSZ      R13, 1, 1
	BRA         L_main83
	DECFSZ      R12, 1, 1
	BRA         L_main83
	DECFSZ      R11, 1, 1
	BRA         L_main83
	NOP
	NOP
;GameTerminal_PS2_HID.c,292 :: 		uart_write(RDR_PRG_END);
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
;GameTerminal_PS2_HID.c,293 :: 		}
L_main79:
;GameTerminal_PS2_HID.c,294 :: 		sysFlags.wr_pass = 0;                                         //сбрасываем флаг записи пароля
	BCF         CVRCON+0, 3 
;GameTerminal_PS2_HID.c,295 :: 		}
L_main72:
;GameTerminal_PS2_HID.c,296 :: 		delay_ms(100);                                 //Задержка, от этой задержки зависит время зажатия кнопок на переключение между клавиатурой и консолью
	MOVLW       7
	MOVWF       R11, 0
	MOVLW       23
	MOVWF       R12, 0
	MOVLW       106
	MOVWF       R13, 0
L_main84:
	DECFSZ      R13, 1, 1
	BRA         L_main84
	DECFSZ      R12, 1, 1
	BRA         L_main84
	DECFSZ      R11, 1, 1
	BRA         L_main84
	NOP
;GameTerminal_PS2_HID.c,297 :: 		}else if(sysFlags.if_pc == 0){
	GOTO        L_main85
L_main29:
	BTFSC       CVRCON+0, 4 
	GOTO        L_main86
;GameTerminal_PS2_HID.c,298 :: 		PWR5 = 0;                                 //Сбрасываем питание с платы
	BCF         PORTB+0, 2 
;GameTerminal_PS2_HID.c,299 :: 		VIDEO_PIN = 0;                            //Переключаемся на ПК
	BCF         PORTB+0, 7 
;GameTerminal_PS2_HID.c,300 :: 		if(USBFlags.if_conf == 1){                  //Если USB подключен выполняется обработка и отправка кнопки
	BTFSS       ADRESL+0, 1 
	GOTO        L_main87
;GameTerminal_PS2_HID.c,305 :: 		if(keycode[0] != 0)                      //Если есть хотябы одно нажате кнопки
	MOVF        _keycode+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_main88
;GameTerminal_PS2_HID.c,306 :: 		USBFlags.upBtn == 0;                //Сбросить флаг отпущеной кнопки
L_main88:
;GameTerminal_PS2_HID.c,307 :: 		if(USBFlags.upBtn == 0){                 //Если есть нажатие то выполняется
	BTFSC       ADRESL+0, 0 
	GOTO        L_main89
;GameTerminal_PS2_HID.c,308 :: 		SendKeys(&keycode, modifier);          //Отправка кнопок клавиатуры
	MOVLW       _keycode+0
	MOVWF       FARG_SendKeys+0 
	MOVLW       hi_addr(_keycode+0)
	MOVWF       FARG_SendKeys+1 
	MOVF        _modifier+0, 0 
	MOVWF       FARG_SendKeys+0 
	CALL        _SendKeys+0, 0
;GameTerminal_PS2_HID.c,309 :: 		if(keycode[0] == 0){                   //Если нет не одной нажатой кнопки
	MOVF        _keycode+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main90
;GameTerminal_PS2_HID.c,311 :: 		SendNoKeys();                       //Отправляем нули (нет нажатой кнопки)
	CALL        _SendNoKeys+0, 0
;GameTerminal_PS2_HID.c,312 :: 		}
L_main90:
;GameTerminal_PS2_HID.c,313 :: 		}
L_main89:
;GameTerminal_PS2_HID.c,314 :: 		}
L_main87:
;GameTerminal_PS2_HID.c,315 :: 		delay_ms(30);
	MOVLW       2
	MOVWF       R11, 0
	MOVLW       212
	MOVWF       R12, 0
	MOVLW       133
	MOVWF       R13, 0
L_main91:
	DECFSZ      R13, 1, 1
	BRA         L_main91
	DECFSZ      R12, 1, 1
	BRA         L_main91
	DECFSZ      R11, 1, 1
	BRA         L_main91
;GameTerminal_PS2_HID.c,316 :: 		}
L_main86:
L_main85:
;GameTerminal_PS2_HID.c,317 :: 		}
	GOTO        L_main18
;GameTerminal_PS2_HID.c,318 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
