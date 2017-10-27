
_Init_PS2:

;kb.c,33 :: 		void Init_PS2(void){
;kb.c,35 :: 		bitcount = 11;                                   //Установка количества бит
	MOVLW       11
	MOVWF       _bitcount+0 
;kb.c,37 :: 		INTCON2.INTEDG1 = 0;       //int1 falling edge   // 0 = falling edge 1 = rising edge
	BCF         INTCON2+0, 5 
;kb.c,38 :: 		INTCON3.INT1IF = 0;                              // INT1 clear flag
	BCF         INTCON3+0, 0 
;kb.c,39 :: 		INTCON3 |= (1<<INT1IP)|(1<<INT1IE);              //INT1 Hight priority, intrrupt enable,
	MOVLW       72
	IORWF       INTCON3+0, 1 
;kb.c,41 :: 		TMR2IP_bit = 1;                                  //TIMER2 LOW priority
	BSF         TMR2IP_bit+0, BitPos(TMR2IP_bit+0) 
;kb.c,42 :: 		TMR2IF_bit = 0;                                  //TIMER2 clear flag
	BCF         TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
;kb.c,43 :: 		T2CON = (1<<T2OUTPS3)|(1<<T2OUTPS1)|(1<<T2OUTPS0)|(1<<T2CKPS0);
	MOVLW       89
	MOVWF       T2CON+0 
;kb.c,44 :: 		PR2 = 250;
	MOVLW       250
	MOVWF       PR2+0 
;kb.c,46 :: 		TMR2IE_bit = 1;                                  //timer2 int. enable
	BSF         TMR2IE_bit+0, BitPos(TMR2IE_bit+0) 
;kb.c,48 :: 		for(i=0; i<=5; i++) keycode[i] = 0;              //Инициализируем переменную с кнопками
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
;kb.c,50 :: 		keyCnt = 0;                                      //Сброс количества нажатых кнопок
	CLRF        _keyCnt+0 
;kb.c,51 :: 		ADRESH = 0;                                      //Переназначеный регистр флагов сбрасываем в 0
	CLRF        ADRESH+0 
;kb.c,52 :: 		}
L_end_Init_PS2:
	RETURN      0
; end of _Init_PS2

_Reset_timeuot:

;kb.c,56 :: 		void Reset_timeuot (void){
;kb.c,57 :: 		TMR2ON_bit = 0;                                   //Остановить таймер
	BCF         TMR2ON_bit+0, BitPos(TMR2ON_bit+0) 
;kb.c,58 :: 		TMR2IF_bit = 0;                                   //TIMER0 clear flag
	BCF         TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
;kb.c,59 :: 		PR2 = 250;                                        //TIMER0 preload (1ms)
	MOVLW       250
	MOVWF       PR2+0 
;kb.c,60 :: 		}
L_end_Reset_timeuot:
	RETURN      0
; end of _Reset_timeuot

_Reset_PS2:

;kb.c,63 :: 		uint8_t Reset_PS2(void){
;kb.c,64 :: 		uint8_t timeout = 10;                                    //Время ожидания ответа  300 + 10*timeout (ms)
	MOVLW       10
	MOVWF       Reset_PS2_timeout_L0+0 
;kb.c,66 :: 		PS2_Send(0xFF);
	MOVLW       255
	MOVWF       FARG_PS2_Send+0 
	CALL        _PS2_Send+0, 0
;kb.c,67 :: 		delay_ms(300);
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
;kb.c,68 :: 		while(timeout != 0){
L_Reset_PS24:
	MOVF        Reset_PS2_timeout_L0+0, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_Reset_PS25
;kb.c,69 :: 		if(KYBState.request == KYB_FLAG_CMPSUCCES){
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
;kb.c,70 :: 		KYBState.kbMode = KEYB_MODE_CONFIGURED;
	MOVLW       1
	XORWF       _KYBState+0, 0 
	MOVWF       R0 
	MOVLW       15
	ANDWF       R0, 1 
	MOVF        _KYBState+0, 0 
	XORWF       R0, 1 
	MOVF        R0, 0 
	MOVWF       _KYBState+0 
;kb.c,71 :: 		return 1;
	MOVLW       1
	MOVWF       R0 
	GOTO        L_end_Reset_PS2
;kb.c,72 :: 		} else if (KYBState.request == KYB_FLAG_FAILURE){
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
;kb.c,73 :: 		KYBState.kbMode = KEYB_MODE_ERROR;
	MOVLW       2
	XORWF       _KYBState+0, 0 
	MOVWF       R0 
	MOVLW       15
	ANDWF       R0, 1 
	MOVF        _KYBState+0, 0 
	XORWF       R0, 1 
	MOVF        R0, 0 
	MOVWF       _KYBState+0 
;kb.c,74 :: 		return 0;
	CLRF        R0 
	GOTO        L_end_Reset_PS2
;kb.c,75 :: 		}
L_Reset_PS28:
;kb.c,76 :: 		timeout--;
	DECF        Reset_PS2_timeout_L0+0, 1 
;kb.c,77 :: 		delay_ms(10);
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_Reset_PS29:
	DECFSZ      R13, 1, 1
	BRA         L_Reset_PS29
	DECFSZ      R12, 1, 1
	BRA         L_Reset_PS29
;kb.c,78 :: 		}
	GOTO        L_Reset_PS24
L_Reset_PS25:
;kb.c,79 :: 		KYBState.kbMode = KEYB_MODE_NOTCONFIGURE;
	MOVLW       240
	ANDWF       _KYBState+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       _KYBState+0 
;kb.c,80 :: 		KYBState.request = KYB_FLAG_NORESPONSE;
	MOVLW       15
	ANDWF       _KYBState+0, 0 
	MOVWF       R0 
	MOVF        R0, 0 
	MOVWF       _KYBState+0 
;kb.c,81 :: 		return 0;
	CLRF        R0 
;kb.c,82 :: 		}
L_end_Reset_PS2:
	RETURN      0
