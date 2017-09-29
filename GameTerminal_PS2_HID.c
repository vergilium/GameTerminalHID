/*
 * Project name: GameTerminal
 * Copyright (c) 2017 Vergilium
 * Description: Игровой терминал. Работает как HID клавиатура через USB
                Подключается PS2 клавиатура.
 * Сonfiguration:
     MCU:             PIC18F2550
     Board:
     Oscillator:      HS+PLL, 48.000 MHz (12MHz Crystal)
     SW:              mikroC PRO for PIC
 */
#include <stdint.h>
#include "main.h"
#include "kb.h"

uint8_t readbuff[64] absolute 0x500;
uint8_t writebuff[64] absolute 0x540;
uint8_t modifier=0b00000000;                  //Модификатор для передачи функциональных клавишь CtrlShiftAltWin
uint8_t reserved=0;                           //Зарезервированая переменная для будущего использования
uint8_t keycode[6];                           //Переменная хранения до 6 кодов клавишь
uint8_t progPass[17] = {0};                   //Переменная хранения ввода пароля программирования или удаления ключей
uint8_t kybCnt = KYBCNT_DELAY;                //Переменная отсчета времени переключения режима клавиатуры

struct UFLG{                                  //Флаги для работы с USB
   unsigned upBtn: 1;                         //Флаг определяющий что кнопка отпущена
   unsigned if_conf: 1;                       //Флаг определяющий что USB подключен. Нужен для определения подключения по USB.
                                              //Так как в библиотеке не предусмотрена функция получения состояния USB прийшлось
                                              //строить костыли. Но работает.
} USBFlags at ADRESH;                         //Размещены в регистре ADRESH

struct FLG{                                         //Структура флагов, аналогичная инициализация находится в файле kb.c
   unsigned if_pc: 1;                               //0 = компьютер 1 = плата
   unsigned if_func: 1;
   unsigned if_up: 1;
   unsigned kb_mode: 1;                            //0 = стандартная клавиатура, 1 = консоль
   unsigned kb_rw: 1;
   unsigned kb_parity: 1;
} sysFlags at CVRCON;                               //Флаги сохряняются в регистре CVRCON настроек компаратора который не используется

void interrupt(){
     USB_Interrupt_Proc();                          // USB servicing is done inside the interrupt
     PS2_interrupt();                               //Прерывание по INT1 при поступлении данных с PS2
     if(SUSPND_bit) USBFlags.if_conf = 0;           //В случае перехода USB в режим SUSPEND(Ожидания) сбрасывается флаг конфигурации USB
}
void interrupt_low(){
     PS2_Timeout_Interrupt();     //Прерывание по timer0 через 1мс в случае ошибочных данных по PS2
}

