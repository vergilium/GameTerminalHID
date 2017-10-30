#line 1 "C:/Users/Vergilium/Desktop/GameTerminal/USB HID Bootloader/Driver/UHB_Driver.c"
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
#line 1 "c:/users/vergilium/desktop/gameterminal/usb hid bootloader/projects/pic18f/config.h"
#line 1 "c:/users/vergilium/desktop/gameterminal/usb hid bootloader/projects/common files/types.h"
#line 32 "c:/users/vergilium/desktop/gameterminal/usb hid bootloader/projects/pic18f/config.h"
extern const unsigned long BOOTLOADER_SIZE;
extern const unsigned long BOOTLOADER_START;
extern const unsigned char RESET_VECTOR_SIZE;

extern const TBootInfo BootInfo;


extern unsigned char HidReadBuff[64];
extern unsigned char HidWriteBuff[64];









void Config();
#line 1 "c:/program files (x86)/mikroc pro for pic/include/built_in.h"
#line 102 "C:/Users/Vergilium/Desktop/GameTerminal/USB HID Bootloader/Driver/UHB_Driver.c"
const STX = 0x0F;
const ETX = 0x04;
const DLE = 0x05;

int GPCounter = 0;
int BytesToWrite at GPCounter;
int BytesToGet at GPCounter;
int BlocksToErase at GPCounter;

unsigned long GPAddress = 0;
unsigned long StartAddress at GPAddress;


struct {
 char fBuffer[_FLASH_ERASE];
 char *fRWPtr;
#line 129 "C:/Users/Vergilium/Desktop/GameTerminal/USB HID Bootloader/Driver/UHB_Driver.c"
} Buffer;

enum TCmd CmdCode = cmdNON;
#line 159 "C:/Users/Vergilium/Desktop/GameTerminal/USB HID Bootloader/Driver/UHB_Driver.c"
static void _Buffer_SaveToFlash() {
 int bCount;
#line 167 "C:/Users/Vergilium/Desktop/GameTerminal/USB HID Bootloader/Driver/UHB_Driver.c"
 bCount =  Buffer.fRWPtr-Buffer.fBuffer ;
 Buffer.fRWPtr = Buffer.fBuffer;
 while (bCount > 0) {
  FLASH_Write_32 (StartAddress, Buffer.fRWPtr);
 bCount -= _FLASH_WRITE_LATCH;
 Buffer.fRWPtr += _FLASH_WRITE_LATCH;



 StartAddress += _FLASH_WRITE_LATCH;

 }
}
#line 203 "C:/Users/Vergilium/Desktop/GameTerminal/USB HID Bootloader/Driver/UHB_Driver.c"
static void SendBootInfo() {
 typedef struct {
 char fArray[sizeof(TBootInfo)];
 } TBootInfoArray;



 *(TBootInfoArray *)(void *)HidWriteBuff = BootInfo;
 HID_Write(HidWriteBuff, 64);
}
#line 236 "C:/Users/Vergilium/Desktop/GameTerminal/USB HID Bootloader/Driver/UHB_Driver.c"
static void Check4Cmd() {
 if (CmdCode == cmdNON) {

 if (HidReadBuff[0] != STX)

 return ;


 CmdCode = HidReadBuff[1];
  ((char *)&GPAddress)[0]  = HidReadBuff[2];
  ((char *)&GPAddress)[1]  = HidReadBuff[3];
  ((char *)&GPAddress)[2]  = HidReadBuff[4];
  ((char *)&GPAddress)[3]  = HidReadBuff[5];
  ((char *)&GPCounter)[0]  = HidReadBuff[6];
  ((char *)&GPCounter)[1]  = HidReadBuff[7];
 }
 else {

 }
}
#line 284 "C:/Users/Vergilium/Desktop/GameTerminal/USB HID Bootloader/Driver/UHB_Driver.c"
static char GetData() {
 char i;
 char *sPtr;


 sPtr = HidReadBuff;
 i = 0;
 while (1) {
 if (!BytesToGet)
 return 1;
 if ( Buffer.fRWPtr-Buffer.fBuffer  ==  sizeof(Buffer.fBuffer) )
 return 1;
 if (i == sizeof(HidReadBuff))
 return 0;
  *Buffer.fRWPtr++ = *sPtr++ ;
 BytesToGet--;
 i++;
 }
 return 0;
}
#line 326 "C:/Users/Vergilium/Desktop/GameTerminal/USB HID Bootloader/Driver/UHB_Driver.c"
static void SendACK(enum TCmd cmd) {

 HidWriteBuff[0] = STX;
 HidWriteBuff[1] = cmd;
 HID_Write(HidWriteBuff, 64);
}
#line 354 "C:/Users/Vergilium/Desktop/GameTerminal/USB HID Bootloader/Driver/UHB_Driver.c"
void StartBootloader() {
 char dataRx;
 char writeData = 0;
#line 362 "C:/Users/Vergilium/Desktop/GameTerminal/USB HID Bootloader/Driver/UHB_Driver.c"
  Buffer.fRWPtr = Buffer.fBuffer ;
 EEPROM_Write(0xFF,0x01);

 while(1) {
 USB_Polling_Proc();
 dataRx = HID_Read();
 if (dataRx) {
 dataRx = 0;
 Check4Cmd();
 switch(CmdCode) {
 case cmdWRITE: {
 if (writeData) {
 if (GetData()) {





 if (StartAddress < BOOTLOADER_START)

  _Buffer_SaveToFlash() ;
 SendACK(CmdCode);
  Buffer.fRWPtr = Buffer.fBuffer ;
 if (BytesToWrite == 0) {
 writeData = 0;
 CmdCode = cmdNON;
 }
 }
 }
 else {
 writeData = 1;
 }
 break;
 }
 case cmdERASE: {
 while (BlocksToErase--) {





 if (StartAddress < BOOTLOADER_START)

  FLASH_Erase_64 (StartAddress);







 StartAddress -= _FLASH_ERASE;


 }
 SendACK(CmdCode);
 CmdCode = cmdNON;
 break;
 }
 case cmdSYNC: {
 SendACK(CmdCode);
 CmdCode = cmdNON;
 break;
 }
 case cmdREBOOT: {


 asm RESET;
#line 440 "C:/Users/Vergilium/Desktop/GameTerminal/USB HID Bootloader/Driver/UHB_Driver.c"
 CmdCode = cmdNON;
 break;
 }
 }
 }
 }
}
#line 473 "C:/Users/Vergilium/Desktop/GameTerminal/USB HID Bootloader/Driver/UHB_Driver.c"
char EnterBootloaderMode() {
char dataRx;
unsigned timer = 10000;


 while (1) {
 USB_Polling_Proc();
 dataRx = HID_Read();
 if (dataRx) {
 dataRx = 0;
 Check4Cmd();
 switch (cmdCode) {
 case cmdBOOT: {
 SendACK(CmdCode);
 CmdCode = cmdNON;
 Delay_10ms();
 return 1;
 }
 case cmdINFO: {
 SendBootInfo();
 CmdCode = cmdNON;
 break;
 }
 }
 }

 Delay_1ms();
 if (!(timer--))
 return 0;
 }
}
#line 529 "C:/Users/Vergilium/Desktop/GameTerminal/USB HID Bootloader/Driver/UHB_Driver.c"
void StartProgram() {

 asm nop;
#line 545 "C:/Users/Vergilium/Desktop/GameTerminal/USB HID Bootloader/Driver/UHB_Driver.c"
}
