#line 1 "C:/Users/Vergilium/Desktop/GameTerminal/GameTerminalHID/Password.c"
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
#line 1 "c:/users/vergilium/desktop/gameterminal/gameterminalhid/password.h"





void SendPassword (uint8_t);
void EEPROM_SavePassword (uint8_t *, uint8_t, uint8_t);
void EEPROM_ClearPassword (uint8_t, uint8_t);
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
#line 151 "c:/users/vergilium/desktop/gameterminal/gameterminalhid/kb.h"
 void Init_PS2(void);
 unsigned char Reset_PS2(void);
 unsigned char GetState_PS2(void);
 void KeyDecode(unsigned char);
 void PS2_interrupt(void);
 void PS2_Timeout_Interrupt(void);
 unsigned char PS2_Send(unsigned char);
 unsigned char RemarkConsole(unsigned char);
#line 34 "C:/Users/Vergilium/Desktop/GameTerminal/GameTerminalHID/Password.c"
void SendPassword (uint8_t stAdres){
 uint8_t i = 0,
 bufKey = 0;

 for(i = 0; i <  32 ; i++){
 bufKey = EEPROM_read(stAdres + i);
 if(bufKey == 0xFF) return;
 else if(bufKey == '\0'){
 SendKey( 0x28 , 0);
 delay_ms(100);
 SendNoKeys();
 delay_ms(10);
 SendKey( 0x28 , 0);
 delay_ms(100);
 break;
 } else {
 SendKey((bufKey & 0x7F), ((bufKey & 0x80)>>6));
 delay_ms(30);
 SendNoKeys();
 delay_ms(30);
 }
 }
 SendNoKeys();
}









void EEPROM_SavePassword (uint8_t *pass, uint8_t len, uint8_t stAddr){
 uint8_t i;

 for(i=0; i<len; i++){
 EEPROM_write(stAddr+i, pass[i]);
 delay_us(100);
 }
 EEPROM_write(stAddr+len, '\0');
}






void EEPROM_ClearPassword (uint8_t stAddr, uint8_t len){
 uint8_t i;
 for(i=0; i<len; i++){
 EEPROM_write(stAddr+i, 0xFF);
 delay_us(100);
 }
}
