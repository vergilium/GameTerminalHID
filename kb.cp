#line 1 "C:/Users/Vergilium/Desktop/GameTerminal/GameTerminalHID-302429613a14668f2cce4eee0f078558fbc7a17d/kb.c"
#line 1 "c:/users/vergilium/desktop/gameterminal/gameterminalhid-302429613a14668f2cce4eee0f078558fbc7a17d/kb.h"
#line 118 "c:/users/vergilium/desktop/gameterminal/gameterminalhid-302429613a14668f2cce4eee0f078558fbc7a17d/kb.h"
 void init_kb(void);
 void KeyDecode(unsigned char);
 void PS2_interrupt(void);
 void PS2_Timeout_Interrupt(void);
 unsigned char PS2_Send(unsigned char);
#line 1 "c:/users/vergilium/desktop/gameterminal/gameterminalhid-302429613a14668f2cce4eee0f078558fbc7a17d/scancodes.h"


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
#line 4 "C:/Users/Vergilium/Desktop/GameTerminal/GameTerminalHID-302429613a14668f2cce4eee0f078558fbc7a17d/kb.c"
unsigned char bitcount;
unsigned char keyCnt;
unsigned char kbWriteBuff;
extern unsigned char keycode[6];
extern unsigned char modifier;
extern unsigned char progPass[16];

struct FLG{
 unsigned if_pc: 1;
 unsigned if_func: 1;
 unsigned if_up: 1;
 unsigned kb_mode: 1;
 unsigned kb_rw: 1;
 unsigned kb_parity: 1;
} sysFlags at CVRCON;




void init_kb(void){
 unsigned char i;
 bitcount = 11;

 INTCON2.INTEDG1 = 0;
 INTCON3.INT1IF = 0;
 INTCON3 |= (1<<INT1IP)|(1<<INT1IE);

 INTCON2.TMR0IP = 0;
 T0CON = (1<<TMR0ON)|(1<<T08BIT)|(0<<T0CS)|(0<<PSA)|(1<<T0PS2)|(1<<T0PS1)|(1<<T0PS0);
 TMR0L = 209;
 INTCON.TMR0IF = 0;

 INTCON |= (1<<TMR0IE);
 for (i=0; i<=5; i++){
 keycode[i] = 0;
 }
 keyCnt = 0;
 CVRCON = 0;
}



void Reset_timeuot (void){
 TMR0L = 209;
 INTCON.TMR0IF = 0;
 T0CON.TMR0ON = 0;
}



unsigned char parity(unsigned char x){
x ^= x >> 8;
x ^= x >> 4;
x ^= x >> 2;
x ^= x >> 1;
return ~(x & 1);
}



void PS2_interrupt(void) {
static unsigned char keyData;
 if(INTCON3.INT1IE == 1 && INTCON3.INT1IF == 1){
 INTCON3.INT1IF = 0;
 T0CON.TMR0ON = 1;
 if(sysFlags.kb_rw == 0){
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
  PORTA.RA4  = sysFlags.kb_parity;
 bitcount --;
 } else if(bitcount == 1){
  PORTA.RA4  = 1;
 bitcount --;
 } else if(bitcount == 0){
 bitcount = 11;
 TRISA.RA4 = 1;
 sysFlags.kb_rw = 0;
 Reset_timeuot();
#line 111 "C:/Users/Vergilium/Desktop/GameTerminal/GameTerminalHID-302429613a14668f2cce4eee0f078558fbc7a17d/kb.c"
 }
 }

 }
 }
}



unsigned char PS2_Send(unsigned char sData){
 if(bitcount == 11){
 kbWriteBuff = sData;
 sysFlags.kb_parity = parity(kbWriteBuff);

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
 sysFlags.kb_rw = 1;
 bitcount = 10;
 INTCON3.INT1IF = 0;
 INTCON3.INT1IE = 1;
 return 1;
 } else return 0;
}



void PS2_Timeout_Interrupt(){
 if(INTCON.TMR0IE && INTCON.TMR0IF){
 if(sysFlags.kb_rw == 1) { sysFlags.kb_rw = 0; kbWriteBuff = 0; }
 bitcount = 11;
 Reset_timeuot();
 }
}



