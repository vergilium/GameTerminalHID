/******************************************************************************
 *                                                                            *
 *  Unit:         Config.h                                                    *
 *                                                                            *
 *  Copyright:    (c) Mikroelektronika, 2011.                                 *
 *                                                                            *
 *  Description:  Config.c declarations and some more.                        *
 *                                                                            *
 *  Requirements: PIC18F specific.                                            *
 *                                                                            *
 *  Migration:    Along with Config.c, this is the only file in this          *
 *                project that might need to be adjusted when migrating.      *
 *                Switching to another MCU within PIC18F family               *
 *                of microcontrollers, may require at most two defines        *
 *                to be changed:                                              *
 *                  1. FLASH_Write                                            *
 *                  2. FLASH_Erase                                            *
 *                If these are already set properly, we are all done :)       *
 *                                                                            *
 ****************************       CHANGE LOG       **************************
 * Version | ACTION                                           |  DATE  | SIG  *
 * --------|--------------------------------------------------|--------|----- *
 *         |                                                  |        |      *
 *    0.01 | - Initial release                                | 030511 |  ST  *
 *         |                                                  |        |      *
 ******************************************************************************/
#ifndef __CONFIG
#define __CONFIG

#include <Types.h>

extern const unsigned long BOOTLOADER_SIZE;   // Bootloader size.
extern const unsigned long BOOTLOADER_START;  // Bootloader start address.
extern const unsigned char RESET_VECTOR_SIZE; // MCU reset vector size.

extern const TBootInfo BootInfo;              // Bootloader info record,
                                              // containing device specific information.

extern unsigned char HidReadBuff[64];         // USB HID read buffer.
extern unsigned char HidWriteBuff[64];        // USB HID write buffer.
                                 
// Flash write and erase block sizes are MCU dependent.
// To reduce confusion and errors, these routines might not have 
// uniform names between different MCUs/architectures.
// Consult library manager for target MCU's flash handling routine names.
// and adjust defines below.
#define FLASH_Write FLASH_Write_32            // flash write (32 bytes)
#define FLASH_Erase FLASH_Erase_64            // flash erase (64 bytes)

void Config();                                // multi purpose configuration routine
#endif