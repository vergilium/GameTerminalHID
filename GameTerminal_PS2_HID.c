/*
 * Project name: GameTerminal
 * Copyright (c) 2017 Vergilium
 * Description: ������� ��������. �������� ��� HID ���������� ����� USB
                ������������ PS2 ����������.
 * �onfiguration:
     MCU:             PIC18F2550
     Board:           Video-Sw 18.11.14
     Oscillator:      HS+PLL, 48.000 MHz (12MHz Crystal)
     SW:              mikroC PRO for PIC
 */
#include <stdint.h>
#include "main.h"
#include "usb.h"
#include "kb.h"
#include "Password.h"
////////////////////////////////������� ����������////////////////////////////////

////////////////////////////////���������� ����������/////////////////////////////
uint8_t keycode[6];                           //���������� �������� �� 6 ����� �������
uint8_t modifier=0b00000000;                  //����������� ��� �������� �������������� ������� CtrlShiftAltWin
uint8_t progPass[PASS_BUFF_SIZE] = {0};       //���������� �������� ����� ������ ���������������� ��� �������� ������
char passCnt = 0;                             //���������� ���������� ��������� �������� ������ (������ ���. ���������� ������ �����)
uint8_t kybCnt = KYBCNT_DELAY;                //���������� ������� ������� ������������ ������ ����������
uint8_t sysConfig;
struct SFLG{                                  //��������� ������, ����������� ������������� ��������� � ����� kb.c
   unsigned kb_mode: 1;                       //0 = ����������� ����������, 1 = �������
   unsigned usb_on: 1;                        //1 = usb ��������, 0 = usb �������
   unsigned kbBtn_mode: 1;                    //0 = 10 ������, 1 = 11 ������
   unsigned wr_pass: 1;                       //1 = ��������� ������ ������ ������
   unsigned if_pc: 1;                         //0 = ��������� 1 = �����
} sysFlags at CVRCON;                         //����� ����������� � �������� CVRCON �������� ����������� ������� �� ������������

void interrupt(){
     if(sysFlags.usb_on == 0)
        USBDev_IntHandler();      // USB servicing is done inside the interrupt
     PS2_interrupt();             //���������� �� INT1 ��� ����������� ������ � PS2
     PS2_Timeout_Interrupt();     //���������� �� timer0 ����� 1�� � ������ ��������� ������ �� PS2
}
/*void interrupt_low(){
}*/

// USB Device callback function called for various events
void USBDev_EventHandler(uint8_t event) {
    switch(event){
      case _USB_DEV_EVENT_CONFIGURED : USBFlags.if_conf = 1; break;
    //  case _USB_DEV_EVENT_RX_ERROR   : break;
    //  case _USB_DEV_EVENT_RESET      : break;
    //  case _USB_DEV_EVENT_ATTACHED   : break;
      case _USB_DEV_EVENT_SUSPENDED  : USBFlags.if_conf = 0; break;
      case _USB_DEV_EVENT_DISCONNECTED: USBFlags.if_conf = 0; break;
    //  case _USB_DEV_EVENT_WAKEUP     : break;
      default : break;
  }
}

// USB Device callback function called when packet received
void USBDev_DataReceivedHandler(uint8_t ep, uint16_t size) {
     USBFlags.hid_rec = 1;
}

// USB Device callback function called when packet is sent
void USBDev_DataSentHandler(uint8_t ep) {
//--------------------- User code ---------------------//
}

//==============================================================================
//    ������� ������� �������������
//    �������:        void
//    ���������:      uint8_t blink - ���������� �������
//==============================================================================
void Led_Indicate(uint8_t blink){
  uint8_t i;
  for(i=0; i<=blink; i++){
     LED_PIN = ~LED_PIN;
     delay_ms(100);
  }
  LED_PIN = 0;
}
//==============================================================================
//    ������� ��������� ������� ����. ��������
//    �������:        uint8_t - 0 = ������ �� �����  1 = ������ �����
//    ���������:      uint8_t *arr1 - ��������� �� ������ ��������� ������
//                    const uint8_t *arr2 - ��������� �� ����������� ������ �����
//                    uint8_t pos - ������� � ������� � ������� ���������� ���������
//                    uint8_t ln - ����� ������������ ��������
//==============================================================================
uint8_t ArrCmp(uint8_t *arr1, const uint8_t *arr2, uint8_t pos, uint8_t ln){
   uint8_t i;
   for (i=0; i<ln; i++){                                  //� ����� ���� ���������
      if((arr1[i+pos] & 0x7F) != arr2[i]) return 0;       //��������. 0�7F - �����, ��� ��� ������� ���
   }                                                      //������������ ��� �������� ������������ SHIFT
   return 1;
}