unsigned char inArray(unsigned char value){
 unsigned char i;
 for(i=0; i<=5; i++){
 if(keycode[i] == value){
 return i+1;
 }
 }
 return 0;
}



void Set_BRDButton (unsigned char key, unsigned char upDown){
 switch (key){
 case  0x3E  : if(sysFlags.kb_mode == 0) break;
 case  0x1E  :
 case  0x59  :  PORTA.RA0  = upDown;  PORTC.RC2  = upDown; break;
 case  0x3F  : if(sysFlags.kb_mode == 0) break;
 case  0x1F  :
 case  0x5A  :  PORTA.RA1  = upDown;  PORTC.RC2  = upDown; break;
 case  0x40  : if(sysFlags.kb_mode == 0) break;
 case  0x20  :
 case  0x5B  :  PORTA.RA2  = upDown;  PORTC.RC2  = upDown; break;
 case  0x41  : if(sysFlags.kb_mode == 0) break;
 case  0x21  :
 case  0x5C  :  PORTA.RA3  = upDown;  PORTC.RC2  = upDown; break;
 case  0x42  : if(sysFlags.kb_mode == 0) break;
 case  0x22  :
 case  0x5D  :  PORTA.RA5  = upDown;  PORTC.RC2  = upDown; break;
 case  0x43  : if(sysFlags.kb_mode == 0) break;
 case  0x24  :
 case  0x5F  :  PORTB.RB6  = upDown;  PORTC.RC2  = upDown; break;
 case  0x44  : if(sysFlags.kb_mode == 0) break;
 case  0x25  :
 case  0x60  :  PORTB.RB5  = upDown;  PORTC.RC2  = upDown; break;
 case  0x26  :
 case  0x61  :  PORTC.RC0  = upDown;  PORTC.RC2  = upDown; break;
 case  0x27  :
 case  0x62  :  PORTC.RC1  = upDown;  PORTC.RC2  = upDown; break;
 case  0x45  : if(sysFlags.kb_mode == 0) break;
 case  0x28  :
 case  0x2C  :
 case  0x58 :  PORTB.RB4  = upDown;  PORTC.RC2  = upDown; break;
 case  0x3C  : if(sysFlags.kb_mode == 0) break;
 case  0x29  :
 case  0x4A  : sysFlags.if_pc = 0; break;
 default : break;
 }
}



void SetPass (unsigned char key){
 unsigned char i;
 for(i=0; i<17; i++){
 progPass[i] = progPass[i+1];
 }
 progPass[16] = key;
}



void KeyDecode(unsigned char sc){
static unsigned char keyPos;
unsigned char i, key=0;


 switch(sc){
 case 0xE0 : sysFlags.if_func = 1; break;
 case 0xF0 : sysFlags.if_up = 1; break;
 default : if(sc > 0 && sc < 0x84){
 if(sysFlags.if_func == 1){
 for(i=0; i<sizeof(funCode)/2; i++){
 if(funCode[i][0] == sc){
 key = funCode[i][1];
 break;
 }
 }
 sysFlags.if_func = 0;
 } else {
 key = scanCode[sc];
 }
 if(key>1){



 if(key >= 0xE0 && key <= 0xE7){
 if(sysFlags.if_up == 1){
 modifier &= ~dvFlags[key & 0x0F];
 } else
 modifier |= dvFlags[key & 0x0F];
 }

 keyPos = inArray(key);
 if(keyPos){
 if(sysFlags.if_up){
 if(sysFlags.if_pc == 1) Set_BRDButton(key, 0);
 for(i=keyPos-1; i<5; i++){
 keycode[i] = keycode[i+1];
 }
 keyCnt--;
 sysFlags.if_up = 0;
 }

 }else if(keyCnt<6){
 keycode[keyCnt] = key;
 keyCnt++;
 if(sysFlags.if_pc == 1) Set_BRDButton(key, 1);
 SetPass(key);
 }
 }
 for (i=keycnt; i<=5; i++){
 keycode[i] = 0;
 }
 }
 break;
 }
}
