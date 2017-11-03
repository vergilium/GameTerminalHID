#line 1 "C:/Users/Vergilium/Desktop/GameTerminal/GameTerminalHID/kb.c"
#line 1 "c:/program files (x86)/mikroc pro for pic/include/stdint.h"




typedef signed char int8_t;
typedef signed int int16_t;
typedef signed long int int32_t;


typedef unsigned char uint8_t;
typedef unsigned int uint16_t;
typedef unsigned long int uint32_t;


typedef signed char int_least8_t;
typedef signed int int_least16_t;
typedef signed long int int_least32_t;


typedef unsigned char uint_least8_t;
typedef unsigned int uint_least16_t;
typedef unsigned long int uint_least32_t;



typedef signed char int_fast8_t;
typedef signed int int_fast16_t;
typedef signed long int int_fast32_t;


typedef unsigned char uint_fast8_t;
typedef unsigned int uint_fast16_t;
typedef unsigned long int uint_fast32_t;


typedef signed int intptr_t;
typedef unsigned int uintptr_t;


typedef signed long int intmax_t;
typedef unsigned long int uintmax_t;
#line 1 "c:/users/vergilium/desktop/gameterminal/gameterminalhid/kb.h"
#line 151 "c:/users/vergilium/desktop/gameterminal/gameterminalhid/kb.h"
 void Init_PS2(void);
 unsigned char Reset_PS2(void);
 unsigned char GetState_PS2(void);
 void KeyDecode(unsigned char);
 void PS2_interrupt(void);
 void PS2_Timeout_Interrupt(void);
 unsigned char PS2_Send(unsigned char);
 unsigned char RemarkConsole(unsigned char);
#line 1 "c:/users/vergilium/desktop/gameterminal/gameterminalhid/scancodes.h"






const code unsigned char scanCode[] = {

0x01,
0x42,
0x00,
0x3E,
0x3C,
0x3A,
0x3B,
0x45,
0x00,
0x43,
0x41,
0x3F,
0x3D,
0x2B,
0x35,
0x67,
0x00,
0xE2,
0xE1,
0x00,
0xE0,
0x14,
0x1E,
0x00,
0x00,
0x00,
0x1D,
0x16,
0x04,
0x1A,
0x1F,
0x00,
0x00,
0x06,
0x1B,
0x07,
0x08,
0x21,
0x20,
0x00,
0x00,
0x2C,
0x19,
0x09,
0x17,
0x15,
0x22,
0x00,
0x00,
0x11,
0x05,
0x0B,
0x0A,
0x1C,
0x23,
0x00,
0x00,
0x00,
0x10,
0x0D,
0x18,
0x24,
0x25,
0x00,
0x00,
0x36,
0x0E,
0x0C,
0x12,
0x27,
0x26,
0x00,
0x00,
0x37,
0x38,
0x0F,
0x33,
0x13,
0x2D,
0x00,
0x00,
0x00,
0x34,
0x00,
0x2F,
0x2E,
0x00,
0x00,
0x39,
0xE5,
0x28,
0x30,
0x00,
0x31,
0x00,
0x00,
0x00,
0x00,
0x00,
0x00,
0x00,
0x00,
0x2A,
0x00,
0x00,
0x59,
0x00,
0x5C,
0x5F,
0x85,
0x00,
0x00,
0x62,
0x63,
0x5A,
0x5D,
0x5E,
0x60,
0x29,
0x53,
0x44,
0x57,
0x5B,
0x56,
0x55,
0x61,
0x47,
0x00,
0x00,
0x00,
0x00,
0x40
};




const code unsigned char funCode[][2] = {

{0x5A, 0x58},
{0x69, 0x4D},
{0x6C, 0x4A},
{0x70, 0x49},
{0x71, 0x4C},
{0x72, 0x51},
{0x74, 0x4F},
{0x75, 0x52},
{0x7A, 0x4E},
{0x7C, 0x46},
{0x7D, 0x4B},
{0x7E, 0x48},
{0x14, 0xE4},
{0x11, 0xE6},
{0x27, 0xE7},
{0x1F, 0xE3},
{0x6B, 0x50},
{0x4A, 0x54}
};

const code unsigned char dvFlags[] = {
0x01,
0x02,
0x04,
0x08,
0x10,
0x20,
0x40,
0x80,
};




const code unsigned char kbRemark[] = {
 0x0B ,
 0x0A ,
 0x13 ,
 0x09 ,
 0x1E ,
 0x1F ,
 0x20 ,
 0x21 ,
 0x22 ,
 0x10 ,
 0x05 ,
 0x2C 
};
#line 5 "C:/Users/Vergilium/Desktop/GameTerminal/GameTerminalHID/kb.c"
extern uint8_t keycode[6];
extern uint8_t modifier;
extern uint8_t progPass[ 32 ];

uint8_t bitcount;
uint8_t keyCnt;
uint8_t kbWriteBuff;

struct SFLG{
 unsigned kb_mode: 1;
 unsigned usb_on: 1;
 unsigned kbBtn_mode: 1;
 unsigned wr_pass: 1;
 unsigned if_pc: 1;
} sysFlags at CVRCON;

