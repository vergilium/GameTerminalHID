#include "kb.h"
#include "Scancodes.h"

unsigned char bitcount;                              //������� ���������� �������� ���
unsigned char keyCnt;                                //����������� ������� �������
unsigned char kbWriteBuff;                           //����� �������� ������� ����������
extern unsigned char keycode[6];
extern unsigned char modifier;
extern unsigned char progPass[16];

struct FLG{
   unsigned if_pc: 1;
   unsigned if_func: 1;                             //���� �������������� ������
   unsigned if_up: 1;                               //���� ���������� ������
   unsigned kb_mode: 1;
   unsigned kb_rw: 1;                               //0 = ����� ������ 1 = �������� � ����������
   unsigned kb_parity: 1;                           //�������� ���������� ����� ����������
} sysFlags at CVRCON;

//==================================================================================
//=============������ ������������� ����������======================================
//==================================================================================
void init_kb(void){
     unsigned char i;
     bitcount = 11;                                   //����� �������� ���
     
     INTCON2.INTEDG1 = 0;       //int1 falling edge   // 0 = falling edge 1 = rising edge
     INTCON3.INT1IF = 0;                              // INT1 clear flag
     INTCON3 |= (1<<INT1IP)|(1<<INT1IE);              //INT1 Hight priority, intrrupt enable,
     
     INTCON2.TMR0IP = 0;                              //TIMER0 LOW priority
     T0CON = (1<<TMR0ON)|(1<<T08BIT)|(0<<T0CS)|(0<<PSA)|(1<<T0PS2)|(1<<T0PS1)|(1<<T0PS0);
     TMR0L =  209;
     INTCON.TMR0IF = 0;                               //TIMER0 clear flag

     INTCON  |= (1<<TMR0IE);     //timer0 int. enable
     for (i=0; i<=5; i++){                          //�������������� ���������� � ��������
        keycode[i] = 0;
     }
     keyCnt = 0;                                    //����� �������� ������� ������
     CVRCON = 0;                                    //�������������� ������� ������ ���������� � 0
}
//==================================================================================
//=============������ ������ ������ � ������ ������=================================
//==================================================================================
void Reset_timeuot (void){
     TMR0L =  209;                                    //TIMER0 preload 209 (1ms)
     INTCON.TMR0IF = 0;                               //TIMER0 clear flag
     T0CON.TMR0ON = 0;                                //��������� �������
}
//==================================================================================
//=============������� ������� �������� ��� ��� �������� ������=====================
//==================================================================================
unsigned char parity(unsigned char x){        //��� ��� ������ - ��������� XOR
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
static unsigned char keyData;                                  // Holds the received scan code
  if(INTCON3.INT1IE == 1 && INTCON3.INT1IF == 1){
    INTCON3.INT1IF = 0;                                       //���� ����� ����������
    T0CON.TMR0ON = 1;                                          //������ ������� ��������
   if(sysFlags.kb_rw == 0){
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
          KEYB_DATA = sysFlags.kb_parity;                      //������ � ���� ���� �������� (����������� �� ����� ������������ �������)
          bitcount --;
        } else if(bitcount == 1){                              //������� �������� ���� ����
          KEYB_DATA = 1;                                       //���� 1 � ����
          bitcount --;
        } else if(bitcount == 0){                              //������� ����� �������� �������
          bitcount = 11;                                       //���������� ������� ���
          TRISA.RA4 = 1;                                       //��������� ��� data �� ����
          sysFlags.kb_rw = 0;                                  //���������� ���� �������� �������
          Reset_timeuot();                                     //���������� ������� �������
        /*
          � ����������� ����� ������� ���� �����. � ������ ���� �� ����� ���� �������� ����������
          �� ������� ����� ������� ��� ���������� �� �������� ������� CLOCK �� �����, ��� ��������
          � ��������� ���������� � ������� ��� �� ������ �� ������� ��� ����������� ������.
          ����� �������� ��� ���������� ������ ���������� �� �������� �� � ������
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
unsigned char PS2_Send(unsigned char sData){
   if(bitcount == 11){                  //�������� ���������� ������ ���� �� ����������
      kbWriteBuff = sData;
      sysFlags.kb_parity = parity(kbWriteBuff); //����������� �������� ������������� �����
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
      sysFlags.kb_rw = 1;               //������������� ���� �������� ������ � ����������
      bitcount = 10;                    //���������� ������� ���
      INTCON3.INT1IF = 0;               //���������� ���� ���������� ����� ������� ������
      INTCON3.INT1IE = 1;               //��������� ���������� �� Clock � ���� � ����������
      return 1;                         //���� ��� ������ ���������� 1
   } else return 0;                     //���� ��� �� ���������� 0
}
//==================================================================================
//=============���������� ���������� �� �������� ������ ������======================
//==================================================================================
void PS2_Timeout_Interrupt(){
     if(INTCON.TMR0IE && INTCON.TMR0IF){           //���� �������� ������� ��� ����������
        if(sysFlags.kb_rw == 1) { sysFlags.kb_rw = 0; kbWriteBuff = 0; }
        bitcount = 11;
        Reset_timeuot();                           //� �������� ������ ��������
     }
}
//==================================================================================
//=============������ ������ ������� �������========================================
//==================================================================================
unsigned char inArray(unsigned char value){               //����� ��������� � �������
     unsigned char i;
     for(i=0; i<=5; i++){                                 //����� ����������� �� ������� keycode
         if(keycode[i] == value){                         //���� ������� ���������� ������� + 1
            return i+1;
         }
     }
     return 0;                                            //� ��������� ������ ������� 0
}
//==================================================================================
//=============������ ��������� ������� ��� �����===================================
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
          case KEY_HOME  : sysFlags.if_pc = 0; break;           //�������� Esc � Home ���������� ����� � ������ �����
          default : break;
       }
}
//==================================================================================
//=============������ ����� ������ � ����������=====================================
//==================================================================================
void SetPass (unsigned char key){
  unsigned char i;
  for(i=0; i<17; i++){
     progPass[i] = progPass[i+1];
  }
  progPass[16] = key;
}
//==================================================================================
//=============������ ��������� ������ �� ����������================================
//==================================================================================
void KeyDecode(unsigned char sc){
static unsigned char keyPos;           //������� ��� ������� ������ � ������� keycode
unsigned char i, key=0;                //�������� ���������� ���� �������
/////////////////////////////////////////////
////////������ ��������� ������///////////////
    switch(sc){
    case 0xE0 : sysFlags.if_func = 1; break;                           //������������� ���� �������������� ������ ���� ������ �� ���
    case 0xF0 : sysFlags.if_up = 1; break;                             //������������� ���� ���� ������ ��������
    default :  if(sc > 0 && sc < 0x84){                       //�������� ��� ������ ������ � �� ��������� ������
                if(sysFlags.if_func == 1){                             //���� ���� ������ �������������� ������
                    for(i=0; i<sizeof(funCode)/2; i++){       //���������� HID ������� �� ������� ������������
                       if(funCode[i][0] == sc){
                          key = funCode[i][1];                //���� ����� ��� ������� �� ���������� ��� � �������� ����������
                         break;                               //� ������� � �����
                       }
                    }
                    sysFlags.if_func = 0;                              //� ��������� ������ ������ ���������� ����
                } else {
                    key = scanCode[sc];                       //���� ���� ������ ������� ������ �� ���������� ��� �� ������� ������� ������
                }
                if(key>1){
                                                    //����� ��������� ���� ������� ������� ������������� HID ����
                  ///////////////////////////////////////////////////////////////
                  ////////���� ��������� ������� ������ CtrlShiftAltWin//////////
                  if(key >= 0xE0 && key <= 0xE7){//��������� ���� ������� ������ �� ������ CtrlShiftAltWin
                     if(sysFlags.if_up == 1){                          //��������� ���� ���� �� ������ ���� ������
                        modifier &= ~dvFlags[key & 0x0F];     //���� ��� �� ������� ��������������� ����
                     } else                                    //����� ��������� ���� ������� ������� ������������� HID ����
                     modifier |= dvFlags[key & 0x0F];
                  } /////////////////////////////////////////////////////////////
                  ////////����� ���� ������� ��������� ������////////////////////
                  keyPos = inArray(key);          //��������� ���� �� ��� ������ ��� � �������
                  if(keyPos){                     //���� ���� ��������� �� �������� �� ������
                    if(sysFlags.if_up){                             //���� ��������
                       if(sysFlags.if_pc == 1)  Set_BRDButton(key, 0);
                       for(i=keyPos-1; i<5; i++){          //������ ������� �� ������� � ��������� �����
                          keycode[i] = keycode[i+1];
                          }
                       keyCnt--;                            //���������������� ������ ������
                       sysFlags.if_up = 0;                           //�������� ���� ��������� ������
                    }
                  //--------------------------------------------------------------------------
                  }else if(keyCnt<6){                      //���� �� �������� �� ��������� � �������������� ������
                    keycode[keyCnt] = key;
                    keyCnt++;
                    if(sysFlags.if_pc == 1) Set_BRDButton(key, 1);
                    SetPass(key);                          //���������� ����� ������ ���������������� � �������� ������ � ����������
                  }
                }
                for (i=keycnt; i<=5; i++){                  //��������� �������� ������
                    keycode[i] = 0;
                }
              }  //-------------------------
              break;
    }
}