//==============================================================================
//    Функция мигания светодиодиком
//==============================================================================
void Led_Indicate(unsigned char blink){
  unsigned char i;
  for(i=0; i<=blink; i++){
     LED_PIN = ~LED_PIN;
     delay_ms(100);
  }
  LED_PIN = 0;
}
//==============================================================================
//    Функция сравнения паролей прог. удаления
//==============================================================================
unsigned char ArrCmp(unsigned char * arr1, unsigned char * arr2, unsigned char pos, unsigned char ln){
   unsigned char i;
   for (i=0; i<ln; i++){
      if(arr1[i+pos] != arr2[i]) return 0;
   }
   return 1;
}
//==============================================================================
//    Тело основной программы
//==============================================================================
void main(){
        INTCON = 0;     //Запрещаются все прерывания
        //Initialize ports
        ADCON1 = 0x0F;  // Configure all PORT pins as digital
        /////////////////////Настройка портов///////////////////////////////////
        TRISA= 0b00010000;
        TRISB= 0b00000011;
        TRISC= 0b10111000;
        PORTA= 0;
        PORTB= 0;
        PORTC= 0;
        //////////////////Настройка периферии///////////////////////////////////
        ADRESH = 0;                            //Сброс регистра в котором находятся флаги USB(USBFlags)
        INTCON2.RBPU = 0;                      //Вклучить подтяжку
        init_kb();                             //Инициализация клавиатуры PS2
        HID_Enable(readbuff,writebuff);        //Инициализация USB в режиме HID клавиатуры
        UART1_Init(9600);                      //Инициализация UART на скорости 9600 bps
        sysFlags.kb_mode = EEPROM_Read(0x00);  //Чтение байта конфигурации режима клавиатуры
        Led_Indicate(2);                       //Индикация готовности
        PWR12 = 1;                             //Включение питания 12В на плату
        INTCON |= (1<<GIE)|(1<<PEIE);          //Разрешение глобальных прерываний
        while(!PS2_Send(0xFF));                //СБРОС PS2 клавиатуры
        //Main cycle
  while(1) {
        /////////////////////////////////////////////////////////////
        //////Переключение с ПК на плату и включение платы///////////
       if(button(&PORTC, RC7, 200, 0)){      //Если включение сработало
           LED_PIN = 1;                       //Зажигаем светодиод
           PWR5 = 1;                          //Включить 5В питание платы
           VIDEO_PIN = 1;                     //Переключить монитор на плату
           sysFlags.if_pc = 1;                //Запоминаем что мы на плате
           USBFlags.if_conf = 0;              //Сбрасываем флаг разрешения передачи данных в ПК
           while(!PS2_Send(0xED));            //Далее гасятся светодиоды на клавиатуре
           delay_ms(10);
           while(!PS2_Send(0x00));
           delay_ms(250);                     //Задержка
           LED_PIN = 0;                       //Гасим светодиод
        }
        /////////////////////////////////////////////////////////////////////////////////
        ///Получение OUT репортов от хоста (Управление светодиодами клавиатуры)//////////
        if(HID_Read()){
           USBFlags.if_conf = 1;                          //Если мы получили данные от USB значит он подключен. Устанавливаем соответствующий флаг
           while(!PS2_Send(0xED));                        //Далее получаем репорт и пишем в клавиатуру
           delay_ms(10);
           while(!PS2_Send((readbuff[0] & 0x03) << 1));
        }
 ////////////////////////////////////////////////////////////////////////////////////////
 ////Далее код делится на 2 ветки: режим платы и  режим компьютера
 ////В режиме компьютера контроллер работает как обычная USB клавиатура
 ////Только в режиме платы доступны функции работы с программированием считывателя
 ////и обрабатываются нажатия кнопок на плате. В режиме платы данные в ПК не передаются
 ////////////////////////////////////////////////////////////////////////////////////////
     if(sysFlags.if_pc == 1){                         //Если на плате
        switch(keycode[0]){
           case KEY_F12: if(sysFlags.kb_mode == 0)                         //Обработка нажатия кнопки F12 (выход из программирования)
                            uart_write(RDR_PRG_END);
                            break;
           case KEY_F5 : if(sysFlags.kb_mode == 0){                        //Обработка переключения на консоль
                          if(--kybCnt == 0){
                             EEPROM_Write(0,1);                            //Запись в EEPROM состояния 1 - режим консоли
                             sysFlags.kb_mode = 1;                         //Выставляем флаг режима консоли
                             kybCnt = KYBCNT_DELAY;                        //Сброс счетчика задержки переключения между консолью и клавиатурой
                             uart_write(RDR_PRG_END);                      //Сигнал перехода режима
                           }
                         } break;
           case KEY_NUM_ENTR : if(sysFlags.kb_mode == 1){                       //Обработка переключения на клавиатуру
                                 if(--kybCnt == 0){
                                    EEPROM_Write(0,0);                          //Запись в EEPROM состояния 1 - режим клавиатуры
                                    sysFlags.kb_mode = 0;                       //Выставляем флаг режима клавиатуры
                                    kybCnt = KYBCNT_DELAY;                      //Сброс счетчика задержки переключения между консолью и клавиатурой
                                    uart_write(RDR_PRG_END);                    //Сигнал перехода режима
                                 }
                               } break;
           default : kybCnt = KYBCNT_DELAY; break;                       //Сброс счетчика если кнопка отпущена или нажата другая кнопка
        }
        
        ///Проверка ввода фразы программирования ключей
        if(ArrCmp(&progPass, &progStr, 0, 16)){
           switch(progPass[16]){
              case KEY_1: UART1_Write(RDR_PRG_CH1); break;   //программирование1 - кредитный
              case KEY_2: UART1_Write(RDR_PRG_CH2); break;   //программирование2 - сьемный
              case KEY_3: UART1_Write(RDR_PRG_CH3); break;   //программирование3 - овнер
              case KEY_4: UART1_Write(RDR_PRG_CH4); break;   //программирование4 - админ
              case KEY_0: EEPROM_Write(0xFF,0xFF);           //Переход в режим бутлодера
                          HID_Disable();                     //Выключение HID устройства
                          delay_ms(10);                      //Задержка для ПК, чтобы успел отключить
                          asm RESET; break;                  //Сброс МК
              default: break;
           }
           progPass[0] = 0;                         //Сброс ввода фразы
        }
        ///Проверка ввода фразы удаления ключей
        else if(ArrCmp(&progPass, &delStr, 8, 8)){
           switch(progPass[16]){
              case KEY_1: UART1_Write(RDR_CLR_CH1); break;   //Удаление1 - кредитный
              case KEY_2: UART1_Write(RDR_CLR_CH2); break;   //Удаление2 - сьемный
              case KEY_3: UART1_Write(RDR_CLR_CH3); break;   //Удаление3 - овнер
              case KEY_4: UART1_Write(RDR_CLR_CH4); break;   //Удаление4 - админ
              case KEY_5: UART1_Write(RDR_CLR_ALL); break;   //Удаление5 - всех ключей
              default: break;
           }
           progPass[8] = 0;                         //Сброс фразы
        }
        delay_ms(100);                                 //Задержка, от этой задержки зависит время зажатия кнопок на переключение между клавиатурой и консолью
     }else if(sysFlags.if_pc == 0){
             PWR5 = 0;                                 //Сбрасываем питание с платы
             VIDEO_PIN = 0;                            //Переключаемся на ПК
           if(USBFlags.if_conf == 1){                  //Если USB подключен выполняется обработка и отправка кнопки
     ///////////////////////////////////////////////////////////////////////////
     /////Режим работы "Keyboard HID"
     //Далее выполняется код поредачи клавишь по USB
     ///////////////////////////////////////////////////////////////////////////
             if(keycode[0] != 0)                      //Если есть хотябы одно нажате кнопки
                  USBFlags.upBtn == 0;                //Сбросить флаг отпущеной кнопки
             if(USBFlags.upBtn == 0){                 //Если есть нажатие то выполняется
               writebuff[0]=modifier;                 //процедура отправки кнопок
               writebuff[1]=reserved;
               writebuff[2]=keycode[0];
               writebuff[3]=keycode[1];
               writebuff[4]=keycode[2];
               writebuff[5]=keycode[3];
               writebuff[6]=keycode[4];
               writebuff[7]=keycode[5];
               while(!HID_Write(writebuff,8));       //Непосредственно сама передача
               if(keycode[0] == 0)                   //Если нет не одной нажатой кнопки
                  USBFlags.upBtn == 1;               //Устанавливаем флаг отпущенных кнопок
             }
           }
         delay_ms(30);
     }
  }
HID_Disable();
}