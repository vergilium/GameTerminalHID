#include "kb.h"
#include "Scancodes.h"

unsigned char bitcount;                              //Счетчик количества принятых бит
unsigned char keyCnt;                                //Колличество нажатых клавишь
unsigned char kbWriteBuff;                           //Буфер отправки команды клавиатуре
extern unsigned char keycode[6];
extern unsigned char modifier;
extern unsigned char progPass[16];

struct FLG{
   unsigned if_pc: 1;
   unsigned if_func: 1;                             //Флаг функциональной кнопки
   unsigned if_up: 1;                               //Флаг отпускания кнопки
   unsigned kb_mode: 1;
   unsigned kb_rw: 1;                               //0 = прием данных 1 = передача в клавиатуру
   unsigned kb_parity: 1;                           //Четность переданого байта клавиатуре
} sysFlags at CVRCON;

//==================================================================================
//=============Функия инициализации клавиатуры======================================
//==================================================================================
void init_kb(void){
     unsigned char i;
     bitcount = 11;                                   //Сброс счетчика бит
     
     INTCON2.INTEDG1 = 0;       //int1 falling edge   // 0 = falling edge 1 = rising edge
     INTCON3.INT1IF = 0;                              // INT1 clear flag
     INTCON3 |= (1<<INT1IP)|(1<<INT1IE);              //INT1 Hight priority, intrrupt enable,
     
     INTCON2.TMR0IP = 0;                              //TIMER0 LOW priority
     T0CON = (1<<TMR0ON)|(1<<T08BIT)|(0<<T0CS)|(0<<PSA)|(1<<T0PS2)|(1<<T0PS1)|(1<<T0PS0);
     TMR0L =  209;
     INTCON.TMR0IF = 0;                               //TIMER0 clear flag

     INTCON  |= (1<<TMR0IE);     //timer0 int. enable
     for (i=0; i<=5; i++){                          //Инициализируем переменную с кнопками
        keycode[i] = 0;
     }
     keyCnt = 0;                                    //Сброс счетчика нажатых кнопок
     CVRCON = 0;                                    //Переназначеный регистр флагов сбрасываем в 0
}
//==================================================================================
//=============Функия сброса данных в случае ошибки=================================
//==================================================================================
void Reset_timeuot (void){
     TMR0L =  209;                                    //TIMER0 preload 209 (1ms)
     INTCON.TMR0IF = 0;                               //TIMER0 clear flag
     T0CON.TMR0ON = 0;                                //Остановка таймера
}
//==================================================================================
//=============Функция расчета четности бит для отправки команд=====================
//==================================================================================
unsigned char parity(unsigned char x){        //Тут все просто - побитовый XOR
x ^= x >> 8;
x ^= x >> 4;
x ^= x >> 2;
x ^= x >> 1;
return ~(x & 1);
}
//==================================================================================
//=============Обработчик прерывания по поступлению данных или отправка команд======
//==================================================================================
void PS2_interrupt(void) {
static unsigned char keyData;                                  // Holds the received scan code
  if(INTCON3.INT1IE == 1 && INTCON3.INT1IF == 1){
    INTCON3.INT1IF = 0;                                       //Срос флага прерывания
    T0CON.TMR0ON = 1;                                          //Запуск таймера таймаута
   if(sysFlags.kb_rw == 0){
    if (INTCON2.INTEDG1 == 0){                                 // Routine entered at falling edge
         if(bitcount < 11 && bitcount > 2) {                   // Bit 3 to 10 is data. Parity bit, start and stop bits are ignored.
            keyData = keyData >> 1;
            if(KEYB_DATA == 1)
               keyData = keyData | 0x80;                       // Store a ’1’
         }
         INTCON2.INTEDG1 = 1;                                  //int1 rising edge
     } else {                                                  // Routine entered at rising edge
         INTCON2.INTEDG1 = 0;                                  //int1 falling edge
         if(--bitcount == 0){                                  // All bits received
            Reset_timeuot();                                  //Disable timeout timer
            KeyDecode(keyData);
            bitcount = 11;
         }
     }
   }else {
   /////////////////////////////////////////////////////////////////////////////////////
   ////////////////////////////Блок отправки команд в клавиатуру////////////////////////
      if (INTCON2.INTEDG1 == 0){                               //Проверяем условие что прерывание по спадающему фронту
        if(bitcount > 2 && bitcount <= 10){                    //Отправляем байт кода команды
          KEYB_DATA = kbWriteBuff & 1;                         //Выставляем младший бит в порт
          kbWriteBuff = kbWriteBuff >> 1;                      //Сдвигаем байт на 1 в право для перехода на следующий бит
          bitcount --;                                         //Инкрементируем счетчик битов
        } else if(bitcount == 2){                              //Условие передачи бита четности
          KEYB_DATA = sysFlags.kb_parity;                      //Запись в порт бита четности (Вычисляется на этапе формирования посылки)
          bitcount --;
        } else if(bitcount == 1){                              //Условие передачи СТОП бита
          KEYB_DATA = 1;                                       //Шлем 1 в порт
          bitcount --;
        } else if(bitcount == 0){                              //Условие конца передачи команды
          bitcount = 11;                                       //Сбрасываем счетчик бит
          TRISA.RA4 = 1;                                       //Переводим пин data на вход
          sysFlags.kb_rw = 0;                                  //Сбрасываем флаг передачи команды
          Reset_timeuot();                                     //Сбрасываем таймаут посылки
        /*
          В завершающем блоке имеется один нюанс. В случае если по каким либо причинам клавиатура
          не приймет конец посылки она зацыклится на передаче сигнала CLOCK по линии, что приведет
          к зависанию клавиатуры и таймаут тут не спасет по пречине его нормального сброса.
          Таких моментов при нормальной работе устройства не замечено но в тиории
          возможно. Лечится перезапуском клавиатуры или всей системы.
        */
        }
       }
   ///////////////////////////////////////////////////////////////////////////////////////
   }
  }
}
//==================================================================================
//=============Функция формирования передачи команды клавиатуре=====================
//==================================================================================
unsigned char PS2_Send(unsigned char sData){
   if(bitcount == 11){                  //Проверка отсутствия приема кода от клавиатуры
      kbWriteBuff = sData;
      sysFlags.kb_parity = parity(kbWriteBuff); //Определение четности отправляемого байта
//////////////////////////Формирование стартовой последовательности/////////////////////
      INTCON3.INT1IE = 0;               //Запрещаем прерывание от клавиатуры
      KEYB_CLOCK = 0;                    //Устанавливаем Clock в 0
      KEYB_DATA = 1;                    //Устанавливаем Data в 1
      TRISB.RB1 = 0;                    //Переводим пин clock на вывод
      TRISA.RA4 = 0;                    //Переводим пин data на вывод
      delay_ms(100);                    //Ждем 100мс
      KEYB_DATA = 0;                    //Устанавливаем Data в 0
      delay_ms(1);                      //Задержка для СТОП бита
      KEYB_CLOCK = 1;                   //Подымаем КЛОК в лог 1
      TRISB.RB1 = 1;                    //Переводим Clock на вход
      sysFlags.kb_rw = 1;               //Устанавливаем флаг передачи данных в клавиатуру
      bitcount = 10;                    //Сбрасываем счетчик бит
      INTCON3.INT1IF = 0;               //Сбрасываем флаг прерывания перед началом работы
      INTCON3.INT1IE = 1;               //Разрешаем прерывания по Clock и идем в прерывание
      return 1;                         //Если все удачно возвращаем 1
   } else return 0;                     //Если нет то возвращаем 0
}
//==================================================================================
//=============Обработчик прерывания по таймауту приема данных======================
//==================================================================================
void PS2_Timeout_Interrupt(){
     if(INTCON.TMR0IE && INTCON.TMR0IF){           //Если сработал таймаут все сбрасываем
        if(sysFlags.kb_rw == 1) { sysFlags.kb_rw = 0; kbWriteBuff = 0; }
        bitcount = 11;
        Reset_timeuot();                           //И стопорим таймер таймаута
     }
}
//==================================================================================
//=============Функия поиска нажатой клавиши========================================
//==================================================================================
unsigned char inArray(unsigned char value){               //Поиск значениея в массиве
     unsigned char i;
     for(i=0; i<=5; i++){                                 //Поиск выполняется по массиву keycode
         if(keycode[i] == value){                         //Если находит возвращает позицию + 1
            return i+1;
         }
     }
     return 0;                                            //В противном случае возврат 0
}
//==================================================================================
//=============Функия обработки клавишь для платы===================================
//==================================================================================
void Set_BRDButton (unsigned char key, unsigned char upDown){
       switch (key){
          case KEY_F5    : if(sysFlags.kb_mode == 0) break;
          case KEY_1     :
          case KEY_NUM_1 : BT_STOP1 = upDown; LED_PIN = upDown; break;
          case KEY_F6    : if(sysFlags.kb_mode == 0) break;
          case KEY_2     :
          case KEY_NUM_2 : BT_STOP2 = upDown;  LED_PIN = upDown; break;
          case KEY_F7    : if(sysFlags.kb_mode == 0) break;
          case KEY_3     :
          case KEY_NUM_3 : BT_STOP3 = upDown;  LED_PIN = upDown; break;
          case KEY_F8    : if(sysFlags.kb_mode == 0) break;
          case KEY_4     :
          case KEY_NUM_4 : BT_STOP4 = upDown;  LED_PIN = upDown; break;
          case KEY_F9    : if(sysFlags.kb_mode == 0) break;
          case KEY_5     :
          case KEY_NUM_5 : BT_STOP5 = upDown;  LED_PIN = upDown; break;
          case KEY_F10    : if(sysFlags.kb_mode == 0) break;
          case KEY_7     :
          case KEY_NUM_7 : BT_LINE = upDown;  LED_PIN = upDown; break;
          case KEY_F11    : if(sysFlags.kb_mode == 0) break;
          case KEY_8     :
          case KEY_NUM_8 : BT_BET = upDown;  LED_PIN = upDown; break;
          case KEY_9     :
          case KEY_NUM_9 : BT_INFO = upDown;  LED_PIN = upDown; break;
          case KEY_0     :
          case KEY_NUM_0 : BT_MENU = upDown;  LED_PIN = upDown; break;
          case KEY_F12   : if(sysFlags.kb_mode == 0) break;
          case KEY_ENTER :
          case KEY_SPACE :
          case KEY_NUM_ENTR: BT_START = upDown;  LED_PIN = upDown; break;
          case KEY_F3    : if(sysFlags.kb_mode == 0) break;
          case KEY_ESC   :
          case KEY_HOME  : sysFlags.if_pc = 0; break;           //Кнопками Esc и Home происходит выход с режима плата
          default : break;
       }
}
//==================================================================================
//=============Функия ввода пароля с клавиатуры=====================================
//==================================================================================
void SetPass (unsigned char key){
  unsigned char i;
  for(i=0; i<17; i++){
     progPass[i] = progPass[i+1];
  }
  progPass[16] = key;
}
//==================================================================================
//=============Функия обработки данных от клавиатуры================================
//==================================================================================
void KeyDecode(unsigned char sc){
static unsigned char keyPos;           //Позиция уже нажатой кнопки в массиве keycode
unsigned char i, key=0;                //Буферная переманная кода клавиши
/////////////////////////////////////////////
////////Начало обработки кнопок///////////////
    switch(sc){
    case 0xE0 : sysFlags.if_func = 1; break;                           //Устанавливаем флаг функциональной кнопки если пришел ее код
    case 0xF0 : sysFlags.if_up = 1; break;                             //Устанавливаем флаг если кнопка отпущена
    default :  if(sc > 0 && sc < 0x84){                       //Проверка что нажата кнопка а не сервисные данные
                if(sysFlags.if_func == 1){                             //Если была нажата функциональная кнопка
                    for(i=0; i<sizeof(funCode)/2; i++){       //Перебераем HID сканкод из массива соответствия
                       if(funCode[i][0] == sc){
                          key = funCode[i][1];                //Если такой код имеется то записываем его в буферную переменную
                         break;                               //и выходим с цикла
                       }
                    }
                    sysFlags.if_func = 0;                              //В противном случае просто сбрасываем флаг
                } else {
                    key = scanCode[sc];                       //Если была нажата простая кнопка то записываем код из массива простых кнопок
                }
                if(key>1){
                                                    //Далее проверяем если нажатая клавиша соответствует HID коду
                  ///////////////////////////////////////////////////////////////
                  ////////Блок обработки нажатий клавиш CtrlShiftAltWin//////////
                  if(key >= 0xE0 && key <= 0xE7){//Проверяем если прийшли данные от кнопок CtrlShiftAltWin
                     if(sysFlags.if_up == 1){                          //Проверяем если одна из кнопок была отжата
                        modifier &= ~dvFlags[key & 0x0F];     //Если так то убираем соответствующий флаг
                     } else                                    //Далее проверяем если нажатая клавиша соответствует HID коду
                     modifier |= dvFlags[key & 0x0F];
                  } /////////////////////////////////////////////////////////////
                  ////////Далее идет обычная обработка кнопок////////////////////
                  keyPos = inArray(key);          //Проверяем есть ли эта кнопка уже в массиве
                  if(keyPos){                     //Если есть проверяем не отпущена ли кнопка
                    if(sysFlags.if_up){                             //Если отпущена
                       if(sysFlags.if_pc == 1)  Set_BRDButton(key, 0);
                       for(i=keyPos-1; i<5; i++){          //изьять элемент из массива и выполнить сдвих
                          keycode[i] = keycode[i+1];
                          }
                       keyCnt--;                            //Инкрементировать щетчик кнопок
                       sysFlags.if_up = 0;                           //Сбросить флаг отпущеной кнопки
                    }
                  //--------------------------------------------------------------------------
                  }else if(keyCnt<6){                      //Если не отпущена то добавляем и инкрементируем массив
                    keycode[keyCnt] = key;
                    keyCnt++;
                    if(sysFlags.if_pc == 1) Set_BRDButton(key, 1);
                    SetPass(key);                          //Обработчик ввода пароля программирования и удаления ключей с клавиатуры
                  }
                }
                for (i=keycnt; i<=5; i++){                  //Остальное забиваем нулями
                    keycode[i] = 0;
                }
              }  //-------------------------
              break;
    }
}