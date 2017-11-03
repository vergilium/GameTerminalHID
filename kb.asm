
_Init_PS2:

;kb.c,36 :: 		void Init_PS2(void){
;kb.c,38 :: 		bitcount = 11;                                   //Установка количества бит
	MOVLW       11
	MOVWF       _bitcount+0 
;kb.c,40 :: 		INTCON2.INTEDG1 = 0;       //int1 falling edge   // 0 = falling edge 1 = rising edge
	BCF         INTCON2+0, 5 
;kb.c,41 :: 		INTCON3.INT1IF = 0;                              // INT1 clear flag
	BCF         INTCON3+0, 0 
;kb.c,42 :: 		INTCON3 |= (1<<INT1IP)|(1<<INT1IE);              //INT1 Hight priority, intrrupt enable,
	MOVLW       72
	IORWF       INTCON3+0, 1 
;kb.c,44 :: 		TMR2IP_bit = 1;                                  //TIMER2 LOW priority
	BSF         TMR2IP_bit+0, BitPos(TMR2IP_bit+0) 
;kb.c,45 :: 		TMR2IF_bit = 0;                                  //TIMER2 clear flag
	BCF         TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
;kb.c,46 :: 		T2CON = (1<<T2OUTPS3)|(1<<T2OUTPS1)|(1<<T2OUTPS0)|(1<<T2CKPS0);
	MOVLW       89
	MOVWF       T2CON+0 
;kb.c,47 :: 		PR2 = 250;
	MOVLW       250
	MOVWF       PR2+0 
;kb.c,49 :: 		TMR2IE_bit = 1;                                  //timer2 int. enable
	BSF         TMR2IE_bit+0, BitPos(TMR2IE_bit+0) 
;kb.c,51 :: 		for(i=0; i<=5; i++) keycode[i] = 0;              //Инициализируем переменную с кнопками
	CLRF        R1 
L_Init_PS20:
	MOVF        R1, 0 
	SUBLW       5
	BTFSS       STATUS+0, 0 
	GOTO        L_Init_PS21
	MOVLW       _keycode+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_keycode+0)
	MOVWF       FSR1H 
	MOVF        R1, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	CLRF        POSTINC1+0 
	INCF        R1, 1 
	GOTO        L_Init_PS20
L_Init_PS21:
;kb.c,53 :: 		keyCnt = 0;                                      //Сброс количества нажатых кнопок
	CLRF        _keyCnt+0 
;kb.c,54 :: 		ADRESH = 0;                                      //Переназначеный регистр флагов сбрасываем в 0
	CLRF        ADRESH+0 
;kb.c,55 :: 		}
L_end_Init_PS2:
	RETURN      0
; end of _Init_PS2

_Reset_timeuot:

;kb.c,59 :: 		void Reset_timeuot (void){
;kb.c,60 :: 		TMR2ON_bit = 0;                                   //Остановить таймер
	BCF         TMR2ON_bit+0, BitPos(TMR2ON_bit+0) 
;kb.c,61 :: 		TMR2IF_bit = 0;                                   //TIMER0 clear flag
	BCF         TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
;kb.c,62 :: 		PR2 = 250;                                        //TIMER0 preload (1ms)
	MOVLW       250
	MOVWF       PR2+0 
;kb.c,63 :: 		}
L_end_Reset_timeuot:
	RETURN      0
; end of _Reset_timeuot

_Reset_PS2:

;kb.c,66 :: 		uint8_t Reset_PS2(void){
;kb.c,67 :: 		uint8_t timeout = 10;                                    //Время ожидания ответа  300 + 10*timeout (ms)
	MOVLW       10
	MOVWF       Reset_PS2_timeout_L0+0 
;kb.c,69 :: 		PS2_Send(0xFF);
	MOVLW       255
	MOVWF       FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;kb.c,70 :: 		delay_ms(300);
	MOVLW       19
	MOVWF       R11, 0
	MOVLW       68
	MOVWF       R12, 0
	MOVLW       68
	MOVWF       R13, 0
L_Reset_PS23:
	DECFSZ      R13, 1, 1
	BRA         L_Reset_PS23
	DECFSZ      R12, 1, 1
	BRA         L_Reset_PS23
	DECFSZ      R11, 1, 1
	BRA         L_Reset_PS23
	NOP
;kb.c,71 :: 		while(timeout != 0){
L_Reset_PS24:
	MOVF        Reset_PS2_timeout_L0+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_Reset_PS25
;kb.c,72 :: 		if(KYBState.request == KYB_FLAG_CMPSUCCES){
	MOVLW       240
	ANDWF       _KYBState+0, 0 
	MOVWF       R1 
	RRCF        R1, 1 
	BCF         R1, 7 
	RRCF        R1, 1 
	BCF         R1, 7 
	RRCF        R1, 1 
	BCF         R1, 7 
	RRCF        R1, 1 
	BCF         R1, 7 
	MOVF        R1, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_Reset_PS26
;kb.c,73 :: 		KYBState.kbMode = KEYB_MODE_CONFIGURED;
	MOVLW       1
	XORWF       _KYBState+0, 0 
	MOVWF       R0 
	MOVLW       15
	ANDWF       R0, 1 
	MOVF        _KYBState+0, 0 
	XORWF       R0, 1 
	MOVF        R0, 0 
	MOVWF       _KYBState+0 
;kb.c,74 :: 		return 1;
	MOVLW       1
	MOVWF       R0 
	GOTO        L_end_Reset_PS2
;kb.c,75 :: 		} else if (KYBState.request == KYB_FLAG_FAILURE){
L_Reset_PS26:
	MOVLW       240
	ANDWF       _KYBState+0, 0 
	MOVWF       R1 
	RRCF        R1, 1 
	BCF         R1, 7 
	RRCF        R1, 1 
	BCF         R1, 7 
	RRCF        R1, 1 
	BCF         R1, 7 
	RRCF        R1, 1 
	BCF         R1, 7 
	MOVF        R1, 0 
	XORLW       4
	BTFSS       STATUS+0, 2 
	GOTO        L_Reset_PS28
;kb.c,76 :: 		KYBState.kbMode = KEYB_MODE_ERROR;
	MOVLW       2
	XORWF       _KYBState+0, 0 
	MOVWF       R0 
	MOVLW       15
	ANDWF       R0, 1 
	MOVF        _KYBState+0, 0 
	XORWF       R0, 1 
	MOVF        R0, 0 
	MOVWF       _KYBState+0 
;kb.c,77 :: 		return 0;
	CLRF        R0 
	GOTO        L_end_Reset_PS2
;kb.c,78 :: 		}
L_Reset_PS28:
;kb.c,79 :: 		timeout--;
	DECF        Reset_PS2_timeout_L0+0, 1 
;kb.c,80 :: 		delay_ms(10);
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_Reset_PS29:
	DECFSZ      R13, 1, 1
	BRA         L_Reset_PS29
	DECFSZ      R12, 1, 1
	BRA         L_Reset_PS29
;kb.c,81 :: 		}
	GOTO        L_Reset_PS24
L_Reset_PS25:
;kb.c,82 :: 		KYBState.kbMode = KEYB_MODE_NOTCONFIGURE;
	MOVLW       240
	ANDWF       _KYBState+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       _KYBState+0 
;kb.c,83 :: 		KYBState.request = KYB_FLAG_NORESPONSE;
	MOVLW       15
	ANDWF       _KYBState+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       _KYBState+0 
;kb.c,84 :: 		return 0;
	CLRF        R0 
;kb.c,85 :: 		}
L_end_Reset_PS2:
	RETURN      0
