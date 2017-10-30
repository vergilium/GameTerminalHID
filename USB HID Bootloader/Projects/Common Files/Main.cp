#line 1 "C:/Users/Vergilium/Desktop/GameTerminal/USB HID Bootloader/Projects/Common Files/Main.c"
#line 1 "c:/users/vergilium/desktop/gameterminal/usb hid bootloader/projects/pic18f/config.h"
#line 1 "c:/users/vergilium/desktop/gameterminal/usb hid bootloader/projects/common files/types.h"
#line 20 "c:/users/vergilium/desktop/gameterminal/usb hid bootloader/projects/common files/types.h"
enum TMcuType {mtPIC16 = 1, mtPIC18, mtPIC18FJ, mtPIC24, mtDSPIC = 10, mtPIC32 = 20};


enum TBootInfoField {bifMCUTYPE=1,
 bifMCUID,
 bifERASEBLOCK,
 bifWRITEBLOCK,
 bifBOOTREV,
 bifBOOTSTART,
 bifDEVDSC,
 bifMCUSIZE
 };


enum TCmd {cmdNON=0,
 cmdSYNC,
 cmdINFO,
 cmdBOOT,
 cmdREBOOT,
 cmdWRITE=11,
 cmdERASE=21};




typedef struct {
 char fFieldType;
 char fValue;
} TCharField;


typedef struct {
 char fFieldType;
 union {
 unsigned int intVal;
 struct {
 char bLo;
 char bHi;
 };
 } fValue;
} TUIntField;


typedef struct {
 char fFieldType;
 unsigned long fValue;
} TULongField;



typedef struct {
 char fFieldType;
 char fValue[ 20 ];
} TStringField;


typedef struct {
 char bSize;
 TCharField bMcuType;
 TULongField ulMcuSize;
 TUIntField uiEraseBlock;
 TUIntField uiWriteBlock;
 TUIntField uiBootRev;
 TULongField ulBootStart;
 TStringField sDevDsc;
} TBootInfo;
#line 32 "c:/users/vergilium/desktop/gameterminal/usb hid bootloader/projects/pic18f/config.h"
extern const unsigned long BOOTLOADER_SIZE;
extern const unsigned long BOOTLOADER_START;
extern const unsigned char RESET_VECTOR_SIZE;

extern const TBootInfo BootInfo;


extern unsigned char HidReadBuff[64];
extern unsigned char HidWriteBuff[64];









void Config();
#line 1 "c:/users/vergilium/desktop/gameterminal/usb hid bootloader/driver/uhb_driver.h"
#line 19 "c:/users/vergilium/desktop/gameterminal/usb hid bootloader/driver/uhb_driver.h"
void StartProgram();
void StartBootloader();
char EnterBootloaderMode();
#line 74 "C:/Users/Vergilium/Desktop/GameTerminal/USB HID Bootloader/Projects/Common Files/Main.c"
void main(void) {

 ADCON1 = 0x0F;
 TRISA= 0b00010000;
 TRISB= 0b00000011;
 TRISC= 0b10111000;
 PORTA= 0;
 PORTB= 0;
 PORTC= 0;
 INTCON2.RBPU = 0;

 if(button(&PORTC, RC7, 200, 0)) EEPROM_Write(0xFF,0xFF);
 if(EEPROM_Read(0xFF) == 0xFF){
 Config();
 HID_Enable(&HidReadBuff, &HidWriteBuff);


 if (!EnterBootloaderMode()) {
 HID_Disable();
 Delay_10ms();

 StartProgram();
 } else
 StartBootloader();
 } else StartProgram();
}
