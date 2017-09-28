
_init_kb:

;kb.c,23 :: 		void init_kb(void){
;kb.c,25 :: 		bitcount = 11;                                   //Сброс счетчика бит
	MOVLW       11
	MOVWF       _bitcount+0 
;kb.c,27 :: 		INTCON2.INTEDG1 = 0;       //int1 falling edge   // 0 = falling edge 1 = rising edge
	BCF         INTCON2+0, 5 
;kb.c,28 :: 		INTCON3.INT1IF = 0;                              // INT1 clear flag
	BCF         INTCON3+0, 0 
;kb.c,29 :: 		INTCON3 |= (1<<INT1IP)|(1<<INT1IE);              //INT1 Hight priority, intrrupt enable,
	MOVLW       72
	IORWF       INTCON3+0, 1 
;kb.c,31 :: 		INTCON2.TMR0IP = 0;                              //TIMER0 LOW priority
	BCF         INTCON2+0, 2 
;kb.c,32 :: 		T0CON = (1<<TMR0ON)|(1<<T08BIT)|(0<<T0CS)|(0<<PSA)|(1<<T0PS2)|(1<<T0PS1)|(1<<T0PS0);
	MOVLW       199
	MOVWF       T0CON+0 
;kb.c,33 :: 		TMR0L =  209;
	MOVLW       209
	MOVWF       TMR0L+0 
;kb.c,34 :: 		INTCON.TMR0IF = 0;                               //TIMER0 clear flag
	BCF         INTCON+0, 2 
;kb.c,36 :: 		INTCON  |= (1<<TMR0IE);     //timer0 int. enable
	BSF         INTCON+0, 5 
;kb.c,37 :: 		for (i=0; i<=5; i++){                          //Инициализируем переменную с кнопками
	CLRF        R1 
L_init_kb0:
	MOVF        R1, 0 
	SUBLW       5
	BTFSS       STATUS+0, 0 
	GOTO        L_init_kb1
;kb.c,38 :: 		keycode[i] = 0;
	MOVLW       _keycode+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_keycode+0)
	MOVWF       FSR1H 
	MOVF        R1, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	CLRF        POSTINC1+0 
;kb.c,37 :: 		for (i=0; i<=5; i++){                          //Инициализируем переменную с кнопками
	INCF        R1, 1 
;kb.c,39 :: 		}
	GOTO        L_init_kb0
L_init_kb1:
;kb.c,40 :: 		keyCnt = 0;                                    //Сброс счетчика нажатых кнопок
	CLRF        _keyCnt+0 
;kb.c,41 :: 		CVRCON = 0;                                    //Переназначеный регистр флагов сбрасываем в 0
	CLRF        CVRCON+0 
;kb.c,42 :: 		}
L_end_init_kb:
	RETURN      0
; end of _init_kb

_Reset_timeuot:

;kb.c,46 :: 		void Reset_timeuot (void){
;kb.c,47 :: 		TMR0L =  209;                                    //TIMER0 preload 209 (1ms)
	MOVLW       209
	MOVWF       TMR0L+0 
;kb.c,48 :: 		INTCON.TMR0IF = 0;                               //TIMER0 clear flag
	BCF         INTCON+0, 2 
;kb.c,49 :: 		T0CON.TMR0ON = 0;                                //Остановка таймера
	BCF         T0CON+0, 7 
;kb.c,50 :: 		}
L_end_Reset_timeuot:
	RETURN      0
; end of _Reset_timeuot

_parity:

;kb.c,54 :: 		unsigned char parity(unsigned char x){        //Тут все просто - побитовый XOR
;kb.c,55 :: 		x ^= x >> 8;
;kb.c,56 :: 		x ^= x >> 4;
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
;kb.c,57 :: 		x ^= x >> 2;
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
;kb.c,58 :: 		x ^= x >> 1;
	MOVF        R2, 0 
	MOVWF       R0 
	RRCF        R0, 1 
	BCF         R0, 7 
	MOVF        R2, 0 
	XORWF       R0, 1 
	MOVF        R0, 0 
	MOVWF       FARG_parity_x+0 
;kb.c,59 :: 		return ~(x & 1);
	MOVLW       1
	ANDWF       R0, 1 
	COMF        R0, 1 
;kb.c,60 :: 		}
L_end_parity:
	RETURN      0
; end of _parity

_PS2_interrupt:

