/*
 * Project name: GameTerminal
 * Copyright (c) 2017 Vergilium
 * Description: Игровой терминал. Работает как HID клавиатура через USB
                Подключается PS2 клавиатура.
 * Сonfiguration:
     MCU:             PIC18F2550
     Board:           Video-Sw 18.11.14
     Oscillator:      HS+PLL, 48.000 MHz (12MHz Crystal)
     SW:              mikroC PRO for PIC
 */
#include <stdint.h>
#include "main.h"
#include "usb.h"
#include "kb.h"
#include "Password.h"
////////////////////////////////Внешние переменные////////////////////////////////

////////////////////////////////Глобальные переменные/////////////////////////////
uint8_t keycode[6];                           //Переменная хранения до 6 кодов клавишь
uint8_t modifier=0b00000000;                  //Модификатор для передачи функциональных клавишь CtrlShiftAltWin
uint8_t progPass[PASS_BUFF_SIZE] = {0};       //Переменная хранения ввода пароля программирования или удаления ключей
char passCnt = 0;                             //переменная количества введенных символов пароля (точнее кол. оставшихся пустых ячеек)
uint8_t kybCnt = KYBCNT_DELAY;                //Переменная отсчета времени переключения режима клавиатуры
uint8_t sysConfig;
struct SFLG{                                  //Структура флагов, аналогичная инициализация находится в файле kb.c
   unsigned kb_mode: 1;                       //0 = стандартная клавиатура, 1 = консоль
   unsigned usb_on: 1;                        //1 = usb отключен, 0 = usb включен
   unsigned kbBtn_mode: 1;                    //0 = 10 кнопок, 1 = 11 кнопок
   unsigned wr_pass: 1;                       //1 = активация режима записи пароля
   unsigned if_pc: 1;                         //0 = компьютер 1 = плата
} sysFlags at CVRCON;                         //Флаги сохряняются в регистре CVRCON настроек компаратора который не используется

void interrupt(){
     if(sysFlags.usb_on == 0)
        USBDev_IntHandler();      // USB servicing is done inside the interrupt
     PS2_interrupt();             //Прерывание по INT1 при поступлении данных с PS2
     PS2_Timeout_Interrupt();     //Прерывание по timer0 через 1мс в случае ошибочных данных по PS2
}
/*void interrupt_low(){
}*/

// USB Device callback function called for various events
void USBDev_EventHandler(uint8_t event) {
    switch(event){
      case _USB_DEV_EVENT_CONFIGURED : USBFlags.if_conf = 1; break;
    //  case _USB_DEV_EVENT_RX_ERROR   : break;
    //  case _USB_DEV_EVENT_RESET      : break;
    //  case _USB_DEV_EVENT_ATTACHED   : break;
      case _USB_DEV_EVENT_SUSPENDED  : USBFlags.if_conf = 0; break;
      case _USB_DEV_EVENT_DISCONNECTED: USBFlags.if_conf = 0; break;
    //  case _USB_DEV_EVENT_WAKEUP     : break;
      default : break;
  }
}

// USB Device callback function called when packet received
void USBDev_DataReceivedHandler(uint8_t ep, uint16_t size) {
     USBFlags.hid_rec = 1;
}

// USB Device callback function called when packet is sent
void USBDev_DataSentHandler(uint8_t ep) {
//--------------------- User code ---------------------//
}

//==============================================================================
//    Функция мигания светодиодиком
//    Возврат:        void
//    Параметры:      uint8_t blink - количество миганий
//==============================================================================
void Led_Indicate(uint8_t blink){
  uint8_t i;
  for(i=0; i<=blink; i++){
     LED_PIN = ~LED_PIN;
     delay_ms(100);
  }
  LED_PIN = 0;
}
//==============================================================================
//    Функция сравнения паролей прог. удаления
//    Возврат:        uint8_t - 0 = строки не равны  1 = строки равны
//    Параметры:      uint8_t *arr1 - указатель на массив введенной строки
//                    const uint8_t *arr2 - указатель на константную строку фразы
//                    uint8_t pos - позиция в массиве с которой начинается сравнение
//                    uint8_t ln - число сравниваемых символов
//==============================================================================
uint8_t ArrCmp(uint8_t *arr1, const uint8_t *arr2, uint8_t pos, uint8_t ln){
   uint8_t i;
   for (i=0; i<ln; i++){                                  //В цикле идет сравнение
      if((arr1[i+pos] & 0x7F) != arr2[i]) return 0;       //массивов. 0х7F - маска, так как старший бит
   }                                                      //использоется для указания модификатора SHIFT
   return 1;
}

