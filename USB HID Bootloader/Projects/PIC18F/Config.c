/******************************************************************************
 *                                                                            *
 *  Unit:         Config.c                                                    *
 *                                                                            *
 *  Copyright:    (c) Mikroelektronika, 2011.                                 *
 *                                                                            *
 *  Description:  Bootloader configuration constants, memory allocation       *
 *                directives and MCU configuration.                           *
 *                Double click to open flash memory layout pdf:               *
 *                ac:PIC18F_USB_HID_BootLoader_Memory_Layout                  *
 *                                                                            *
 *  Requirements: PIC18F specific.                                            *
 *                                                                            *
 *  Migration:    Along with Config.h, this is the only file in this          *
 *                project that might need to be adjusted when migrating.      *
 *                Switching to another MCU within PIC18F family               *
 *                of microcontrollers, may require at most two constants      *
 *                to be changed:                                              *
 *                  1. DEVICE_NAME                                            *
 *                  2. BOOTLOADER_SIZE                                        *
 *                Target MCU may needs some additional initialization code.   *
 *                Place it in Config() routine.                               *
 *                If these are already set properly, we are all done :)       *
 *                                                                            *
 ****************************       CHANGE LOG       **************************
 * Version | ACTION                                           |  DATE  | SIG  *
 * --------|--------------------------------------------------|--------|----- *
 *         |                                                  |        |      *
 *    0.01 | - Initial release                                | 030511 |  ST  *
 *         |                                                  |        |      *
 ******************************************************************************/
#include <Main.h>
#include <Types.h>
#include <UHB_Driver.h>

/* Bootloader constantats */
const enum TMcuType MCU_TYPE = mtPIC18;       // Target MCU family.
                                              // Use predefined family constants (TMcuType).

// Device name: Name of hardware product bootloader is set for (not MCU name).
// This name will be displayed in PC application name field once device is detected.
#define DEVICE_NAME "GameTerminal"

const unsigned long BOOTLOADER_SIZE   = 6536; // Bootloader (this) code size.
                                              // Easiest way to set this field
                                              //   is to enter a large value here
                                              //   (i.e. half the MCU flash size),
                                              //   then compile the project and
                                              //   reset this value to the
                                              //   'USED ROM' value given in Compiler messages.
                                              // Recompile the project!

const unsigned int  BOOTLOADER_REVISION = 0x1200; // Version of bootlaoder firmware.

// Bootloader start address equasion:
const unsigned long BOOTLOADER_START  = ((__FLASH_SIZE-BOOTLOADER_SIZE)/_FLASH_ERASE)*_FLASH_ERASE;
const unsigned char RESET_VECTOR_SIZE = 4;    // MCU reset vector size in bytes.

// Bootloader info record.
// It is used by PC application tool to identify device and get device 
// specific information.
const TBootInfo BootInfo = { sizeof(TBootInfo),                   // This record's size in bytes.
                            {bifMCUTYPE,    MCU_TYPE},            // MCU family.
                            {bifMCUSIZE,    __FLASH_SIZE},        // MCU flash size.
                            {bifERASEBLOCK, _FLASH_ERASE},        // MCU Flash erase block size in bytes.
                            {bifWRITEBLOCK, _FLASH_WRITE_LATCH},  // MCU Flash write block size in bytes.
                            {bifBOOTREV,    BOOTLOADER_REVISION}, // Version of bootlaoder firmware.
                            {bifBOOTSTART,  BOOTLOADER_START},    // Bootloader code start address.
                            {bifDEVDSC,     DEVICE_NAME}          // Name of this device.
                           };
                        
/* Bootloader memory allocation */

// USB HID read/write buffers
// Buffers should be in USB RAM, please consult datasheet
unsigned char HidReadBuff[64]  absolute 0x500;          // USB HID read buffer.
unsigned char HidWriteBuff[64] absolute 0x540;          // USB HID write buffer.
unsigned char Reserve4thBankForUSB[256] absolute 0x400; // Dummy allocation of 4th bank 
                                                        //   (used by USB module internaly),
                                                        //   to prevent compiler from allocating
                                                        //   ram variables there.

/******************************************************************************
 *                                                                            *
 *  Macro:        ConfigMem()                                                 *
 *                                                                            *
 *  Description:  Specific program allocation directives:                     *
 *                  1. all routines above                                     *
 *                     BOOTLOADER_START-RESET_VECTOR_SIZE address.            *
 *                  2. bootloader main routine at BOOTLOADER_START address.   *
 *                  3. StartProgram routine at                                *
 *                     BOOTLOADER_START-RESET_VECTOR_SIZE address             *
 *                  4. dummy if to allocate Reserve4thBankForUSB buffer.      *
 *                                                                            *
 *  Parameters:   None.                                                       *
 *                                                                            *
 *  Return Value: None.                                                       *
 *                                                                            *
 *  Requirements: None.                                                       *
 *                                                                            *
 *  Notes:        None.                                                       *
 *                                                                            *
 ****************************       CHANGE LOG       **************************
 * Version | ACTION                                           |  DATE  | SIG  *
 * --------|--------------------------------------------------|--------|----- *
 *         |                                                  |        |      *
 *    0.01 | - Initial release                                | 030511 |  ST  *
 *         |                                                  |        |      *
 ******************************************************************************/
#define ConfigMem()   OrgAll(BOOTLOADER_START-RESET_VECTOR_SIZE); \
                      FuncOrg(main, BOOTLOADER_START); \
                      FuncOrg(StartProgram, BOOTLOADER_START-RESET_VECTOR_SIZE); \
                      if (Reserve4thBankForUSB) \
                        ;

/******************************************************************************
 *                                                                            *
 *  Function:     void Config()                                               *
 *                                                                            *
 *  Description:  MCU configuration and memory allocation directives.         *
 *                                                                            *
 *  Parameters:   None.                                                       *
 *                                                                            *
 *  Return Value: None.                                                       *
 *                                                                            *
 *  Requirements: None.                                                       *
 *                                                                            *
 *  Notes:        None.                                                       *
 *                                                                            *
 ****************************       CHANGE LOG       **************************
 * Version | ACTION                                           |  DATE  | SIG  *
 * --------|--------------------------------------------------|--------|----- *
 *         |                                                  |        |      *
 *    0.01 | - Initial release                                | 030511 |  ST  *
 *         |                                                  |        |      *
 ******************************************************************************/
void Config() {
  ConfigMem(); // allocate memory
}