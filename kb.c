#include <stdint.h>
#include "kb.h"
#include "Scancodes.h"

extern uint8_t keycode[6];
extern uint8_t modifier;
extern uint8_t progPass[PASS_BUFF_SIZE];

uint8_t bitcount;                              //������� ���������� �������� ���
uint8_t keyCnt;                                //����������� ������� �������
uint8_t kbWriteBuff;                           //����� �������� ������� ����������

struct SFLG{                                   //��������� ������, ����������� ������������� ��������� � ����� kb.c
   unsigned if_pc: 1;                          //0 = ��������� 1 = �����
   unsigned kb_mode: 1;                        //0 = ����������� ����������, 1 = �������
} sysFlags at CVRCON;                          //����� ����������� � �������� CVRCON �������� ����������� ������� �� ������������

struct KFLG{
   unsigned if_conf  : 1;                      //���� ����������������� ����������
   unsigned if_func  : 1;                      //���� �������������� ������
   unsigned if_up    : 1;                      //���� ���������� ������
   unsigned kb_rw    : 1;                      //0 = ����� ������ 1 = �������� � ����������
   unsigned kb_parity: 1;                      //��� �������� ��� �������� ������ � ����������
} keyFlags at ADRESH;

struct KYB{
   unsigned kbMode:  4;                        //��������� ����������
   unsigned request: 4;                        //����� �� ����������
} KYBState = {0};
//==================================================================================
//=============������ ������������� ����������======================================
//==================================================================================
void Init_PS2(void){
     uint8_t i;
     bitcount = 11;                                   //��������� ���������� ���
     
     INTCON2.INTEDG1 = 0;       //int1 falling edge   // 0 = falling edge 1 = rising edge
     INTCON3.INT1IF = 0;                              // INT1 clear flag
     INTCON3 |= (1<<INT1IP)|(1<<INT1IE);              //INT1 Hight priority, intrrupt enable,
     
     TMR2IP_bit = 1;                                  //TIMER2 LOW priority
     TMR2IF_bit = 0;                                  //TIMER2 clear flag
     T2CON = (1<<T2OUTPS3)|(1<<T2OUTPS1)|(1<<T2OUTPS0)|(1<<T2CKPS0);
     PR2 = 250;

     TMR2IE_bit = 1;                                  //timer2 int. enable

     for(i=0; i<=5; i++) keycode[i] = 0;              //�������������� ���������� � ��������

     keyCnt = 0;                                      //����� ���������� ������� ������
     ADRESH = 0;                                      //�������������� ������� ������ ���������� � 0
}
//==================================================================================
//=============������ ������ ������ � ������ ������=================================
//==================================================================================
void Reset_timeuot (void){
     TMR2ON_bit = 0;                                   //���������� ������
     TMR2IF_bit = 0;                                   //TIMER0 clear flag
     PR2 = 250;                                        //TIMER0 preload (1ms)
}
////////////////////////////////////////////////////////////////////////////////////
//////////////����� ���������� � ��������� ������������/////////////////////////////
uint8_t Reset_PS2(void){
     uint8_t timeout = 10;                                    //����� �������� ������  300 + 10*timeout (ms)

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
/////////////////////////��������� ������ � ������������ ����������/////////////////
/*uint8_t GetState_PS2 (void){
 return  KYBState.kbMode >> 4;
}*/
//==================================================================================
//=============������� ������� �������� ��� ��� �������� ������=====================
//==================================================================================
uint8_t parity(uint8_t x){        //��� ��� ������ - ��������� XOR
x ^= x >> 8;
x ^= x >> 4;
x ^= x >> 2;
x ^= x >> 1;
return ~(x & 1);
}
//==================================================================================
//=============���������� ���������� �� ����������� ������ ��� �������� ������======
//==================================================================================
void PS2_interrupt(void) {
static uint8_t keyData;                                  // Holds the received scan code
  if(INTCON3.INT1IE == 1 && INTCON3.INT1IF == 1){
    INTCON3.INT1IF = 0;                                       //���� ����� ����������
    TMR2ON_bit = 1;                                           //Enable timeout timer
   if(keyFlags.kb_rw == 0){
    if (INTCON2.INTEDG1 == 0){                                 // Routine entered at falling edge
         if(bitcount < 11 && bitcount > 2) {                   // Bit 3 to 10 is data. Parity bit, start and stop bits are ignored.
            keyData = keyData >> 1;
            if(KEYB_DATA == 1)
               keyData = keyData | 0x80;                       // Store a �1�
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
   ////////////////////////////���� �������� ������ � ����������////////////////////////
      if (INTCON2.INTEDG1 == 0){                               //��������� ������� ��� ���������� �� ���������� ������
        if(bitcount > 2 && bitcount <= 10){                    //���������� ���� ���� �������
          KEYB_DATA = kbWriteBuff & 1;                         //���������� ������� ��� � ����
          kbWriteBuff = kbWriteBuff >> 1;                      //�������� ���� �� 1 � ����� ��� �������� �� ��������� ���
          bitcount --;                                         //�������������� ������� �����
        } else if(bitcount == 2){                              //������� �������� ���� ��������
          KEYB_DATA = keyFlags.kb_parity;                      //������ � ���� ���� �������� (����������� �� ����� ������������ �������)
          bitcount --;
        } else if(bitcount == 1){                              //������� �������� ���� ����
          KEYB_DATA = 1;                                       //���� 1 � ����
          bitcount --;
        } else if(bitcount == 0){                              //������� ����� �������� �������
          bitcount = 11;                                       //���������� ������� ���
          TRISA.RA4 = 1;                                       //��������� ��� data �� ����
          keyFlags.kb_rw = 0;                                  //���������� ���� �������� �������
          Reset_timeuot();                                     //���������� ������� �������
        /*
          � ����������� ����� ������� ���� �����. � ������ ���� �� ����� ���� �������� ����������
          �� ������� ����� ������� ��� ���������� �� �������� ������� CLOCK �� �����, ��� ��������
          � ��������� ���������� � ������� ��� �� ������ �� ������� ��� ����������� ������.
          ����� �������� ��� ���������� ������ �������� �� �������� �� � ������
          ��������. ������� ������������ ���������� ��� ���� �������.
        */
        }
       }
   ///////////////////////////////////////////////////////////////////////////////////////
   }
  }
}
//==================================================================================
//=============������� ������������ �������� ������� ����������=====================
//==================================================================================
uint8_t PS2_Send(uint8_t sData){
   if(bitcount == 11){                  //�������� ���������� ������ ���� �� ����������
      kbWriteBuff = sData;
      keyFlags.kb_parity = parity(kbWriteBuff);
//////////////////////////������������ ��������� ������������������/////////////////////
      INTCON3.INT1IE = 0;               //��������� ���������� �� ����������
      KEYB_CLOCK = 0;                    //������������� Clock � 0
      KEYB_DATA = 1;                    //������������� Data � 1
      TRISB.RB1 = 0;                    //��������� ��� clock �� �����
      TRISA.RA4 = 0;                    //��������� ��� data �� �����
      delay_ms(100);                    //���� 100��
      KEYB_DATA = 0;                    //������������� Data � 0
      delay_ms(1);                      //�������� ��� ���� ����
      KEYB_CLOCK = 1;                   //�������� ���� � ��� 1
      TRISB.RB1 = 1;                    //��������� Clock �� ����
      keyFlags.kb_rw = 1;               //������������� ���� �������� ������ � ����������
      bitcount = 10;                    //���������� ������� ���
      INTCON3.INT1IF = 0;               //���������� ���� ���������� ����� ������� ������
      INTCON3.INT1IE = 1;               //��������� ���������� �� Clock � ���� � ����������
      TMR2ON_bit = 1;                   //Enable timeout timer
      return 1;
   } else return 0;
}
//==================================================================================
//=============���������� ���������� �� �������� ������ ������======================
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
//=============������ ������ ������� �������========================================
//==================================================================================
uint8_t inArray(uint8_t value){               //����� ��������� � �������
     uint8_t i;
     for(i=0; i<=5; i++){                     //����� ����������� �� ������� keycode
         if(keycode[i] == value){             //���� ������� ���������� ������� + 1
            return i+1;
         }
     }
     return 0;                                //� ��������� ������ ������� 0
}
//==================================================================================
//=============������ ��������� ������� ��� �����===================================
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
          case KEY_HOME  : sysFlags.if_pc = 0; break;           //�������� Esc � Home ���������� ����� � ������ �����
          default : break;
       }
}
//==================================================================================
//=============������ ����� ������ � ����������=====================================
//   ������ ������� ��� ������ ������� �� ������� ���������� (����������) ����������
// ������� � ������ ��� ������������� ������������� ���������������� ������ � �������.
// ������ ����� ������������ � ��� ���������� ������ ����������. ��� ����������� ����
// � �������� �� ��� ��� ������������ ������� 0�27 � �� ���������� ������� ���.
// � ����� � ���� 8� ��� ��������� �� ������� ������� ������ shift.
//==================================================================================
void SetPass (uint8_t key){
  uint8_t i;
  
  for(i=0; i<PASS_BUFF_SIZE; i++){          //��� ������� ������ ������ ������ ����������
     progPass[i] = progPass[i+1];           //�� ������� ������
  }
  if((modifier & 0x22) != 0)                     //���� ����� ����� ��� ������ shift
      progPass[PASS_BUFF_SIZE-1] = key | 0x80;    //� ����� ������������ ��� ������� ������ � ���� shift
  else
      progPass[PASS_BUFF_SIZE-1] = key;
}
//==================================================================================
//=============������ ��������� ������ �� ����������================================
//==================================================================================
void KeyDecode(uint8_t sc){
static uint8_t keyPos;           //������� ��� ������� ������ � ������� keycode
uint8_t i, key=0;                //�������� ���������� ���� �������
////////////////////////////////////////////////////////////////////////////////////
//////////////////////////������ ��������� ������///////////////////////////////////
    switch(sc){
    case KEYB_FUNC_CODE        : keyFlags.if_func = 1; break;                   //������������� ���� �������������� ������ ���� ������ �� ���
    case KEYB_BREAK_CODE       : keyFlags.if_up = 1; break;                     //������������� ���� ���� ������ ��������
    case KEYB_COMPLETE_SUCCESS : KYBState.request =  KYB_FLAG_CMPSUCCES; break;//����� ���������� �� ������� ������������
    case KEYB_RESEND           : KYBState.request =  KYB_FLAG_RESEND; break;     //������ ���������� �� ��������� �������� �������
    case KEYB_FAILURE          : KYBState.request =  KYB_FLAG_FAILURE; break;//������ ����������
    case KEYB_ACKNOWLEDGE      : KYBState.request =  KYB_FLAG_ACKNOWLEDGE; break;//������������� ��������� �������
    default :  if(sc > 0 && sc < 0x84){                                //�������� ��� ������ ������ � �� ��������� ������
                if(keyFlags.if_func == 1){                             //���� ���� ������ �������������� ������
                    for(i=0; i<sizeof(funCode)/2; i++){                //���������� HID ������� �� ������� ������������
                       if(funCode[i][0] == sc){
                          key = funCode[i][1];                         //���� ����� ��� ������� �� ���������� ��� � �������� ����������
                         break;                                        //� ������� � �����
                       }
                    }
                    keyFlags.if_func = 0;                              //� ��������� ������ ������ ���������� ����
                } else {
                    key = scanCode[sc];                       //���� ���� ������ ������� ������ �� ���������� ��� �� ������� ������� ������
                }
                if(key>1){
                                                    //����� ��������� ���� ������� ������� ������������� HID ����
                  ///////////////////////////////////////////////////////////////
                  ////////���� ��������� ������� ������ CtrlShiftAltWin//////////
                  if(key >= 0xE0 && key <= 0xE7){//��������� ���� ������� ������ �� ������ CtrlShiftAltWin
                     if(keyFlags.if_up == 1){                          //��������� ���� ���� �� ������ ���� ������
                        modifier &= ~dvFlags[key & 0x0F];     //���� ��� �� ������� ��������������� ����
                     } else                                    //����� ��������� ���� ������� ������� ������������� HID ����
                     modifier |= dvFlags[key & 0x0F];
                  } /////////////////////////////////////////////////////////////
                  ////////����� ���� ������� ��������� ������////////////////////
                  keyPos = inArray(key);          //��������� ���� �� ��� ������ ��� � �������
                  if(keyPos){                     //���� ���� ��������� �� �������� �� ������
                    if(keyFlags.if_up){                             //���� ��������
                       if(sysFlags.if_pc == 1)  Set_BRDButton(key, 0);
                       for(i=keyPos-1; i<5; i++){          //������ ������� �� ������� � ��������� �����
                          keycode[i] = keycode[i+1];
                          }
                       keyCnt--;                            //���������������� ������ ������
                       keyFlags.if_up = 0;                           //�������� ���� ��������� ������
                    }
                  //--------------------------------------------------------------------------
                  }else if(keyCnt<6){                      //���� �� �������� �� ��������� � �������������� ������
                    keycode[keyCnt] = key;
                    keyCnt++;
                    if(sysFlags.if_pc == 1) Set_BRDButton(key, 1);
                    if(key >= KEY_A && key <= KEY_0){         //�������� ����� ������ ��������
                       SetPass(key);                          //���������� ����� ������ ���������������� � �������� ������ � ����������
                    }
                  }
                }
                for (i=keycnt; i<=5; i++){                  //��������� �������� ������
                    keycode[i] = 0;
                }
              }  //-------------------------
              break;
    }
}