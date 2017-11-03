#line 1 "C:/Users/Vergilium/Desktop/GameTerminal/GameTerminalHID/GameTerminal_PS2_HID.c"
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
#line 1 "c:/users/vergilium/desktop/gameterminal/gameterminalhid/main.h"
#line 19 "c:/users/vergilium/desktop/gameterminal/gameterminalhid/main.h"
 const code unsigned char progStr[] = {
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

 const code unsigned char delStr[] = {
 0x08,
 0x0F,
 0x09,
 0x0E,
 0x17,
 0x1C,
 0x05,
 0x17
 };
#line 1 "c:/users/vergilium/desktop/gameterminal/gameterminalhid/usb.h"



struct UFLG{
 unsigned upBtn: 1;
 unsigned if_conf: 1;
 unsigned hid_rec: 1;
} USBFlags at ADRESL;

void USB_StateInit (void);
void USB_ReceiveBuffSet (void);
void SendNoKeys (void);
void SendKey (uint8_t, uint8_t);
uint8_t SendKeys (uint8_t *, uint8_t);
uint8_t USB_GetLEDs (void);
#line 1 "c:/users/vergilium/desktop/gameterminal/gameterminalhid/kb.h"
#line 147 "c:/users/vergilium/desktop/gameterminal/gameterminalhid/kb.h"
 void Init_PS2(void);
 unsigned char Reset_PS2(void);
 unsigned char GetState_PS2(void);
 void KeyDecode(unsigned char);
 void PS2_interrupt(void);
 void PS2_Timeout_Interrupt(void);
 unsigned char PS2_Send(unsigned char);
#line 1 "c:/users/vergilium/desktop/gameterminal/gameterminalhid/password.h"





void SendPassword (uint8_t);
void EEPROM_SavePassword (uint8_t *, uint8_t, uint8_t);
void EEPROM_ClearPassword (uint8_t, uint8_t);
#line 20 "C:/Users/Vergilium/Desktop/GameTerminal/GameTerminalHID/GameTerminal_PS2_HID.c"
uint8_t keycode[6];
uint8_t modifier=0b00000000;
uint8_t progPass[ 32 ] = {0};
char passCnt = 0;
uint8_t kybCnt =  50 ;
struct SFLG{
 unsigned if_pc: 1;
 unsigned kb_mode: 1;
 unsigned wr_pass: 1;
} sysFlags at CVRCON;

void interrupt(){
 USBDev_IntHandler();
 PS2_interrupt();
 PS2_Timeout_Interrupt();
}
#line 40 "C:/Users/Vergilium/Desktop/GameTerminal/GameTerminalHID/GameTerminal_PS2_HID.c"
void USBDev_EventHandler(uint8_t event) {
 switch(event){
 case _USB_DEV_EVENT_CONFIGURED : USBFlags.if_conf = 1; break;



 case _USB_DEV_EVENT_SUSPENDED : USBFlags.if_conf = 0; break;
 case _USB_DEV_EVENT_DISCONNECTED: USBFlags.if_conf = 0; break;

 default : break;
 }
}


void USBDev_DataReceivedHandler(uint8_t ep, uint16_t size) {
 USBFlags.hid_rec = 1;
}


void USBDev_DataSentHandler(uint8_t ep) {

}






void Led_Indicate(uint8_t blink){
 uint8_t i;
 for(i=0; i<=blink; i++){
  PORTC.RC2  = ~ PORTC.RC2 ;
 delay_ms(100);
 }
  PORTC.RC2  = 0;
}








uint8_t ArrCmp(uint8_t *arr1, const uint8_t *arr2, uint8_t pos, uint8_t ln){
 uint8_t i;
 for (i=0; i<ln; i++){
 if((arr1[i+pos] & 0x7F) != arr2[i]) return 0;
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
 INTCON2.RBPU = 0;


 CVRCON = 0;
 ADRESL = 0;
 Init_PS2();
 UART1_Init(9600);
 switch(EEPROM_Read(0)){
 case 0xFF : EEPROM_Write(0,0);
 sysFlags.kb_mode = 0;
 break;
 case 0x01 : sysFlags.kb_mode = 1;
 break;
 case 0x00 : sysFlags.kb_mode = 0;
 break;
 default : break;
 }
  PORTB.RB3  = 1;



 USBDev_Init();
 IPEN_bit = 1;
 USBIP_bit = 1;
 USBIE_bit = 1;
 GIEH_bit = 1;
 USBFlags.hid_rec = 0;

 GIE_bit = 1;
 PEIE_bit = 1;
 delay_ms(100);
 Reset_PS2();
 Led_Indicate(2);

 while(1) {
 asm clrwdt;
 USB_StateInit();


 if(button(&PORTC, RC7, 200, 0)){
  PORTC.RC2  = 1;
 if(keycode[0] ==  0xE0 ){
 SendPassword( 0x01 );
 delay_ms(10000);

 } else {
 if(Reset_PS2() == 0){  PORTC.RC2  = 0; }
  PORTB.RB2  = 1;
  PORTB.RB7  = 1;
 sysFlags.if_pc = 1;
 delay_ms(3000);
 }
  PORTC.RC2  = 0;
 }


 if(USBFlags.hid_rec == 1){
 USBFlags.hid_rec = 0;
 PS2_Send( 0xED );
 delay_ms(10);
 PS2_Send(USB_GetLEDs());
 USB_ReceiveBuffSet();
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



 if(ArrCmp(&progPass, &progStr, ( 32  - (sizeof(progStr)+1)), sizeof(progStr))){
 switch(progPass[ 32 -1]){
 case  0x1E : UART1_Write( 201 ); break;
 case  0x1F : UART1_Write( 202 ); break;
 case  0x20 : UART1_Write( 203 ); break;
 case  0x21 : UART1_Write( 204 ); break;
 case  0x27 : EEPROM_Write(0xFF,0xFF);
 USBEN_bit = 0;
 delay_ms(10);
 asm RESET; break;
 case  0x0A : uart_write( 30 );
 sysFlags.wr_pass = 1;
 memset(progPass, 0,  32 );
 PS2_Send( 0xED );
 delay_ms(10);
 PS2_Send( 0x01 );
 break;
 default: break;
 }
 progPass[ 32 -2] = 0;
 }



 else if(ArrCmp(&progPass, &delStr,  32  - sizeof(delStr) - 1, sizeof(delStr))){
 switch(progPass[ 32 -1]){
 case  0x1E : UART1_Write( 205 ); break;
 case  0x1F : UART1_Write( 206 ); break;
 case  0x20 : UART1_Write( 207 ); break;
 case  0x21 : UART1_Write( 208 ); break;
 case  0x22 : UART1_Write( 209 ); break;
 case  0x0A : EEPROM_ClearPassword( 0x01 ,  32 );
 uart_write( 30 );
 break;
 default: break;
 }
 progPass[ 32 -2] = 0;
 }



 if(sysFlags.wr_pass == 1 && keycode[0] ==  0x28 ){

 passCnt =  32 -1;
 while(progPass[passCnt] != 0 && passCnt >= 0) passCnt--;
 if(passCnt !=  32 -1){
 EEPROM_ClearPassword( 0x01 ,  32 );
 EEPROM_SavePassword(&progPass+(passCnt+1),  32  - (passCnt+1),  0x01 );
 PS2_Send( 0xED );
 delay_ms(10);
 PS2_Send( 0x00 );
 uart_write( 30 );
 } else {
 PS2_Send( 0xED );
 delay_ms(10);
 PS2_Send( 0x02  |  0x04  |  0x01 );
 delay_ms(1000);
 PS2_Send( 0xED );
 delay_ms(10);
 PS2_Send( 0x00 );
 uart_write( 30 );
 delay_ms(400);
 uart_write( 30 );
 }
 sysFlags.wr_pass = 0;
 }
 delay_ms(100);
 }else if(sysFlags.if_pc == 0){
  PORTB.RB2  = 0;
  PORTB.RB7  = 0;
 if(USBFlags.if_conf == 1){




 if(keycode[0] != 0)
 USBFlags.upBtn == 0;
 if(USBFlags.upBtn == 0){
 SendKeys(&keycode, modifier);
 if(keycode[0] == 0){
 USBFlags.upBtn == 1;
 SendNoKeys();
 }
 }
 }
 delay_ms(30);
 }
 }
}
