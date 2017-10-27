#include <stdint.h>
#include "usb.h"

uint8_t readbuff[64] absolute 0x500;          //����� ������ ������ �� USB
uint8_t writebuff[64] absolute 0x540;         //����� �������� ������ USB
uint8_t reserved=0;                           //���������������� ���������� ��� �������� �������������

//==============================================================================
//    ������� ����������� ������������ USB � ������������� ������
//    �������:        void
//    ���������:      void
//==============================================================================
void USB_StateInit (void){
   /////////////////////////////////////////////////////////////////
       //////////////����������� ��������� USB//////////////////////////
       //   _USB_DEV_STATE_CONFIGURED
       //   _USB_DEV_STATE_DETACHED
       //   _USB_DEV_STATE_ATTACHED
       //   _USB_DEV_STATE_POWERED
       //   _USB_DEV_STATE_DEFAULT
       //   _USB_DEV_STATE_ADDRESS
       //   _USB_DEV_STATE_SUSPEND
       if(USBDev_GetDeviceState() == _USB_DEV_STATE_CONFIGURED){
          USBFlags.if_conf = 1;                   //���� USB ��������������� ������������� ���� ���������� ������
          USBDev_SetReceiveBuffer(1, readbuff);   //����������������� ������� ������ ������ HID
       } else {
          USBFlags.if_conf = 0;                   //���� USB � ������ ������������� - ���������� ���� ������ USB
          delay_ms(10);                           //���� 10�� ����� ����� ���������� ��� �� ������������
       }
}
//==============================================================================
//    ����������������� ��������� ������ ��� USB
//    �������:        void
//    ���������:      void
//==============================================================================
void USB_ReceiveBuffSet (void){
   USBDev_SetReceiveBuffer(1, readbuff);
}
//==============================================================================
//    ������� �������� ����� ������� �� USB
//    �������:        uint8_t - ����������� ������� ������
//    ���������:      void
//==============================================================================
uint8_t SendKeys (uint8_t *keys, uint8_t modifier){
   uint8_t i = 0,
           cnt = 0;
      writebuff[0] = modifier;
      writebuff[1] = reserved;
      for(i=0; i<=5; i++){
         if(keys[i] != 0) cnt++;
         writebuff[i+2]=keys[i];
      }
      USBDev_HIDWrite(1,writebuff,8);
   return cnt;
}
//==============================================================================
//    �������� "��� ������ ���������" USB
//    �������:        void
//    ���������:      void
//==============================================================================
void SendNoKeys (void){
    memset(writebuff, 0, 8);
    USBDev_HIDWrite(1,writebuff,8);
}
//==============================================================================
//    ������� �������� ����� ������� �� USB
//    �������:        void
//    ���������:      uint8_t key - ������� ������� �� ��������
//                    uint8_t modif - �����������
//==============================================================================
void SendKey (uint8_t key, uint8_t modifier){
      writebuff[0] = modifier;
      writebuff[1] = reserved;
      writebuff[2] = key;
      memset(writebuff+3, 0, 5);
      USBDev_HIDWrite(1,writebuff,8);       //��������������� ���� ��������
}
//==============================================================================
//    ������� ��������� ��������� ����������� ���������� USB
//    �������:        uint8_t - ����� �����������
//    ���������:      void
//==============================================================================
uint8_t USB_GetLEDs (void){
      uint8_t leds;
      leds = (readbuff[0] & 0x07)<<1;
      if((leds & 0x08) == 8) leds = (leds & 0x07)|0x01;
      
      return leds;
}