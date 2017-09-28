#line 1 "C:/Users/Vergilium/Desktop/GameTerminal/GameTerminalHID-302429613a14668f2cce4eee0f078558fbc7a17d/GameTerminal_PS2_HID.c"
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
#line 1 "c:/users/vergilium/desktop/gameterminal/gameterminalhid-302429613a14668f2cce4eee0f078558fbc7a17d/main.h"
#line 18 "c:/users/vergilium/desktop/gameterminal/gameterminalhid-302429613a14668f2cce4eee0f078558fbc7a17d/main.h"
 unsigned char progStr[] = {
 0x0A,
 0x0B,
 0x0D,
 0x18,
 0x0B,
 0x09,
 0x19,
 0x19,
 0x05,
 0x0B,
 0x0D,
 0x07,
 0x09,
 0x1C,
 0x05,
 0x17
 };

 unsigned char delStr[] = {
 0x08,
 0x0F,
 0x09,
 0x0E,
 0x17,
 0x1C,
 0x05,
 0x17
 };

 void USB_Timeout_interrupt();
#line 1 "c:/users/vergilium/desktop/gameterminal/gameterminalhid-302429613a14668f2cce4eee0f078558fbc7a17d/kb.h"
#line 118 "c:/users/vergilium/desktop/gameterminal/gameterminalhid-302429613a14668f2cce4eee0f078558fbc7a17d/kb.h"
 void init_kb(void);
 void KeyDecode(unsigned char);
 void PS2_interrupt(void);
 void PS2_Timeout_Interrupt(void);
 unsigned char PS2_Send(unsigned char);
#line 16 "C:/Users/Vergilium/Desktop/GameTerminal/GameTerminalHID-302429613a14668f2cce4eee0f078558fbc7a17d/GameTerminal_PS2_HID.c"
uint8_t readbuff[64] absolute 0x500;
uint8_t writebuff[64] absolute 0x540;
uint8_t modifier=0b00000000;
uint8_t reserved=0;
uint8_t keycode[6];
uint8_t progPass[17] = {0};
uint8_t kybCnt =  50 ;

struct UFLG{
 unsigned upBtn: 1;
 unsigned if_conf: 1;


} USBFlags at ADRESH;

struct FLG{
 unsigned if_pc: 1;
 unsigned if_func: 1;
 unsigned if_up: 1;
 unsigned kb_mode: 1;
 unsigned kb_rw: 1;
 unsigned kb_parity: 1;
} sysFlags at CVRCON;

void interrupt(){
 USB_Interrupt_Proc();
 PS2_interrupt();
 if(SUSPND_bit) USBFlags.if_conf = 0;
}
void interrupt_low(){
 PS2_Timeout_Interrupt();
}




void Led_Indicate(unsigned char blink){
 unsigned char i;
 for(i=0; i<=blink; i++){
  PORTC.RC2  = ~ PORTC.RC2 ;
 delay_ms(100);
 }
  PORTC.RC2  = 0;
}



unsigned char ArrCmp(unsigned char * arr1, unsigned char * arr2, unsigned char pos, unsigned char ln){
 unsigned char i;
 for (i=0; i<ln; i++){
 if(arr1[i+pos] != arr2[i]) return 0;
 }
 return 1;
}



void main(){
 INTCON = 0;

 ADCON1 = 0x0F;

 TRISA= 0b00010000;
 TRISB= 0b00000011;
 TRISC= 0b10111000;
 PORTA= 0;
 PORTB= 0;
 PORTC= 0;

 ADRESH = 0;
 INTCON2.RBPU = 0;
 init_kb();
 HID_Enable(readbuff,writebuff);
 UART1_Init(9600);
 sysFlags.kb_mode = EEPROM_Read(0x00);
 Led_Indicate(2);
  PORTB.RB3  = 1;
 INTCON |= (1<<GIE)|(1<<PEIE);
 while(!PS2_Send(0xFF));

 while(1) {


 if(button(&PORTC, RC7, 200, 0)){
  PORTC.RC2  = 1;
  PORTB.RB2  = 1;
  PORTB.RB7  = 1;
 sysFlags.if_pc = 1;
 USBFlags.if_conf = 0;
 while(!PS2_Send(0xED));
 delay_ms(10);
 while(!PS2_Send(0x00));
 delay_ms(250);
  PORTC.RC2  = 0;
 }


 if(HID_Read()){
 USBFlags.if_conf = 1;
 while(!PS2_Send(0xED));
 delay_ms(10);
 while(!PS2_Send((readbuff[0] & 0x03) << 1));
 }






 if(sysFlags.if_pc == 1){
 switch(keycode[0]){
 case  0x45 : if(sysFlags.kb_mode == 0)
 uart_write( 30 );
 break;
 case  0x3E  : if(sysFlags.kb_mode == 0){
 if(--kybCnt == 0){
 EEPROM_Write(0,1);
 sysFlags.kb_mode = 1;
 kybCnt =  50 ;
 uart_write( 30 );
 }
 } break;
 case  0x58  : if(sysFlags.kb_mode == 1){
 if(--kybCnt == 0){
 EEPROM_Write(0,0);
 sysFlags.kb_mode = 0;
 kybCnt =  50 ;
 uart_write( 30 );
 }
 } break;
 default : kybCnt =  50 ; break;
 }


 if(ArrCmp(&progPass, &progStr, 0, 16)){
 switch(progPass[16]){
 case  0x1E : UART1_Write( 201 ); break;
 case  0x1F : UART1_Write( 202 ); break;
 case  0x20 : UART1_Write( 203 ); break;
 case  0x21 : UART1_Write( 204 ); break;
 default: break;
 }
 progPass[0] = 0;
 }

 else if(ArrCmp(&progPass, &delStr, 8, 8)){
 switch(progPass[16]){
 case  0x1E : UART1_Write( 205 ); break;
 case  0x1F : UART1_Write( 206 ); break;
 case  0x20 : UART1_Write( 207 ); break;
 case  0x21 : UART1_Write( 208 ); break;
 case  0x22 : UART1_Write( 209 ); break;
 default: break;
 }
 progPass[8] = 0;
 }
 delay_ms(100);
 }else if(sysFlags.if_pc == 0){
  PORTB.RB2  = 0;
  PORTB.RB7  = 0;
 if(USBFlags.if_conf == 1){




 if(keycode[0] != 0)
 USBFlags.upBtn == 0;
 if(USBFlags.upBtn == 0){
 writebuff[0]=modifier;
 writebuff[1]=reserved;
 writebuff[2]=keycode[0];
 writebuff[3]=keycode[1];
 writebuff[4]=keycode[2];
 writebuff[5]=keycode[3];
 writebuff[6]=keycode[4];
 writebuff[7]=keycode[5];
 while(!HID_Write(writebuff,8));
 if(keycode[0] == 0)
 USBFlags.upBtn == 1;
 }
 }
 delay_ms(30);
 }
 }
HID_Disable();
}
