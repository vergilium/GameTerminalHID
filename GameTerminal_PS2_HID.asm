
_interrupt:

;GameTerminal_PS2_HID.c,31 :: 		void interrupt(){
;GameTerminal_PS2_HID.c,32 :: 		USBDev_IntHandler();         // USB servicing is done inside the interrupt
	CALL        _USBDev_IntHandler+0, 0
;GameTerminal_PS2_HID.c,33 :: 		PS2_interrupt();             //Прерывание по INT1 при поступлении данных с PS2
	CALL        _PS2_interrupt+0, 0
;GameTerminal_PS2_HID.c,34 :: 		PS2_Timeout_Interrupt();     //Прерывание по timer0 через 1мс в случае ошибочных данных по PS2
	CALL        _PS2_Timeout_Interrupt+0, 0
;GameTerminal_PS2_HID.c,35 :: 		}
L_end_interrupt:
L__interrupt91:
	RETFIE      1
; end of _interrupt

_USBDev_EventHandler:

;GameTerminal_PS2_HID.c,40 :: 		void USBDev_EventHandler(uint8_t event) {
;GameTerminal_PS2_HID.c,41 :: 		switch(event){
	GOTO        L_USBDev_EventHandler0
;GameTerminal_PS2_HID.c,42 :: 		case _USB_DEV_EVENT_CONFIGURED : USBFlags.if_conf = 1; break;
L_USBDev_EventHandler2:
	BSF         ADRESL+0, 1 
	GOTO        L_USBDev_EventHandler1
;GameTerminal_PS2_HID.c,46 :: 		case _USB_DEV_EVENT_SUSPENDED  : USBFlags.if_conf = 0; break;
L_USBDev_EventHandler3:
	BCF         ADRESL+0, 1 
	GOTO        L_USBDev_EventHandler1
;GameTerminal_PS2_HID.c,47 :: 		case _USB_DEV_EVENT_DISCONNECTED: USBFlags.if_conf = 0; break;
L_USBDev_EventHandler4:
	BCF         ADRESL+0, 1 
	GOTO        L_USBDev_EventHandler1
;GameTerminal_PS2_HID.c,49 :: 		default : break;
L_USBDev_EventHandler5:
	GOTO        L_USBDev_EventHandler1
;GameTerminal_PS2_HID.c,50 :: 		}
L_USBDev_EventHandler0:
	MOVF        FARG_USBDev_EventHandler_event+0, 0 
	XORLW       5
	BTFSC       STATUS+0, 2 
	GOTO        L_USBDev_EventHandler2
	MOVF        FARG_USBDev_EventHandler_event+0, 0 
	XORLW       6
	BTFSC       STATUS+0, 2 
	GOTO        L_USBDev_EventHandler3
	MOVF        FARG_USBDev_EventHandler_event+0, 0 
	XORLW       7
	BTFSC       STATUS+0, 2 
	GOTO        L_USBDev_EventHandler4
	GOTO        L_USBDev_EventHandler5
L_USBDev_EventHandler1:
;GameTerminal_PS2_HID.c,51 :: 		}
L_end_USBDev_EventHandler:
	RETURN      0
; end of _USBDev_EventHandler

_USBDev_DataReceivedHandler:

;GameTerminal_PS2_HID.c,54 :: 		void USBDev_DataReceivedHandler(uint8_t ep, uint16_t size) {
;GameTerminal_PS2_HID.c,55 :: 		USBFlags.hid_rec = 1;
	BSF         ADRESL+0, 2 
;GameTerminal_PS2_HID.c,56 :: 		}
L_end_USBDev_DataReceivedHandler:
	RETURN      0
; end of _USBDev_DataReceivedHandler

_USBDev_DataSentHandler:

;GameTerminal_PS2_HID.c,59 :: 		void USBDev_DataSentHandler(uint8_t ep) {
;GameTerminal_PS2_HID.c,61 :: 		}
L_end_USBDev_DataSentHandler:
	RETURN      0
; end of _USBDev_DataSentHandler

_Led_Indicate:

