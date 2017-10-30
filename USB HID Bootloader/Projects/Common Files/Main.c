/******************************************************************************
 *                                                                            *
 *  Project:      USB HID Bootloader                                          *
 *                                                                            *
 *  Copyright:    (c) Mikroelektronika, 2011.                                 *
 *                                                                            *
 *  Description:  Bootloader is relatively small code which resides inside    *
 *                MCU flash. It is used, instead of programming tools, to     *
 *                load real program code into the MCU. Real program code can  *
 *                be passed from PC to bootloader by specific PC application  *
 *                (Bootloader Tool) over numerous communication interfaces.   *
 *                                                                            *
 *                This bootloader communicates with PC over USB HID inteface  *
 *                by using mikroE bootloader protocol. It is designed to      *
 *                work in conjuction with mikroE's 'USB HID Bootloader'       *
 *                PC application.                                             *
 *                                                                            *
 *  Requirements: - Minor modifications can make this code can work with any  *
 *                  MCU which has internal USB module and Flash self write    *
 *                  capabilities.                                             *
 *                - Bootloader code does not implement USB and Flash handling *
 *                  code (drivers). They are properties of mikroC compiler.   *
 *                - MikroE 'USB HID Bootloader' PC application.               *
 *                                                                            *
 *  Migration:    Making a bootloader for your own device is now an easy job. *
 *                1. Make a new project.                                      *
 *                   Select and configure target device.                      *
 *                2. Add these files to the project:                          *
 *                     - this Main.c  (Common FIles folder)                   *
 *                     - UHB_Driver.c (Driver folder)                         *
 *                     - USBdsc.c     (Driver folder)                         *
 *                3. Add these folders to header search paths:                *
 *                     - your Project folder                                  *
 *                     - Common Files folder                                  *
 *                     - Driver folder                                        *
 *                4. Copy Config.h and Config.c files from appropriate MCU    *
 *                   family folder to your project folder.                    *
 *                   If necessary, adjust Config files to suite your project. *
 *                5. All done, ready to compile :)                            *
 *                   Build the project and make bootloader firmware           *
 *                   for your device.                                         *
 *                                                                            *
 ****************************       CHANGE LOG       **************************
 * Version | ACTION                                           |  DATE  | SIG  *
 * --------|--------------------------------------------------|--------|----- *
 *         |                                                  |        |      *
 *    0.01 | - Initial release                                | 030511 |  ST  *
 *         |                                                  |        |      *
 ******************************************************************************/
#include <Config.h>
#include <UHB_Driver.h>
/******************************************************************************
 *                                                                            *
 *  Function:     void main(void)                                             *
 *                                                                            *
 *  Description:  Main loop.                                                  *
 *                                                                            *
 *  Parameters:   None.                                                       *
 *                                                                            *
 *  Return Value: None.                                                       *
 *                                                                            *
 *  Requirements: Must be allocated at the beginning of bootloader code       *
 *                (BOOTLOADER_START address).                                 *
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
void main(void) {
  //Initialize ports
        ADCON1 = 0x0F;  // Configure all PORT pins as digital
        TRISA= 0b00010000;
        TRISB= 0b00000011;
        TRISC= 0b10111000;
        PORTA= 0;
        PORTB= 0;
        PORTC= 0;
        INTCON2.RBPU = 0;
        
        if(button(&PORTC, RC7, 200, 0)) EEPROM_Write(0xFF,0xFF);
        if(EEPROM_Read(0xFF) == 0xFF){
             Config(); // Configure device and memory allocation.
             HID_Enable(&HidReadBuff, &HidWriteBuff); // Enable USB HID communication.
             //  asm CLRWDT;
             // wait 10secs for PC application bootloading request
             if (!EnterBootloaderMode()) { // Should we enter bootloader mode?
                 HID_Disable();              // No, disable USB HID module.
                 Delay_10ms();               // Wait a little bit.
                                             //   (PC's OS need some time to detect USB disconnection)
                 StartProgram();             // Start already loaded application.
             } else
                 StartBootloader();          // Yes, enter bootloader mode.
        } else StartProgram();
}