//==============================================================================
//    ���� �������� ���������
//==============================================================================
void main(){
   uint8_t i;
        INTCON = 0;     //����������� ��� ����������
        /////////////////////��������� ������///////////////////////////////////
        ADCON1 = 0x0F;  //���������������� ��� ����� ��� ��������
        TRISA= 0b00010000;
        TRISB= 0b00000011;
        TRISC= 0b10111000;
        PORTA= 0;
        PORTB= 0;
        PORTC= 0;
        INTCON2.RBPU = 0;                      //�������� ��������
        ///////////////////////////////////////////////////////////////
        /////////////������������� ���������///////////////////////////
        CVRCON = 0;                            //����� ��������� ������
        ADRESL = 0;                            //��������������
        Init_PS2();                            //������������� ���������� PS2
        UART1_Init(9600);                      //������������� UART �� 9600 bps
        /////���������� ������������ � EEPROM//////////////////////////
        sysConfig = EEPROM_Read(SYS_CONF_ADDR);                   //������ ����� ������������
        if(sysConfig == 0xFF) EEPROM_Write(SYS_CONF_ADDR,0);      //���� ������ �� ���������������� �� ������� ����� �� ���������
        sysFlags.kb_mode = sysConfig & 0x01;                      //������� ���� � ��������� ������������
        sysFlags.usb_on = (sysConfig & 0x02)>>1;
        sysFlags.kbBtn_mode = (sysConfig & 0x04)>>2;
        ///////////////////////////////////////////////////////////////
        PWR12 = 1;                             //��������� ������� 12� �� �����
        ///////////////////////////////////////////////////////////////
        ////////������������� USB HID//////////////////////////////////
        if(sysFlags.usb_on == 0){                                 //���� USB ������� �� ��������������
           USBDev_Init();
           USBFlags.hid_rec = 0;
        }
        IPEN_bit = 1;
        USBIP_bit = 1;
        USBIE_bit = 1;
        GIEH_bit = 1;
        ///////////////////////////////////////////////////////////////
        GIE_bit = 1;
        PEIE_bit = 1;
        delay_ms(100);
        Reset_PS2();                           //����� ����������
        Led_Indicate(2);                       //��������� ����������
        //�������� ����
  while(1) {
       asm clrwdt;                       //����� ����������� �������
       if(sysFlags.usb_on == ON)         //���� USB �������
          USB_StateInit();               //����������� ��������� USB
       ////////////////////////////////////////////////////////////////
       //////������������ � �� �� ����� � ��������� �����//////////////
       if(button(&PORTC, RC7, 200, 0)){          //���� ��������� ���������
           if(sysFlags.kbBtn_mode == KBBTN_10) LED_PIN = 1;  //�������� ��������� � ������ ���� �� ������������ 11� ����� �� ������
           if(keycode[0] == KEY_L_CTRL){         //���� ����� ����� CTRL � ��� ���� �������� ����
              SendPassword(PASS_START_ADDR);     //����������� ������� �������� ������������ ������
              delay_ms(9000);                    //����� ����� ������ ����� ������������ � ���������� �������� �� �����
           } else {                              //���� ����� CTRL �� ����� �� ����������� ������� �� �����
              Reset_PS2();                       //����� ����������
              PWR5 = 1;                          //�������� 5� ������� �����
              VIDEO_PIN = 1;                     //����������� ������� �� �����
              sysFlags.if_pc = 1;                //���������� ��� �� �� �����
           }
           delay_ms(1000);
           LED_PIN = 0;                          //����� ���������
        }
        /////////////////////////////////////////////////////////////////////////////////
        ///��������� OUT �������� �� ����� (���������� ������������ ����������)//////////
        if(USBFlags.hid_rec == 1){
           USBFlags.hid_rec = 0;
           PS2_Send(SET_KEYB_INDICATORS);
           delay_ms(10);
           PS2_Send(USB_GetLEDs());
           USB_ReceiveBuffSet();             // Prepere buffer for reception of next packet
        }
 ////////////////////////////////////////////////////////////////////////////////////////
 ////����� ��� ������� �� 2 �����: ����� ����� �  ����� ����������
 ////� ������ ���������� ���������� �������� ��� ������� USB ����������
 ////������ � ������ ����� �������� ������� ������ � ����������������� �����������
 ////� �������������� ������� ������ �� �����. � ������ ����� ������ � �� �� ����������
 ////////////////////////////////////////////////////////////////////////////////////////
     if(sysFlags.if_pc == 1){                         //���� �� �����
        switch(keycode[0]){
           case KEY_F12: if(sysFlags.kb_mode == 0)                         //��������� ������� ������ F12 (����� �� ����������������)
                            uart_write(RDR_PRG_END);
                            break;
           case KEY_F5 : if(sysFlags.kb_mode == 0){                        //��������� ������������ �� �������
                          if(--kybCnt == 0){
                             sysConfig |= 1;
                             EEPROM_Write(SYS_CONF_ADDR,sysConfig);
                             sysFlags.kb_mode = 1;
                       //      memset(keycode, 0, 6);                        //������� ����� ������ ����� ��������� ������ � ���������������
                             kybCnt = KYBCNT_DELAY;
                             uart_write(RDR_PRG_END);
                           }
                         } break;
           case KEY_NUM_ENTR : if(sysFlags.kb_mode == 1){                  //��������� ������������ �� ����������
                                 if(--kybCnt == 0){
                                    sysConfig &= ~1;
                                    EEPROM_Write(SYS_CONF_ADDR,sysConfig);
                                    sysFlags.kb_mode = 0;
                        //            memset(keycode, 0, 6);                 //������� ����� ������ ����� ��������� ������ � ���������������
                                    kybCnt = KYBCNT_DELAY;
                                    uart_write(RDR_PRG_END);
                                 }
                               } break;
           default : kybCnt = KYBCNT_DELAY; break;                       //����� �������� ���� ������ �������� ��� ������ ������ ������
        }
        //
        ///�������� ����� ����� ���������������� ������
        //
        if(ArrCmp(&progPass, &progStr, (PASS_BUFF_SIZE - (sizeof(progStr)+1)), sizeof(progStr))){
           switch(progPass[PASS_BUFF_SIZE-1]){
              case KEY_1: UART1_Write(RDR_PRG_CH1); break;   //����������������1 - ���������
              case KEY_2: UART1_Write(RDR_PRG_CH2); break;   //����������������2 - �������
              case KEY_3: UART1_Write(RDR_PRG_CH3); break;   //����������������3 - �����
              case KEY_4: UART1_Write(RDR_PRG_CH4); break;   //����������������4 - �����
              case KEY_0: EEPROM_Write(0xFF,0xFF);           //������� � ����� ���������
                          USBEN_bit = 0;                     //���������� HID ����������
                          delay_ms(10);                      //�������� ��� ��, ����� ����� ���������
                          asm RESET; break;                  //����� ��
              case KEY_P: uart_write(RDR_PRG_END);           //���� � ����� ���������������� ������, ������ �����
                          sysFlags.wr_pass = 1;              //������������� ��������������� ����
                          memset(progPass, 0, PASS_BUFF_SIZE);//������� ������ ����� ������
                          PS2_Send(SET_KEYB_INDICATORS);     //�������� �� ���������� ��������� SCR LOCK
                          delay_ms(10);
                          PS2_Send(SET_SCRL_LED);
                          break;
              case KEY_U: uart_write(RDR_PRG_END);            //��������� ���������� USB, ������
                          sysConfig &= ~(1<<1);               //������� ��� ������������ � ����������
                          EEPROM_write(SYS_CONF_ADDR,sysConfig);//����� ����� ������������ � EEPROM
                          delay_ms(10);
                          asm RESET;                           //������������� ����������
                          break;
              case KEY_E: sysConfig |= (1<<2);                 //��������� 11� ������, ��������� � ���������� ������������
                          EEPROM_write(SYS_CONF_ADDR, sysConfig);//������ ����� ����. � EEPROM
                          sysFlags.kbBtn_mode = 1;             //������������� �����. ����
                          uart_write(RDR_PRG_END);             //������ �� ����������
                          break;
              default: break;
           }
           progPass[PASS_BUFF_SIZE-2] = 0;                  //����� ����� �����
        }
        //
        ///�������� ����� ����� �������� ������
        //
        else if(ArrCmp(&progPass, &delStr, PASS_BUFF_SIZE - sizeof(delStr) - 1, sizeof(delStr))){
           switch(progPass[PASS_BUFF_SIZE-1]){
              case KEY_1: UART1_Write(RDR_CLR_CH1); break;   //��������1 - ���������
              case KEY_2: UART1_Write(RDR_CLR_CH2); break;   //��������2 - �������
              case KEY_3: UART1_Write(RDR_CLR_CH3); break;   //��������3 - �����
              case KEY_4: UART1_Write(RDR_CLR_CH4); break;   //��������4 - �����
              case KEY_5: UART1_Write(RDR_CLR_ALL); break;   //��������5 - ���� ������
              case KEY_P: EEPROM_ClearPassword(PASS_START_ADDR, PASS_BUFF_SIZE); //�������� ������ �����
                          uart_write(RDR_PRG_END);            //������ �� ����������
                          break;
              case KEY_U: uart_write(RDR_PRG_END);            //����������� USB ����������
                          sysConfig |= (1<<1);                //�������������� ����� ������
                          EEPROM_write(SYS_CONF_ADDR, sysConfig);//� ����� � EEPROM
                          USBEN_bit = 0;                     //���������� HID ����������
                          delay_ms(10);
                          asm RESET;                         //������������� ����������
                          break;
              case KEY_E: sysConfig &= ~(1<<2);              //����������� 11� ������, ����. ������
                          EEPROM_write(SYS_CONF_ADDR, sysConfig);//����� � EEPROM
                          sysFlags.kbBtn_mode = 0;           //���������� ��������������� ����
                          uart_write(RDR_PRG_END);           //������ �� ����������
                          break;
              default: break;
           }
           progPass[PASS_BUFF_SIZE-2] = 0;                    //����� ����� �����
        }
        ////////////////////////////////////////////////////////////////////////////
        //������ ������ ����������
        ///////////////////////////////////////////////////////////////////////////
        if(sysFlags.wr_pass == 1 && keycode[0] == KEY_ENTER){            //���� ���������� ���� ������ ������ � ������ ������ ENTER
                                                                         //����������� ��������� ���������� ����� ������ � ������ EEPROM
           passCnt = PASS_BUFF_SIZE-1;                                   //�������� �������� ������������� ������������ ����������� ��������
           while(progPass[passCnt] != 0 && passCnt >= 0) passCnt--;      //������������ ������� �������� ������� (������ ������� �������� ������ �����)
           if(passCnt != PASS_BUFF_SIZE-1){                              //���� ������ ������ ���� ������ ���������� ���������� ��� � ������
              EEPROM_ClearPassword(PASS_START_ADDR, PASS_BUFF_SIZE);     //����������� ������� ������� ������
              EEPROM_SavePassword(&progPass+(passCnt+1), PASS_BUFF_SIZE - (passCnt+1), PASS_START_ADDR);//����������� ����� ������
              PS2_Send(SET_KEYB_INDICATORS);                             //����� ���������� ����������
              delay_ms(10);
              PS2_Send(SET_OFF_LED);
              uart_write(RDR_PRG_END);                                   //����� ������
           } else {                                                      //���� �� ������� �� ������ �������
              PS2_Send(SET_KEYB_INDICATORS);                             //�������� ��� ����������
              delay_ms(10);
              PS2_Send(SET_NUM_LED | SET_CAPS_LED | SET_SCRL_LED);
              delay_ms(1000);                                            //���� �������
              PS2_Send(SET_KEYB_INDICATORS);                             //����� ��� ����������
              delay_ms(10);
              PS2_Send(SET_OFF_LED);
              uart_write(RDR_PRG_END);                                   //������ ��� ����
              delay_ms(600);
              uart_write(RDR_PRG_END);
           }
           sysFlags.wr_pass = 0;                                         //���������� ���� ������ ������
        }
     delay_ms(100);                                 //��������, �� ���� �������� ������� ����� ������� ������ �� ������������ ����� ����������� � ��������
     }else if(sysFlags.if_pc == 0){
             PWR5 = 0;                                 //���������� ������� � �����
             VIDEO_PIN = 0;                            //������������� �� ��
           if(USBFlags.if_conf == 1){                  //���� USB ��������� ����������� ��������� � �������� ������
     ///////////////////////////////////////////////////////////////////////////
     /////����� ������ "Keyboard HID"
     //����� ����������� ��� �������� ������� �� USB
     ///////////////////////////////////////////////////////////////////////////
             if(keycode[0] != 0)                      //���� ���� ������ ���� ������ ������
                  USBFlags.upBtn == 0;                //�������� ���� ��������� ������
             if(USBFlags.upBtn == 0){                 //���� ���� ������� �� �����������
               SendKeys(&keycode, modifier);          //�������� ������ ����������
               if(keycode[0] == 0){                   //���� ��� �� ����� ������� ������
                  USBFlags.upBtn == 1;                //������������� ���� ���������� ������
                  SendNoKeys();                       //���������� ���� (��� ������� ������)
               }
             }
           }
         delay_ms(30);
     }
  }
}