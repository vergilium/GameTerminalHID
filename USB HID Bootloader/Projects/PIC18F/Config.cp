#line 1 "C:/Users/Vergilium/Desktop/GameTerminal/USB HID Bootloader/Projects/PIC18F/Config.c"
#line 1 "c:/users/vergilium/desktop/gameterminal/usb hid bootloader/projects/common files/main.h"
#line 19 "c:/users/vergilium/desktop/gameterminal/usb hid bootloader/projects/common files/main.h"
void main(void);
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
#line 1 "c:/users/vergilium/desktop/gameterminal/usb hid bootloader/driver/uhb_driver.h"
#line 19 "c:/users/vergilium/desktop/gameterminal/usb hid bootloader/driver/uhb_driver.h"
void StartProgram();
void StartBootloader();
char EnterBootloaderMode();
#line 37 "C:/Users/Vergilium/Desktop/GameTerminal/USB HID Bootloader/Projects/PIC18F/Config.c"
const enum TMcuType MCU_TYPE = mtPIC18;






const unsigned long BOOTLOADER_SIZE = 6536;








const unsigned int BOOTLOADER_REVISION = 0x1200;


const unsigned long BOOTLOADER_START = ((__FLASH_SIZE-BOOTLOADER_SIZE)/_FLASH_ERASE)*_FLASH_ERASE;
const unsigned char RESET_VECTOR_SIZE = 4;




const TBootInfo BootInfo = { sizeof(TBootInfo),
 {bifMCUTYPE, MCU_TYPE},
 {bifMCUSIZE, __FLASH_SIZE},
 {bifERASEBLOCK, _FLASH_ERASE},
 {bifWRITEBLOCK, _FLASH_WRITE_LATCH},
 {bifBOOTREV, BOOTLOADER_REVISION},
 {bifBOOTSTART, BOOTLOADER_START},
 {bifDEVDSC,  "GameTerminal" }
 };





unsigned char HidReadBuff[64] absolute 0x500;
unsigned char HidWriteBuff[64] absolute 0x540;
unsigned char Reserve4thBankForUSB[256] absolute 0x400;
#line 137 "C:/Users/Vergilium/Desktop/GameTerminal/USB HID Bootloader/Projects/PIC18F/Config.c"
void Config() {
  OrgAll(BOOTLOADER_START-RESET_VECTOR_SIZE); FuncOrg(main, BOOTLOADER_START); FuncOrg(StartProgram, BOOTLOADER_START-RESET_VECTOR_SIZE); if (Reserve4thBankForUSB) ; ;
}