; end of _Reset_PS2

_parity:

;kb.c,91 :: 		uint8_t parity(uint8_t x){        //Тут все просто - побитовый XOR
;kb.c,92 :: 		x ^= x >> 8;
;kb.c,93 :: 		x ^= x >> 4;
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
;kb.c,94 :: 		x ^= x >> 2;
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
;kb.c,95 :: 		x ^= x >> 1;
	MOVF        R2, 0 
	MOVWF       R0 
	RRCF        R0, 1 
	BCF         R0, 7 
	MOVF        R2, 0 
	XORWF       R0, 1 
	MOVF        R0, 0 
	MOVWF       FARG_parity_x+0 
;kb.c,96 :: 		return ~(x & 1);
	MOVLW       1
	ANDWF       R0, 1 
	COMF        R0, 1 
;kb.c,97 :: 		}
L_end_parity:
	RETURN      0
; end of _parity

_PS2_interrupt:

;kb.c,101 :: 		void PS2_interrupt(void) {
;kb.c,103 :: 		if(INTCON3.INT1IE == 1 && INTCON3.INT1IF == 1){
	BTFSS       INTCON3+0, 3 
	GOTO        L_PS2_interrupt12
	BTFSS       INTCON3+0, 0 
	GOTO        L_PS2_interrupt12
L__PS2_interrupt132:
;kb.c,104 :: 		INTCON3.INT1IF = 0;                                       //Срос флага прерывания
	BCF         INTCON3+0, 0 
;kb.c,105 :: 		TMR2ON_bit = 1;                                           //Enable timeout timer
	BSF         TMR2ON_bit+0, BitPos(TMR2ON_bit+0) 
;kb.c,106 :: 		if(keyFlags.kb_rw == 0){
	BTFSC       ADRESH+0, 3 
	GOTO        L_PS2_interrupt13
;kb.c,107 :: 		if (INTCON2.INTEDG1 == 0){                                 // Routine entered at falling edge
	BTFSC       INTCON2+0, 5 
	GOTO        L_PS2_interrupt14
;kb.c,108 :: 		if(bitcount < 11 && bitcount > 2) {                   // Bit 3 to 10 is data. Parity bit, start and stop bits are ignored.
	MOVLW       11
	SUBWF       _bitcount+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_PS2_interrupt17
	MOVF        _bitcount+0, 0 
	SUBLW       2
	BTFSC       STATUS+0, 0 
	GOTO        L_PS2_interrupt17
L__PS2_interrupt131:
;kb.c,109 :: 		keyData = keyData >> 1;
	RRCF        PS2_interrupt_keyData_L0+0, 1 
	BCF         PS2_interrupt_keyData_L0+0, 7 
;kb.c,110 :: 		if(KEYB_DATA == 1)
	BTFSS       PORTA+0, 4 
	GOTO        L_PS2_interrupt18
;kb.c,111 :: 		keyData = keyData | 0x80;                       // Store a ’1’
	BSF         PS2_interrupt_keyData_L0+0, 7 
L_PS2_interrupt18:
;kb.c,112 :: 		}
L_PS2_interrupt17:
;kb.c,113 :: 		INTCON2.INTEDG1 = 1;                                  //int1 rising edge
	BSF         INTCON2+0, 5 
;kb.c,114 :: 		} else {                                                  // Routine entered at rising edge
	GOTO        L_PS2_interrupt19
L_PS2_interrupt14:
;kb.c,115 :: 		INTCON2.INTEDG1 = 0;                                  //int1 falling edge
	BCF         INTCON2+0, 5 
;kb.c,116 :: 		if(--bitcount == 0){                                  // All bits received
	DECF        _bitcount+0, 1 
	MOVF        _bitcount+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_PS2_interrupt20
;kb.c,117 :: 		Reset_timeuot();                                  //Disable timeout timer
	CALL        _Reset_timeuot+0, 0
;kb.c,118 :: 		KeyDecode(keyData);
	MOVF        PS2_interrupt_keyData_L0+0, 0 
	MOVWF       FARG_KeyDecode+0 
	CALL        _KeyDecode+0, 0
;kb.c,119 :: 		bitcount = 11;
	MOVLW       11
	MOVWF       _bitcount+0 
;kb.c,120 :: 		}
L_PS2_interrupt20:
;kb.c,121 :: 		}
L_PS2_interrupt19:
;kb.c,122 :: 		}else {
	GOTO        L_PS2_interrupt21
L_PS2_interrupt13:
;kb.c,125 :: 		if (INTCON2.INTEDG1 == 0){                               //Проверяем условие что прерывание по спадающему фронту
	BTFSC       INTCON2+0, 5 
	GOTO        L_PS2_interrupt22
;kb.c,126 :: 		if(bitcount > 2 && bitcount <= 10){                    //Отправляем байт кода команды
	MOVF        _bitcount+0, 0 
	SUBLW       2
	BTFSC       STATUS+0, 0 
	GOTO        L_PS2_interrupt25
	MOVF        _bitcount+0, 0 
	SUBLW       10
	BTFSS       STATUS+0, 0 
	GOTO        L_PS2_interrupt25
L__PS2_interrupt130:
;kb.c,127 :: 		KEYB_DATA = kbWriteBuff & 1;                         //Выставляем младший бит в порт
	MOVLW       1
	ANDWF       _kbWriteBuff+0, 0 
	MOVWF       R0 
	BTFSC       R0, 0 
	GOTO        L__PS2_interrupt141
	BCF         PORTA+0, 4 
	GOTO        L__PS2_interrupt142
L__PS2_interrupt141:
	BSF         PORTA+0, 4 
L__PS2_interrupt142:
;kb.c,128 :: 		kbWriteBuff = kbWriteBuff >> 1;                      //Сдвигаем байт на 1 в право для перехода на следующий бит
	RRCF        _kbWriteBuff+0, 1 
	BCF         _kbWriteBuff+0, 7 
;kb.c,129 :: 		bitcount --;                                         //Инкрементируем счетчик битов
	DECF        _bitcount+0, 1 
;kb.c,130 :: 		} else if(bitcount == 2){                              //Условие передачи бита четности
	GOTO        L_PS2_interrupt26
L_PS2_interrupt25:
	MOVF        _bitcount+0, 0 
	XORLW       2
	BTFSS       STATUS+0, 2 
	GOTO        L_PS2_interrupt27
;kb.c,131 :: 		KEYB_DATA = keyFlags.kb_parity;                      //Запись в порт бита четности (Вычисляется на этапе формирования посылки)
	BTFSC       ADRESH+0, 4 
	GOTO        L__PS2_interrupt143
	BCF         PORTA+0, 4 
	GOTO        L__PS2_interrupt144
L__PS2_interrupt143:
	BSF         PORTA+0, 4 
L__PS2_interrupt144:
;kb.c,132 :: 		bitcount --;
	DECF        _bitcount+0, 1 
;kb.c,133 :: 		} else if(bitcount == 1){                              //Условие передачи СТОП бита
	GOTO        L_PS2_interrupt28
L_PS2_interrupt27:
	MOVF        _bitcount+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_PS2_interrupt29
;kb.c,134 :: 		KEYB_DATA = 1;                                       //Шлем 1 в порт
	BSF         PORTA+0, 4 
;kb.c,135 :: 		bitcount --;
	DECF        _bitcount+0, 1 
;kb.c,136 :: 		} else if(bitcount == 0){                              //Условие конца передачи команды
	GOTO        L_PS2_interrupt30
L_PS2_interrupt29:
	MOVF        _bitcount+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_PS2_interrupt31
;kb.c,137 :: 		bitcount = 11;                                       //Сбрасываем счетчик бит
	MOVLW       11
	MOVWF       _bitcount+0 
;kb.c,138 :: 		TRISA.RA4 = 1;                                       //Переводим пин data на вход
	BSF         TRISA+0, 4 
;kb.c,139 :: 		keyFlags.kb_rw = 0;                                  //Сбрасываем флаг передачи команды
	BCF         ADRESH+0, 3 
;kb.c,140 :: 		Reset_timeuot();                                     //Сбрасываем таймаут посылки
	CALL        _Reset_timeuot+0, 0
;kb.c,148 :: 		}
L_PS2_interrupt31:
L_PS2_interrupt30:
L_PS2_interrupt28:
L_PS2_interrupt26:
;kb.c,149 :: 		}
L_PS2_interrupt22:
;kb.c,151 :: 		}
L_PS2_interrupt21:
;kb.c,152 :: 		}
L_PS2_interrupt12:
;kb.c,153 :: 		}
L_end_PS2_interrupt:
	RETURN      0
