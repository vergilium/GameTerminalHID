
_interrupt:

;GameTerminal_PS2_HID.c,40 :: 		void interrupt(){
;GameTerminal_PS2_HID.c,41 :: 		USB_Interrupt_Proc();                          // USB servicing is done inside the interrupt
	CALL        _USB_Interrupt_Proc+0, 0
;GameTerminal_PS2_HID.c,42 :: 		PS2_interrupt();                               //Прерывание по INT1 при поступлении данных с PS2
	CALL        _PS2_interrupt+0, 0
;GameTerminal_PS2_HID.c,43 :: 		if(SUSPND_bit) USBFlags.if_conf = 0;           //В случае перехода USB в режим SUSPEND(Ожидания) сбрасывается флаг конфигурации USB
	BTFSS       SUSPND_bit+0, BitPos(SUSPND_bit+0) 
	GOTO        L_interrupt0
	BCF         ADRESH+0, 1 
L_interrupt0:
;GameTerminal_PS2_HID.c,44 :: 		}
L_end_interrupt:
L__interrupt69:
	RETFIE      1
; end of _interrupt

_interrupt_low:
	MOVWF       ___Low_saveWREG+0 
	MOVF        STATUS+0, 0 
	MOVWF       ___Low_saveSTATUS+0 
	MOVF        BSR+0, 0 
	MOVWF       ___Low_saveBSR+0 

;GameTerminal_PS2_HID.c,45 :: 		void interrupt_low(){
;GameTerminal_PS2_HID.c,46 :: 		PS2_Timeout_Interrupt();     //Прерывание по timer0 через 1мс в случае ошибочных данных по PS2
	CALL        _PS2_Timeout_Interrupt+0, 0
;GameTerminal_PS2_HID.c,47 :: 		}
L_end_interrupt_low:
L__interrupt_low71:
	MOVF        ___Low_saveBSR+0, 0 
	MOVWF       BSR+0 
	MOVF        ___Low_saveSTATUS+0, 0 
	MOVWF       STATUS+0 
	SWAPF       ___Low_saveWREG+0, 1 
	SWAPF       ___Low_saveWREG+0, 0 
	RETFIE      0
; end of _interrupt_low

_Led_Indicate:

;GameTerminal_PS2_HID.c,52 :: 		void Led_Indicate(unsigned char blink){
;GameTerminal_PS2_HID.c,54 :: 		for(i=0; i<=blink; i++){
	CLRF        R1 
L_Led_Indicate1:
	MOVF        R1, 0 
	SUBWF       FARG_Led_Indicate_blink+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_Led_Indicate2
;GameTerminal_PS2_HID.c,55 :: 		LED_PIN = ~LED_PIN;
	BTG         PORTC+0, 2 
;GameTerminal_PS2_HID.c,56 :: 		delay_ms(100);
	MOVLW       7
	MOVWF       R11, 0
	MOVLW       23
	MOVWF       R12, 0
	MOVLW       106
	MOVWF       R13, 0
L_Led_Indicate4:
	DECFSZ      R13, 1, 1
	BRA         L_Led_Indicate4
	DECFSZ      R12, 1, 1
	BRA         L_Led_Indicate4
	DECFSZ      R11, 1, 1
	BRA         L_Led_Indicate4
	NOP
;GameTerminal_PS2_HID.c,54 :: 		for(i=0; i<=blink; i++){
	INCF        R1, 1 
;GameTerminal_PS2_HID.c,57 :: 		}
	GOTO        L_Led_Indicate1
L_Led_Indicate2:
;GameTerminal_PS2_HID.c,58 :: 		LED_PIN = 0;
	BCF         PORTC+0, 2 
;GameTerminal_PS2_HID.c,59 :: 		}
L_end_Led_Indicate:
	RETURN      0
; end of _Led_Indicate

_ArrCmp:

;GameTerminal_PS2_HID.c,63 :: 		unsigned char ArrCmp(unsigned char * arr1, unsigned char * arr2, unsigned char pos, unsigned char ln){
;GameTerminal_PS2_HID.c,65 :: 		for (i=0; i<ln; i++){
	CLRF        R2 
L_ArrCmp5:
	MOVF        FARG_ArrCmp_ln+0, 0 
	SUBWF       R2, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_ArrCmp6
;GameTerminal_PS2_HID.c,66 :: 		if(arr1[i+pos] != arr2[i]) return 0;
	MOVF        FARG_ArrCmp_pos+0, 0 
	ADDWF       R2, 0 
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
	MOVF        R2, 0 
	ADDWF       FARG_ArrCmp_arr2+0, 0 
	MOVWF       FSR2 
	MOVLW       0
	ADDWFC      FARG_ArrCmp_arr2+1, 0 
	MOVWF       FSR2H 
	MOVF        POSTINC0+0, 0 
	XORWF       POSTINC2+0, 0 
	BTFSC       STATUS+0, 2 
	GOTO        L_ArrCmp8
	CLRF        R0 
	GOTO        L_end_ArrCmp
L_ArrCmp8:
;GameTerminal_PS2_HID.c,65 :: 		for (i=0; i<ln; i++){
	INCF        R2, 1 
;GameTerminal_PS2_HID.c,67 :: 		}
	GOTO        L_ArrCmp5
L_ArrCmp6:
;GameTerminal_PS2_HID.c,68 :: 		return 1;
	MOVLW       1
	MOVWF       R0 
;GameTerminal_PS2_HID.c,69 :: 		}
L_end_ArrCmp:
	RETURN      0
; end of _ArrCmp

_main:

;GameTerminal_PS2_HID.c,73 :: 		void main(){
;GameTerminal_PS2_HID.c,74 :: 		INTCON = 0;     //Запрещаются все прерывания
	CLRF        INTCON+0 
;GameTerminal_PS2_HID.c,76 :: 		ADCON1 = 0x0F;  // Configure all PORT pins as digital
	MOVLW       15
	MOVWF       ADCON1+0 
;GameTerminal_PS2_HID.c,78 :: 		TRISA= 0b00010000;
	MOVLW       16
	MOVWF       TRISA+0 
;GameTerminal_PS2_HID.c,79 :: 		TRISB= 0b00000011;
	MOVLW       3
	MOVWF       TRISB+0 
;GameTerminal_PS2_HID.c,80 :: 		TRISC= 0b10111000;
	MOVLW       184
	MOVWF       TRISC+0 
;GameTerminal_PS2_HID.c,81 :: 		PORTA= 0;
	CLRF        PORTA+0 
;GameTerminal_PS2_HID.c,82 :: 		PORTB= 0;
	CLRF        PORTB+0 
;GameTerminal_PS2_HID.c,83 :: 		PORTC= 0;
	CLRF        PORTC+0 
;GameTerminal_PS2_HID.c,85 :: 		ADRESH = 0;                            //Сброс регистра в котором находятся флаги USB(USBFlags)
	CLRF        ADRESH+0 
;GameTerminal_PS2_HID.c,86 :: 		INTCON2.RBPU = 0;                      //Вклучить подтяжку
	BCF         INTCON2+0, 7 
;GameTerminal_PS2_HID.c,87 :: 		init_kb();                             //Инициализация клавиатуры PS2
	CALL        _init_kb+0, 0
;GameTerminal_PS2_HID.c,88 :: 		HID_Enable(readbuff,writebuff);        //Инициализация USB в режиме HID клавиатуры
	MOVLW       _readbuff+0
	MOVWF       FARG_HID_Enable_readbuff+0 
	MOVLW       hi_addr(_readbuff+0)
	MOVWF       FARG_HID_Enable_readbuff+1 
	MOVLW       _writebuff+0
	MOVWF       FARG_HID_Enable_writebuff+0 
	MOVLW       hi_addr(_writebuff+0)
	MOVWF       FARG_HID_Enable_writebuff+1 
	CALL        _HID_Enable+0, 0
;GameTerminal_PS2_HID.c,89 :: 		UART1_Init(9600);                      //Инициализация UART на скорости 9600 bps
	BSF         BAUDCON+0, 3, 0
	MOVLW       4
	MOVWF       SPBRGH+0 
	MOVLW       225
	MOVWF       SPBRG+0 
	BSF         TXSTA+0, 2, 0
	CALL        _UART1_Init+0, 0
;GameTerminal_PS2_HID.c,90 :: 		sysFlags.kb_mode = EEPROM_Read(0x00);  //Чтение байта конфигурации режима клавиатуры
	CLRF        FARG_EEPROM_Read_address+0 
	CALL        _EEPROM_Read+0, 0
	BTFSC       R0, 0 
	GOTO        L__main75
	BCF         CVRCON+0, 3 
	GOTO        L__main76
L__main75:
	BSF         CVRCON+0, 3 
L__main76:
;GameTerminal_PS2_HID.c,91 :: 		Led_Indicate(2);                       //Индикация готовности
	MOVLW       2
	MOVWF       FARG_Led_Indicate_blink+0 
	CALL        _Led_Indicate+0, 0
;GameTerminal_PS2_HID.c,92 :: 		PWR12 = 1;                             //Включение питания 12В на плату
	BSF         PORTB+0, 3 
;GameTerminal_PS2_HID.c,93 :: 		INTCON |= (1<<GIE)|(1<<PEIE);          //Разрешение глобальных прерываний
	MOVLW       192
	IORWF       INTCON+0, 1 
;GameTerminal_PS2_HID.c,94 :: 		while(!PS2_Send(0xFF));                //СБРОС PS2 клавиатуры
L_main9:
	MOVLW       255
	MOVWF       FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
	MOVF        R0, 1 
	BTFSS       STATUS+0, 2 
	GOTO        L_main10
	GOTO        L_main9
L_main10:
;GameTerminal_PS2_HID.c,96 :: 		while(1) {
L_main11:
;GameTerminal_PS2_HID.c,99 :: 		if(button(&PORTC, RC7, 200, 0)){      //Если включение сработало
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
	GOTO        L_main13
;GameTerminal_PS2_HID.c,100 :: 		LED_PIN = 1;                       //Зажигаем светодиод
	BSF         PORTC+0, 2 
;GameTerminal_PS2_HID.c,101 :: 		PWR5 = 1;                          //Включить 5В питание платы
	BSF         PORTB+0, 2 
;GameTerminal_PS2_HID.c,102 :: 		VIDEO_PIN = 1;                     //Переключить монитор на плату
	BSF         PORTB+0, 7 
;GameTerminal_PS2_HID.c,103 :: 		sysFlags.if_pc = 1;                //Запоминаем что мы на плате
	BSF         CVRCON+0, 0 
;GameTerminal_PS2_HID.c,104 :: 		USBFlags.if_conf = 0;              //Сбрасываем флаг разрешения передачи данных в ПК
	BCF         ADRESH+0, 1 
;GameTerminal_PS2_HID.c,105 :: 		while(!PS2_Send(0xED));            //Далее гасятся светодиоды на клавиатуре
L_main14:
	MOVLW       237
	MOVWF       FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
	MOVF        R0, 1 
	BTFSS       STATUS+0, 2 
	GOTO        L_main15
	GOTO        L_main14
L_main15:
;GameTerminal_PS2_HID.c,106 :: 		delay_ms(10);
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_main16:
	DECFSZ      R13, 1, 1
	BRA         L_main16
	DECFSZ      R12, 1, 1
	BRA         L_main16
;GameTerminal_PS2_HID.c,107 :: 		while(!PS2_Send(0x00));
L_main17:
	CLRF        FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
	MOVF        R0, 1 
	BTFSS       STATUS+0, 2 
	GOTO        L_main18
	GOTO        L_main17
L_main18:
;GameTerminal_PS2_HID.c,108 :: 		delay_ms(250);                     //Задержка
	MOVLW       16
	MOVWF       R11, 0
	MOVLW       57
	MOVWF       R12, 0
	MOVLW       13
	MOVWF       R13, 0
L_main19:
	DECFSZ      R13, 1, 1
	BRA         L_main19
	DECFSZ      R12, 1, 1
	BRA         L_main19
	DECFSZ      R11, 1, 1
	BRA         L_main19
	NOP
	NOP
;GameTerminal_PS2_HID.c,109 :: 		LED_PIN = 0;                       //Гасим светодиод
	BCF         PORTC+0, 2 
;GameTerminal_PS2_HID.c,110 :: 		}
L_main13:
;GameTerminal_PS2_HID.c,113 :: 		if(HID_Read()){
	CALL        _HID_Read+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main20
;GameTerminal_PS2_HID.c,114 :: 		USBFlags.if_conf = 1;                          //Если мы получили данные от USB значит он подключен. Устанавливаем соответствующий флаг
	BSF         ADRESH+0, 1 
;GameTerminal_PS2_HID.c,115 :: 		while(!PS2_Send(0xED));                        //Далее получаем репорт и пишем в клавиатуру
L_main21:
	MOVLW       237
	MOVWF       FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
	MOVF        R0, 1 
	BTFSS       STATUS+0, 2 
	GOTO        L_main22
	GOTO        L_main21
L_main22:
;GameTerminal_PS2_HID.c,116 :: 		delay_ms(10);
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_main23:
	DECFSZ      R13, 1, 1
	BRA         L_main23
	DECFSZ      R12, 1, 1
	BRA         L_main23
;GameTerminal_PS2_HID.c,117 :: 		while(!PS2_Send((readbuff[0] & 0x03) << 1));
L_main24:
	MOVLW       3
	ANDWF       1280, 0 
	MOVWF       FARG_PS2_Send+0 
	RLCF        FARG_PS2_Send+0, 1 
	BCF         FARG_PS2_Send+0, 0 
	CALL        _PS2_Send+0, 0
	MOVF        R0, 1 
	BTFSS       STATUS+0, 2 
	GOTO        L_main25
	GOTO        L_main24
L_main25:
;GameTerminal_PS2_HID.c,118 :: 		}
L_main20:
;GameTerminal_PS2_HID.c,125 :: 		if(sysFlags.if_pc == 1){                         //Если на плате
	BTFSS       CVRCON+0, 0 
	GOTO        L_main26
;GameTerminal_PS2_HID.c,126 :: 		switch(keycode[0]){
	GOTO        L_main27
;GameTerminal_PS2_HID.c,127 :: 		case KEY_F12: if(sysFlags.kb_mode == 0)                         //Обработка нажатия кнопки F12 (выход из программирования)
L_main29:
	BTFSC       CVRCON+0, 3 
	GOTO        L_main30
;GameTerminal_PS2_HID.c,128 :: 		uart_write(RDR_PRG_END);
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
L_main30:
;GameTerminal_PS2_HID.c,129 :: 		break;
	GOTO        L_main28
;GameTerminal_PS2_HID.c,130 :: 		case KEY_F5 : if(sysFlags.kb_mode == 0){                        //Обработка переключения на консоль
L_main31:
	BTFSC       CVRCON+0, 3 
	GOTO        L_main32
;GameTerminal_PS2_HID.c,131 :: 		if(--kybCnt == 0){
	DECF        _kybCnt+0, 1 
	MOVF        _kybCnt+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main33
;GameTerminal_PS2_HID.c,132 :: 		EEPROM_Write(0,1);                            //Запись в EEPROM состояния 1 - режим консоли
	CLRF        FARG_EEPROM_Write_address+0 
	MOVLW       1
	MOVWF       FARG_EEPROM_Write_data_+0 
	CALL        _EEPROM_Write+0, 0
;GameTerminal_PS2_HID.c,133 :: 		sysFlags.kb_mode = 1;                         //Выставляем флаг режима консоли
	BSF         CVRCON+0, 3 
;GameTerminal_PS2_HID.c,134 :: 		kybCnt = KYBCNT_DELAY;                        //Сброс счетчика задержки переключения между консолью и клавиатурой
	MOVLW       50
	MOVWF       _kybCnt+0 
;GameTerminal_PS2_HID.c,135 :: 		uart_write(RDR_PRG_END);                      //Сигнал перехода режима
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
;GameTerminal_PS2_HID.c,136 :: 		}
L_main33:
;GameTerminal_PS2_HID.c,137 :: 		} break;
L_main32:
	GOTO        L_main28
;GameTerminal_PS2_HID.c,138 :: 		case KEY_NUM_ENTR : if(sysFlags.kb_mode == 1){                       //Обработка переключения на клавиатуру
L_main34:
	BTFSS       CVRCON+0, 3 
	GOTO        L_main35
;GameTerminal_PS2_HID.c,139 :: 		if(--kybCnt == 0){
	DECF        _kybCnt+0, 1 
	MOVF        _kybCnt+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main36
;GameTerminal_PS2_HID.c,140 :: 		EEPROM_Write(0,0);                          //Запись в EEPROM состояния 1 - режим клавиатуры
	CLRF        FARG_EEPROM_Write_address+0 
	CLRF        FARG_EEPROM_Write_data_+0 
	CALL        _EEPROM_Write+0, 0
;GameTerminal_PS2_HID.c,141 :: 		sysFlags.kb_mode = 0;                       //Выставляем флаг режима клавиатуры
	BCF         CVRCON+0, 3 
;GameTerminal_PS2_HID.c,142 :: 		kybCnt = KYBCNT_DELAY;                      //Сброс счетчика задержки переключения между консолью и клавиатурой
	MOVLW       50
	MOVWF       _kybCnt+0 
;GameTerminal_PS2_HID.c,143 :: 		uart_write(RDR_PRG_END);                    //Сигнал перехода режима
	MOVLW       30
	MOVWF       FARG_UART_Write__data+0 
	CALL        _UART_Write+0, 0
;GameTerminal_PS2_HID.c,144 :: 		}
L_main36:
;GameTerminal_PS2_HID.c,145 :: 		} break;
L_main35:
	GOTO        L_main28
;GameTerminal_PS2_HID.c,146 :: 		default : kybCnt = KYBCNT_DELAY; break;                       //Сброс счетчика если кнопка отпущена или нажата другая кнопка
L_main37:
	MOVLW       50
	MOVWF       _kybCnt+0 
	GOTO        L_main28
;GameTerminal_PS2_HID.c,147 :: 		}
L_main27:
	MOVF        _keycode+0, 0 
	XORLW       69
	BTFSC       STATUS+0, 2 
	GOTO        L_main29
	MOVF        _keycode+0, 0 
	XORLW       62
	BTFSC       STATUS+0, 2 
	GOTO        L_main31
	MOVF        _keycode+0, 0 
	XORLW       88
	BTFSC       STATUS+0, 2 
	GOTO        L_main34
	GOTO        L_main37
L_main28:
;GameTerminal_PS2_HID.c,150 :: 		if(ArrCmp(&progPass, &progStr, 0, 16)){
	MOVLW       _progPass+0
	MOVWF       FARG_ArrCmp_arr1+0 
	MOVLW       hi_addr(_progPass+0)
	MOVWF       FARG_ArrCmp_arr1+1 
	MOVLW       _progStr+0
	MOVWF       FARG_ArrCmp_arr2+0 
	MOVLW       hi_addr(_progStr+0)
	MOVWF       FARG_ArrCmp_arr2+1 
	CLRF        FARG_ArrCmp_pos+0 
	MOVLW       16
	MOVWF       FARG_ArrCmp_ln+0 
	CALL        _ArrCmp+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main38
;GameTerminal_PS2_HID.c,151 :: 		switch(progPass[16]){
	GOTO        L_main39
;GameTerminal_PS2_HID.c,152 :: 		case KEY_1: UART1_Write(RDR_PRG_CH1); break;   //программирование1 - кредитный
L_main41:
	MOVLW       201
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main40
;GameTerminal_PS2_HID.c,153 :: 		case KEY_2: UART1_Write(RDR_PRG_CH2); break;   //программирование2 - сьемный
L_main42:
	MOVLW       202
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main40
;GameTerminal_PS2_HID.c,154 :: 		case KEY_3: UART1_Write(RDR_PRG_CH3); break;   //программирование3 - овнер
L_main43:
	MOVLW       203
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main40
;GameTerminal_PS2_HID.c,155 :: 		case KEY_4: UART1_Write(RDR_PRG_CH4); break;   //программирование4 - админ
L_main44:
	MOVLW       204
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main40
;GameTerminal_PS2_HID.c,156 :: 		case KEY_0: EEPROM_Write(0xFF,0xFF);           //Переход в режим бутлодера
L_main45:
	MOVLW       255
	MOVWF       FARG_EEPROM_Write_address+0 
	MOVLW       255
	MOVWF       FARG_EEPROM_Write_data_+0 
	CALL        _EEPROM_Write+0, 0
;GameTerminal_PS2_HID.c,157 :: 		HID_Disable();                     //Выключение HID устройства
	CALL        _HID_Disable+0, 0
;GameTerminal_PS2_HID.c,158 :: 		delay_ms(10);                      //Задержка для ПК, чтобы успел отключить
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_main46:
	DECFSZ      R13, 1, 1
	BRA         L_main46
	DECFSZ      R12, 1, 1
	BRA         L_main46
;GameTerminal_PS2_HID.c,159 :: 		asm RESET; break;                  //Сброс МК
	RESET
	GOTO        L_main40
;GameTerminal_PS2_HID.c,160 :: 		default: break;
L_main47:
	GOTO        L_main40
;GameTerminal_PS2_HID.c,161 :: 		}
L_main39:
	MOVF        _progPass+16, 0 
	XORLW       30
	BTFSC       STATUS+0, 2 
	GOTO        L_main41
	MOVF        _progPass+16, 0 
	XORLW       31
	BTFSC       STATUS+0, 2 
	GOTO        L_main42
	MOVF        _progPass+16, 0 
	XORLW       32
	BTFSC       STATUS+0, 2 
	GOTO        L_main43
	MOVF        _progPass+16, 0 
	XORLW       33
	BTFSC       STATUS+0, 2 
	GOTO        L_main44
	MOVF        _progPass+16, 0 
	XORLW       39
	BTFSC       STATUS+0, 2 
	GOTO        L_main45
	GOTO        L_main47
L_main40:
;GameTerminal_PS2_HID.c,162 :: 		progPass[0] = 0;                         //Сброс ввода фразы
	CLRF        _progPass+0 
;GameTerminal_PS2_HID.c,163 :: 		}
	GOTO        L_main48
L_main38:
;GameTerminal_PS2_HID.c,165 :: 		else if(ArrCmp(&progPass, &delStr, 8, 8)){
	MOVLW       _progPass+0
	MOVWF       FARG_ArrCmp_arr1+0 
	MOVLW       hi_addr(_progPass+0)
	MOVWF       FARG_ArrCmp_arr1+1 
	MOVLW       _delStr+0
	MOVWF       FARG_ArrCmp_arr2+0 
	MOVLW       hi_addr(_delStr+0)
	MOVWF       FARG_ArrCmp_arr2+1 
	MOVLW       8
	MOVWF       FARG_ArrCmp_pos+0 
	MOVLW       8
	MOVWF       FARG_ArrCmp_ln+0 
	CALL        _ArrCmp+0, 0
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_main49
;GameTerminal_PS2_HID.c,166 :: 		switch(progPass[16]){
	GOTO        L_main50
;GameTerminal_PS2_HID.c,167 :: 		case KEY_1: UART1_Write(RDR_CLR_CH1); break;   //Удаление1 - кредитный
L_main52:
	MOVLW       205
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main51
;GameTerminal_PS2_HID.c,168 :: 		case KEY_2: UART1_Write(RDR_CLR_CH2); break;   //Удаление2 - сьемный
L_main53:
	MOVLW       206
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main51
;GameTerminal_PS2_HID.c,169 :: 		case KEY_3: UART1_Write(RDR_CLR_CH3); break;   //Удаление3 - овнер
L_main54:
	MOVLW       207
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main51
;GameTerminal_PS2_HID.c,170 :: 		case KEY_4: UART1_Write(RDR_CLR_CH4); break;   //Удаление4 - админ
L_main55:
	MOVLW       208
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main51
;GameTerminal_PS2_HID.c,171 :: 		case KEY_5: UART1_Write(RDR_CLR_ALL); break;   //Удаление5 - всех ключей
L_main56:
	MOVLW       209
	MOVWF       FARG_UART1_Write_data_+0 
	CALL        _UART1_Write+0, 0
	GOTO        L_main51
;GameTerminal_PS2_HID.c,172 :: 		default: break;
L_main57:
	GOTO        L_main51
;GameTerminal_PS2_HID.c,173 :: 		}
L_main50:
	MOVF        _progPass+16, 0 
	XORLW       30
	BTFSC       STATUS+0, 2 
	GOTO        L_main52
	MOVF        _progPass+16, 0 
	XORLW       31
	BTFSC       STATUS+0, 2 
	GOTO        L_main53
	MOVF        _progPass+16, 0 
	XORLW       32
	BTFSC       STATUS+0, 2 
	GOTO        L_main54
	MOVF        _progPass+16, 0 
	XORLW       33
	BTFSC       STATUS+0, 2 
	GOTO        L_main55
	MOVF        _progPass+16, 0 
	XORLW       34
	BTFSC       STATUS+0, 2 
	GOTO        L_main56
	GOTO        L_main57
L_main51:
;GameTerminal_PS2_HID.c,174 :: 		progPass[8] = 0;                         //Сброс фразы
	CLRF        _progPass+8 
;GameTerminal_PS2_HID.c,175 :: 		}
L_main49:
L_main48:
;GameTerminal_PS2_HID.c,176 :: 		delay_ms(100);                                 //Задержка, от этой задержки зависит время зажатия кнопок на переключение между клавиатурой и консолью
	MOVLW       7
	MOVWF       R11, 0
	MOVLW       23
	MOVWF       R12, 0
	MOVLW       106
	MOVWF       R13, 0
L_main58:
	DECFSZ      R13, 1, 1
	BRA         L_main58
	DECFSZ      R12, 1, 1
	BRA         L_main58
	DECFSZ      R11, 1, 1
	BRA         L_main58
	NOP
;GameTerminal_PS2_HID.c,177 :: 		}else if(sysFlags.if_pc == 0){
	GOTO        L_main59
L_main26:
	BTFSC       CVRCON+0, 0 
	GOTO        L_main60
;GameTerminal_PS2_HID.c,178 :: 		PWR5 = 0;                                 //Сбрасываем питание с платы
	BCF         PORTB+0, 2 
;GameTerminal_PS2_HID.c,179 :: 		VIDEO_PIN = 0;                            //Переключаемся на ПК
	BCF         PORTB+0, 7 
;GameTerminal_PS2_HID.c,180 :: 		if(USBFlags.if_conf == 1){                  //Если USB подключен выполняется обработка и отправка кнопки
	BTFSS       ADRESH+0, 1 
	GOTO        L_main61
;GameTerminal_PS2_HID.c,185 :: 		if(keycode[0] != 0)                      //Если есть хотябы одно нажате кнопки
	MOVF        _keycode+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_main62
;GameTerminal_PS2_HID.c,186 :: 		USBFlags.upBtn == 0;                //Сбросить флаг отпущеной кнопки
L_main62:
;GameTerminal_PS2_HID.c,187 :: 		if(USBFlags.upBtn == 0){                 //Если есть нажатие то выполняется
	BTFSC       ADRESH+0, 0 
	GOTO        L_main63
;GameTerminal_PS2_HID.c,188 :: 		writebuff[0]=modifier;                 //процедура отправки кнопок
	MOVF        _modifier+0, 0 
	MOVWF       1344 
;GameTerminal_PS2_HID.c,189 :: 		writebuff[1]=reserved;
	MOVF        _reserved+0, 0 
	MOVWF       1345 
;GameTerminal_PS2_HID.c,190 :: 		writebuff[2]=keycode[0];
	MOVF        _keycode+0, 0 
	MOVWF       1346 
;GameTerminal_PS2_HID.c,191 :: 		writebuff[3]=keycode[1];
	MOVF        _keycode+1, 0 
	MOVWF       1347 
;GameTerminal_PS2_HID.c,192 :: 		writebuff[4]=keycode[2];
	MOVF        _keycode+2, 0 
	MOVWF       1348 
;GameTerminal_PS2_HID.c,193 :: 		writebuff[5]=keycode[3];
	MOVF        _keycode+3, 0 
	MOVWF       1349 
;GameTerminal_PS2_HID.c,194 :: 		writebuff[6]=keycode[4];
	MOVF        _keycode+4, 0 
	MOVWF       1350 
;GameTerminal_PS2_HID.c,195 :: 		writebuff[7]=keycode[5];
	MOVF        _keycode+5, 0 
	MOVWF       1351 
;GameTerminal_PS2_HID.c,196 :: 		while(!HID_Write(writebuff,8));       //Непосредственно сама передача
L_main64:
	MOVLW       _writebuff+0
	MOVWF       FARG_HID_Write_writebuff+0 
	MOVLW       hi_addr(_writebuff+0)
	MOVWF       FARG_HID_Write_writebuff+1 
	MOVLW       8
	MOVWF       FARG_HID_Write_len+0 
	CALL        _HID_Write+0, 0
	MOVF        R0, 1 
	BTFSS       STATUS+0, 2 
	GOTO        L_main65
	GOTO        L_main64
L_main65:
;GameTerminal_PS2_HID.c,197 :: 		if(keycode[0] == 0)                   //Если нет не одной нажатой кнопки
	MOVF        _keycode+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_main66
;GameTerminal_PS2_HID.c,198 :: 		USBFlags.upBtn == 1;               //Устанавливаем флаг отпущенных кнопок
L_main66:
;GameTerminal_PS2_HID.c,199 :: 		}
L_main63:
;GameTerminal_PS2_HID.c,200 :: 		}
L_main61:
;GameTerminal_PS2_HID.c,201 :: 		delay_ms(30);
	MOVLW       2
	MOVWF       R11, 0
	MOVLW       212
	MOVWF       R12, 0
	MOVLW       133
	MOVWF       R13, 0
L_main67:
	DECFSZ      R13, 1, 1
	BRA         L_main67
	DECFSZ      R12, 1, 1
	BRA         L_main67
	DECFSZ      R11, 1, 1
	BRA         L_main67
;GameTerminal_PS2_HID.c,202 :: 		}
L_main60:
L_main59:
;GameTerminal_PS2_HID.c,203 :: 		}
	GOTO        L_main11
;GameTerminal_PS2_HID.c,205 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