;kb.c,64 :: 		void PS2_interrupt(void) {
;kb.c,66 :: 		if(INTCON3.INT1IE == 1 && INTCON3.INT1IF == 1){
	BTFSS       INTCON3+0, 3 
	GOTO        L_PS2_interrupt5
	BTFSS       INTCON3+0, 0 
	GOTO        L_PS2_interrupt5
L__PS2_interrupt118:
;kb.c,67 :: 		INTCON3.INT1IF = 0;                                       //Срос флага прерывания
	BCF         INTCON3+0, 0 
;kb.c,68 :: 		T0CON.TMR0ON = 1;                                          //Запуск таймера таймаута
	BSF         T0CON+0, 7 
;kb.c,69 :: 		if(sysFlags.kb_rw == 0){
	BTFSC       CVRCON+0, 4 
	GOTO        L_PS2_interrupt6
;kb.c,70 :: 		if (INTCON2.INTEDG1 == 0){                                 // Routine entered at falling edge
	BTFSC       INTCON2+0, 5 
	GOTO        L_PS2_interrupt7
;kb.c,71 :: 		if(bitcount < 11 && bitcount > 2) {                   // Bit 3 to 10 is data. Parity bit, start and stop bits are ignored.
	MOVLW       11
	SUBWF       _bitcount+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_PS2_interrupt10
	MOVF        _bitcount+0, 0 
	SUBLW       2
	BTFSC       STATUS+0, 0 
	GOTO        L_PS2_interrupt10
L__PS2_interrupt117:
;kb.c,72 :: 		keyData = keyData >> 1;
	RRCF        PS2_interrupt_keyData_L0+0, 1 
	BCF         PS2_interrupt_keyData_L0+0, 7 
;kb.c,73 :: 		if(KEYB_DATA == 1)
	BTFSS       PORTA+0, 4 
	GOTO        L_PS2_interrupt11
;kb.c,74 :: 		keyData = keyData | 0x80;                       // Store a ’1’
	BSF         PS2_interrupt_keyData_L0+0, 7 
L_PS2_interrupt11:
;kb.c,75 :: 		}
L_PS2_interrupt10:
;kb.c,76 :: 		INTCON2.INTEDG1 = 1;                                  //int1 rising edge
	BSF         INTCON2+0, 5 
;kb.c,77 :: 		} else {                                                  // Routine entered at rising edge
	GOTO        L_PS2_interrupt12
L_PS2_interrupt7:
;kb.c,78 :: 		INTCON2.INTEDG1 = 0;                                  //int1 falling edge
	BCF         INTCON2+0, 5 
;kb.c,79 :: 		if(--bitcount == 0){                                  // All bits received
	DECF        _bitcount+0, 1 
	MOVF        _bitcount+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_PS2_interrupt13
;kb.c,80 :: 		Reset_timeuot();                                  //Disable timeout timer
	CALL        _Reset_timeuot+0, 0
;kb.c,81 :: 		KeyDecode(keyData);
	MOVF        PS2_interrupt_keyData_L0+0, 0 
	MOVWF       FARG_KeyDecode+0 
	CALL        _KeyDecode+0, 0
;kb.c,82 :: 		bitcount = 11;
	MOVLW       11
	MOVWF       _bitcount+0 
;kb.c,83 :: 		}
L_PS2_interrupt13:
;kb.c,84 :: 		}
L_PS2_interrupt12:
;kb.c,85 :: 		}else {
	GOTO        L_PS2_interrupt14
L_PS2_interrupt6:
;kb.c,88 :: 		if (INTCON2.INTEDG1 == 0){                               //Проверяем условие что прерывание по спадающему фронту
	BTFSC       INTCON2+0, 5 
	GOTO        L_PS2_interrupt15
;kb.c,89 :: 		if(bitcount > 2 && bitcount <= 10){                    //Отправляем байт кода команды
	MOVF        _bitcount+0, 0 
	SUBLW       2
	BTFSC       STATUS+0, 0 
	GOTO        L_PS2_interrupt18
	MOVF        _bitcount+0, 0 
	SUBLW       10
	BTFSS       STATUS+0, 0 
	GOTO        L_PS2_interrupt18
L__PS2_interrupt116:
;kb.c,90 :: 		KEYB_DATA = kbWriteBuff & 1;                         //Выставляем младший бит в порт
	MOVLW       1
	ANDWF       _kbWriteBuff+0, 0 
	MOVWF       R0 
	BTFSC       R0, 0 
	GOTO        L__PS2_interrupt126
	BCF         PORTA+0, 4 
	GOTO        L__PS2_interrupt127
L__PS2_interrupt126:
	BSF         PORTA+0, 4 
L__PS2_interrupt127:
;kb.c,91 :: 		kbWriteBuff = kbWriteBuff >> 1;                      //Сдвигаем байт на 1 в право для перехода на следующий бит
	RRCF        _kbWriteBuff+0, 1 
	BCF         _kbWriteBuff+0, 7 
;kb.c,92 :: 		bitcount --;                                         //Инкрементируем счетчик битов
	DECF        _bitcount+0, 1 
;kb.c,93 :: 		} else if(bitcount == 2){                              //Условие передачи бита четности
	GOTO        L_PS2_interrupt19
L_PS2_interrupt18:
	MOVF        _bitcount+0, 0 
	XORLW       2
	BTFSS       STATUS+0, 2 
	GOTO        L_PS2_interrupt20
;kb.c,94 :: 		KEYB_DATA = sysFlags.kb_parity;                      //Запись в порт бита четности (Вычисляется на этапе формирования посылки)
	BTFSC       CVRCON+0, 5 
	GOTO        L__PS2_interrupt128
	BCF         PORTA+0, 4 
	GOTO        L__PS2_interrupt129
L__PS2_interrupt128:
	BSF         PORTA+0, 4 
L__PS2_interrupt129:
;kb.c,95 :: 		bitcount --;
	DECF        _bitcount+0, 1 
;kb.c,96 :: 		} else if(bitcount == 1){                              //Условие передачи СТОП бита
	GOTO        L_PS2_interrupt21
L_PS2_interrupt20:
	MOVF        _bitcount+0, 0 
	XORLW       1
	BTFSS       STATUS+0, 2 
	GOTO        L_PS2_interrupt22
;kb.c,97 :: 		KEYB_DATA = 1;                                       //Шлем 1 в порт
	BSF         PORTA+0, 4 
;kb.c,98 :: 		bitcount --;
	DECF        _bitcount+0, 1 
;kb.c,99 :: 		} else if(bitcount == 0){                              //Условие конца передачи команды
	GOTO        L_PS2_interrupt23
L_PS2_interrupt22:
	MOVF        _bitcount+0, 0 
	XORLW       0
	BTFSS       STATUS+0, 2 
	GOTO        L_PS2_interrupt24
;kb.c,100 :: 		bitcount = 11;                                       //Сбрасываем счетчик бит
	MOVLW       11
	MOVWF       _bitcount+0 
;kb.c,101 :: 		TRISA.RA4 = 1;                                       //Переводим пин data на вход
	BSF         TRISA+0, 4 
;kb.c,102 :: 		sysFlags.kb_rw = 0;                                  //Сбрасываем флаг передачи команды
	BCF         CVRCON+0, 4 
;kb.c,103 :: 		Reset_timeuot();                                     //Сбрасываем таймаут посылки
	CALL        _Reset_timeuot+0, 0
;kb.c,111 :: 		}
L_PS2_interrupt24:
L_PS2_interrupt23:
L_PS2_interrupt21:
L_PS2_interrupt19:
;kb.c,112 :: 		}
L_PS2_interrupt15:
;kb.c,114 :: 		}
L_PS2_interrupt14:
;kb.c,115 :: 		}
L_PS2_interrupt5:
;kb.c,116 :: 		}
L_end_PS2_interrupt:
	RETURN      0
