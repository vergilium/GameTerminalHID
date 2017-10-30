/******************************************************************************
 *                                                                            *
 *  Unit:         Types.h                                                     *
 *                                                                            *
 *  Copyright:    (c) Mikroelektronika, 2011.                                 *
 *                                                                            *
 *  Description:  Type definitions for this project.                          *
 *                                                                            *
 ****************************       CHANGE LOG       **************************
 * Version | ACTION                                           |  DATE  | SIG  *
 * --------|--------------------------------------------------|--------|----- *
 *         |                                                  |        |      *
 *    0.01 | - Initial release                                | 030511 |  ST  *
 *         |                                                  |        |      *
 ******************************************************************************/
#ifndef __TYPES
#define __TYPES

// Supported MCU families/types.
enum TMcuType {mtPIC16 = 1, mtPIC18, mtPIC18FJ, mtPIC24, mtDSPIC = 10, mtPIC32 = 20};

// Bootloader info field ID's.
enum TBootInfoField {bifMCUTYPE=1,  // MCU type/family.
                     bifMCUID,      // MCU ID number.
                     bifERASEBLOCK, // MCU flash erase block size.
                     bifWRITEBLOCK, // MCU flash write block size.
                     bifBOOTREV,    // Bootloader revision.
                     bifBOOTSTART,  // Bootloader start address.
                     bifDEVDSC,     // Device descriptor string.
                     bifMCUSIZE     // MCU flash size
                     };

// Suported commands.
enum TCmd {cmdNON=0,                // 'Idle'.
           cmdSYNC,                 // Synchronize with PC tool.
           cmdINFO,                 // Send bootloader info record.
           cmdBOOT,                 // Go to bootloader mode.
           cmdREBOOT,               // Restart MCU.
           cmdWRITE=11,             // Write to MCU flash.
           cmdERASE=21};            // Erase MCU flash.

/* Bootloader info field types */

// Byte field (1 byte).
typedef struct {
  char fFieldType;
  char fValue;
} TCharField;

// Int field (2 bytes).
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

// Long field (4 bytes).
typedef struct {
  char fFieldType;
  unsigned long fValue;
} TULongField;

// String field (MAX_STRING_FIELD_LENGTH bytes).
#define MAX_STRING_FIELD_LENGTH 20
typedef struct {
  char fFieldType;
  char fValue[MAX_STRING_FIELD_LENGTH];
} TStringField;

// Bootloader info record (device specific information).
typedef struct {
  char bSize;
  TCharField   bMcuType;
  TULongField  ulMcuSize;
  TUIntField   uiEraseBlock;
  TUIntField   uiWriteBlock;
  TUIntField   uiBootRev;
  TULongField  ulBootStart;
  TStringField sDevDsc;
} TBootInfo;
#endif