; end of _PS2_interrupt

_PS2_Send:

;kb.c,157 :: 		uint8_t PS2_Send(uint8_t sData){
;kb.c,158 :: 		if(bitcount == 11){                  //Проверка отсутствия приема кода от клавиатуры
	MOVF        _bitcount+0, 0 
	XORLW       11
	BTFSS       STATUS+0, 2 
	GOTO        L_PS2_Send32
;kb.c,159 :: 		kbWriteBuff = sData;
	MOVF        FARG_PS2_Send_sData+0, 0 
	MOVWF       _kbWriteBuff+0 
;kb.c,160 :: 		keyFlags.kb_parity = parity(kbWriteBuff);
	MOVF        FARG_PS2_Send_sData+0, 0 
	MOVWF       FARG_parity_x+0 
	CALL        _parity+0, 0
	BTFSC       R0, 0 
	GOTO        L__PS2_Send146
	BCF         ADRESH+0, 4 
	GOTO        L__PS2_Send147
L__PS2_Send146:
	BSF         ADRESH+0, 4 
L__PS2_Send147:
;kb.c,162 :: 		INTCON3.INT1IE = 0;               //Запрещаем прерывание от клавиатуры
	BCF         INTCON3+0, 3 
;kb.c,163 :: 		KEYB_CLOCK = 0;                    //Устанавливаем Clock в 0
	BCF         PORTB+0, 1 
;kb.c,164 :: 		KEYB_DATA = 1;                    //Устанавливаем Data в 1
	BSF         PORTA+0, 4 
;kb.c,165 :: 		TRISB.RB1 = 0;                    //Переводим пин clock на вывод
	BCF         TRISB+0, 1 
;kb.c,166 :: 		TRISA.RA4 = 0;                    //Переводим пин data на вывод
	BCF         TRISA+0, 4 
;kb.c,167 :: 		delay_ms(100);                    //Ждем 100мс
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
;kb.c,168 :: 		KEYB_DATA = 0;                    //Устанавливаем Data в 0
	BCF         PORTA+0, 4 
;kb.c,169 :: 		delay_ms(1);                      //Задержка для СТОП бита
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
;kb.c,170 :: 		KEYB_CLOCK = 1;                   //Подымаем КЛОК в лог 1
	BSF         PORTB+0, 1 
;kb.c,171 :: 		TRISB.RB1 = 1;                    //Переводим Clock на вход
	BSF         TRISB+0, 1 
;kb.c,172 :: 		keyFlags.kb_rw = 1;               //Устанавливаем флаг передачи данных в клавиатуру
	BSF         ADRESH+0, 3 
;kb.c,173 :: 		bitcount = 10;                    //Сбрасываем счетчик бит
	MOVLW       10
	MOVWF       _bitcount+0 
;kb.c,174 :: 		INTCON3.INT1IF = 0;               //Сбрасываем флаг прерывания перед началом работы
	BCF         INTCON3+0, 0 
;kb.c,175 :: 		INTCON3.INT1IE = 1;               //Разрешаем прерывания по Clock и идем в прерывание
	BSF         INTCON3+0, 3 
;kb.c,176 :: 		TMR2ON_bit = 1;                   //Enable timeout timer
	BSF         TMR2ON_bit+0, BitPos(TMR2ON_bit+0) 
;kb.c,177 :: 		return 1;
	MOVLW       1
	MOVWF       R0 
	GOTO        L_end_PS2_Send
;kb.c,178 :: 		} else return 0;
L_PS2_Send32:
	CLRF        R0 
;kb.c,179 :: 		}
L_end_PS2_Send:
	RETURN      0