struct KFLG{
 unsigned if_conf : 1;
 unsigned if_func : 1;
 unsigned if_up : 1;
 unsigned kb_rw : 1;
 unsigned kb_parity: 1;
} keyFlags at ADRESH;

struct KYB{
 unsigned kbMode: 4;
 unsigned request: 4;
} KYBState = {0};



void Init_PS2(void){
 uint8_t i;
 bitcount = 11;

 INTCON2.INTEDG1 = 0;
 INTCON3.INT1IF = 0;
 INTCON3 |= (1<<INT1IP)|(1<<INT1IE);

 TMR2IP_bit = 1;
 TMR2IF_bit = 0;
 T2CON = (1<<T2OUTPS3)|(1<<T2OUTPS1)|(1<<T2OUTPS0)|(1<<T2CKPS0);
 PR2 = 250;

 TMR2IE_bit = 1;

 for(i=0; i<=5; i++) keycode[i] = 0;

 keyCnt = 0;
 ADRESH = 0;
}



void Reset_timeuot (void){
 TMR2ON_bit = 0;
 TMR2IF_bit = 0;
 PR2 = 250;
}


uint8_t Reset_PS2(void){
 uint8_t timeout = 10;

 PS2_Send(0xFF);
 delay_ms(300);
 while(timeout != 0){
 if(KYBState.request ==  1 ){
 KYBState.kbMode =  1 ;
 return 1;
 } else if (KYBState.request ==  4 ){
 KYBState.kbMode =  2 ;
 return 0;
 }
 timeout--;
 delay_ms(10);
 }
 KYBState.kbMode =  0 ;
 KYBState.request =  0 ;
 return 0;
}
#line 94 "C:/Users/Vergilium/Desktop/GameTerminal/GameTerminalHID/kb.c"
uint8_t parity(uint8_t x){
x ^= x >> 8;
x ^= x >> 4;
x ^= x >> 2;
x ^= x >> 1;
return ~(x & 1);
}



void PS2_interrupt(void) {
static uint8_t keyData;
 if(INTCON3.INT1IE == 1 && INTCON3.INT1IF == 1){
 INTCON3.INT1IF = 0;
 TMR2ON_bit = 1;
 if(keyFlags.kb_rw == 0){
 if (INTCON2.INTEDG1 == 0){
 if(bitcount < 11 && bitcount > 2) {
 keyData = keyData >> 1;
 if( PORTA.RA4  == 1)
 keyData = keyData | 0x80;
 }
 INTCON2.INTEDG1 = 1;
 } else {
 INTCON2.INTEDG1 = 0;
 if(--bitcount == 0){
 Reset_timeuot();
 KeyDecode(keyData);
 bitcount = 11;
 }
 }
 }else {


 if (INTCON2.INTEDG1 == 0){
 if(bitcount > 2 && bitcount <= 10){
  PORTA.RA4  = kbWriteBuff & 1;
 kbWriteBuff = kbWriteBuff >> 1;
 bitcount --;
 } else if(bitcount == 2){
  PORTA.RA4  = keyFlags.kb_parity;
 bitcount --;
 } else if(bitcount == 1){
  PORTA.RA4  = 1;
 bitcount --;
 } else if(bitcount == 0){
 bitcount = 11;
 TRISA.RA4 = 1;
 keyFlags.kb_rw = 0;
 Reset_timeuot();
#line 151 "C:/Users/Vergilium/Desktop/GameTerminal/GameTerminalHID/kb.c"
 }
 }

 }
 }
}



uint8_t PS2_Send(uint8_t sData){
 if(bitcount == 11){
 kbWriteBuff = sData;
 keyFlags.kb_parity = parity(kbWriteBuff);

 INTCON3.INT1IE = 0;
  PORTB.RB1  = 0;
  PORTA.RA4  = 1;
 TRISB.RB1 = 0;
 TRISA.RA4 = 0;
 delay_ms(100);
  PORTA.RA4  = 0;
 delay_ms(1);
  PORTB.RB1  = 1;
 TRISB.RB1 = 1;
 keyFlags.kb_rw = 1;
 bitcount = 10;
 INTCON3.INT1IF = 0;
 INTCON3.INT1IE = 1;
 TMR2ON_bit = 1;
 return 1;
 } else return 0;
}



void PS2_Timeout_Interrupt(){
 if(TMR2IF_bit){
 Reset_timeuot();
 if(keyFlags.kb_rw == 1) {
 keyFlags.kb_rw = 0;
 kbWriteBuff = 0;
  PORTA.RA4  = 1;
 TRISA.RA4 = 1;
 }
 bitcount = 11;
 }
}



uint8_t inArray(uint8_t value){
 uint8_t i;
 for(i=0; i<=5; i++){
 if(keycode[i] == value){
 return i+1;
 }
 }
 return 0;
}



