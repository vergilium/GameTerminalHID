#line 1 "C:/Users/Vergilium/Desktop/GameTerminal/GameTerminalHID/usb.c"
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
#line 5 "C:/Users/Vergilium/Desktop/GameTerminal/GameTerminalHID/usb.c"
uint8_t readbuff[64] absolute 0x500;
uint8_t writebuff[64] absolute 0x540;
uint8_t reserved=0;

struct SFLG{
 unsigned kb_mode: 1;
 unsigned usb_on: 1;
 unsigned kbBtn_mode: 1;
 unsigned wr_pass: 1;
 unsigned if_pc: 1;
} sysFlags at CVRCON;






void USB_StateInit (void){









 if(USBDev_GetDeviceState() == _USB_DEV_STATE_CONFIGURED){
 USBFlags.if_conf = 1;
 USBDev_SetReceiveBuffer(1, readbuff);
 } else {
 USBFlags.if_conf = 0;
 delay_ms(10);
 }
}





void USB_ReceiveBuffSet (void){
 USBDev_SetReceiveBuffer(1, readbuff);
}





uint8_t SendKeys (uint8_t *keys, uint8_t modifier){
 uint8_t i,
 cnt = 0;
 memset(writebuff, 0, 8);
 writebuff[0] = modifier;
 writebuff[1] = reserved;
 for(i=0; i<=5; i++){
 if(keys[i] != 0) cnt++;
 if(sysFlags.kb_mode == 1){
 if(keys[i] >=  0x3A  && keys[i] <=  0x45 )
 writebuff[i+2] = RemarkConsole(keys[i]);
 } else
 writebuff[i+2]=keys[i];
 }
 USBDev_HIDWrite(1,writebuff,8);
 return cnt;
}





void SendNoKeys (void){
 memset(writebuff, 0, 8);
 USBDev_HIDWrite(1,writebuff,8);
}






void SendKey (uint8_t key, uint8_t modifier){
 writebuff[0] = modifier;
 writebuff[1] = reserved;
 writebuff[2] = key;
 memset(writebuff+3, 0, 5);
 USBDev_HIDWrite(1,writebuff,8);
}





uint8_t USB_GetLEDs (void){
 uint8_t leds;
 leds = (readbuff[0] & 0x07)<<1;
 if((leds & 0x08) == 8) leds = (leds & 0x07)|0x01;

 return leds;
}