; end of _Reset_PS2

_parity:

;kb.c,94 :: 		uint8_t parity(uint8_t x){        //Тут все просто - побитовый XOR
;kb.c,95 :: 		x ^= x >> 8;
;kb.c,96 :: 		x ^= x >> 4;
	MOVF        FARG_parity_x+0, 0 
	MOVWF       R0 
	RRCF        R0, 1 
	BCF         R0, 7 
	RRCF        R0, 1 
	BCF         R0, 7 
	RRCF        R0, 1 
	BCF         R0, 7 
	RRCF        R0, 1 
	BCF         R0, 7 
	MOVF        R0, 0 
	XORWF       FARG_parity_x+0, 0 
	MOVWF       R2 
	MOVF        R2, 0 
	MOVWF       FARG_parity_x+0 
;kb.c,97 :: 		x ^= x >> 2;
	MOVF        R2, 0 
	MOVWF       R0 
	RRCF        R0, 1 
	BCF         R0, 7 
	RRCF        R0, 1 
	BCF         R0, 7 
	MOVF        R0, 0 
	XORWF       R2, 1 
	MOVF        R2, 0 
	MOVWF       FARG_parity_x+0 
;kb.c,98 :: 		x ^= x >> 1;
	MOVF        R2, 0 
	MOVWF       R0 
	RRCF        R0, 1 
	BCF         R0, 7 
	MOVF        R2, 0 
	XORWF       R0, 1 
	MOVF        R0, 0 
	MOVWF       FARG_parity_x+0 
;kb.c,99 :: 		return ~(x & 1);
	MOVLW       1
	ANDWF       R0, 1 
	COMF        R0, 1 
;kb.c,100 :: 		}
L_end_parity:
	RETURN      0
; end of _parity

_PS2_interrupt:

;kb.c,104 :: 		void PS2_interrupt(void) {
;kb.c,106 :: 		if(INTCON3.INT1IE == 1 && INTCON3.INT1IF == 1){
	BTFSS       INTCON3+0, 3 
	GOTO        L_PS2_interrupt12
	BTFSS       INTCON3+0, 0 
	GOTO        L_PS2_interrupt12
L__PS2_interrupt151:
;kb.c,107 :: 		INTCON3.INT1IF = 0;                                       //Срос флага прерывания
	BCF         INTCON3+0, 0 
;kb.c,108 :: 		TMR2ON_bit = 1;                                           //Enable timeout timer
	BSF         TMR2ON_bit+0, BitPos(TMR2ON_bit+0) 
;kb.c,109 :: 		if(keyFlags.kb_rw == 0){
	BTFSC       ADRESH+0, 3 
	GOTO        L_PS2_interrupt13
;kb.c,110 :: 		if (INTCON2.INTEDG1 == 0){                                 // Routine entered at falling edge
	BTFSC       INTCON2+0, 5 
	GOTO        L_PS2_interrupt14
;kb.c,111 :: 		if(bitcount < 11 && bitcount > 2) {                   // Bit 3 to 10 is data. Parity bit, start and stop bits are ignored.
	MOVLW       11
	SUBWF       _bitcount+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_PS2_interrupt17
	MOVF        _bitcount+0, 0 
	SUBLW       2
	BTFSC       STATUS+0, 0 
	GOTO        L_PS2_interrupt17
L__PS2_interrupt150:
;kb.c,112 :: 		keyData = keyData >> 1;
	RRCF        PS2_interrupt_keyData_L0+0, 1 
	BCF         PS2_interrupt_keyData_L0+0, 7 
;kb.c,113 :: 		if(KEYB_DATA == 1)
	BTFSS       PORTA+0, 4 
	GOTO        L_PS2_interrupt18
;kb.c,114 :: 		keyData = keyData | 0x80;                       // Store a ’1’
	BSF         PS2_interrupt_keyData_L0+0, 7 
L_PS2_interrupt18:
;kb.c,115 :: 		}
L_PS2_interrupt17:
;kb.c,116 :: 		INTCON2.INTEDG1 = 1;                                  //int1 rising edge
	BSF         INTCON2+0, 5 
;kb.c,117 :: 		} else {                                                  // Routine entered at rising edge
	GOTO        L_PS2_interrupt19
L_PS2_interrupt14:
;kb.c,118 :: 		INTCON2.INTEDG1 = 0;                                  //int1 falling edge
	BCF         INTCON2+0, 5 
;kb.c,119 :: 		if(--bitcount == 0){                                  // All bits received
	DECF        _bitcount+0, 1 
	MOVF        _bitcount+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_PS2_interrupt20
;kb.c,120 :: 		Reset_timeuot();                                  //Disable timeout timer
	CALL        _Reset_timeuot+0, 0
;kb.c,121 :: 		KeyDecode(keyData);
	MOVF        PS2_interrupt_keyData_L0+0, 0 
	MOVWF       FARG_KeyDecode+0 
	CALL        _KeyDecode+0, 0
;kb.c,122 :: 		bitcount = 11;
	MOVLW       11
	MOVWF       _bitcount+0 
;kb.c,123 :: 		}
L_PS2_interrupt20:
;kb.c,124 :: 		}
L_PS2_interrupt19:
;kb.c,125 :: 		}else {
	GOTO        L_PS2_interrupt21
L_PS2_interrupt13:
;kb.c,128 :: 		if (INTCON2.INTEDG1 == 0){                               //Проверяем условие что прерывание по спадающему фронту
	BTFSC       INTCON2+0, 5 
	GOTO        L_PS2_interrupt22
;kb.c,129 :: 		if(bitcount > 2 && bitcount <= 10){                    //Отправляем байт кода команды
	MOVF        _bitcount+0, 0 
	SUBLW       2
	BTFSC       STATUS+0, 0 
	GOTO        L_PS2_interrupt25
	MOVF        _bitcount+0, 0 
	SUBLW       10
	BTFSS       STATUS+0, 0 
	GOTO        L_PS2_interrupt25
L__PS2_interrupt149:
;kb.c,130 :: 		KEYB_DATA = kbWriteBuff & 1;                         //Выставляем младший бит в порт
	MOVLW       1
	ANDWF       _kbWriteBuff+0, 0 
	MOVWF       R0 
	BTFSC       R0, 0 
	GOTO        L__PS2_interrupt160
	BCF         PORTA+0, 4 
	GOTO        L__PS2_interrupt161
L__PS2_interrupt160:
	BSF         PORTA+0, 4 
L__PS2_interrupt161:
;kb.c,131 :: 		kbWriteBuff = kbWriteBuff >> 1;                      //Сдвигаем байт на 1 в право для перехода на следующий бит
	RRCF        _kbWriteBuff+0, 1 
	BCF         _kbWriteBuff+0, 7 
;kb.c,132 :: 		bitcount --;                                         //Инкрементируем счетчик битов
	DECF        _bitcount+0, 1 
;kb.c,133 :: 		} else if(bitcount == 2){                              //Условие передачи бита четности
	GOTO        L_PS2_interrupt26
L_PS2_interrupt25:
	MOVF        _bitcount+0, 0 
	XORLW       2
	BTFSS       STATUS+0, 2 
	GOTO        L_PS2_interrupt27
;kb.c,134 :: 		KEYB_DATA = keyFlags.kb_parity;                      //Запись в порт бита четности (Вычисляется на этапе формирования посылки)
	BTFSC       ADRESH+0, 4 
	GOTO        L__PS2_interrupt162
	BCF         PORTA+0, 4 
	GOTO        L__PS2_interrupt163
L__PS2_interrupt162:
	BSF         PORTA+0, 4 
L__PS2_interrupt163:
;kb.c,135 :: 		bitcount --;
	DECF        _bitcount+0, 1 
;kb.c,136 :: 		} else if(bitcount == 1){                              //Условие передачи СТОП бита
	GOTO        L_PS2_interrupt28
L_PS2_interrupt27:
	MOVF        _bitcount+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_PS2_interrupt29
;kb.c,137 :: 		KEYB_DATA = 1;                                       //Шлем 1 в порт
	BSF         PORTA+0, 4 
;kb.c,138 :: 		bitcount --;
	DECF        _bitcount+0, 1 
;kb.c,139 :: 		} else if(bitcount == 0){                              //Условие конца передачи команды
	GOTO        L_PS2_interrupt30
L_PS2_interrupt29:
	MOVF        _bitcount+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_PS2_interrupt31
;kb.c,140 :: 		bitcount = 11;                                       //Сбрасываем счетчик бит
	MOVLW       11
	MOVWF       _bitcount+0 
;kb.c,141 :: 		TRISA.RA4 = 1;                                       //Переводим пин data на вход
	BSF         TRISA+0, 4 
;kb.c,142 :: 		keyFlags.kb_rw = 0;                                  //Сбрасываем флаг передачи команды
	BCF         ADRESH+0, 3 
;kb.c,143 :: 		Reset_timeuot();                                     //Сбрасываем таймаут посылки
	CALL        _Reset_timeuot+0, 0
;kb.c,151 :: 		}
L_PS2_interrupt31:
L_PS2_interrupt30:
L_PS2_interrupt28:
L_PS2_interrupt26:
;kb.c,152 :: 		}
L_PS2_interrupt22:
;kb.c,154 :: 		}
L_PS2_interrupt21:
;kb.c,155 :: 		}
L_PS2_interrupt12:
;kb.c,156 :: 		}
L_end_PS2_interrupt:
	RETURN      0