void Set_BRDButton (uint8_t key, uint8_t upDown){
 switch (key){

 case  0x3E  : if(sysFlags.kb_mode == 0) break;
 case  0x1E  :
 case  0x59  :  PORTA.RA0  = upDown;
 if (sysFlags.kbBtn_mode ==  0 )
  PORTC.RC2  = upDown;
 break;

 case  0x3F  : if(sysFlags.kb_mode == 0) break;
 case  0x1F  :
 case  0x5A  :  PORTA.RA1  = upDown;
 if (sysFlags.kbBtn_mode ==  0 )
  PORTC.RC2  = upDown;
 break;

 case  0x40  : if(sysFlags.kb_mode == 0) break;
 case  0x20  :
 case  0x5B  :  PORTA.RA2  = upDown;
 if (sysFlags.kbBtn_mode ==  0 )
  PORTC.RC2  = upDown;
 break;

 case  0x41  : if(sysFlags.kb_mode == 0) break;
 case  0x21  :
 case  0x5C  :  PORTA.RA3  = upDown;
 if (sysFlags.kbBtn_mode ==  0 )
  PORTC.RC2  = upDown;
 break;

 case  0x42  : if(sysFlags.kb_mode == 0) break;
 case  0x22  :
 case  0x5D  :  PORTA.RA5  = upDown;
 if (sysFlags.kbBtn_mode ==  0 )
  PORTC.RC2  = upDown;
 break;

 case  0x3D  : if(sysFlags.kb_mode == 0) break;
 case  0x23  :
 case  0x5E  : if(sysFlags.kbBtn_mode ==  1 )  PORTC.RC2  = upDown;
 break;

 case  0x43  : if(sysFlags.kb_mode == 0) break;
 case  0x24  :
 case  0x5F  :  PORTB.RB6  = upDown;
 if (sysFlags.kbBtn_mode ==  0 )
  PORTC.RC2  = upDown;
 break;

 case  0x44  : if(sysFlags.kb_mode == 0) break;
 case  0x25  :
 case  0x60  :  PORTB.RB5  = upDown;
 if (sysFlags.kbBtn_mode ==  0 )
  PORTC.RC2  = upDown;
 break;

 case  0x3A  : if(sysFlags.kb_mode == 0) break;
 case  0x26  :
 case  0x61  :  PORTC.RC0  = upDown;
 if (sysFlags.kbBtn_mode ==  0 )
  PORTC.RC2  = upDown;
 break;

 case  0x3B  : if(sysFlags.kb_mode == 0) break;
 case  0x27  :
 case  0x62  :  PORTC.RC1  = upDown;
 if (sysFlags.kbBtn_mode ==  0 )
  PORTC.RC2  = upDown;
 break;

 case  0x45  : if(sysFlags.kb_mode == 0) break;
 case  0x28  :
 case  0x2C  :
 case  0x58 :  PORTB.RB4  = upDown;
 if (sysFlags.kbBtn_mode ==  0 )
  PORTC.RC2  = upDown;
 break;

 case  0x3C  : if(sysFlags.kb_mode == 0) break;
 case  0x29  :
 case  0x4A  : sysFlags.if_pc = 0; break;

 default : break;
 }
}








void SetPass (uint8_t key){
 uint8_t i;

 for(i=0; i< 32 ; i++){
 progPass[i] = progPass[i+1];
 }
 if((modifier & 0x22) != 0)
 progPass[ 32 -1] = key | 0x80;
 else
 progPass[ 32 -1] = key;
}

unsigned char RemarkConsole(unsigned char key){
 key = kbRemark[key - 0x3A];
 return key;
}



void KeyDecode(uint8_t sc){
static uint8_t keyPos;
uint8_t i, key=0;


 switch(sc){
 case  0xE0  : keyFlags.if_func = 1; break;
 case  0xF0  : keyFlags.if_up = 1; break;
 case  0xAA  : KYBState.request =  1 ; break;
 case  0xFE  : KYBState.request =  3 ; break;
 case  0xFC  : KYBState.request =  4 ; break;
 case  0xFA  : KYBState.request =  2 ; break;
 default : if(sc > 0 && sc < 0x84){
 if(keyFlags.if_func == 1){
 for(i=0; i<sizeof(funCode)/2; i++){
 if(funCode[i][0] == sc){
 key = funCode[i][1];
 break;
 }
 }
 keyFlags.if_func = 0;
 } else {
 key = scanCode[sc];
 }
 if(key>1){



 if(key >= 0xE0 && key <= 0xE7){
 if(keyFlags.if_up == 1){
 modifier &= ~dvFlags[key & 0x0F];
 } else
 modifier |= dvFlags[key & 0x0F];
 }

 keyPos = inArray(key);
 if(keyPos){
 if(keyFlags.if_up){
 if(sysFlags.if_pc == 1) Set_BRDButton(key, 0);
 for(i=keyPos-1; i<5; i++){
 keycode[i] = keycode[i+1];
 }
 keyCnt--;
 keyFlags.if_up = 0;
 }

 }else if(keyCnt<6){
 if(sysFlags.if_pc == 1) Set_BRDButton(key, 1);
 keycode[keyCnt] = key;
 keyCnt++;
 if(key >=  0x04  && key <=  0x27 ){
 SetPass(key);
 }
 }
 }
 for (i=keycnt; i<=5; i++){
 keycode[i] = 0;
 }
 }
 break;
 }
}
