#include <stdint.h>
#include "kb.h"
#include "Scancodes.h"

extern uint8_t keycode[6];
extern uint8_t modifier;
extern uint8_t progPass[PASS_BUFF_SIZE];

uint8_t bitcount;                              //Счетчик количества принятых бит
uint8_t keyCnt;                                //Колличество нажатых клавишь
uint8_t kbWriteBuff;                           //Буфер отправки команды клавиатуре

struct SFLG{                                   //Структура флагов, аналогичная инициализация находится в файле kb.c
   unsigned if_pc: 1;                          //0 = компьютер 1 = плата
   unsigned kb_mode: 1;                        //0 = стандартная клавиатура, 1 = консоль
} sysFlags at CVRCON;                          //Флаги сохряняются в регистре CVRCON настроек компаратора который не используется

struct KFLG{
   unsigned if_conf  : 1;                      //флаг сконфигурированой клавиатуры
   unsigned if_func  : 1;                      //Флаг функциональной кнопки
   unsigned if_up    : 1;                      //Флаг отпускания кнопки
   unsigned kb_rw    : 1;                      //0 = прием данных 1 = передача в клавиатуру
   unsigned kb_parity: 1;                      //Бит четности для отправки данных в клавиатуру
} keyFlags at ADRESH;

struct KYB{
   unsigned kbMode:  4;                        //Состояние клавиатуры
   unsigned request: 4;                        //Ответ от клавиатуры
} KYBState = {0};
//==================================================================================
//=============Функия инициализации клавиатуры======================================
//==================================================================================
void Init_PS2(void){
     uint8_t i;
     bitcount = 11;                                   //Установка количества бит
     
     INTCON2.INTEDG1 = 0;       //int1 falling edge   // 0 = falling edge 1 = rising edge
     INTCON3.INT1IF = 0;                              // INT1 clear flag
     INTCON3 |= (1<<INT1IP)|(1<<INT1IE);              //INT1 Hight priority, intrrupt enable,
     
     TMR2IP_bit = 1;                                  //TIMER2 LOW priority
     TMR2IF_bit = 0;                                  //TIMER2 clear flag
     T2CON = (1<<T2OUTPS3)|(1<<T2OUTPS1)|(1<<T2OUTPS0)|(1<<T2CKPS0);
     PR2 = 250;

     TMR2IE_bit = 1;                                  //timer2 int. enable

     for(i=0; i<=5; i++) keycode[i] = 0;              //Инициализируем переменную с кнопками

     keyCnt = 0;                                      //Сброс количества нажатых кнопок
     ADRESH = 0;                                      //Переназначеный регистр флагов сбрасываем в 0
}
//==================================================================================
//=============Функия сброса данных в случае ошибки=================================
//==================================================================================
void Reset_timeuot (void){
     TMR2ON_bit = 0;                                   //Остановить таймер
     TMR2IF_bit = 0;                                   //TIMER0 clear flag
     PR2 = 250;                                        //TIMER0 preload (1ms)
}
////////////////////////////////////////////////////////////////////////////////////
//////////////Сброс клавиатуры и получение конфигурации/////////////////////////////
uint8_t Reset_PS2(void){
     uint8_t timeout = 10;                                    //Время ожидания ответа  300 + 10*timeout (ms)

     PS2_Send(0xFF);
     delay_ms(300);
     while(timeout != 0){
        if(KYBState.request == KYB_FLAG_CMPSUCCES){
           KYBState.kbMode = KEYB_MODE_CONFIGURED;
           return 1;
        } else if (KYBState.request == KYB_FLAG_FAILURE){
           KYBState.kbMode = KEYB_MODE_ERROR;
           return 0;
        }
        timeout--;
        delay_ms(10);
     }
     KYBState.kbMode = KEYB_MODE_NOTCONFIGURE;
     KYBState.request = KYB_FLAG_NORESPONSE;
     return 0;
}
////////////////////////////////////////////////////////////////////////////////////
/////////////////////////Получение данных о конфигурации клавиатуры/////////////////
/*uint8_t GetState_PS2 (void){
 return  KYBState.kbMode >> 4;
}*/
//==================================================================================
//=============Функция расчета четности бит для отправки команд=====================
//==================================================================================
uint8_t parity(uint8_t x){        //Тут все просто - побитовый XOR
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
static uint8_t keyData;                                  // Holds the received scan code
  if(INTCON3.INT1IE == 1 && INTCON3.INT1IF == 1){
    INTCON3.INT1IF = 0;                                       //Срос флага прерывания
    TMR2ON_bit = 1;                                           //Enable timeout timer
   if(keyFlags.kb_rw == 0){
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
          KEYB_DATA = keyFlags.kb_parity;                      //Запись в порт бита четности (Вычисляется на этапе формирования посылки)
          bitcount --;
        } else if(bitcount == 1){                              //Условие передачи СТОП бита
          KEYB_DATA = 1;                                       //Шлем 1 в порт
          bitcount --;
        } else if(bitcount == 0){                              //Условие конца передачи команды
          bitcount = 11;                                       //Сбрасываем счетчик бит
          TRISA.RA4 = 1;                                       //Переводим пин data на вход
          keyFlags.kb_rw = 0;                                  //Сбрасываем флаг передачи команды
          Reset_timeuot();                                     //Сбрасываем таймаут посылки
        /*
          В завершающем блоке имеется один нюанс. В случае если по каким либо причинам клавиатура
          не приймет конец посылки она зацыклится на передаче сигнала CLOCK по линии, что приведет
          к зависанию клавиатуры и таймаут тут не спасет по пречине его нормального сброса.
          Таких моментов при нормальной работе устройст не замечено но в тиории
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
uint8_t PS2_Send(uint8_t sData){
   if(bitcount == 11){                  //Проверка отсутствия приема кода от клавиатуры
      kbWriteBuff = sData;
      keyFlags.kb_parity = parity(kbWriteBuff);
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
      keyFlags.kb_rw = 1;               //Устанавливаем флаг передачи данных в клавиатуру
      bitcount = 10;                    //Сбрасываем счетчик бит
      INTCON3.INT1IF = 0;               //Сбрасываем флаг прерывания перед началом работы
      INTCON3.INT1IE = 1;               //Разрешаем прерывания по Clock и идем в прерывание
      TMR2ON_bit = 1;                   //Enable timeout timer
      return 1;
   } else return 0;
}
//==================================================================================
//=============Обработчик прерывания по таймауту приема данных======================
//==================================================================================
void PS2_Timeout_Interrupt(){
     if(TMR2IF_bit){
        Reset_timeuot();
        if(keyFlags.kb_rw == 1) {
           keyFlags.kb_rw = 0;
           kbWriteBuff = 0; 
           KEYB_DATA = 1;
           TRISA.RA4 = 1;
        }
        bitcount = 11;
     }
}
//==================================================================================
//=============Функия поиска нажатой клавиши========================================
//==================================================================================
uint8_t inArray(uint8_t value){               //Поиск значениея в массиве
     uint8_t i;
     for(i=0; i<=5; i++){                     //Поиск выполняется по массиву keycode
         if(keycode[i] == value){             //Если находит возвращает позицию + 1
            return i+1;
         }
     }
     return 0;                                //В противном случае возврат 0
}
//==================================================================================
//=============Функия обработки клавишь для платы===================================
//==================================================================================
void Set_BRDButton (uint8_t key, uint8_t upDown){
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
//   Данная функция при каждом нажатии на клавишу клавиатуры (символьную) записывает
// сканкод в массив для использования инициализации программирования ключей и прочего.
// Данный масив используется и для сохранения пароля шифрования. Для оптимизации кода
// и ресурсов МК так как максимальный сканкод 0х27 и не использует старший бит.
// В связи с этим 8й бит указывает на наличие нажатия кнопки shift.
//==================================================================================
void SetPass (uint8_t key){
  uint8_t i;
  
  for(i=0; i<PASS_BUFF_SIZE; i++){          //При нажатии кнопки массив пароля сдвигается
     progPass[i] = progPass[i+1];           //на позицию вперед
  }
  if((modifier & 0x22) != 0)                     //Если нажат левый или правый shift
      progPass[PASS_BUFF_SIZE-1] = key | 0x80;    //в конец дописывается код нажатой кнопки и бита shift
  else
      progPass[PASS_BUFF_SIZE-1] = key;
}
//==================================================================================
//=============Функия обработки данных от клавиатуры================================
//==================================================================================
void KeyDecode(uint8_t sc){
static uint8_t keyPos;           //Позиция уже нажатой кнопки в массиве keycode
uint8_t i, key=0;                //Буферная переманная кода клавиши
////////////////////////////////////////////////////////////////////////////////////
//////////////////////////Начало обработки кнопок///////////////////////////////////
    switch(sc){
    case KEYB_FUNC_CODE        : keyFlags.if_func = 1; break;                   //Устанавливаем флаг функциональной кнопки если пришел ее код
    case KEYB_BREAK_CODE       : keyFlags.if_up = 1; break;                     //Устанавливаем флаг если кнопка отпущена
    case KEYB_COMPLETE_SUCCESS : KYBState.request =  KYB_FLAG_CMPSUCCES; break;//Ответ клавиатуры об удачной конфигурации
    case KEYB_RESEND           : KYBState.request =  KYB_FLAG_RESEND; break;     //Запрос клавиатуры на повторную отправку команды
    case KEYB_FAILURE          : KYBState.request =  KYB_FLAG_FAILURE; break;//Ошибка устройства
    case KEYB_ACKNOWLEDGE      : KYBState.request =  KYB_FLAG_ACKNOWLEDGE; break;//Подтверждение получения команды
    default :  if(sc > 0 && sc < 0x84){                                //Проверка что нажата кнопка а не сервисные данные
                if(keyFlags.if_func == 1){                             //Если была нажата функциональная кнопка
                    for(i=0; i<sizeof(funCode)/2; i++){                //Перебераем HID сканкод из массива соответствия
                       if(funCode[i][0] == sc){
                          key = funCode[i][1];                         //Если такой код имеется то записываем его в буферную переменную
                         break;                                        //и выходим с цикла
                       }
                    }
                    keyFlags.if_func = 0;                              //В противном случае просто сбрасываем флаг
                } else {
                    key = scanCode[sc];                       //Если была нажата простая кнопка то записываем код из массива простых кнопок
                }
                if(key>1){
                                                    //Далее проверяем если нажатая клавиша соответствует HID коду
                  ///////////////////////////////////////////////////////////////
                  ////////Блок обработки нажатий клавиш CtrlShiftAltWin//////////
                  if(key >= 0xE0 && key <= 0xE7){//Проверяем если прийшли данные от кнопок CtrlShiftAltWin
                     if(keyFlags.if_up == 1){                          //Проверяем если одна из кнопок была отжата
                        modifier &= ~dvFlags[key & 0x0F];     //Если так то убираем соответствующий флаг
                     } else                                    //Далее проверяем если нажатая клавиша соответствует HID коду
                     modifier |= dvFlags[key & 0x0F];
                  } /////////////////////////////////////////////////////////////
                  ////////Далее идет обычная обработка кнопок////////////////////
                  keyPos = inArray(key);          //Проверяем есть ли эта кнопка уже в массиве
                  if(keyPos){                     //Если есть проверяем не отпущена ли кнопка
                    if(keyFlags.if_up){                             //Если отпущена
                       if(sysFlags.if_pc == 1)  Set_BRDButton(key, 0);
                       for(i=keyPos-1; i<5; i++){          //изьять элемент из массива и выполнить сдвих
                          keycode[i] = keycode[i+1];
                          }
                       keyCnt--;                            //Инкрементировать щетчик кнопок
                       keyFlags.if_up = 0;                           //Сбросить флаг отпущеной кнопки
                    }
                  //--------------------------------------------------------------------------
                  }else if(keyCnt<6){                      //Если не отпущена то добавляем и инкрементируем массив
                    keycode[keyCnt] = key;
                    keyCnt++;
                    if(sysFlags.if_pc == 1) Set_BRDButton(key, 1);
                    if(key >= KEY_A && key <= KEY_0){         //Проверка ввода только символов
                       SetPass(key);                          //Обработчик ввода пароля программирования и удаления ключей с клавиатуры
                    }
                  }
                }
                for (i=keycnt; i<=5; i++){                  //Остальное забиваем нулями
                    keycode[i] = 0;
                }
              }  //-------------------------
              break;
    }
}