; end of _PS2_interrupt

_PS2_Send:

;kb.c,160 :: 		uint8_t PS2_Send(uint8_t sData){
;kb.c,161 :: 		if(bitcount == 11){                  //Проверка отсутствия приема кода от клавиатуры
	MOVF        _bitcount+0, 0 
	XORLW       11
	BTFSS       STATUS+0, 2 
	GOTO        L_PS2_Send32
;kb.c,162 :: 		kbWriteBuff = sData;
	MOVF        FARG_PS2_Send_sData+0, 0 
	MOVWF       _kbWriteBuff+0 
;kb.c,163 :: 		keyFlags.kb_parity = parity(kbWriteBuff);
	MOVF        FARG_PS2_Send_sData+0, 0 
	MOVWF       FARG_parity_x+0 
	CALL        _parity+0, 0
	BTFSC       R0, 0 
	GOTO        L__PS2_Send165
	BCF         ADRESH+0, 4 
	GOTO        L__PS2_Send166
L__PS2_Send165:
	BSF         ADRESH+0, 4 
L__PS2_Send166:
;kb.c,165 :: 		INTCON3.INT1IE = 0;               //Запрещаем прерывание от клавиатуры
	BCF         INTCON3+0, 3 
;kb.c,166 :: 		KEYB_CLOCK = 0;                    //Устанавливаем Clock в 0
	BCF         PORTB+0, 1 
;kb.c,167 :: 		KEYB_DATA = 1;                    //Устанавливаем Data в 1
	BSF         PORTA+0, 4 
;kb.c,168 :: 		TRISB.RB1 = 0;                    //Переводим пин clock на вывод
	BCF         TRISB+0, 1 
;kb.c,169 :: 		TRISA.RA4 = 0;                    //Переводим пин data на вывод
	BCF         TRISA+0, 4 
;kb.c,170 :: 		delay_ms(100);                    //Ждем 100мс
	MOVLW       7
	MOVWF       R11, 0
	MOVLW       23
	MOVWF       R12, 0
	MOVLW       106
	MOVWF       R13, 0
L_PS2_Send33:
	DECFSZ      R13, 1, 1
	BRA         L_PS2_Send33
	DECFSZ      R12, 1, 1
	BRA         L_PS2_Send33
	DECFSZ      R11, 1, 1
	BRA         L_PS2_Send33
	NOP
;kb.c,171 :: 		KEYB_DATA = 0;                    //Устанавливаем Data в 0
	BCF         PORTA+0, 4 
;kb.c,172 :: 		delay_ms(1);                      //Задержка для СТОП бита
	MOVLW       16
	MOVWF       R12, 0
	MOVLW       148
	MOVWF       R13, 0
L_PS2_Send34:
	DECFSZ      R13, 1, 1
	BRA         L_PS2_Send34
	DECFSZ      R12, 1, 1
	BRA         L_PS2_Send34
	NOP
;kb.c,173 :: 		KEYB_CLOCK = 1;                   //Подымаем КЛОК в лог 1
	BSF         PORTB+0, 1 
;kb.c,174 :: 		TRISB.RB1 = 1;                    //Переводим Clock на вход
	BSF         TRISB+0, 1 
;kb.c,175 :: 		keyFlags.kb_rw = 1;               //Устанавливаем флаг передачи данных в клавиатуру
	BSF         ADRESH+0, 3 
;kb.c,176 :: 		bitcount = 10;                    //Сбрасываем счетчик бит
	MOVLW       10
	MOVWF       _bitcount+0 
;kb.c,177 :: 		INTCON3.INT1IF = 0;               //Сбрасываем флаг прерывания перед началом работы
	BCF         INTCON3+0, 0 
;kb.c,178 :: 		INTCON3.INT1IE = 1;               //Разрешаем прерывания по Clock и идем в прерывание
	BSF         INTCON3+0, 3 
;kb.c,179 :: 		TMR2ON_bit = 1;                   //Enable timeout timer
	BSF         TMR2ON_bit+0, BitPos(TMR2ON_bit+0) 
;kb.c,180 :: 		return 1;
	MOVLW       1
	MOVWF       R0 
	GOTO        L_end_PS2_Send
;kb.c,181 :: 		} else return 0;
L_PS2_Send32:
	CLRF        R0 
;kb.c,182 :: 		}
L_end_PS2_Send:
	RETURN      0
; end of _PS2_Send

_PS2_Timeout_Interrupt:

;kb.c,186 :: 		void PS2_Timeout_Interrupt(){
;kb.c,187 :: 		if(TMR2IF_bit){
	BTFSS       TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
	GOTO        L_PS2_Timeout_Interrupt36
;kb.c,188 :: 		Reset_timeuot();
	CALL        _Reset_timeuot+0, 0
;kb.c,189 :: 		if(keyFlags.kb_rw == 1) {
	BTFSS       ADRESH+0, 3 
	GOTO        L_PS2_Timeout_Interrupt37
;kb.c,190 :: 		keyFlags.kb_rw = 0;
	BCF         ADRESH+0, 3 
;kb.c,191 :: 		kbWriteBuff = 0;
	CLRF        _kbWriteBuff+0 
;kb.c,192 :: 		KEYB_DATA = 1;
	BSF         PORTA+0, 4 
;kb.c,193 :: 		TRISA.RA4 = 1;
	BSF         TRISA+0, 4 
;kb.c,194 :: 		}
L_PS2_Timeout_Interrupt37:
;kb.c,195 :: 		bitcount = 11;
	MOVLW       11
	MOVWF       _bitcount+0 
;kb.c,196 :: 		}
L_PS2_Timeout_Interrupt36:
;kb.c,197 :: 		}
L_end_PS2_Timeout_Interrupt:
	RETURN      0
; end of _PS2_Timeout_Interrupt

_inArray:

;kb.c,201 :: 		uint8_t inArray(uint8_t value){               //Поиск значениея в массиве
;kb.c,203 :: 		for(i=0; i<=5; i++){                     //Поиск выполняется по массиву keycode
	CLRF        R1 
L_inArray38:
	MOVF        R1, 0 
	SUBLW       5
	BTFSS       STATUS+0, 0 
	GOTO        L_inArray39
;kb.c,204 :: 		if(keycode[i] == value){             //Если находит возвращает позицию + 1
	MOVLW       _keycode+0
	MOVWF       FSR0 
	MOVLW       hi_addr(_keycode+0)
	MOVWF       FSR0H 
	MOVF        R1, 0 
	ADDWF       FSR0, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR0H, 1 
	MOVF        POSTINC0+0, 0 
	XORWF       FARG_inArray_value+0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L_inArray41
;kb.c,205 :: 		return i+1;
	MOVF        R1, 0 
	ADDLW       1
	MOVWF       R0 
	GOTO        L_end_inArray
;kb.c,206 :: 		}
L_inArray41:
;kb.c,203 :: 		for(i=0; i<=5; i++){                     //Поиск выполняется по массиву keycode
	INCF        R1, 1 
;kb.c,207 :: 		}
	GOTO        L_inArray38
L_inArray39:
;kb.c,208 :: 		return 0;                                //В противном случае возврат 0
	CLRF        R0 
;kb.c,209 :: 		}
L_end_inArray:
	RETURN      0
; end of _inArray

_Set_BRDButton:

;kb.c,213 :: 		void Set_BRDButton (uint8_t key, uint8_t upDown){
;kb.c,214 :: 		switch (key){
	GOTO        L_Set_BRDButton42
;kb.c,216 :: 		case KEY_F5    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton44:
	BTFSC       CVRCON+0, 0 
	GOTO        L_Set_BRDButton45
	GOTO        L_Set_BRDButton43
L_Set_BRDButton45:
;kb.c,217 :: 		case KEY_1     :
L_Set_BRDButton46:
;kb.c,218 :: 		case KEY_NUM_1 : BT_STOP1 = upDown;
L_Set_BRDButton47:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton170
	BCF         PORTA+0, 0 
	GOTO        L__Set_BRDButton171
L__Set_BRDButton170:
	BSF         PORTA+0, 0 
L__Set_BRDButton171:
;kb.c,219 :: 		if (sysFlags.kbBtn_mode == OFF)
	BTFSC       CVRCON+0, 2 
	GOTO        L_Set_BRDButton48
;kb.c,220 :: 		LED_PIN = upDown;
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton172
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton173
L__Set_BRDButton172:
	BSF         PORTC+0, 2 
L__Set_BRDButton173:
L_Set_BRDButton48:
;kb.c,221 :: 		break;
	GOTO        L_Set_BRDButton43
;kb.c,223 :: 		case KEY_F6    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton49:
	BTFSC       CVRCON+0, 0 
	GOTO        L_Set_BRDButton50
	GOTO        L_Set_BRDButton43
L_Set_BRDButton50:
;kb.c,224 :: 		case KEY_2     :
L_Set_BRDButton51:
;kb.c,225 :: 		case KEY_NUM_2 : BT_STOP2 = upDown;
L_Set_BRDButton52:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton174
	BCF         PORTA+0, 1 
	GOTO        L__Set_BRDButton175
L__Set_BRDButton174:
	BSF         PORTA+0, 1 
L__Set_BRDButton175:
;kb.c,226 :: 		if (sysFlags.kbBtn_mode == OFF)
	BTFSC       CVRCON+0, 2 
	GOTO        L_Set_BRDButton53
;kb.c,227 :: 		LED_PIN = upDown;
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton176
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton177
L__Set_BRDButton176:
	BSF         PORTC+0, 2 
L__Set_BRDButton177:
L_Set_BRDButton53:
;kb.c,228 :: 		break;
	GOTO        L_Set_BRDButton43
;kb.c,230 :: 		case KEY_F7    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton54:
	BTFSC       CVRCON+0, 0 
	GOTO        L_Set_BRDButton55
	GOTO        L_Set_BRDButton43
L_Set_BRDButton55:
;kb.c,231 :: 		case KEY_3     :
L_Set_BRDButton56:
;kb.c,232 :: 		case KEY_NUM_3 : BT_STOP3 = upDown;
L_Set_BRDButton57:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton178
	BCF         PORTA+0, 2 
	GOTO        L__Set_BRDButton179
L__Set_BRDButton178:
	BSF         PORTA+0, 2 
L__Set_BRDButton179:
;kb.c,233 :: 		if (sysFlags.kbBtn_mode == OFF)
	BTFSC       CVRCON+0, 2 
	GOTO        L_Set_BRDButton58
;kb.c,234 :: 		LED_PIN = upDown;
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton180
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton181
L__Set_BRDButton180:
	BSF         PORTC+0, 2 
L__Set_BRDButton181:
L_Set_BRDButton58:
;kb.c,235 :: 		break;
	GOTO        L_Set_BRDButton43
;kb.c,237 :: 		case KEY_F8    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton59:
	BTFSC       CVRCON+0, 0 
	GOTO        L_Set_BRDButton60
	GOTO        L_Set_BRDButton43
L_Set_BRDButton60:
;kb.c,238 :: 		case KEY_4     :
L_Set_BRDButton61:
;kb.c,239 :: 		case KEY_NUM_4 : BT_STOP4 = upDown;
L_Set_BRDButton62:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton182
	BCF         PORTA+0, 3 
	GOTO        L__Set_BRDButton183
L__Set_BRDButton182:
	BSF         PORTA+0, 3 
L__Set_BRDButton183:
;kb.c,240 :: 		if (sysFlags.kbBtn_mode == OFF)
	BTFSC       CVRCON+0, 2 
	GOTO        L_Set_BRDButton63
;kb.c,241 :: 		LED_PIN = upDown;
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton184
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton185
L__Set_BRDButton184:
	BSF         PORTC+0, 2 
L__Set_BRDButton185:
L_Set_BRDButton63:
;kb.c,242 :: 		break;
	GOTO        L_Set_BRDButton43
;kb.c,244 :: 		case KEY_F9    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton64:
	BTFSC       CVRCON+0, 0 
	GOTO        L_Set_BRDButton65
	GOTO        L_Set_BRDButton43
L_Set_BRDButton65:
;kb.c,245 :: 		case KEY_5     :
L_Set_BRDButton66:
;kb.c,246 :: 		case KEY_NUM_5 : BT_STOP5 = upDown;
L_Set_BRDButton67:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton186
	BCF         PORTA+0, 5 
	GOTO        L__Set_BRDButton187
L__Set_BRDButton186:
	BSF         PORTA+0, 5 
L__Set_BRDButton187:
;kb.c,247 :: 		if (sysFlags.kbBtn_mode == OFF)
	BTFSC       CVRCON+0, 2 
	GOTO        L_Set_BRDButton68
;kb.c,248 :: 		LED_PIN = upDown;
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton188
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton189
L__Set_BRDButton188:
	BSF         PORTC+0, 2 
L__Set_BRDButton189:
L_Set_BRDButton68:
;kb.c,249 :: 		break;
	GOTO        L_Set_BRDButton43
;kb.c,251 :: 		case KEY_F4    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton69:
	BTFSC       CVRCON+0, 0 
	GOTO        L_Set_BRDButton70
	GOTO        L_Set_BRDButton43
L_Set_BRDButton70:
;kb.c,252 :: 		case KEY_6     :
L_Set_BRDButton71:
;kb.c,253 :: 		case KEY_NUM_6 : if(sysFlags.kbBtn_mode == ON) BT_AUTO = upDown;
L_Set_BRDButton72:
	BTFSS       CVRCON+0, 2 
	GOTO        L_Set_BRDButton73
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton190
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton191
L__Set_BRDButton190:
	BSF         PORTC+0, 2 
L__Set_BRDButton191:
L_Set_BRDButton73:
;kb.c,254 :: 		break;
	GOTO        L_Set_BRDButton43
;kb.c,256 :: 		case KEY_F10   : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton74:
	BTFSC       CVRCON+0, 0 
	GOTO        L_Set_BRDButton75
	GOTO        L_Set_BRDButton43
L_Set_BRDButton75:
;kb.c,257 :: 		case KEY_7     :
L_Set_BRDButton76:
;kb.c,258 :: 		case KEY_NUM_7 : BT_LINE = upDown;
L_Set_BRDButton77:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton192
	BCF         PORTB+0, 6 
	GOTO        L__Set_BRDButton193
L__Set_BRDButton192:
	BSF         PORTB+0, 6 
L__Set_BRDButton193:
;kb.c,259 :: 		if (sysFlags.kbBtn_mode == OFF)
	BTFSC       CVRCON+0, 2 
	GOTO        L_Set_BRDButton78
;kb.c,260 :: 		LED_PIN = upDown;
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton194
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton195
L__Set_BRDButton194:
	BSF         PORTC+0, 2 
L__Set_BRDButton195:
L_Set_BRDButton78:
;kb.c,261 :: 		break;
	GOTO        L_Set_BRDButton43
;kb.c,263 :: 		case KEY_F11   : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton79:
	BTFSC       CVRCON+0, 0 
	GOTO        L_Set_BRDButton80
	GOTO        L_Set_BRDButton43
L_Set_BRDButton80:
;kb.c,264 :: 		case KEY_8     :
L_Set_BRDButton81:
;kb.c,265 :: 		case KEY_NUM_8 : BT_BET = upDown;
L_Set_BRDButton82:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton196
	BCF         PORTB+0, 5 
	GOTO        L__Set_BRDButton197
L__Set_BRDButton196:
	BSF         PORTB+0, 5 
L__Set_BRDButton197:
;kb.c,266 :: 		if (sysFlags.kbBtn_mode == OFF)
	BTFSC       CVRCON+0, 2 
	GOTO        L_Set_BRDButton83
;kb.c,267 :: 		LED_PIN = upDown;
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton198
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton199
L__Set_BRDButton198:
	BSF         PORTC+0, 2 
L__Set_BRDButton199:
L_Set_BRDButton83:
;kb.c,268 :: 		break;
	GOTO        L_Set_BRDButton43
;kb.c,270 :: 		case KEY_F1    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton84:
	BTFSC       CVRCON+0, 0 
	GOTO        L_Set_BRDButton85
	GOTO        L_Set_BRDButton43
L_Set_BRDButton85:
;kb.c,271 :: 		case KEY_9     :
L_Set_BRDButton86:
;kb.c,272 :: 		case KEY_NUM_9 : BT_INFO = upDown;
L_Set_BRDButton87:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton200
	BCF         PORTC+0, 0 
	GOTO        L__Set_BRDButton201
L__Set_BRDButton200:
	BSF         PORTC+0, 0 
L__Set_BRDButton201:
;kb.c,273 :: 		if (sysFlags.kbBtn_mode == OFF)
	BTFSC       CVRCON+0, 2 
	GOTO        L_Set_BRDButton88
;kb.c,274 :: 		LED_PIN = upDown;
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton202
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton203
L__Set_BRDButton202:
	BSF         PORTC+0, 2 
L__Set_BRDButton203:
L_Set_BRDButton88:
;kb.c,275 :: 		break;
	GOTO        L_Set_BRDButton43
;kb.c,277 :: 		case KEY_F2    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton89:
	BTFSC       CVRCON+0, 0 
	GOTO        L_Set_BRDButton90
	GOTO        L_Set_BRDButton43
L_Set_BRDButton90:
;kb.c,278 :: 		case KEY_0     :
L_Set_BRDButton91:
;kb.c,279 :: 		case KEY_NUM_0 : BT_MENU = upDown;
L_Set_BRDButton92:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton204
	BCF         PORTC+0, 1 
	GOTO        L__Set_BRDButton205
L__Set_BRDButton204:
	BSF         PORTC+0, 1 
L__Set_BRDButton205:
;kb.c,280 :: 		if (sysFlags.kbBtn_mode == OFF)
	BTFSC       CVRCON+0, 2 
	GOTO        L_Set_BRDButton93
;kb.c,281 :: 		LED_PIN = upDown;
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton206
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton207
L__Set_BRDButton206:
	BSF         PORTC+0, 2 
L__Set_BRDButton207:
L_Set_BRDButton93:
;kb.c,282 :: 		break;
	GOTO        L_Set_BRDButton43
;kb.c,284 :: 		case KEY_F12   : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton94:
	BTFSC       CVRCON+0, 0 
	GOTO        L_Set_BRDButton95
	GOTO        L_Set_BRDButton43
L_Set_BRDButton95:
;kb.c,285 :: 		case KEY_ENTER :
L_Set_BRDButton96:
;kb.c,286 :: 		case KEY_SPACE :
L_Set_BRDButton97:
;kb.c,287 :: 		case KEY_NUM_ENTR: BT_START = upDown;
L_Set_BRDButton98:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton208
	BCF         PORTB+0, 4 
	GOTO        L__Set_BRDButton209
L__Set_BRDButton208:
	BSF         PORTB+0, 4 
L__Set_BRDButton209:
;kb.c,288 :: 		if (sysFlags.kbBtn_mode == OFF)
	BTFSC       CVRCON+0, 2 
	GOTO        L_Set_BRDButton99
;kb.c,289 :: 		LED_PIN = upDown;
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton210
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton211
L__Set_BRDButton210:
	BSF         PORTC+0, 2 
L__Set_BRDButton211:
L_Set_BRDButton99:
;kb.c,290 :: 		break;
	GOTO        L_Set_BRDButton43
;kb.c,292 :: 		case KEY_F3    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton100:
	BTFSC       CVRCON+0, 0 
	GOTO        L_Set_BRDButton101
	GOTO        L_Set_BRDButton43
L_Set_BRDButton101:
;kb.c,293 :: 		case KEY_ESC   :
L_Set_BRDButton102:
;kb.c,294 :: 		case KEY_HOME  : sysFlags.if_pc = 0; break;           //Кнопками Esc и Home происходит выход с режима плата
L_Set_BRDButton103:
	BCF         CVRCON+0, 4 
	GOTO        L_Set_BRDButton43
;kb.c,296 :: 		default : break;
L_Set_BRDButton104:
	GOTO        L_Set_BRDButton43
;kb.c,297 :: 		}
L_Set_BRDButton42:
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       62
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton44
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       30
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton46
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       89
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton47
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       63
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton49
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       31
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton51
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       90
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton52
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       64
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton54
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       32
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton56
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       91
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton57
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       65
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton59
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       33
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton61
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       92
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton62
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       66
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton64
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       34
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton66
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       93
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton67
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       61
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton69
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       35
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton71
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       94
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton72
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       67
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton74
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       36
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton76
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       95
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton77
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       68
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton79
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       37
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton81
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       96
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton82
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       58
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton84
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       38
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton86
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       97
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton87
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       59
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton89
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       39
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton91
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       98
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton92
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       69
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton94
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       40
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton96
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       44
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton97
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       88
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton98
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       60
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton100
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       41
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton102
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       74
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton103
	GOTO        L_Set_BRDButton104
L_Set_BRDButton43:
;kb.c,298 :: 		}
L_end_Set_BRDButton:
	RETURN      0
; end of _Set_BRDButton

_SetPass:

;kb.c,307 :: 		void SetPass (uint8_t key){
;kb.c,310 :: 		for(i=0; i<PASS_BUFF_SIZE; i++){          //При нажатии кнопки массив пароля сдвигается
	CLRF        R2 
L_SetPass105:
	MOVLW       32
	SUBWF       R2, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_SetPass106
;kb.c,311 :: 		progPass[i] = progPass[i+1];           //на позицию вперед
	MOVLW       _progPass+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_progPass+0)
	MOVWF       FSR1H 
	MOVF        R2, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVF        R2, 0 
	ADDLW       1
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVLW       _progPass+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_progPass+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;kb.c,310 :: 		for(i=0; i<PASS_BUFF_SIZE; i++){          //При нажатии кнопки массив пароля сдвигается
	INCF        R2, 1 
;kb.c,312 :: 		}
	GOTO        L_SetPass105
L_SetPass106:
;kb.c,313 :: 		if((modifier & 0x22) != 0)                     //Если нажат левый или правый shift
	MOVLW       34
	ANDWF       _modifier+0, 0 
	MOVWF       R1 
	MOVF        R1, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_SetPass108
;kb.c,314 :: 		progPass[PASS_BUFF_SIZE-1] = key | 0x80;    //в конец дописывается код нажатой кнопки и бита shift
	MOVLW       128
	IORWF       FARG_SetPass_key+0, 0 
	MOVWF       _progPass+31 
	GOTO        L_SetPass109
L_SetPass108:
;kb.c,316 :: 		progPass[PASS_BUFF_SIZE-1] = key;
	MOVF        FARG_SetPass_key+0, 0 
	MOVWF       _progPass+31 
L_SetPass109:
;kb.c,317 :: 		}
L_end_SetPass:
	RETURN      0
; end of _SetPass

_RemarkConsole:

;kb.c,319 :: 		unsigned char RemarkConsole(unsigned char key){
;kb.c,320 :: 		key = kbRemark[key - 0x3A];
	MOVLW       58
	SUBWF       FARG_RemarkConsole_key+0, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	SUBWFB      R1, 1 
	MOVLW       _kbRemark+0
	ADDWF       R0, 0 
	MOVWF       TBLPTRL 
	MOVLW       hi_addr(_kbRemark+0)
	ADDWFC      R1, 0 
	MOVWF       TBLPTRH 
	MOVLW       higher_addr(_kbRemark+0)
	MOVWF       TBLPTRU 
	MOVLW       0
	BTFSC       R1, 7 
	MOVLW       255
	ADDWFC      TBLPTRU, 1 
	TBLRD*+
	MOVFF       TABLAT+0, R0
	MOVF        R0, 0 
	MOVWF       FARG_RemarkConsole_key+0 
;kb.c,321 :: 		return key;
;kb.c,322 :: 		}
L_end_RemarkConsole:
	RETURN      0
; end of _RemarkConsole

_KeyDecode:

;kb.c,326 :: 		void KeyDecode(uint8_t sc){
;kb.c,328 :: 		uint8_t i, key=0;                //Буферная переманная кода клавиши
	CLRF        KeyDecode_key_L0+0 
;kb.c,331 :: 		switch(sc){
	GOTO        L_KeyDecode110
;kb.c,332 :: 		case KEYB_FUNC_CODE        : keyFlags.if_func = 1; break;                   //Устанавливаем флаг функциональной кнопки если пришел ее код
L_KeyDecode112:
	BSF         ADRESH+0, 1 
	GOTO        L_KeyDecode111
;kb.c,333 :: 		case KEYB_BREAK_CODE       : keyFlags.if_up = 1; break;                     //Устанавливаем флаг если кнопка отпущена
L_KeyDecode113:
	BSF         ADRESH+0, 2 
	GOTO        L_KeyDecode111
;kb.c,334 :: 		case KEYB_COMPLETE_SUCCESS : KYBState.request =  KYB_FLAG_CMPSUCCES; break;//Ответ клавиатуры об удачной конфигурации
L_KeyDecode114:
	MOVLW       16
	XORWF       _KYBState+0, 0 
	MOVWF       R0 
	MOVLW       240
	ANDWF       R0, 1 
	MOVF        _KYBState+0, 0 
	XORWF       R0, 1 
	MOVF        R0, 0 
	MOVWF       _KYBState+0 
	GOTO        L_KeyDecode111
;kb.c,335 :: 		case KEYB_RESEND           : KYBState.request =  KYB_FLAG_RESEND; break;     //Запрос клавиатуры на повторную отправку команды
L_KeyDecode115:
	MOVLW       48
	XORWF       _KYBState+0, 0 
	MOVWF       R0 
	MOVLW       240
	ANDWF       R0, 1 
	MOVF        _KYBState+0, 0 
	XORWF       R0, 1 
	MOVF        R0, 0 
	MOVWF       _KYBState+0 
	GOTO        L_KeyDecode111
;kb.c,336 :: 		case KEYB_FAILURE          : KYBState.request =  KYB_FLAG_FAILURE; break;//Ошибка устройства
L_KeyDecode116:
	MOVLW       64
	XORWF       _KYBState+0, 0 
	MOVWF       R0 
	MOVLW       240
	ANDWF       R0, 1 
	MOVF        _KYBState+0, 0 
	XORWF       R0, 1 
	MOVF        R0, 0 
	MOVWF       _KYBState+0 
	GOTO        L_KeyDecode111
;kb.c,337 :: 		case KEYB_ACKNOWLEDGE      : KYBState.request =  KYB_FLAG_ACKNOWLEDGE; break;//Подтверждение получения команды
L_KeyDecode117:
	MOVLW       32
	XORWF       _KYBState+0, 0 
	MOVWF       R0 
	MOVLW       240
	ANDWF       R0, 1 
	MOVF        _KYBState+0, 0 
	XORWF       R0, 1 
	MOVF        R0, 0 
	MOVWF       _KYBState+0 
	GOTO        L_KeyDecode111
;kb.c,338 :: 		default :  if(sc > 0 && sc < 0x84){                                //Проверка что нажата кнопка а не сервисные данные
L_KeyDecode118:
	MOVF        FARG_KeyDecode_sc+0, 0 
	SUBLW       0
	BTFSC       STATUS+0, 0 
	GOTO        L_KeyDecode121
	MOVLW       132
	SUBWF       FARG_KeyDecode_sc+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_KeyDecode121
L__KeyDecode154:
;kb.c,339 :: 		if(keyFlags.if_func == 1){                             //Если была нажата функциональная кнопка
	BTFSS       ADRESH+0, 1 
	GOTO        L_KeyDecode122
;kb.c,340 :: 		for(i=0; i<sizeof(funCode)/2; i++){                //Перебераем HID сканкод из массива соответствия
	CLRF        KeyDecode_i_L0+0 
L_KeyDecode123:
	MOVLW       18
	SUBWF       KeyDecode_i_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_KeyDecode124
;kb.c,341 :: 		if(funCode[i][0] == sc){
	MOVF        KeyDecode_i_L0+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVWF       R2 
	MOVWF       R3 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	RLCF        R2, 1 
	RLCF        R3, 1 
	MOVLW       _funCode+0
	ADDWF       R0, 0 
	MOVWF       TBLPTRL 
	MOVLW       hi_addr(_funCode+0)
	ADDWFC      R1, 0 
	MOVWF       TBLPTRH 
	MOVLW       higher_addr(_funCode+0)
	ADDWFC      R2, 0 
	MOVWF       TBLPTRU 
	TBLRD*+
	MOVFF       TABLAT+0, R1
	MOVF        R1, 0 
	XORWF       FARG_KeyDecode_sc+0, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L_KeyDecode126
;kb.c,342 :: 		key = funCode[i][1];                         //Если такой код имеется то записываем его в буферную переменную
	MOVF        KeyDecode_i_L0+0, 0 
	MOVWF       R0 
	MOVLW       0
	MOVWF       R1 
	MOVWF       R2 
	MOVWF       R3 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	RLCF        R2, 1 
	RLCF        R3, 1 
	MOVLW       _funCode+0
	ADDWF       R0, 1 
	MOVLW       hi_addr(_funCode+0)
	ADDWFC      R1, 1 
	MOVLW       higher_addr(_funCode+0)
	ADDWFC      R2, 1 
	MOVLW       1
	ADDWF       R0, 0 
	MOVWF       TBLPTRL 
	MOVLW       0
	ADDWFC      R1, 0 
	MOVWF       TBLPTRH 
	MOVLW       0
	ADDWFC      R2, 0 
	MOVWF       TBLPTRU 
	TBLRD*+
	MOVFF       TABLAT+0, KeyDecode_key_L0+0
;kb.c,343 :: 		break;                                        //и выходим с цикла
	GOTO        L_KeyDecode124
;kb.c,344 :: 		}
L_KeyDecode126:
;kb.c,340 :: 		for(i=0; i<sizeof(funCode)/2; i++){                //Перебераем HID сканкод из массива соответствия
	INCF        KeyDecode_i_L0+0, 1 
;kb.c,345 :: 		}
	GOTO        L_KeyDecode123
L_KeyDecode124:
;kb.c,346 :: 		keyFlags.if_func = 0;                              //В противном случае просто сбрасываем флаг
	BCF         ADRESH+0, 1 
;kb.c,347 :: 		} else {
	GOTO        L_KeyDecode127
L_KeyDecode122:
;kb.c,348 :: 		key = scanCode[sc];                       //Если была нажата простая кнопка то записываем код из массива простых кнопок
	MOVLW       _scanCode+0
	ADDWF       FARG_KeyDecode_sc+0, 0 
	MOVWF       TBLPTRL 
	MOVLW       hi_addr(_scanCode+0)
	MOVWF       TBLPTRH 
	MOVLW       0
	ADDWFC      TBLPTRH, 1 
	MOVLW       higher_addr(_scanCode+0)
	MOVWF       TBLPTRU 
	MOVLW       0
	ADDWFC      TBLPTRU, 1 
	TBLRD*+
	MOVFF       TABLAT+0, KeyDecode_key_L0+0
;kb.c,349 :: 		}
L_KeyDecode127:
;kb.c,350 :: 		if(key>1){
	MOVF        KeyDecode_key_L0+0, 0 
	SUBLW       1
	BTFSC       STATUS+0, 0 
	GOTO        L_KeyDecode128
;kb.c,354 :: 		if(key >= 0xE0 && key <= 0xE7){//Проверяем если прийшли данные от кнопок CtrlShiftAltWin
	MOVLW       224
	SUBWF       KeyDecode_key_L0+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_KeyDecode131
	MOVF        KeyDecode_key_L0+0, 0 
	SUBLW       231
	BTFSS       STATUS+0, 0 
	GOTO        L_KeyDecode131
L__KeyDecode153:
;kb.c,355 :: 		if(keyFlags.if_up == 1){                          //Проверяем если одна из кнопок была отжата
	BTFSS       ADRESH+0, 2 
	GOTO        L_KeyDecode132
;kb.c,356 :: 		modifier &= ~dvFlags[key & 0x0F];     //Если так то убираем соответствующий флаг
	MOVLW       15
	ANDWF       KeyDecode_key_L0+0, 0 
	MOVWF       R0 
	MOVLW       _dvFlags+0
	ADDWF       R0, 0 
	MOVWF       TBLPTRL 
	MOVLW       hi_addr(_dvFlags+0)
	MOVWF       TBLPTRH 
	MOVLW       0
	ADDWFC      TBLPTRH, 1 
	MOVLW       higher_addr(_dvFlags+0)
	MOVWF       TBLPTRU 
	MOVLW       0
	ADDWFC      TBLPTRU, 1 
	TBLRD*+
	MOVFF       TABLAT+0, R0
	COMF        R0, 1 
	MOVF        R0, 0 
	ANDWF       _modifier+0, 1 
;kb.c,357 :: 		} else                                    //Далее проверяем если нажатая клавиша соответствует HID коду
	GOTO        L_KeyDecode133
L_KeyDecode132:
;kb.c,358 :: 		modifier |= dvFlags[key & 0x0F];
	MOVLW       15
	ANDWF       KeyDecode_key_L0+0, 0 
	MOVWF       R0 
	MOVLW       _dvFlags+0
	ADDWF       R0, 0 
	MOVWF       TBLPTRL 
	MOVLW       hi_addr(_dvFlags+0)
	MOVWF       TBLPTRH 
	MOVLW       0
	ADDWFC      TBLPTRH, 1 
	MOVLW       higher_addr(_dvFlags+0)
	MOVWF       TBLPTRU 
	MOVLW       0
	ADDWFC      TBLPTRU, 1 
	TBLRD*+
	MOVFF       TABLAT+0, R0
	MOVF        R0, 0 
	IORWF       _modifier+0, 1 
L_KeyDecode133:
;kb.c,359 :: 		} /////////////////////////////////////////////////////////////
L_KeyDecode131:
;kb.c,361 :: 		keyPos = inArray(key);             //Проверяем есть ли эта кнопка уже в массиве (режим клавиатуры)
	MOVF        KeyDecode_key_L0+0, 0 
	MOVWF       FARG_inArray_value+0 
	CALL        _inArray+0, 0
	MOVF        R0, 0 
	MOVWF       KeyDecode_keyPos_L0+0 
;kb.c,362 :: 		if(keyPos){                     //Если есть проверяем не отпущена ли кнопка
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_KeyDecode134
;kb.c,363 :: 		if(keyFlags.if_up){                             //Если отпущена
	BTFSS       ADRESH+0, 2 
	GOTO        L_KeyDecode135
;kb.c,364 :: 		if(sysFlags.if_pc == 1)  Set_BRDButton(key, 0);
	BTFSS       CVRCON+0, 4 
	GOTO        L_KeyDecode136
	MOVF        KeyDecode_key_L0+0, 0 
	MOVWF       FARG_Set_BRDButton_key+0 
	CLRF        FARG_Set_BRDButton_upDown+0 
	CALL        _Set_BRDButton+0, 0
L_KeyDecode136:
;kb.c,365 :: 		for(i=keyPos-1; i<5; i++){          //изьять элемент из массива и выполнить сдвих
	DECF        KeyDecode_keyPos_L0+0, 0 
	MOVWF       KeyDecode_i_L0+0 
L_KeyDecode137:
	MOVLW       5
	SUBWF       KeyDecode_i_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_KeyDecode138
;kb.c,366 :: 		keycode[i] = keycode[i+1];
	MOVLW       _keycode+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_keycode+0)
	MOVWF       FSR1H 
	MOVF        KeyDecode_i_L0+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVF        KeyDecode_i_L0+0, 0 
	ADDLW       1
	MOVWF       R0 
	CLRF        R1 
	MOVLW       0
	ADDWFC      R1, 1 
	MOVLW       _keycode+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_keycode+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       POSTINC1+0 
;kb.c,365 :: 		for(i=keyPos-1; i<5; i++){          //изьять элемент из массива и выполнить сдвих
	INCF        KeyDecode_i_L0+0, 1 
;kb.c,367 :: 		}
	GOTO        L_KeyDecode137
L_KeyDecode138:
;kb.c,368 :: 		keyCnt--;                            //Инкрементировать щетчик кнопок
	DECF        _keyCnt+0, 1 
;kb.c,369 :: 		keyFlags.if_up = 0;                           //Сбросить флаг отпущеной кнопки
	BCF         ADRESH+0, 2 
;kb.c,370 :: 		}
L_KeyDecode135:
;kb.c,372 :: 		}else if(keyCnt<6){                      //Если не отпущена то проверяем какой режим клавиатуры или консоли
	GOTO        L_KeyDecode140
L_KeyDecode134:
	MOVLW       6
	SUBWF       _keyCnt+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_KeyDecode141
;kb.c,373 :: 		if(sysFlags.if_pc == 1) Set_BRDButton(key, 1);
	BTFSS       CVRCON+0, 4 
	GOTO        L_KeyDecode142
	MOVF        KeyDecode_key_L0+0, 0 
	MOVWF       FARG_Set_BRDButton_key+0 
	MOVLW       1
	MOVWF       FARG_Set_BRDButton_upDown+0 
	CALL        _Set_BRDButton+0, 0
L_KeyDecode142:
;kb.c,374 :: 		keycode[keyCnt] = key;
	MOVLW       _keycode+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_keycode+0)
	MOVWF       FSR1H 
	MOVF        _keyCnt+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	MOVF        KeyDecode_key_L0+0, 0 
	MOVWF       POSTINC1+0 
;kb.c,375 :: 		keyCnt++;                                     //инкрементируем массив кнопок
	INCF        _keyCnt+0, 1 
;kb.c,376 :: 		if(key >= KEY_A && key <= KEY_0){         //Проверка ввода только символов
	MOVLW       4
	SUBWF       KeyDecode_key_L0+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_KeyDecode145
	MOVF        KeyDecode_key_L0+0, 0 
	SUBLW       39
	BTFSS       STATUS+0, 0 
	GOTO        L_KeyDecode145
L__KeyDecode152:
;kb.c,377 :: 		SetPass(key);                          //Обработчик ввода пароля программирования и удаления ключей с клавиатуры
	MOVF        KeyDecode_key_L0+0, 0 
	MOVWF       FARG_SetPass_key+0 
	CALL        _SetPass+0, 0
;kb.c,378 :: 		}
L_KeyDecode145:
;kb.c,379 :: 		}
L_KeyDecode141:
L_KeyDecode140:
;kb.c,380 :: 		}
L_KeyDecode128:
;kb.c,381 :: 		for (i=keycnt; i<=5; i++){                  //Остальное забиваем нулями
	MOVF        _keyCnt+0, 0 
	MOVWF       KeyDecode_i_L0+0 
L_KeyDecode146:
	MOVF        KeyDecode_i_L0+0, 0 
	SUBLW       5
	BTFSS       STATUS+0, 0 
	GOTO        L_KeyDecode147
;kb.c,382 :: 		keycode[i] = 0;
	MOVLW       _keycode+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_keycode+0)
	MOVWF       FSR1H 
	MOVF        KeyDecode_i_L0+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	CLRF        POSTINC1+0 
;kb.c,381 :: 		for (i=keycnt; i<=5; i++){                  //Остальное забиваем нулями
	INCF        KeyDecode_i_L0+0, 1 
;kb.c,383 :: 		}
	GOTO        L_KeyDecode146
L_KeyDecode147:
;kb.c,384 :: 		}  //-------------------------
L_KeyDecode121:
;kb.c,385 :: 		break;
	GOTO        L_KeyDecode111
;kb.c,386 :: 		}
L_KeyDecode110:
	MOVF        FARG_KeyDecode_sc+0, 0 
	XORLW       224
	BTFSC       STATUS+0, 2 
	GOTO        L_KeyDecode112
	MOVF        FARG_KeyDecode_sc+0, 0 
	XORLW       240
	BTFSC       STATUS+0, 2 
	GOTO        L_KeyDecode113
	MOVF        FARG_KeyDecode_sc+0, 0 
	XORLW       170
	BTFSC       STATUS+0, 2 
	GOTO        L_KeyDecode114
	MOVF        FARG_KeyDecode_sc+0, 0 
	XORLW       254
	BTFSC       STATUS+0, 2 
	GOTO        L_KeyDecode115
	MOVF        FARG_KeyDecode_sc+0, 0 
	XORLW       252
	BTFSC       STATUS+0, 2 
	GOTO        L_KeyDecode116
	MOVF        FARG_KeyDecode_sc+0, 0 
	XORLW       250
	BTFSC       STATUS+0, 2 
	GOTO        L_KeyDecode117
	GOTO        L_KeyDecode118
L_KeyDecode111:
;kb.c,387 :: 		}
L_end_KeyDecode:
	RETURN      0
; end of _KeyDecode