; end of _PS2_interrupt

_PS2_Send:

;kb.c,120 :: 		unsigned char PS2_Send(unsigned char sData){
;kb.c,121 :: 		if(bitcount == 11){                  //Проверка отсутствия приема кода от клавиатуры
	MOVF        _bitcount+0, 0 
	XORLW       11
	BTFSS       STATUS+0, 2 
	GOTO        L_PS2_Send25
;kb.c,122 :: 		kbWriteBuff = sData;
	MOVF        FARG_PS2_Send_sData+0, 0 
	MOVWF       _kbWriteBuff+0 
;kb.c,123 :: 		sysFlags.kb_parity = parity(kbWriteBuff); //Определение четности отправляемого байта
	MOVF        FARG_PS2_Send_sData+0, 0 
	MOVWF       FARG_parity_x+0 
	CALL        _parity+0, 0
	BTFSC       R0, 0 
	GOTO        L__PS2_Send131
	BCF         CVRCON+0, 5 
	GOTO        L__PS2_Send132
L__PS2_Send131:
	BSF         CVRCON+0, 5 
L__PS2_Send132:
;kb.c,125 :: 		INTCON3.INT1IE = 0;               //Запрещаем прерывание от клавиатуры
	BCF         INTCON3+0, 3 
;kb.c,126 :: 		KEYB_CLOCK = 0;                    //Устанавливаем Clock в 0
	BCF         PORTB+0, 1 
;kb.c,127 :: 		KEYB_DATA = 1;                    //Устанавливаем Data в 1
	BSF         PORTA+0, 4 
;kb.c,128 :: 		TRISB.RB1 = 0;                    //Переводим пин clock на вывод
	BCF         TRISB+0, 1 
;kb.c,129 :: 		TRISA.RA4 = 0;                    //Переводим пин data на вывод
	BCF         TRISA+0, 4 
;kb.c,130 :: 		delay_ms(100);                    //Ждем 100мс
	MOVLW       7
	MOVWF       R11, 0
	MOVLW       23
	MOVWF       R12, 0
	MOVLW       106
	MOVWF       R13, 0
L_PS2_Send26:
	DECFSZ      R13, 1, 1
	BRA         L_PS2_Send26
	DECFSZ      R12, 1, 1
	BRA         L_PS2_Send26
	DECFSZ      R11, 1, 1
	BRA         L_PS2_Send26
	NOP
;kb.c,131 :: 		KEYB_DATA = 0;                    //Устанавливаем Data в 0
	BCF         PORTA+0, 4 
;kb.c,132 :: 		delay_ms(1);                      //Задержка для СТОП бита
	MOVLW       16
	MOVWF       R12, 0
	MOVLW       148
	MOVWF       R13, 0
L_PS2_Send27:
	DECFSZ      R13, 1, 1
	BRA         L_PS2_Send27
	DECFSZ      R12, 1, 1
	BRA         L_PS2_Send27
	NOP
;kb.c,133 :: 		KEYB_CLOCK = 1;                   //Подымаем КЛОК в лог 1
	BSF         PORTB+0, 1 
;kb.c,134 :: 		TRISB.RB1 = 1;                    //Переводим Clock на вход
	BSF         TRISB+0, 1 
;kb.c,135 :: 		sysFlags.kb_rw = 1;               //Устанавливаем флаг передачи данных в клавиатуру
	BSF         CVRCON+0, 4 
;kb.c,136 :: 		bitcount = 10;                    //Сбрасываем счетчик бит
	MOVLW       10
	MOVWF       _bitcount+0 
;kb.c,137 :: 		INTCON3.INT1IF = 0;               //Сбрасываем флаг прерывания перед началом работы
	BCF         INTCON3+0, 0 
;kb.c,138 :: 		INTCON3.INT1IE = 1;               //Разрешаем прерывания по Clock и идем в прерывание
	BSF         INTCON3+0, 3 
;kb.c,139 :: 		return 1;                         //Если все удачно возвращаем 1
	MOVLW       1
	MOVWF       R0 
	GOTO        L_end_PS2_Send
;kb.c,140 :: 		} else return 0;                     //Если нет то возвращаем 0
L_PS2_Send25:
	CLRF        R0 
;kb.c,141 :: 		}
L_end_PS2_Send:
	RETURN      0