;GameTerminal_PS2_HID.c,68 :: 		void Led_Indicate(uint8_t blink){
;GameTerminal_PS2_HID.c,70 :: 		for(i=0; i<=blink; i++){
	CLRF        R1 
L_Led_Indicate6:
	MOVF        R1, 0 
	SUBWF       FARG_Led_Indicate_blink+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_Led_Indicate7
;GameTerminal_PS2_HID.c,71 :: 		LED_PIN = ~LED_PIN;
	BTG         PORTC+0, 2 
;GameTerminal_PS2_HID.c,72 :: 		delay_ms(100);
	MOVLW       7
	MOVWF       R11, 0
	MOVLW       23
	MOVWF       R12, 0
	MOVLW       106
	MOVWF       R13, 0
L_Led_Indicate9:
	DECFSZ      R13, 1, 1
	BRA         L_Led_Indicate9
	DECFSZ      R12, 1, 1
	BRA         L_Led_Indicate9
	DECFSZ      R11, 1, 1
	BRA         L_Led_Indicate9
	NOP
;GameTerminal_PS2_HID.c,70 :: 		for(i=0; i<=blink; i++){
	INCF        R1, 1 
;GameTerminal_PS2_HID.c,73 :: 		}
	GOTO        L_Led_Indicate6
L_Led_Indicate7:
;GameTerminal_PS2_HID.c,74 :: 		LED_PIN = 0;
	BCF         PORTC+0, 2 
;GameTerminal_PS2_HID.c,75 :: 		}
L_end_Led_Indicate:
	RETURN      0
; end of _Led_Indicate

_ArrCmp:

;GameTerminal_PS2_HID.c,84 :: 		uint8_t ArrCmp(uint8_t *arr1, const uint8_t *arr2, uint8_t pos, uint8_t ln){
;GameTerminal_PS2_HID.c,86 :: 		for (i=0; i<ln; i++){                                  //В цикле идет сравнение
	CLRF        R3 
L_ArrCmp10:
	MOVF        FARG_ArrCmp_ln+0, 0 
	SUBWF       R3, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_ArrCmp11
;GameTerminal_PS2_HID.c,87 :: 		if((arr1[i+pos] & 0x7F) != arr2[i]) return 0;       //массивов. 0х7F - маска, так как старший бит
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
	GOTO        L_ArrCmp13
	CLRF        R0 
	GOTO        L_end_ArrCmp
L_ArrCmp13:
;GameTerminal_PS2_HID.c,86 :: 		for (i=0; i<ln; i++){                                  //В цикле идет сравнение
	INCF        R3, 1 
;GameTerminal_PS2_HID.c,88 :: 		}                                                      //использоется для указания модификатора SHIFT
	GOTO        L_ArrCmp10
L_ArrCmp11:
;GameTerminal_PS2_HID.c,89 :: 		return 1;
	MOVLW       1
	MOVWF       R0 
;GameTerminal_PS2_HID.c,90 :: 		}
L_end_ArrCmp:
	RETURN      0
; end of _ArrCmp

_main:

;GameTerminal_PS2_HID.c,95 :: 		void main(){
;GameTerminal_PS2_HID.c,96 :: 		INTCON = 0;     //Запрещаются все прерывания
	CLRF        INTCON+0 
;GameTerminal_PS2_HID.c,98 :: 		ADCON1 = 0x0F;  //Сконфигурировать все порты нак цифровые
	MOVLW       15
	MOVWF       ADCON1+0 
;GameTerminal_PS2_HID.c,99 :: 		TRISA= 0b00010000;
	MOVLW       16
	MOVWF       TRISA+0 
;GameTerminal_PS2_HID.c,100 :: 		TRISB= 0b00000011;
	MOVLW       3
	MOVWF       TRISB+0 
;GameTerminal_PS2_HID.c,101 :: 		TRISC= 0b10111000;
	MOVLW       184
	MOVWF       TRISC+0 
;GameTerminal_PS2_HID.c,102 :: 		PORTA= 0;
	CLRF        PORTA+0 
;GameTerminal_PS2_HID.c,103 :: 		PORTB= 0;
	CLRF        PORTB+0 
;GameTerminal_PS2_HID.c,104 :: 		PORTC= 0;
	CLRF        PORTC+0 
;GameTerminal_PS2_HID.c,105 :: 		INTCON2.RBPU = 0;                      //Вклучить подтяжку
	BCF         INTCON2+0, 7 
;GameTerminal_PS2_HID.c,108 :: 		CVRCON = 0;                            //Сброс регистров флагов
	CLRF        CVRCON+0 
;GameTerminal_PS2_HID.c,109 :: 		ADRESL = 0;                            //переназначеных
	CLRF        ADRESL+0 
;GameTerminal_PS2_HID.c,110 :: 		Init_PS2();                            //Инициализация клавиатуры PS2
	CALL        _Init_PS2+0, 0
;GameTerminal_PS2_HID.c,111 :: 		UART1_Init(9600);                      //инициализация UART на 9600 bps
	BSF         BAUDCON+0, 3, 0
	MOVLW       4
	MOVWF       SPBRGH+0 
	MOVLW       225
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;GameTerminal_PS2_HID.c,112 :: 		switch(EEPROM_Read(0)){                //Чтение байта конфигурации режима клавиатуры
	CLRF        FARG_EEPROM_Read_address+0 
	CALL        _EEPROM_Read+0, 0
	MOVF        R0, 0 
	MOVWF       FLOC__main+0 
	GOTO        L_main14
;GameTerminal_PS2_HID.c,113 :: 		case 0xFF : EEPROM_Write(0,0);      //Если ячейка не инициализирована то прошить режим Клавиатура
L_main16:
	CLRF        FARG_EEPROM_Write_address+0 
	CLRF        FARG_EEPROM_Write_data_+0 
	CALL        _EEPROM_Write+0, 0
;GameTerminal_PS2_HID.c,114 :: 		sysFlags.kb_mode = 0;   //и присвоить этот режим
	BCF         CVRCON+0, 1 
;GameTerminal_PS2_HID.c,115 :: 		break;
	GOTO        L_main15
;GameTerminal_PS2_HID.c,116 :: 		case 0x01 : sysFlags.kb_mode = 1;   //Если присвоен режим консоли
L_main17:
	BSF         CVRCON+0, 1 
;GameTerminal_PS2_HID.c,117 :: 		break;
	GOTO        L_main15
;GameTerminal_PS2_HID.c,118 :: 		case 0x00 : sysFlags.kb_mode = 0;   //Если присвоен режим клавиатуры
L_main18:
	BCF         CVRCON+0, 1 
;GameTerminal_PS2_HID.c,119 :: 		break;
	GOTO        L_main15
;GameTerminal_PS2_HID.c,120 :: 		default : break;
L_main19:
	GOTO        L_main15
;GameTerminal_PS2_HID.c,121 :: 		}
L_main14:
	MOVF        FLOC__main+0, 0 
	XORLW       255
	BTFSC       STATUS+0, 2 
	GOTO        L_main16
	MOVF        FLOC__main+0, 0 
	XORLW       1
	BTFSC       STATUS+0, 2 
	GOTO        L_main17
	MOVF        FLOC__main+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_main18
	GOTO        L_main19
L_main15:
;GameTerminal_PS2_HID.c,122 :: 		PWR12 = 1;                             //Включение питания 12В на плату
	BSF         PORTB+0, 3 
;GameTerminal_PS2_HID.c,126 :: 		USBDev_Init();
	CALL        _USBDev_Init+0, 0
;GameTerminal_PS2_HID.c,127 :: 		IPEN_bit = 1;
	BSF         IPEN_bit+0, BitPos(IPEN_bit+0) 
;GameTerminal_PS2_HID.c,128 :: 		USBIP_bit = 1;
	BSF         USBIP_bit+0, BitPos(USBIP_bit+0) 
;GameTerminal_PS2_HID.c,129 :: 		USBIE_bit = 1;
	BSF         USBIE_bit+0, BitPos(USBIE_bit+0) 
;GameTerminal_PS2_HID.c,130 :: 		GIEH_bit = 1;
	BSF         GIEH_bit+0, BitPos(GIEH_bit+0) 
;GameTerminal_PS2_HID.c,131 :: 		USBFlags.hid_rec = 0;
	BCF         ADRESL+0, 2 
;GameTerminal_PS2_HID.c,133 :: 		GIE_bit = 1;
	BSF         GIE_bit+0, BitPos(GIE_bit+0) 
;GameTerminal_PS2_HID.c,134 :: 		PEIE_bit = 1;
	BSF         PEIE_bit+0, BitPos(PEIE_bit+0) 
;GameTerminal_PS2_HID.c,135 :: 		delay_ms(100);
	MOVLW       7
	MOVWF       R11, 0
	MOVLW       23
	MOVWF       R12, 0
	MOVLW       106
	MOVWF       R13, 0
L_main20:
	DECFSZ      R13, 1, 1
	BRA         L_main20
	DECFSZ      R12, 1, 1
	BRA         L_main20
	DECFSZ      R11, 1, 1
	BRA         L_main20
	NOP
;GameTerminal_PS2_HID.c,136 :: 		Reset_PS2();
	CALL        _Reset_PS2+0, 0
;GameTerminal_PS2_HID.c,137 :: 		Led_Indicate(2);                       //Индикация готовности
	MOVLW       2
	MOVWF       FARG_Led_Indicate_blink+0 
	CALL        _Led_Indicate+0, 0
;GameTerminal_PS2_HID.c,139 :: 		while(1) {
L_main21:
;GameTerminal_PS2_HID.c,140 :: 		asm clrwdt;                    //Сброс сторожевого таймера
	CLRWDT
;GameTerminal_PS2_HID.c,141 :: 		USB_StateInit();               //Определение состояние USB
	CALL        _USB_StateInit+0, 0
;GameTerminal_PS2_HID.c,144 :: 		if(button(&PORTC, RC7, 200, 0)){          //Если включение сработало
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
	GOTO        L_main23
;GameTerminal_PS2_HID.c,145 :: 		LED_PIN = 1;
	BSF         PORTC+0, 2 
;GameTerminal_PS2_HID.c,146 :: 		if(keycode[0] == KEY_L_CTRL){         //Если зажат левый CTRL и при этом сработал ключ
	MOVF        _keycode+0, 0 
	XORLW       224
	BTFSS       STATUS+0, 2 
	GOTO        L_main24
;GameTerminal_PS2_HID.c,147 :: 		SendPassword(PASS_START_ADDR);     //Запускается функция введения сохраненного пароля
	MOVLW       1
	MOVWF       FARG_SendPassword+0 
	CALL        _SendPassword+0, 0
;GameTerminal_PS2_HID.c,148 :: 		delay_ms(10000);                   //задержка для защиты от повторного срабатывания, в течении
	MOVLW       3
	MOVWF       R10, 0
	MOVLW       97
	MOVWF       R11, 0
	MOVLW       195
	MOVWF       R12, 0
	MOVLW       142
	MOVWF       R13, 0
L_main25:
	DECFSZ      R13, 1, 1
	BRA         L_main25
	DECFSZ      R12, 1, 1
	BRA         L_main25
	DECFSZ      R11, 1, 1
	BRA         L_main25
	DECFSZ      R10, 1, 1
	BRA         L_main25
	NOP
;GameTerminal_PS2_HID.c,150 :: 		} else {                              //Если левый CTRL не нажат то выполняется переход на плату
	GOTO        L_main26
L_main24:
;GameTerminal_PS2_HID.c,151 :: 		if(Reset_PS2() == 0){ LED_PIN = 0; }
	CALL        _Reset_PS2+0, 0
	MOVF        R0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main27
	BCF         PORTC+0, 2 
L_main27:
;GameTerminal_PS2_HID.c,152 :: 		PWR5 = 1;                          //Включить 5В питание платы
	BSF         PORTB+0, 2 
;GameTerminal_PS2_HID.c,153 :: 		VIDEO_PIN = 1;                     //Переключить монитор на плату
	BSF         PORTB+0, 7 
;GameTerminal_PS2_HID.c,154 :: 		sysFlags.if_pc = 1;                //Запоминаем что мы на плате
	BSF         CVRCON+0, 0 
;GameTerminal_PS2_HID.c,155 :: 		delay_ms(3000);
	MOVLW       183
	MOVWF       R11, 0
	MOVLW       161
	MOVWF       R12, 0
	MOVLW       195
	MOVWF       R13, 0
L_main28:
	DECFSZ      R13, 1, 1
	BRA         L_main28
	DECFSZ      R12, 1, 1
	BRA         L_main28
	DECFSZ      R11, 1, 1
	BRA         L_main28
	NOP
	NOP
;GameTerminal_PS2_HID.c,156 :: 		}
L_main26:
;GameTerminal_PS2_HID.c,157 :: 		LED_PIN = 0;
	BCF         PORTC+0, 2 
;GameTerminal_PS2_HID.c,158 :: 		}
L_main23:
;GameTerminal_PS2_HID.c,161 :: 		if(USBFlags.hid_rec == 1){
	BTFSS       ADRESL+0, 2 
	GOTO        L_main29
;GameTerminal_PS2_HID.c,162 :: 		USBFlags.hid_rec = 0;
	BCF         ADRESL+0, 2 
;GameTerminal_PS2_HID.c,163 :: 		PS2_Send(SET_KEYB_INDICATORS);
	MOVLW       237
	MOVWF       FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;GameTerminal_PS2_HID.c,164 :: 		delay_ms(10);
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_main30:
	DECFSZ      R13, 1, 1
	BRA         L_main30
	DECFSZ      R12, 1, 1
	BRA         L_main30
;GameTerminal_PS2_HID.c,165 :: 		PS2_Send(USB_GetLEDs());
	CALL        _USB_GetLEDs+0, 0
	MOVF        R0, 0 
	MOVWF       FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;GameTerminal_PS2_HID.c,166 :: 		USB_ReceiveBuffSet();             // Prepere buffer for reception of next packet
	CALL        _USB_ReceiveBuffSet+0, 0
;GameTerminal_PS2_HID.c,167 :: 		}
L_main29:
;GameTerminal_PS2_HID.c,174 :: 		if(sysFlags.if_pc == 1){                         //Если на плате
	BTFSS       CVRCON+0, 0 
	GOTO        L_main31
;GameTerminal_PS2_HID.c,175 :: 		switch(keycode[0]){
	GOTO        L_main32
;GameTerminal_PS2_HID.c,176 :: 		case KEY_F12: if(sysFlags.kb_mode == 0)                         //Обработка нажатия кнопки F12 (выход из программирования)
L_main34:
	BTFSC       CVRCON+0, 1 
	GOTO        L_main35
;GameTerminal_PS2_HID.c,177 :: 		uart_write(RDR_PRG_END);
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
L_main35:
;GameTerminal_PS2_HID.c,178 :: 		break;
	GOTO        L_main33
;GameTerminal_PS2_HID.c,179 :: 		case KEY_F5 : if(sysFlags.kb_mode == 0){                        //Обработка переключения на консоль
L_main36:
	BTFSC       CVRCON+0, 1 
	GOTO        L_main37
;GameTerminal_PS2_HID.c,180 :: 		if(--kybCnt == 0){
	DECF        _kybCnt+0, 1 
	MOVF        _kybCnt+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main38
;GameTerminal_PS2_HID.c,181 :: 		EEPROM_Write(0,1);
	CLRF        FARG_EEPROM_Write_address+0 
	MOVLW       1
	MOVWF       FARG_EEPROM_Write_data_+0 
	CALL        _EEPROM_Write+0, 0
;GameTerminal_PS2_HID.c,182 :: 		sysFlags.kb_mode = 1;
	BSF         CVRCON+0, 1 
;GameTerminal_PS2_HID.c,183 :: 		kybCnt = KYBCNT_DELAY;
	MOVLW       50
	MOVWF       _kybCnt+0 
;GameTerminal_PS2_HID.c,184 :: 		uart_write(RDR_PRG_END);
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
;GameTerminal_PS2_HID.c,185 :: 		}
L_main38:
;GameTerminal_PS2_HID.c,186 :: 		} break;
L_main37:
	GOTO        L_main33
;GameTerminal_PS2_HID.c,187 :: 		case KEY_NUM_ENTR : if(sysFlags.kb_mode == 1){                  //Обработка переключения на клавиатуру
L_main39:
	BTFSS       CVRCON+0, 1 
	GOTO        L_main40
;GameTerminal_PS2_HID.c,188 :: 		if(--kybCnt == 0){
	DECF        _kybCnt+0, 1 
	MOVF        _kybCnt+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main41
;GameTerminal_PS2_HID.c,189 :: 		EEPROM_Write(0,0);
	CLRF        FARG_EEPROM_Write_address+0 
	CLRF        FARG_EEPROM_Write_data_+0 
	CALL        _EEPROM_Write+0, 0
;GameTerminal_PS2_HID.c,190 :: 		sysFlags.kb_mode = 0;
	BCF         CVRCON+0, 1 
;GameTerminal_PS2_HID.c,191 :: 		kybCnt = KYBCNT_DELAY;
	MOVLW       50
	MOVWF       _kybCnt+0 
;GameTerminal_PS2_HID.c,192 :: 		uart_write(RDR_PRG_END);
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
;GameTerminal_PS2_HID.c,193 :: 		}
L_main41:
;GameTerminal_PS2_HID.c,194 :: 		} break;
L_main40:
	GOTO        L_main33
;GameTerminal_PS2_HID.c,195 :: 		default : kybCnt = KYBCNT_DELAY; break;                       //Сброс счетчика если кнопка отпущена или нажата другая кнопка
L_main42:
	MOVLW       50
	MOVWF       _kybCnt+0 
	GOTO        L_main33
;GameTerminal_PS2_HID.c,196 :: 		}
L_main32:
	MOVF        _keycode+0, 0 
	XORLW       69
	BTFSC       STATUS+0, 2 
	GOTO        L_main34
	MOVF        _keycode+0, 0 
	XORLW       62
	BTFSC       STATUS+0, 2 
	GOTO        L_main36
	MOVF        _keycode+0, 0 
	XORLW       88
	BTFSC       STATUS+0, 2 
	GOTO        L_main39
	GOTO        L_main42
L_main33:
;GameTerminal_PS2_HID.c,200 :: 		if(ArrCmp(&progPass, &progStr, (PASS_BUFF_SIZE - (sizeof(progStr)+1)), sizeof(progStr))){
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
	GOTO        L_main43
;GameTerminal_PS2_HID.c,201 :: 		switch(progPass[PASS_BUFF_SIZE-1]){
	GOTO        L_main44
;GameTerminal_PS2_HID.c,202 :: 		case KEY_1: UART1_Write(RDR_PRG_CH1); break;   //программирование1 - кредитный
L_main46:
	MOVLW       201
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main45
;GameTerminal_PS2_HID.c,203 :: 		case KEY_2: UART1_Write(RDR_PRG_CH2); break;   //программирование2 - сьемный
L_main47:
	MOVLW       202
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main45
;GameTerminal_PS2_HID.c,204 :: 		case KEY_3: UART1_Write(RDR_PRG_CH3); break;   //программирование3 - овнер
L_main48:
	MOVLW       203
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main45
;GameTerminal_PS2_HID.c,205 :: 		case KEY_4: UART1_Write(RDR_PRG_CH4); break;   //программирование4 - админ
L_main49:
	MOVLW       204
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main45
;GameTerminal_PS2_HID.c,206 :: 		case KEY_0: EEPROM_Write(0xFF,0xFF);           //Переход в режим бутлодера
L_main50:
	MOVLW       255
	MOVWF       FARG_EEPROM_Write_address+0 
	MOVLW       255
	MOVWF       FARG_EEPROM_Write_data_+0 
	CALL        _EEPROM_Write+0, 0
;GameTerminal_PS2_HID.c,207 :: 		USBEN_bit = 0;                     //Выключение HID устройства
	BCF         USBEN_bit+0, BitPos(USBEN_bit+0) 
;GameTerminal_PS2_HID.c,208 :: 		delay_ms(10);                      //Задержка для ПК, чтобы успел отключить
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_main51:
	DECFSZ      R13, 1, 1
	BRA         L_main51
	DECFSZ      R12, 1, 1
	BRA         L_main51
;GameTerminal_PS2_HID.c,209 :: 		asm RESET; break;                  //Сброс МК
	RESET
	GOTO        L_main45
;GameTerminal_PS2_HID.c,210 :: 		case KEY_G: uart_write(RDR_PRG_END);           //Вход в режим программирования пароля, пикаем разок
L_main52:
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
;GameTerminal_PS2_HID.c,211 :: 		sysFlags.wr_pass = 1;              //устанавливаем соответствующий флаг
	BSF         CVRCON+0, 2 
;GameTerminal_PS2_HID.c,212 :: 		memset(progPass, 0, PASS_BUFF_SIZE);//очищаем массив ввода пароля
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
;GameTerminal_PS2_HID.c,213 :: 		PS2_Send(SET_KEYB_INDICATORS);     //Зажигаем на клавиатуре светодиод SCR LOCK
	MOVLW       237
	MOVWF       FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;GameTerminal_PS2_HID.c,214 :: 		delay_ms(10);
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_main53:
	DECFSZ      R13, 1, 1
	BRA         L_main53
	DECFSZ      R12, 1, 1
	BRA         L_main53
;GameTerminal_PS2_HID.c,215 :: 		PS2_Send(SET_SCRL_LED);
	MOVLW       1
	MOVWF       FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;GameTerminal_PS2_HID.c,216 :: 		break;
	GOTO        L_main45
;GameTerminal_PS2_HID.c,217 :: 		default: break;
L_main54:
	GOTO        L_main45
;GameTerminal_PS2_HID.c,218 :: 		}
L_main44:
	MOVF        _progPass+31, 0 
	XORLW       30
	BTFSC       STATUS+0, 2 
	GOTO        L_main46
	MOVF        _progPass+31, 0 
	XORLW       31
	BTFSC       STATUS+0, 2 
	GOTO        L_main47
	MOVF        _progPass+31, 0 
	XORLW       32
	BTFSC       STATUS+0, 2 
	GOTO        L_main48
	MOVF        _progPass+31, 0 
	XORLW       33
	BTFSC       STATUS+0, 2 
	GOTO        L_main49
	MOVF        _progPass+31, 0 
	XORLW       39
	BTFSC       STATUS+0, 2 
	GOTO        L_main50
	MOVF        _progPass+31, 0 
	XORLW       10
	BTFSC       STATUS+0, 2 
	GOTO        L_main52
	GOTO        L_main54
L_main45:
;GameTerminal_PS2_HID.c,219 :: 		progPass[PASS_BUFF_SIZE-2] = 0;                  //Сброс ввода фразы
	CLRF        _progPass+30 
;GameTerminal_PS2_HID.c,220 :: 		}
	GOTO        L_main55
L_main43:
;GameTerminal_PS2_HID.c,224 :: 		else if(ArrCmp(&progPass, &delStr, PASS_BUFF_SIZE - sizeof(delStr) - 1, sizeof(delStr))){
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
	GOTO        L_main56
;GameTerminal_PS2_HID.c,225 :: 		switch(progPass[PASS_BUFF_SIZE-1]){
	GOTO        L_main57
;GameTerminal_PS2_HID.c,226 :: 		case KEY_1: UART1_Write(RDR_CLR_CH1); break;   //Удаление1 - кредитный
L_main59:
	MOVLW       205
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main58
;GameTerminal_PS2_HID.c,227 :: 		case KEY_2: UART1_Write(RDR_CLR_CH2); break;   //Удаление2 - сьемный
L_main60:
	MOVLW       206
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main58
;GameTerminal_PS2_HID.c,228 :: 		case KEY_3: UART1_Write(RDR_CLR_CH3); break;   //Удаление3 - овнер
L_main61:
	MOVLW       207
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main58
;GameTerminal_PS2_HID.c,229 :: 		case KEY_4: UART1_Write(RDR_CLR_CH4); break;   //Удаление4 - админ
L_main62:
	MOVLW       208
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main58
;GameTerminal_PS2_HID.c,230 :: 		case KEY_5: UART1_Write(RDR_CLR_ALL); break;   //Удаление5 - всех ключей
L_main63:
	MOVLW       209
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main58
;GameTerminal_PS2_HID.c,231 :: 		case KEY_G: EEPROM_ClearPassword(PASS_START_ADDR, PASS_BUFF_SIZE); //Удаление пароля ввода
L_main64:
	MOVLW       1
	MOVWF       FARG_EEPROM_ClearPassword+0 
	MOVLW       32
	MOVWF       FARG_EEPROM_ClearPassword+0 
	CALL        _EEPROM_ClearPassword+0, 0
;GameTerminal_PS2_HID.c,232 :: 		uart_write(RDR_PRG_END);            //Пикаем по завершении
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
;GameTerminal_PS2_HID.c,233 :: 		break;
	GOTO        L_main58
;GameTerminal_PS2_HID.c,234 :: 		default: break;
L_main65:
	GOTO        L_main58
;GameTerminal_PS2_HID.c,235 :: 		}
L_main57:
	MOVF        _progPass+31, 0 
	XORLW       30
	BTFSC       STATUS+0, 2 
	GOTO        L_main59
	MOVF        _progPass+31, 0 
	XORLW       31
	BTFSC       STATUS+0, 2 
	GOTO        L_main60
	MOVF        _progPass+31, 0 
	XORLW       32
	BTFSC       STATUS+0, 2 
	GOTO        L_main61
	MOVF        _progPass+31, 0 
	XORLW       33
	BTFSC       STATUS+0, 2 
	GOTO        L_main62
	MOVF        _progPass+31, 0 
	XORLW       34
	BTFSC       STATUS+0, 2 
	GOTO        L_main63
	MOVF        _progPass+31, 0 
	XORLW       10
	BTFSC       STATUS+0, 2 
	GOTO        L_main64
	GOTO        L_main65
L_main58:
;GameTerminal_PS2_HID.c,236 :: 		progPass[PASS_BUFF_SIZE-2] = 0;                    //Сброс ввода фразы
	CLRF        _progPass+30 
;GameTerminal_PS2_HID.c,237 :: 		}
L_main56:
L_main55:
;GameTerminal_PS2_HID.c,241 :: 		if(sysFlags.wr_pass == 1 && keycode[0] == KEY_ENTER){            //Если установлен флаг записи пароля и нажата кнопка ENTER
	BTFSS       CVRCON+0, 2 
	GOTO        L_main68
	MOVF        _keycode+0, 0 
	XORLW       40
	BTFSS       STATUS+0, 2 
	GOTO        L_main68
L__main89:
;GameTerminal_PS2_HID.c,243 :: 		passCnt = PASS_BUFF_SIZE-1;                                   //Счетчику символов присваевается максимальное колличество символов
	MOVLW       31
	MOVWF       _passCnt+0 
;GameTerminal_PS2_HID.c,244 :: 		while(progPass[passCnt] != 0 && passCnt >= 0) passCnt--;      //Определяется сколько символов введено (вернее сколько осталось пустых ячеек)
L_main69:
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
	GOTO        L_main70
	MOVLW       0
	SUBWF       _passCnt+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_main70
L__main88:
	DECF        _passCnt+0, 1 
	GOTO        L_main69
L_main70:
;GameTerminal_PS2_HID.c,245 :: 		if(passCnt != PASS_BUFF_SIZE-1){                              //Если введен хотябы один символ происходит сохранение его в память
	MOVF        _passCnt+0, 0 
	XORLW       31
	BTFSC       STATUS+0, 2 
	GOTO        L_main73
;GameTerminal_PS2_HID.c,246 :: 		EEPROM_ClearPassword(PASS_START_ADDR, PASS_BUFF_SIZE);     //Выполняется очистка старого пароля
	MOVLW       1
	MOVWF       FARG_EEPROM_ClearPassword+0 
	MOVLW       32
	MOVWF       FARG_EEPROM_ClearPassword+0 
	CALL        _EEPROM_ClearPassword+0, 0
;GameTerminal_PS2_HID.c,247 :: 		EEPROM_SavePassword(&progPass+(passCnt+1), PASS_BUFF_SIZE - (passCnt+1), PASS_START_ADDR);//Сохраняется новый пароль
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
;GameTerminal_PS2_HID.c,248 :: 		PS2_Send(SET_KEYB_INDICATORS);                             //Гасим светодиоды клавиатуры
	MOVLW       237
	MOVWF       FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;GameTerminal_PS2_HID.c,249 :: 		delay_ms(10);
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_main74:
	DECFSZ      R13, 1, 1
	BRA         L_main74
	DECFSZ      R12, 1, 1
	BRA         L_main74
;GameTerminal_PS2_HID.c,250 :: 		PS2_Send(SET_OFF_LED);
	CLRF        FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;GameTerminal_PS2_HID.c,251 :: 		uart_write(RDR_PRG_END);                                   //Разок пикаем
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
;GameTerminal_PS2_HID.c,252 :: 		} else {                                                      //Если не введено ни одного символа
	GOTO        L_main75
L_main73:
;GameTerminal_PS2_HID.c,253 :: 		PS2_Send(SET_KEYB_INDICATORS);                             //Включаем все светодиоды
	MOVLW       237
	MOVWF       FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;GameTerminal_PS2_HID.c,254 :: 		delay_ms(10);
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_main76:
	DECFSZ      R13, 1, 1
	BRA         L_main76
	DECFSZ      R12, 1, 1
	BRA         L_main76
;GameTerminal_PS2_HID.c,255 :: 		PS2_Send(SET_NUM_LED | SET_CAPS_LED | SET_SCRL_LED);
	MOVLW       7
	MOVWF       FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;GameTerminal_PS2_HID.c,256 :: 		delay_ms(1000);                                            //ждем секунду
	MOVLW       61
	MOVWF       R11, 0
	MOVLW       225
	MOVWF       R12, 0
	MOVLW       63
	MOVWF       R13, 0
L_main77:
	DECFSZ      R13, 1, 1
	BRA         L_main77
	DECFSZ      R12, 1, 1
	BRA         L_main77
	DECFSZ      R11, 1, 1
	BRA         L_main77
	NOP
	NOP
;GameTerminal_PS2_HID.c,257 :: 		PS2_Send(SET_KEYB_INDICATORS);                             //Гасим все светодиоды
	MOVLW       237
	MOVWF       FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;GameTerminal_PS2_HID.c,258 :: 		delay_ms(10);
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_main78:
	DECFSZ      R13, 1, 1
	BRA         L_main78
	DECFSZ      R12, 1, 1
	BRA         L_main78
;GameTerminal_PS2_HID.c,259 :: 		PS2_Send(SET_OFF_LED);
	CLRF        FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;GameTerminal_PS2_HID.c,260 :: 		uart_write(RDR_PRG_END);                                   //Пикаем два раза
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
;GameTerminal_PS2_HID.c,261 :: 		delay_ms(400);
	MOVLW       25
	MOVWF       R11, 0
	MOVLW       90
	MOVWF       R12, 0
	MOVLW       177
	MOVWF       R13, 0
L_main79:
	DECFSZ      R13, 1, 1
	BRA         L_main79
	DECFSZ      R12, 1, 1
	BRA         L_main79
	DECFSZ      R11, 1, 1
	BRA         L_main79
	NOP
	NOP
;GameTerminal_PS2_HID.c,262 :: 		uart_write(RDR_PRG_END);
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
;GameTerminal_PS2_HID.c,263 :: 		}
L_main75:
;GameTerminal_PS2_HID.c,264 :: 		sysFlags.wr_pass = 0;                                         //сбрасываем флаг записи пароля
	BCF         CVRCON+0, 2 
;GameTerminal_PS2_HID.c,265 :: 		}
L_main68:
;GameTerminal_PS2_HID.c,266 :: 		delay_ms(100);                                 //Задержка, от этой задержки зависит время зажатия кнопок на переключение между клавиатурой и консолью
	MOVLW       7
	MOVWF       R11, 0
	MOVLW       23
	MOVWF       R12, 0
	MOVLW       106
	MOVWF       R13, 0
L_main80:
	DECFSZ      R13, 1, 1
	BRA         L_main80
	DECFSZ      R12, 1, 1
	BRA         L_main80
	DECFSZ      R11, 1, 1
	BRA         L_main80
	NOP
;GameTerminal_PS2_HID.c,267 :: 		}else if(sysFlags.if_pc == 0){
	GOTO        L_main81
L_main31:
	BTFSC       CVRCON+0, 0 
	GOTO        L_main82
;GameTerminal_PS2_HID.c,268 :: 		PWR5 = 0;                                 //Сбрасываем питание с платы
	BCF         PORTB+0, 2 
;GameTerminal_PS2_HID.c,269 :: 		VIDEO_PIN = 0;                            //Переключаемся на ПК
	BCF         PORTB+0, 7 
;GameTerminal_PS2_HID.c,270 :: 		if(USBFlags.if_conf == 1){                  //Если USB подключен выполняется обработка и отправка кнопки
	BTFSS       ADRESL+0, 1 
	GOTO        L_main83
;GameTerminal_PS2_HID.c,275 :: 		if(keycode[0] != 0)                      //Если есть хотябы одно нажате кнопки
	MOVF        _keycode+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_main84
;GameTerminal_PS2_HID.c,276 :: 		USBFlags.upBtn == 0;                //Сбросить флаг отпущеной кнопки
L_main84:
;GameTerminal_PS2_HID.c,277 :: 		if(USBFlags.upBtn == 0){                 //Если есть нажатие то выполняется
	BTFSC       ADRESL+0, 0 
	GOTO        L_main85
;GameTerminal_PS2_HID.c,278 :: 		SendKeys(&keycode, modifier);          //Отправка кнопок клавиатуры
	MOVLW       _keycode+0
	MOVWF       FARG_SendKeys+0 
	MOVLW       hi_addr(_keycode+0)
	MOVWF       FARG_SendKeys+1 
	MOVF        _modifier+0, 0 
	MOVWF       FARG_SendKeys+0 
	CALL        _SendKeys+0, 0
;GameTerminal_PS2_HID.c,279 :: 		if(keycode[0] == 0){                   //Если нет не одной нажатой кнопки
	MOVF        _keycode+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main86
;GameTerminal_PS2_HID.c,281 :: 		SendNoKeys();                       //Отправляем нули (нет нажатой кнопки)
	CALL        _SendNoKeys+0, 0
;GameTerminal_PS2_HID.c,282 :: 		}
L_main86:
;GameTerminal_PS2_HID.c,283 :: 		}
L_main85:
;GameTerminal_PS2_HID.c,284 :: 		}
L_main83:
;GameTerminal_PS2_HID.c,285 :: 		delay_ms(30);
	MOVLW       2
	MOVWF       R11, 0
	MOVLW       212
	MOVWF       R12, 0
	MOVLW       133
	MOVWF       R13, 0
L_main87:
	DECFSZ      R13, 1, 1
	BRA         L_main87
	DECFSZ      R12, 1, 1
	BRA         L_main87
	DECFSZ      R11, 1, 1
	BRA         L_main87
;GameTerminal_PS2_HID.c,286 :: 		}
L_main82:
L_main81:
;GameTerminal_PS2_HID.c,287 :: 		}
	GOTO        L_main21
;GameTerminal_PS2_HID.c,288 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