//==============================================================================
//    Тело основной программы
//==============================================================================
void main(){
   uint8_t i;
        INTCON = 0;     //Запрещаются все прерывания
        /////////////////////Настройка портов///////////////////////////////////
        ADCON1 = 0x0F;  //Сконфигурировать все порты нак цифровые
        TRISA= 0b00010000;
        TRISB= 0b00000011;
        TRISC= 0b10111000;
        PORTA= 0;
        PORTB= 0;
        PORTC= 0;
        INTCON2.RBPU = 0;                      //Вклучить подтяжку
        ///////////////////////////////////////////////////////////////
        /////////////Инициализация периферии///////////////////////////
        CVRCON = 0;                            //Сброс регистров флагов
        ADRESL = 0;                            //переназначеных
        Init_PS2();                            //Инициализация клавиатуры PS2
        UART1_Init(9600);                      //инициализация UART на 9600 bps
        /////Считывание конфигурации с EEPROM//////////////////////////
        sysConfig = EEPROM_Read(SYS_CONF_ADDR);                   //Чтение байта конфигурации
        if(sysConfig == 0xFF) EEPROM_Write(SYS_CONF_ADDR,0);      //Если ячейка не инициализирована то прошить режим по умолчанию
        sysFlags.kb_mode = sysConfig & 0x01;                      //Заносим биты в структуру конфигурации
        sysFlags.usb_on = (sysConfig & 0x02)>>1;
        sysFlags.kbBtn_mode = (sysConfig & 0x04)>>2;
        ///////////////////////////////////////////////////////////////
        PWR12 = 1;                             //Включение питания 12В на плату
        ///////////////////////////////////////////////////////////////
        ////////Инициализация USB HID//////////////////////////////////
        if(sysFlags.usb_on == 0){                                 //Если USB включен то инициализируем
           USBDev_Init();
           USBFlags.hid_rec = 0;
        }
        IPEN_bit = 1;
        USBIP_bit = 1;
        USBIE_bit = 1;
        GIEH_bit = 1;
        ///////////////////////////////////////////////////////////////
        GIE_bit = 1;
        PEIE_bit = 1;
        delay_ms(100);
        Reset_PS2();                           //Сброс клавиатуры
        Led_Indicate(2);                       //Индикация готовности
        //Основной цикл
  while(1) {
       asm clrwdt;                       //Сброс сторожевого таймера
       if(sysFlags.usb_on == ON)         //Если USB включен
          USB_StateInit();               //Определение состояние USB
       ////////////////////////////////////////////////////////////////
       //////Переключение с ПК на плату и включение платы//////////////
       if(button(&PORTC, RC7, 200, 0)){          //Если включение сработало
           if(sysFlags.kbBtn_mode == KBBTN_10) LED_PIN = 1;  //Зажигаем светодиод в случае если не используется 11й вывод на кнопки
           if(keycode[0] == KEY_L_CTRL){         //Если зажат левый CTRL и при этом сработал ключ
              SendPassword(PASS_START_ADDR);     //Запускается функция введения сохраненного пароля
              delay_ms(9000);                    //Тупим чтобы небыло много срабатываний и случайного перехода на плату
           } else {                              //Если левый CTRL не нажат то выполняется переход на плату
              Reset_PS2();                       //Сброс клавиатуры
              PWR5 = 1;                          //Включить 5В питание платы
              VIDEO_PIN = 1;                     //Переключить монитор на плату
              sysFlags.if_pc = 1;                //Запоминаем что мы на плате
           }
           delay_ms(1000);
           LED_PIN = 0;                          //Гасим светодиод
        }
        /////////////////////////////////////////////////////////////////////////////////
        ///Получение OUT репортов от хоста (Управление светодиодами клавиатуры)//////////
        if(USBFlags.hid_rec == 1){
           USBFlags.hid_rec = 0;
           PS2_Send(SET_KEYB_INDICATORS);
           delay_ms(10);
           PS2_Send(USB_GetLEDs());
           USB_ReceiveBuffSet();             // Prepere buffer for reception of next packet
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
                             sysConfig |= 1;
                             EEPROM_Write(SYS_CONF_ADDR,sysConfig);
                             sysFlags.kb_mode = 1;
                       //      memset(keycode, 0, 6);                        //Очищаем буфер кнопок чтобы исключить ошибки в переназначениях
                             kybCnt = KYBCNT_DELAY;
                             uart_write(RDR_PRG_END);
                           }
                         } break;
           case KEY_NUM_ENTR : if(sysFlags.kb_mode == 1){                  //Обработка переключения на клавиатуру
                                 if(--kybCnt == 0){
                                    sysConfig &= ~1;
                                    EEPROM_Write(SYS_CONF_ADDR,sysConfig);
                                    sysFlags.kb_mode = 0;
                        //            memset(keycode, 0, 6);                 //Очищаем буфер кнопок чтобы исключить ошибки в переназначениях
                                    kybCnt = KYBCNT_DELAY;
                                    uart_write(RDR_PRG_END);
                                 }
                               } break;
           default : kybCnt = KYBCNT_DELAY; break;                       //Сброс счетчика если кнопка отпущена или нажата другая кнопка
        }
        //
        ///Проверка ввода фразы программирования ключей
        //
        if(ArrCmp(&progPass, &progStr, (PASS_BUFF_SIZE - (sizeof(progStr)+1)), sizeof(progStr))){
           switch(progPass[PASS_BUFF_SIZE-1]){
              case KEY_1: UART1_Write(RDR_PRG_CH1); break;   //программирование1 - кредитный
              case KEY_2: UART1_Write(RDR_PRG_CH2); break;   //программирование2 - сьемный
              case KEY_3: UART1_Write(RDR_PRG_CH3); break;   //программирование3 - овнер
              case KEY_4: UART1_Write(RDR_PRG_CH4); break;   //программирование4 - админ
              case KEY_0: EEPROM_Write(0xFF,0xFF);           //Переход в режим бутлодера
                          USBEN_bit = 0;                     //Выключение HID устройства
                          delay_ms(10);                      //Задержка для ПК, чтобы успел отключить
                          asm RESET; break;                  //Сброс МК
              case KEY_P: uart_write(RDR_PRG_END);           //Вход в режим программирования пароля, пикаем разок
                          sysFlags.wr_pass = 1;              //устанавливаем соответствующий флаг
                          memset(progPass, 0, PASS_BUFF_SIZE);//очищаем массив ввода пароля
                          PS2_Send(SET_KEYB_INDICATORS);     //Зажигаем на клавиатуре светодиод SCR LOCK
                          delay_ms(10);
                          PS2_Send(SET_SCRL_LED);
                          break;
              case KEY_U: uart_write(RDR_PRG_END);            //Активация интерфейса USB, пикаем
                          sysConfig &= ~(1<<1);               //Заносим бит конфигурации в переменную
                          EEPROM_write(SYS_CONF_ADDR,sysConfig);//Пишем новую конфигурацию в EEPROM
                          delay_ms(10);
                          asm RESET;                           //Перезагружаем контроллер
                          break;
              case KEY_E: sysConfig |= (1<<2);                 //Активация 11й кнопки, занесение в переменную конфигурации
                          EEPROM_write(SYS_CONF_ADDR, sysConfig);//Запись новой конф. в EEPROM
                          sysFlags.kbBtn_mode = 1;             //Устанавливаем соотв. флаг
                          uart_write(RDR_PRG_END);             //Пикаем по завершению
                          break;
              default: break;
           }
           progPass[PASS_BUFF_SIZE-2] = 0;                  //Сброс ввода фразы
        }
        //
        ///Проверка ввода фразы удаления ключей
        //
        else if(ArrCmp(&progPass, &delStr, PASS_BUFF_SIZE - sizeof(delStr) - 1, sizeof(delStr))){
           switch(progPass[PASS_BUFF_SIZE-1]){
              case KEY_1: UART1_Write(RDR_CLR_CH1); break;   //Удаление1 - кредитный
              case KEY_2: UART1_Write(RDR_CLR_CH2); break;   //Удаление2 - сьемный
              case KEY_3: UART1_Write(RDR_CLR_CH3); break;   //Удаление3 - овнер
              case KEY_4: UART1_Write(RDR_CLR_CH4); break;   //Удаление4 - админ
              case KEY_5: UART1_Write(RDR_CLR_ALL); break;   //Удаление5 - всех ключей
              case KEY_P: EEPROM_ClearPassword(PASS_START_ADDR, PASS_BUFF_SIZE); //Удаление пароля ввода
                          uart_write(RDR_PRG_END);            //Пикаем по завершении
                          break;
              case KEY_U: uart_write(RDR_PRG_END);            //Деактивация USB интерфейса
                          sysConfig |= (1<<1);                //Подготавливаем новый конфиг
                          EEPROM_write(SYS_CONF_ADDR, sysConfig);//и пишем в EEPROM
                          USBEN_bit = 0;                     //Выключение HID устройства
                          delay_ms(10);
                          asm RESET;                         //Перезапускаем контроллер
                          break;
              case KEY_E: sysConfig &= ~(1<<2);              //Деактивация 11й кнопки, подг. конфиг
                          EEPROM_write(SYS_CONF_ADDR, sysConfig);//Пишем в EEPROM
                          sysFlags.kbBtn_mode = 0;           //Сбрасываем соответствующий флаг
                          uart_write(RDR_PRG_END);           //Пикаем по завершении
                          break;
              default: break;
           }
           progPass[PASS_BUFF_SIZE-2] = 0;                    //Сброс ввода фразы
        }
        ////////////////////////////////////////////////////////////////////////////
        //Запись пароля шифрования
        ///////////////////////////////////////////////////////////////////////////
        if(sysFlags.wr_pass == 1 && keycode[0] == KEY_ENTER){            //Если установлен флаг записи пароля и нажата кнопка ENTER
                                                                         //выполняется процедура сохранения фразы пароля в память EEPROM
           passCnt = PASS_BUFF_SIZE-1;                                   //Счетчику символов присваевается максимальное колличество символов
           while(progPass[passCnt] != 0 && passCnt >= 0) passCnt--;      //Определяется сколько символов введено (вернее сколько осталось пустых ячеек)
           if(passCnt != PASS_BUFF_SIZE-1){                              //Если введен хотябы один символ происходит сохранение его в память
              EEPROM_ClearPassword(PASS_START_ADDR, PASS_BUFF_SIZE);     //Выполняется очистка старого пароля
              EEPROM_SavePassword(&progPass+(passCnt+1), PASS_BUFF_SIZE - (passCnt+1), PASS_START_ADDR);//Сохраняется новый пароль
              PS2_Send(SET_KEYB_INDICATORS);                             //Гасим светодиоды клавиатуры
              delay_ms(10);
              PS2_Send(SET_OFF_LED);
              uart_write(RDR_PRG_END);                                   //Разок пикаем
           } else {                                                      //Если не введено ни одного символа
              PS2_Send(SET_KEYB_INDICATORS);                             //Включаем все светодиоды
              delay_ms(10);
              PS2_Send(SET_NUM_LED | SET_CAPS_LED | SET_SCRL_LED);
              delay_ms(1000);                                            //ждем секунду
              PS2_Send(SET_KEYB_INDICATORS);                             //Гасим все светодиоды
              delay_ms(10);
              PS2_Send(SET_OFF_LED);
              uart_write(RDR_PRG_END);                                   //Пикаем два раза
              delay_ms(600);
              uart_write(RDR_PRG_END);
           }
           sysFlags.wr_pass = 0;                                         //сбрасываем флаг записи пароля
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
               SendKeys(&keycode, modifier);          //Отправка кнопок клавиатуры
               if(keycode[0] == 0){                   //Если нет не одной нажатой кнопки
                  USBFlags.upBtn == 1;                //Устанавливаем флаг отпущенных кнопок
                  SendNoKeys();                       //Отправляем нули (нет нажатой кнопки)
               }
             }
           }
         delay_ms(30);
     }
  }
}