; end of _PS2_Send

_PS2_Timeout_Interrupt:

;kb.c,183 :: 		void PS2_Timeout_Interrupt(){
;kb.c,184 :: 		if(TMR2IF_bit){
	BTFSS       TMR2IF_bit+0, BitPos(TMR2IF_bit+0) 
	GOTO        L_PS2_Timeout_Interrupt36
;kb.c,185 :: 		Reset_timeuot();
	CALL        _Reset_timeuot+0, 0
;kb.c,186 :: 		if(keyFlags.kb_rw == 1) {
	BTFSS       ADRESH+0, 3 
	GOTO        L_PS2_Timeout_Interrupt37
;kb.c,187 :: 		keyFlags.kb_rw = 0;
	BCF         ADRESH+0, 3 
;kb.c,188 :: 		kbWriteBuff = 0;
	CLRF        _kbWriteBuff+0 
;kb.c,189 :: 		KEYB_DATA = 1;
	BSF         PORTA+0, 4 
;kb.c,190 :: 		TRISA.RA4 = 1;
	BSF         TRISA+0, 4 
;kb.c,191 :: 		}
L_PS2_Timeout_Interrupt37:
;kb.c,192 :: 		bitcount = 11;
	MOVLW       11
	MOVWF       _bitcount+0 
;kb.c,193 :: 		}
L_PS2_Timeout_Interrupt36:
;kb.c,194 :: 		}
L_end_PS2_Timeout_Interrupt:
	RETURN      0
; end of _PS2_Timeout_Interrupt

_inArray:

;kb.c,198 :: 		uint8_t inArray(uint8_t value){               //Поиск значениея в массиве
;kb.c,200 :: 		for(i=0; i<=5; i++){                     //Поиск выполняется по массиву keycode
	CLRF        R1 
L_inArray38:
	MOVF        R1, 0 
	SUBLW       5
	BTFSS       STATUS+0, 0 
	GOTO        L_inArray39
;kb.c,201 :: 		if(keycode[i] == value){             //Если находит возвращает позицию + 1
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
;kb.c,202 :: 		return i+1;
	MOVF        R1, 0 
	ADDLW       1
	MOVWF       R0 
	GOTO        L_end_inArray
;kb.c,203 :: 		}
L_inArray41:
;kb.c,200 :: 		for(i=0; i<=5; i++){                     //Поиск выполняется по массиву keycode
	INCF        R1, 1 
;kb.c,204 :: 		}
	GOTO        L_inArray38
L_inArray39:
;kb.c,205 :: 		return 0;                                //В противном случае возврат 0
	CLRF        R0 
;kb.c,206 :: 		}
L_end_inArray:
	RETURN      0
; end of _inArray

_Set_BRDButton:

;kb.c,210 :: 		void Set_BRDButton (uint8_t key, uint8_t upDown){
;kb.c,211 :: 		switch (key){
	GOTO        L_Set_BRDButton42
;kb.c,212 :: 		case KEY_F5    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton44:
	BTFSC       CVRCON+0, 1 
	GOTO        L_Set_BRDButton45
	GOTO        L_Set_BRDButton43
L_Set_BRDButton45:
;kb.c,213 :: 		case KEY_1     :
L_Set_BRDButton46:
;kb.c,214 :: 		case KEY_NUM_1 : BT_STOP1 = upDown; LED_PIN = upDown; break;
L_Set_BRDButton47:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton151
	BCF         PORTA+0, 0 
	GOTO        L__Set_BRDButton152
L__Set_BRDButton151:
	BSF         PORTA+0, 0 
L__Set_BRDButton152:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton153
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton154
L__Set_BRDButton153:
	BSF         PORTC+0, 2 
L__Set_BRDButton154:
	GOTO        L_Set_BRDButton43
;kb.c,215 :: 		case KEY_F6    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton48:
	BTFSC       CVRCON+0, 1 
	GOTO        L_Set_BRDButton49
	GOTO        L_Set_BRDButton43
L_Set_BRDButton49:
;kb.c,216 :: 		case KEY_2     :
L_Set_BRDButton50:
;kb.c,217 :: 		case KEY_NUM_2 : BT_STOP2 = upDown;  LED_PIN = upDown; break;
L_Set_BRDButton51:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton155
	BCF         PORTA+0, 1 
	GOTO        L__Set_BRDButton156
L__Set_BRDButton155:
	BSF         PORTA+0, 1 
L__Set_BRDButton156:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton157
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton158
L__Set_BRDButton157:
	BSF         PORTC+0, 2 
L__Set_BRDButton158:
	GOTO        L_Set_BRDButton43
;kb.c,218 :: 		case KEY_F7    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton52:
	BTFSC       CVRCON+0, 1 
	GOTO        L_Set_BRDButton53
	GOTO        L_Set_BRDButton43
L_Set_BRDButton53:
;kb.c,219 :: 		case KEY_3     :
L_Set_BRDButton54:
;kb.c,220 :: 		case KEY_NUM_3 : BT_STOP3 = upDown;  LED_PIN = upDown; break;
L_Set_BRDButton55:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton159
	BCF         PORTA+0, 2 
	GOTO        L__Set_BRDButton160
L__Set_BRDButton159:
	BSF         PORTA+0, 2 
L__Set_BRDButton160:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton161
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton162
L__Set_BRDButton161:
	BSF         PORTC+0, 2 
L__Set_BRDButton162:
	GOTO        L_Set_BRDButton43
;kb.c,221 :: 		case KEY_F8    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton56:
	BTFSC       CVRCON+0, 1 
	GOTO        L_Set_BRDButton57
	GOTO        L_Set_BRDButton43
L_Set_BRDButton57:
;kb.c,222 :: 		case KEY_4     :
L_Set_BRDButton58:
;kb.c,223 :: 		case KEY_NUM_4 : BT_STOP4 = upDown;  LED_PIN = upDown; break;
L_Set_BRDButton59:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton163
	BCF         PORTA+0, 3 
	GOTO        L__Set_BRDButton164
L__Set_BRDButton163:
	BSF         PORTA+0, 3 
L__Set_BRDButton164:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton165
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton166
L__Set_BRDButton165:
	BSF         PORTC+0, 2 
L__Set_BRDButton166:
	GOTO        L_Set_BRDButton43
;kb.c,224 :: 		case KEY_F9    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton60:
	BTFSC       CVRCON+0, 1 
	GOTO        L_Set_BRDButton61
	GOTO        L_Set_BRDButton43
L_Set_BRDButton61:
;kb.c,225 :: 		case KEY_5     :
L_Set_BRDButton62:
;kb.c,226 :: 		case KEY_NUM_5 : BT_STOP5 = upDown;  LED_PIN = upDown; break;
L_Set_BRDButton63:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton167
	BCF         PORTA+0, 5 
	GOTO        L__Set_BRDButton168
L__Set_BRDButton167:
	BSF         PORTA+0, 5 
L__Set_BRDButton168:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton169
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton170
L__Set_BRDButton169:
	BSF         PORTC+0, 2 
L__Set_BRDButton170:
	GOTO        L_Set_BRDButton43
;kb.c,227 :: 		case KEY_F10    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton64:
	BTFSC       CVRCON+0, 1 
	GOTO        L_Set_BRDButton65
	GOTO        L_Set_BRDButton43
L_Set_BRDButton65:
;kb.c,228 :: 		case KEY_7     :
L_Set_BRDButton66:
;kb.c,229 :: 		case KEY_NUM_7 : BT_LINE = upDown;  LED_PIN = upDown; break;
L_Set_BRDButton67:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton171
	BCF         PORTB+0, 6 
	GOTO        L__Set_BRDButton172
L__Set_BRDButton171:
	BSF         PORTB+0, 6 
L__Set_BRDButton172:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton173
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton174
L__Set_BRDButton173:
	BSF         PORTC+0, 2 
L__Set_BRDButton174:
	GOTO        L_Set_BRDButton43
;kb.c,230 :: 		case KEY_F11    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton68:
	BTFSC       CVRCON+0, 1 
	GOTO        L_Set_BRDButton69
	GOTO        L_Set_BRDButton43
L_Set_BRDButton69:
;kb.c,231 :: 		case KEY_8     :
L_Set_BRDButton70:
;kb.c,232 :: 		case KEY_NUM_8 : BT_BET = upDown;  LED_PIN = upDown; break;
L_Set_BRDButton71:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton175
	BCF         PORTB+0, 5 
	GOTO        L__Set_BRDButton176
L__Set_BRDButton175:
	BSF         PORTB+0, 5 
L__Set_BRDButton176:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton177
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton178
L__Set_BRDButton177:
	BSF         PORTC+0, 2 
L__Set_BRDButton178:
	GOTO        L_Set_BRDButton43
;kb.c,233 :: 		case KEY_9     :
L_Set_BRDButton72:
;kb.c,234 :: 		case KEY_NUM_9 : BT_INFO = upDown;  LED_PIN = upDown; break;
L_Set_BRDButton73:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton179
	BCF         PORTC+0, 0 
	GOTO        L__Set_BRDButton180
L__Set_BRDButton179:
	BSF         PORTC+0, 0 
L__Set_BRDButton180:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton181
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton182
L__Set_BRDButton181:
	BSF         PORTC+0, 2 
L__Set_BRDButton182:
	GOTO        L_Set_BRDButton43
;kb.c,235 :: 		case KEY_0     :
L_Set_BRDButton74:
;kb.c,236 :: 		case KEY_NUM_0 : BT_MENU = upDown;  LED_PIN = upDown; break;
L_Set_BRDButton75:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton183
	BCF         PORTC+0, 1 
	GOTO        L__Set_BRDButton184
L__Set_BRDButton183:
	BSF         PORTC+0, 1 
L__Set_BRDButton184:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton185
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton186
L__Set_BRDButton185:
	BSF         PORTC+0, 2 
L__Set_BRDButton186:
	GOTO        L_Set_BRDButton43
;kb.c,237 :: 		case KEY_F12   : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton76:
	BTFSC       CVRCON+0, 1 
	GOTO        L_Set_BRDButton77
	GOTO        L_Set_BRDButton43
L_Set_BRDButton77:
;kb.c,238 :: 		case KEY_ENTER :
L_Set_BRDButton78:
;kb.c,239 :: 		case KEY_SPACE :
L_Set_BRDButton79:
;kb.c,240 :: 		case KEY_NUM_ENTR: BT_START = upDown;  LED_PIN = upDown; break;
L_Set_BRDButton80:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton187
	BCF         PORTB+0, 4 
	GOTO        L__Set_BRDButton188
L__Set_BRDButton187:
	BSF         PORTB+0, 4 
L__Set_BRDButton188:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton189
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton190
L__Set_BRDButton189:
	BSF         PORTC+0, 2 
L__Set_BRDButton190:
	GOTO        L_Set_BRDButton43
;kb.c,241 :: 		case KEY_F3    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton81:
	BTFSC       CVRCON+0, 1 
	GOTO        L_Set_BRDButton82
	GOTO        L_Set_BRDButton43
L_Set_BRDButton82:
;kb.c,242 :: 		case KEY_ESC   :
L_Set_BRDButton83:
;kb.c,243 :: 		case KEY_HOME  : sysFlags.if_pc = 0; break;           //Кнопками Esc и Home происходит выход с режима плата
L_Set_BRDButton84:
	BCF         CVRCON+0, 0 
	GOTO        L_Set_BRDButton43
;kb.c,244 :: 		default : break;
L_Set_BRDButton85:
	GOTO        L_Set_BRDButton43
;kb.c,245 :: 		}
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
	GOTO        L_Set_BRDButton48
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       31
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton50
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       90
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton51
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       64
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton52
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       32
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton54
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       91
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton55
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       65
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton56
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       33
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton58
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       92
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton59
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       66
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton60
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       34
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton62
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       93
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton63
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       67
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton64
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       36
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton66
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       95
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton67
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       68
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton68
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       37
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton70
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       96
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton71
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       38
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton72
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       97
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton73
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       39
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton74
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       98
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton75
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       69
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton76
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       40
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton78
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       44
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton79
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       88
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton80
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       60
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton81
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       41
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton83
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       74
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton84
	GOTO        L_Set_BRDButton85
L_Set_BRDButton43:
;kb.c,246 :: 		}
L_end_Set_BRDButton:
	RETURN      0
; end of _Set_BRDButton

_SetPass:

;kb.c,250 :: 		void SetPass (uint8_t key){
;kb.c,253 :: 		for(i=0; i<PASS_BUFF_SIZE; i++){          //При нажатии кнопки массив пароля сдвигается
	CLRF        R2 
L_SetPass86:
	MOVLW       32
	SUBWF       R2, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_SetPass87
;kb.c,254 :: 		progPass[i] = progPass[i+1];           //на позицию вперед
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
;kb.c,253 :: 		for(i=0; i<PASS_BUFF_SIZE; i++){          //При нажатии кнопки массив пароля сдвигается
	INCF        R2, 1 
;kb.c,255 :: 		}
	GOTO        L_SetPass86
L_SetPass87:
;kb.c,256 :: 		if((modifier & 0x22) != 0)                     //Если нажат левый или правый shift
	MOVLW       34
	ANDWF       _modifier+0, 0 
	MOVWF       R1 
	MOVF        R1, 0 
	XORLW       0
	BTFSC       STATUS+0, 2 
	GOTO        L_SetPass89
;kb.c,257 :: 		progPass[PASS_BUFF_SIZE-1] = key | 0x80;    //в конец дописывается код нажатой кнопки и бита shift
	MOVLW       128
	IORWF       FARG_SetPass_key+0, 0 
	MOVWF       _progPass+31 
	GOTO        L_SetPass90
L_SetPass89:
;kb.c,259 :: 		progPass[PASS_BUFF_SIZE-1] = key;
	MOVF        FARG_SetPass_key+0, 0 
	MOVWF       _progPass+31 
L_SetPass90:
;kb.c,260 :: 		}
L_end_SetPass:
	RETURN      0
; end of _SetPass

_KeyDecode:

;kb.c,264 :: 		void KeyDecode(uint8_t sc){
;kb.c,266 :: 		uint8_t i, key=0;                //Буферная переманная кода клавиши
	CLRF        KeyDecode_key_L0+0 
;kb.c,269 :: 		switch(sc){
	GOTO        L_KeyDecode91
;kb.c,270 :: 		case KEYB_FUNC_CODE        : keyFlags.if_func = 1; break;                   //Устанавливаем флаг функциональной кнопки если пришел ее код
L_KeyDecode93:
	BSF         ADRESH+0, 1 
	GOTO        L_KeyDecode92
;kb.c,271 :: 		case KEYB_BREAK_CODE       : keyFlags.if_up = 1; break;                     //Устанавливаем флаг если кнопка отпущена
L_KeyDecode94:
	BSF         ADRESH+0, 2 
	GOTO        L_KeyDecode92
;kb.c,272 :: 		case KEYB_COMPLETE_SUCCESS : KYBState.request =  KYB_FLAG_CMPSUCCES; break;//Ответ клавиатуры об удачной конфигурации
L_KeyDecode95:
	MOVLW       16
	XORWF       _KYBState+0, 0 
	MOVWF       R0 
	MOVLW       240
	ANDWF       R0, 1 
	MOVF        _KYBState+0, 0 
	XORWF       R0, 1 
	MOVF        R0, 0 
	MOVWF       _KYBState+0 
	GOTO        L_KeyDecode92
;kb.c,273 :: 		case KEYB_RESEND           : KYBState.request =  KYB_FLAG_RESEND; break;     //Запрос клавиатуры на повторную отправку команды
L_KeyDecode96:
	MOVLW       48
	XORWF       _KYBState+0, 0 
	MOVWF       R0 
	MOVLW       240
	ANDWF       R0, 1 
	MOVF        _KYBState+0, 0 
	XORWF       R0, 1 
	MOVF        R0, 0 
	MOVWF       _KYBState+0 
	GOTO        L_KeyDecode92
;kb.c,274 :: 		case KEYB_FAILURE          : KYBState.request =  KYB_FLAG_FAILURE; break;//Ошибка устройства
L_KeyDecode97:
	MOVLW       64
	XORWF       _KYBState+0, 0 
	MOVWF       R0 
	MOVLW       240
	ANDWF       R0, 1 
	MOVF        _KYBState+0, 0 
	XORWF       R0, 1 
	MOVF        R0, 0 
	MOVWF       _KYBState+0 
	GOTO        L_KeyDecode92
;kb.c,275 :: 		case KEYB_ACKNOWLEDGE      : KYBState.request =  KYB_FLAG_ACKNOWLEDGE; break;//Подтверждение получения команды
L_KeyDecode98:
	MOVLW       32
	XORWF       _KYBState+0, 0 
	MOVWF       R0 
	MOVLW       240
	ANDWF       R0, 1 
	MOVF        _KYBState+0, 0 
	XORWF       R0, 1 
	MOVF        R0, 0 
	MOVWF       _KYBState+0 
	GOTO        L_KeyDecode92
;kb.c,276 :: 		default :  if(sc > 0 && sc < 0x84){                                //Проверка что нажата кнопка а не сервисные данные
L_KeyDecode99:
	MOVF        FARG_KeyDecode_sc+0, 0 
	SUBLW       0
	BTFSC       STATUS+0, 0 
	GOTO        L_KeyDecode102
	MOVLW       132
	SUBWF       FARG_KeyDecode_sc+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_KeyDecode102
L__KeyDecode135:
;kb.c,277 :: 		if(keyFlags.if_func == 1){                             //Если была нажата функциональная кнопка
	BTFSS       ADRESH+0, 1 
	GOTO        L_KeyDecode103
;kb.c,278 :: 		for(i=0; i<sizeof(funCode)/2; i++){                //Перебераем HID сканкод из массива соответствия
	CLRF        KeyDecode_i_L0+0 
L_KeyDecode104:
	MOVLW       18
	SUBWF       KeyDecode_i_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_KeyDecode105
;kb.c,279 :: 		if(funCode[i][0] == sc){
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
	GOTO        L_KeyDecode107
;kb.c,280 :: 		key = funCode[i][1];                         //Если такой код имеется то записываем его в буферную переменную
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
;kb.c,281 :: 		break;                                        //и выходим с цикла
	GOTO        L_KeyDecode105
;kb.c,282 :: 		}
L_KeyDecode107:
;kb.c,278 :: 		for(i=0; i<sizeof(funCode)/2; i++){                //Перебераем HID сканкод из массива соответствия
	INCF        KeyDecode_i_L0+0, 1 
;kb.c,283 :: 		}
	GOTO        L_KeyDecode104
L_KeyDecode105:
;kb.c,284 :: 		keyFlags.if_func = 0;                              //В противном случае просто сбрасываем флаг
	BCF         ADRESH+0, 1 
;kb.c,285 :: 		} else {
	GOTO        L_KeyDecode108
L_KeyDecode103:
;kb.c,286 :: 		key = scanCode[sc];                       //Если была нажата простая кнопка то записываем код из массива простых кнопок
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
;kb.c,287 :: 		}
L_KeyDecode108:
;kb.c,288 :: 		if(key>1){
	MOVF        KeyDecode_key_L0+0, 0 
	SUBLW       1
	BTFSC       STATUS+0, 0 
	GOTO        L_KeyDecode109
;kb.c,292 :: 		if(key >= 0xE0 && key <= 0xE7){//Проверяем если прийшли данные от кнопок CtrlShiftAltWin
	MOVLW       224
	SUBWF       KeyDecode_key_L0+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_KeyDecode112
	MOVF        KeyDecode_key_L0+0, 0 
	SUBLW       231
	BTFSS       STATUS+0, 0 
	GOTO        L_KeyDecode112
L__KeyDecode134:
;kb.c,293 :: 		if(keyFlags.if_up == 1){                          //Проверяем если одна из кнопок была отжата
	BTFSS       ADRESH+0, 2 
	GOTO        L_KeyDecode113
;kb.c,294 :: 		modifier &= ~dvFlags[key & 0x0F];     //Если так то убираем соответствующий флаг
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
;kb.c,295 :: 		} else                                    //Далее проверяем если нажатая клавиша соответствует HID коду
	GOTO        L_KeyDecode114
L_KeyDecode113:
;kb.c,296 :: 		modifier |= dvFlags[key & 0x0F];
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
L_KeyDecode114:
;kb.c,297 :: 		} /////////////////////////////////////////////////////////////
L_KeyDecode112:
;kb.c,299 :: 		keyPos = inArray(key);          //Проверяем есть ли эта кнопка уже в массиве
	MOVF        KeyDecode_key_L0+0, 0 
	MOVWF       FARG_inArray_value+0 
	CALL        _inArray+0, 0
	MOVF        R0, 0 
	MOVWF       KeyDecode_keyPos_L0+0 
;kb.c,300 :: 		if(keyPos){                     //Если есть проверяем не отпущена ли кнопка
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_KeyDecode115
;kb.c,301 :: 		if(keyFlags.if_up){                             //Если отпущена
	BTFSS       ADRESH+0, 2 
	GOTO        L_KeyDecode116
;kb.c,302 :: 		if(sysFlags.if_pc == 1)  Set_BRDButton(key, 0);
	BTFSS       CVRCON+0, 0 
	GOTO        L_KeyDecode117
	MOVF        KeyDecode_key_L0+0, 0 
	MOVWF       FARG_Set_BRDButton_key+0 
	CLRF        FARG_Set_BRDButton_upDown+0 
	CALL        _Set_BRDButton+0, 0
L_KeyDecode117:
;kb.c,303 :: 		for(i=keyPos-1; i<5; i++){          //изьять элемент из массива и выполнить сдвих
	DECF        KeyDecode_keyPos_L0+0, 0 
	MOVWF       KeyDecode_i_L0+0 
L_KeyDecode118:
	MOVLW       5
	SUBWF       KeyDecode_i_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_KeyDecode119
;kb.c,304 :: 		keycode[i] = keycode[i+1];
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
;kb.c,303 :: 		for(i=keyPos-1; i<5; i++){          //изьять элемент из массива и выполнить сдвих
	INCF        KeyDecode_i_L0+0, 1 
;kb.c,305 :: 		}
	GOTO        L_KeyDecode118
L_KeyDecode119:
;kb.c,306 :: 		keyCnt--;                            //Инкрементировать щетчик кнопок
	DECF        _keyCnt+0, 1 
;kb.c,307 :: 		keyFlags.if_up = 0;                           //Сбросить флаг отпущеной кнопки
	BCF         ADRESH+0, 2 
;kb.c,308 :: 		}
L_KeyDecode116:
;kb.c,310 :: 		}else if(keyCnt<6){                      //Если не отпущена то добавляем и инкрементируем массив
	GOTO        L_KeyDecode121
L_KeyDecode115:
	MOVLW       6
	SUBWF       _keyCnt+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_KeyDecode122
;kb.c,311 :: 		keycode[keyCnt] = key;
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
;kb.c,312 :: 		keyCnt++;
	INCF        _keyCnt+0, 1 
;kb.c,313 :: 		if(sysFlags.if_pc == 1) Set_BRDButton(key, 1);
	BTFSS       CVRCON+0, 0 
	GOTO        L_KeyDecode123
	MOVF        KeyDecode_key_L0+0, 0 
	MOVWF       FARG_Set_BRDButton_key+0 
	MOVLW       1
	MOVWF       FARG_Set_BRDButton_upDown+0 
	CALL        _Set_BRDButton+0, 0
L_KeyDecode123:
;kb.c,314 :: 		if(key >= KEY_A && key <= KEY_0){         //Проверка ввода только символов
	MOVLW       4
	SUBWF       KeyDecode_key_L0+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_KeyDecode126
	MOVF        KeyDecode_key_L0+0, 0 
	SUBLW       39
	BTFSS       STATUS+0, 0 
	GOTO        L_KeyDecode126
L__KeyDecode133:
;kb.c,315 :: 		SetPass(key);                          //Обработчик ввода пароля программирования и удаления ключей с клавиатуры
	MOVF        KeyDecode_key_L0+0, 0 
	MOVWF       FARG_SetPass_key+0 
	CALL        _SetPass+0, 0
;kb.c,316 :: 		}
L_KeyDecode126:
;kb.c,317 :: 		}
L_KeyDecode122:
L_KeyDecode121:
;kb.c,318 :: 		}
L_KeyDecode109:
;kb.c,319 :: 		for (i=keycnt; i<=5; i++){                  //Остальное забиваем нулями
	MOVF        _keyCnt+0, 0 
	MOVWF       KeyDecode_i_L0+0 
L_KeyDecode127:
	MOVF        KeyDecode_i_L0+0, 0 
	SUBLW       5
	BTFSS       STATUS+0, 0 
	GOTO        L_KeyDecode128
;kb.c,320 :: 		keycode[i] = 0;
	MOVLW       _keycode+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_keycode+0)
	MOVWF       FSR1H 
	MOVF        KeyDecode_i_L0+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	CLRF        POSTINC1+0 
;kb.c,319 :: 		for (i=keycnt; i<=5; i++){                  //Остальное забиваем нулями
	INCF        KeyDecode_i_L0+0, 1 
;kb.c,321 :: 		}
	GOTO        L_KeyDecode127
L_KeyDecode128:
;kb.c,322 :: 		}  //-------------------------
L_KeyDecode102:
;kb.c,323 :: 		break;
	GOTO        L_KeyDecode92
;kb.c,324 :: 		}
L_KeyDecode91:
	MOVF        FARG_KeyDecode_sc+0, 0 
	XORLW       224
	BTFSC       STATUS+0, 2 
	GOTO        L_KeyDecode93
	MOVF        FARG_KeyDecode_sc+0, 0 
	XORLW       240
	BTFSC       STATUS+0, 2 
	GOTO        L_KeyDecode94
	MOVF        FARG_KeyDecode_sc+0, 0 
	XORLW       170
	BTFSC       STATUS+0, 2 
	GOTO        L_KeyDecode95
	MOVF        FARG_KeyDecode_sc+0, 0 
	XORLW       254
	BTFSC       STATUS+0, 2 
	GOTO        L_KeyDecode96
	MOVF        FARG_KeyDecode_sc+0, 0 
	XORLW       252
	BTFSC       STATUS+0, 2 
	GOTO        L_KeyDecode97
	MOVF        FARG_KeyDecode_sc+0, 0 
	XORLW       250
	BTFSC       STATUS+0, 2 
	GOTO        L_KeyDecode98
	GOTO        L_KeyDecode99
L_KeyDecode92:
;kb.c,325 :: 		}
L_end_KeyDecode:
	RETURN      0
; end of _KeyDecode