; end of _PS2_Send

_PS2_Timeout_Interrupt:

;kb.c,145 :: 		void PS2_Timeout_Interrupt(){
;kb.c,146 :: 		if(INTCON.TMR0IE && INTCON.TMR0IF){           //Если сработал таймаут все сбрасываем
	BTFSS       INTCON+0, 5 
	GOTO        L_PS2_Timeout_Interrupt31
	BTFSS       INTCON+0, 2 
	GOTO        L_PS2_Timeout_Interrupt31
L__PS2_Timeout_Interrupt119:
;kb.c,147 :: 		if(sysFlags.kb_rw == 1) { sysFlags.kb_rw = 0; kbWriteBuff = 0; }
	BTFSS       CVRCON+0, 4 
	GOTO        L_PS2_Timeout_Interrupt32
	BCF         CVRCON+0, 4 
	CLRF        _kbWriteBuff+0 
L_PS2_Timeout_Interrupt32:
;kb.c,148 :: 		bitcount = 11;
	MOVLW       11
	MOVWF       _bitcount+0 
;kb.c,149 :: 		Reset_timeuot();                           //И стопорим таймер таймаута
	CALL        _Reset_timeuot+0, 0
;kb.c,150 :: 		}
L_PS2_Timeout_Interrupt31:
;kb.c,151 :: 		}
L_end_PS2_Timeout_Interrupt:
	RETURN      0
; end of _PS2_Timeout_Interrupt

_inArray:

;kb.c,155 :: 		unsigned char inArray(unsigned char value){               //Поиск значениея в массиве
;kb.c,157 :: 		for(i=0; i<=5; i++){                                 //Поиск выполняется по массиву keycode
	CLRF        R1 
L_inArray33:
	MOVF        R1, 0 
	SUBLW       5
	BTFSS       STATUS+0, 0 
	GOTO        L_inArray34
;kb.c,158 :: 		if(keycode[i] == value){                         //Если находит возвращает позицию + 1
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
	GOTO        L_inArray36
;kb.c,159 :: 		return i+1;
	MOVF        R1, 0 
	ADDLW       1
	MOVWF       R0 
	GOTO        L_end_inArray
;kb.c,160 :: 		}
L_inArray36:
;kb.c,157 :: 		for(i=0; i<=5; i++){                                 //Поиск выполняется по массиву keycode
	INCF        R1, 1 
;kb.c,161 :: 		}
	GOTO        L_inArray33
L_inArray34:
;kb.c,162 :: 		return 0;                                            //В противном случае возврат 0
	CLRF        R0 
;kb.c,163 :: 		}
L_end_inArray:
	RETURN      0
; end of _inArray

_Set_BRDButton:

;kb.c,167 :: 		void Set_BRDButton (unsigned char key, unsigned char upDown){
;kb.c,168 :: 		switch (key){
	GOTO        L_Set_BRDButton37
;kb.c,169 :: 		case KEY_F5    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton39:
	BTFSC       CVRCON+0, 3 
	GOTO        L_Set_BRDButton40
	GOTO        L_Set_BRDButton38
L_Set_BRDButton40:
;kb.c,170 :: 		case KEY_1     :
L_Set_BRDButton41:
;kb.c,171 :: 		case KEY_NUM_1 : BT_STOP1 = upDown; LED_PIN = upDown; break;
L_Set_BRDButton42:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton136
	BCF         PORTA+0, 0 
	GOTO        L__Set_BRDButton137
L__Set_BRDButton136:
	BSF         PORTA+0, 0 
L__Set_BRDButton137:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton138
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton139
L__Set_BRDButton138:
	BSF         PORTC+0, 2 
L__Set_BRDButton139:
	GOTO        L_Set_BRDButton38
;kb.c,172 :: 		case KEY_F6    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton43:
	BTFSC       CVRCON+0, 3 
	GOTO        L_Set_BRDButton44
	GOTO        L_Set_BRDButton38
L_Set_BRDButton44:
;kb.c,173 :: 		case KEY_2     :
L_Set_BRDButton45:
;kb.c,174 :: 		case KEY_NUM_2 : BT_STOP2 = upDown;  LED_PIN = upDown; break;
L_Set_BRDButton46:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton140
	BCF         PORTA+0, 1 
	GOTO        L__Set_BRDButton141
L__Set_BRDButton140:
	BSF         PORTA+0, 1 
L__Set_BRDButton141:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton142
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton143
L__Set_BRDButton142:
	BSF         PORTC+0, 2 
L__Set_BRDButton143:
	GOTO        L_Set_BRDButton38
;kb.c,175 :: 		case KEY_F7    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton47:
	BTFSC       CVRCON+0, 3 
	GOTO        L_Set_BRDButton48
	GOTO        L_Set_BRDButton38
L_Set_BRDButton48:
;kb.c,176 :: 		case KEY_3     :
L_Set_BRDButton49:
;kb.c,177 :: 		case KEY_NUM_3 : BT_STOP3 = upDown;  LED_PIN = upDown; break;
L_Set_BRDButton50:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton144
	BCF         PORTA+0, 2 
	GOTO        L__Set_BRDButton145
L__Set_BRDButton144:
	BSF         PORTA+0, 2 
L__Set_BRDButton145:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton146
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton147
L__Set_BRDButton146:
	BSF         PORTC+0, 2 
L__Set_BRDButton147:
	GOTO        L_Set_BRDButton38
;kb.c,178 :: 		case KEY_F8    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton51:
	BTFSC       CVRCON+0, 3 
	GOTO        L_Set_BRDButton52
	GOTO        L_Set_BRDButton38
L_Set_BRDButton52:
;kb.c,179 :: 		case KEY_4     :
L_Set_BRDButton53:
;kb.c,180 :: 		case KEY_NUM_4 : BT_STOP4 = upDown;  LED_PIN = upDown; break;
L_Set_BRDButton54:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton148
	BCF         PORTA+0, 3 
	GOTO        L__Set_BRDButton149
L__Set_BRDButton148:
	BSF         PORTA+0, 3 
L__Set_BRDButton149:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton150
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton151
L__Set_BRDButton150:
	BSF         PORTC+0, 2 
L__Set_BRDButton151:
	GOTO        L_Set_BRDButton38
;kb.c,181 :: 		case KEY_F9    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton55:
	BTFSC       CVRCON+0, 3 
	GOTO        L_Set_BRDButton56
	GOTO        L_Set_BRDButton38
L_Set_BRDButton56:
;kb.c,182 :: 		case KEY_5     :
L_Set_BRDButton57:
;kb.c,183 :: 		case KEY_NUM_5 : BT_STOP5 = upDown;  LED_PIN = upDown; break;
L_Set_BRDButton58:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton152
	BCF         PORTA+0, 5 
	GOTO        L__Set_BRDButton153
L__Set_BRDButton152:
	BSF         PORTA+0, 5 
L__Set_BRDButton153:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton154
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton155
L__Set_BRDButton154:
	BSF         PORTC+0, 2 
L__Set_BRDButton155:
	GOTO        L_Set_BRDButton38
;kb.c,184 :: 		case KEY_F10    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton59:
	BTFSC       CVRCON+0, 3 
	GOTO        L_Set_BRDButton60
	GOTO        L_Set_BRDButton38
L_Set_BRDButton60:
;kb.c,185 :: 		case KEY_7     :
L_Set_BRDButton61:
;kb.c,186 :: 		case KEY_NUM_7 : BT_LINE = upDown;  LED_PIN = upDown; break;
L_Set_BRDButton62:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton156
	BCF         PORTB+0, 6 
	GOTO        L__Set_BRDButton157
L__Set_BRDButton156:
	BSF         PORTB+0, 6 
L__Set_BRDButton157:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton158
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton159
L__Set_BRDButton158:
	BSF         PORTC+0, 2 
L__Set_BRDButton159:
	GOTO        L_Set_BRDButton38
;kb.c,187 :: 		case KEY_F11    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton63:
	BTFSC       CVRCON+0, 3 
	GOTO        L_Set_BRDButton64
	GOTO        L_Set_BRDButton38
L_Set_BRDButton64:
;kb.c,188 :: 		case KEY_8     :
L_Set_BRDButton65:
;kb.c,189 :: 		case KEY_NUM_8 : BT_BET = upDown;  LED_PIN = upDown; break;
L_Set_BRDButton66:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton160
	BCF         PORTB+0, 5 
	GOTO        L__Set_BRDButton161
L__Set_BRDButton160:
	BSF         PORTB+0, 5 
L__Set_BRDButton161:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton162
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton163
L__Set_BRDButton162:
	BSF         PORTC+0, 2 
L__Set_BRDButton163:
	GOTO        L_Set_BRDButton38
;kb.c,190 :: 		case KEY_9     :
L_Set_BRDButton67:
;kb.c,191 :: 		case KEY_NUM_9 : BT_INFO = upDown;  LED_PIN = upDown; break;
L_Set_BRDButton68:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton164
	BCF         PORTC+0, 0 
	GOTO        L__Set_BRDButton165
L__Set_BRDButton164:
	BSF         PORTC+0, 0 
L__Set_BRDButton165:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton166
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton167
L__Set_BRDButton166:
	BSF         PORTC+0, 2 
L__Set_BRDButton167:
	GOTO        L_Set_BRDButton38
;kb.c,192 :: 		case KEY_0     :
L_Set_BRDButton69:
;kb.c,193 :: 		case KEY_NUM_0 : BT_MENU = upDown;  LED_PIN = upDown; break;
L_Set_BRDButton70:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton168
	BCF         PORTC+0, 1 
	GOTO        L__Set_BRDButton169
L__Set_BRDButton168:
	BSF         PORTC+0, 1 
L__Set_BRDButton169:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton170
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton171
L__Set_BRDButton170:
	BSF         PORTC+0, 2 
L__Set_BRDButton171:
	GOTO        L_Set_BRDButton38
;kb.c,194 :: 		case KEY_F12   : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton71:
	BTFSC       CVRCON+0, 3 
	GOTO        L_Set_BRDButton72
	GOTO        L_Set_BRDButton38
L_Set_BRDButton72:
;kb.c,195 :: 		case KEY_ENTER :
L_Set_BRDButton73:
;kb.c,196 :: 		case KEY_SPACE :
L_Set_BRDButton74:
;kb.c,197 :: 		case KEY_NUM_ENTR: BT_START = upDown;  LED_PIN = upDown; break;
L_Set_BRDButton75:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton172
	BCF         PORTB+0, 4 
	GOTO        L__Set_BRDButton173
L__Set_BRDButton172:
	BSF         PORTB+0, 4 
L__Set_BRDButton173:
	BTFSC       FARG_Set_BRDButton_upDown+0, 0 
	GOTO        L__Set_BRDButton174
	BCF         PORTC+0, 2 
	GOTO        L__Set_BRDButton175
L__Set_BRDButton174:
	BSF         PORTC+0, 2 
L__Set_BRDButton175:
	GOTO        L_Set_BRDButton38
;kb.c,198 :: 		case KEY_F3    : if(sysFlags.kb_mode == 0) break;
L_Set_BRDButton76:
	BTFSC       CVRCON+0, 3 
	GOTO        L_Set_BRDButton77
	GOTO        L_Set_BRDButton38
L_Set_BRDButton77:
;kb.c,199 :: 		case KEY_ESC   :
L_Set_BRDButton78:
;kb.c,200 :: 		case KEY_HOME  : sysFlags.if_pc = 0; break;           //Кнопками Esc и Home происходит выход с режима плата
L_Set_BRDButton79:
	BCF         CVRCON+0, 0 
	GOTO        L_Set_BRDButton38
;kb.c,201 :: 		default : break;
L_Set_BRDButton80:
	GOTO        L_Set_BRDButton38
;kb.c,202 :: 		}
L_Set_BRDButton37:
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       62
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton39
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       30
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton41
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       89
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton42
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       63
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton43
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       31
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton45
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       90
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton46
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       64
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton47
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       32
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton49
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       91
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton50
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       65
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton51
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       33
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton53
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       92
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton54
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       66
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton55
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       34
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton57
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       93
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton58
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       67
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton59
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       36
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton61
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       95
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton62
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       68
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton63
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       37
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton65
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       96
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton66
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       38
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton67
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       97
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton68
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       39
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton69
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       98
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton70
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       69
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton71
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       40
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton73
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       44
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton74
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       88
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton75
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       60
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton76
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       41
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton78
	MOVF        FARG_Set_BRDButton_key+0, 0 
	XORLW       74
	BTFSC       STATUS+0, 2 
	GOTO        L_Set_BRDButton79
	GOTO        L_Set_BRDButton80
L_Set_BRDButton38:
;kb.c,203 :: 		}
L_end_Set_BRDButton:
	RETURN      0
; end of _Set_BRDButton

_SetPass:

;kb.c,207 :: 		void SetPass (unsigned char key){
;kb.c,209 :: 		for(i=0; i<17; i++){
	CLRF        R2 
L_SetPass81:
	MOVLW       17
	SUBWF       R2, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_SetPass82
;kb.c,210 :: 		progPass[i] = progPass[i+1];
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
;kb.c,209 :: 		for(i=0; i<17; i++){
	INCF        R2, 1 
;kb.c,211 :: 		}
	GOTO        L_SetPass81
L_SetPass82:
;kb.c,212 :: 		progPass[16] = key;
	MOVF        FARG_SetPass_key+0, 0 
	MOVWF       _progPass+16 
;kb.c,213 :: 		}
L_end_SetPass:
	RETURN      0
; end of _SetPass

_KeyDecode:

;kb.c,217 :: 		void KeyDecode(unsigned char sc){
;kb.c,219 :: 		unsigned char i, key=0;                //Буферная переманная кода клавиши
	CLRF        KeyDecode_key_L0+0 
;kb.c,222 :: 		switch(sc){
	GOTO        L_KeyDecode84
;kb.c,223 :: 		case 0xE0 : sysFlags.if_func = 1; break;                           //Устанавливаем флаг функциональной кнопки если пришел ее код
L_KeyDecode86:
	BSF         CVRCON+0, 1 
	GOTO        L_KeyDecode85
;kb.c,224 :: 		case 0xF0 : sysFlags.if_up = 1; break;                             //Устанавливаем флаг если кнопка отпущена
L_KeyDecode87:
	BSF         CVRCON+0, 2 
	GOTO        L_KeyDecode85
;kb.c,225 :: 		default :  if(sc > 0 && sc < 0x84){                       //Проверка что нажата кнопка а не сервисные данные
L_KeyDecode88:
	MOVF        FARG_KeyDecode_sc+0, 0 
	SUBLW       0
	BTFSC       STATUS+0, 0 
	GOTO        L_KeyDecode91
	MOVLW       132
	SUBWF       FARG_KeyDecode_sc+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_KeyDecode91
L__KeyDecode121:
;kb.c,226 :: 		if(sysFlags.if_func == 1){                             //Если была нажата функциональная кнопка
	BTFSS       CVRCON+0, 1 
	GOTO        L_KeyDecode92
;kb.c,227 :: 		for(i=0; i<sizeof(funCode)/2; i++){       //Перебераем HID сканкод из массива соответствия
	CLRF        KeyDecode_i_L0+0 
L_KeyDecode93:
	MOVLW       18
	SUBWF       KeyDecode_i_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_KeyDecode94
;kb.c,228 :: 		if(funCode[i][0] == sc){
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
	GOTO        L_KeyDecode96
;kb.c,229 :: 		key = funCode[i][1];                //Если такой код имеется то записываем его в буферную переменную
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
;kb.c,230 :: 		break;                               //и выходим с цикла
	GOTO        L_KeyDecode94
;kb.c,231 :: 		}
L_KeyDecode96:
;kb.c,227 :: 		for(i=0; i<sizeof(funCode)/2; i++){       //Перебераем HID сканкод из массива соответствия
	INCF        KeyDecode_i_L0+0, 1 
;kb.c,232 :: 		}
	GOTO        L_KeyDecode93
L_KeyDecode94:
;kb.c,233 :: 		sysFlags.if_func = 0;                              //В противном случае просто сбрасываем флаг
	BCF         CVRCON+0, 1 
;kb.c,234 :: 		} else {
	GOTO        L_KeyDecode97
L_KeyDecode92:
;kb.c,235 :: 		key = scanCode[sc];                       //Если была нажата простая кнопка то записываем код из массива простых кнопок
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
;kb.c,236 :: 		}
L_KeyDecode97:
;kb.c,237 :: 		if(key>1){
	MOVF        KeyDecode_key_L0+0, 0 
	SUBLW       1
	BTFSC       STATUS+0, 0 
	GOTO        L_KeyDecode98
;kb.c,241 :: 		if(key >= 0xE0 && key <= 0xE7){//Проверяем если прийшли данные от кнопок CtrlShiftAltWin
	MOVLW       224
	SUBWF       KeyDecode_key_L0+0, 0 
	BTFSS       STATUS+0, 0 
	GOTO        L_KeyDecode101
	MOVF        KeyDecode_key_L0+0, 0 
	SUBLW       231
	BTFSS       STATUS+0, 0 
	GOTO        L_KeyDecode101
L__KeyDecode120:
;kb.c,242 :: 		if(sysFlags.if_up == 1){                          //Проверяем если одна из кнопок была отжата
	BTFSS       CVRCON+0, 2 
	GOTO        L_KeyDecode102
;kb.c,243 :: 		modifier &= ~dvFlags[key & 0x0F];     //Если так то убираем соответствующий флаг
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
;kb.c,244 :: 		} else                                    //Далее проверяем если нажатая клавиша соответствует HID коду
	GOTO        L_KeyDecode103
L_KeyDecode102:
;kb.c,245 :: 		modifier |= dvFlags[key & 0x0F];
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
L_KeyDecode103:
;kb.c,246 :: 		} /////////////////////////////////////////////////////////////
L_KeyDecode101:
;kb.c,248 :: 		keyPos = inArray(key);          //Проверяем есть ли эта кнопка уже в массиве
	MOVF        KeyDecode_key_L0+0, 0 
	MOVWF       FARG_inArray_value+0 
	CALL        _inArray+0, 0
	MOVF        R0, 0 
	MOVWF       KeyDecode_keyPos_L0+0 
;kb.c,249 :: 		if(keyPos){                     //Если есть проверяем не отпущена ли кнопка
	MOVF        R0, 1 
	BTFSC       STATUS+0, 2 
	GOTO        L_KeyDecode104
;kb.c,250 :: 		if(sysFlags.if_up){                             //Если отпущена
	BTFSS       CVRCON+0, 2 
	GOTO        L_KeyDecode105
;kb.c,251 :: 		if(sysFlags.if_pc == 1)  Set_BRDButton(key, 0);
	BTFSS       CVRCON+0, 0 
	GOTO        L_KeyDecode106
	MOVF        KeyDecode_key_L0+0, 0 
	MOVWF       FARG_Set_BRDButton_key+0 
	CLRF        FARG_Set_BRDButton_upDown+0 
	CALL        _Set_BRDButton+0, 0
L_KeyDecode106:
;kb.c,252 :: 		for(i=keyPos-1; i<5; i++){          //изьять элемент из массива и выполнить сдвих
	DECF        KeyDecode_keyPos_L0+0, 0 
	MOVWF       KeyDecode_i_L0+0 
L_KeyDecode107:
	MOVLW       5
	SUBWF       KeyDecode_i_L0+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_KeyDecode108
;kb.c,253 :: 		keycode[i] = keycode[i+1];
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
;kb.c,252 :: 		for(i=keyPos-1; i<5; i++){          //изьять элемент из массива и выполнить сдвих
	INCF        KeyDecode_i_L0+0, 1 
;kb.c,254 :: 		}
	GOTO        L_KeyDecode107
L_KeyDecode108:
;kb.c,255 :: 		keyCnt--;                            //Инкрементировать щетчик кнопок
	DECF        _keyCnt+0, 1 
;kb.c,256 :: 		sysFlags.if_up = 0;                           //Сбросить флаг отпущеной кнопки
	BCF         CVRCON+0, 2 
;kb.c,257 :: 		}
L_KeyDecode105:
;kb.c,259 :: 		}else if(keyCnt<6){                      //Если не отпущена то добавляем и инкрементируем массив
	GOTO        L_KeyDecode110
L_KeyDecode104:
	MOVLW       6
	SUBWF       _keyCnt+0, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_KeyDecode111
;kb.c,260 :: 		keycode[keyCnt] = key;
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
;kb.c,261 :: 		keyCnt++;
	INCF        _keyCnt+0, 1 
;kb.c,262 :: 		if(sysFlags.if_pc == 1) Set_BRDButton(key, 1);
	BTFSS       CVRCON+0, 0 
	GOTO        L_KeyDecode112
	MOVF        KeyDecode_key_L0+0, 0 
	MOVWF       FARG_Set_BRDButton_key+0 
	MOVLW       1
	MOVWF       FARG_Set_BRDButton_upDown+0 
	CALL        _Set_BRDButton+0, 0
L_KeyDecode112:
;kb.c,263 :: 		SetPass(key);                          //Обработчик ввода пароля программирования и удаления ключей с клавиатуры
	MOVF        KeyDecode_key_L0+0, 0 
	MOVWF       FARG_SetPass_key+0 
	CALL        _SetPass+0, 0
;kb.c,264 :: 		}
L_KeyDecode111:
L_KeyDecode110:
;kb.c,265 :: 		}
L_KeyDecode98:
;kb.c,266 :: 		for (i=keycnt; i<=5; i++){                  //Остальное забиваем нулями
	MOVF        _keyCnt+0, 0 
	MOVWF       KeyDecode_i_L0+0 
L_KeyDecode113:
	MOVF        KeyDecode_i_L0+0, 0 
	SUBLW       5
	BTFSS       STATUS+0, 0 
	GOTO        L_KeyDecode114
;kb.c,267 :: 		keycode[i] = 0;
	MOVLW       _keycode+0
	MOVWF       FSR1 
	MOVLW       hi_addr(_keycode+0)
	MOVWF       FSR1H 
	MOVF        KeyDecode_i_L0+0, 0 
	ADDWF       FSR1, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	CLRF        POSTINC1+0 
;kb.c,266 :: 		for (i=keycnt; i<=5; i++){                  //Остальное забиваем нулями
	INCF        KeyDecode_i_L0+0, 1 
;kb.c,268 :: 		}
	GOTO        L_KeyDecode113
L_KeyDecode114:
;kb.c,269 :: 		}  //-------------------------
L_KeyDecode91:
;kb.c,270 :: 		break;
	GOTO        L_KeyDecode85
;kb.c,271 :: 		}
L_KeyDecode84:
	MOVF        FARG_KeyDecode_sc+0, 0 
	XORLW       224
	BTFSC       STATUS+0, 2 
	GOTO        L_KeyDecode86
	MOVF        FARG_KeyDecode_sc+0, 0 
	XORLW       240
	BTFSC       STATUS+0, 2 
	GOTO        L_KeyDecode87
	GOTO        L_KeyDecode88
L_KeyDecode85:
;kb.c,272 :: 		}
L_end_KeyDecode:
	RETURN      0
; end of _KeyDecode
