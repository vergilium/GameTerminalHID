/*
 * Project name: GameTerminal
 * Copyright (c) 2017 Vergilium
 * Description: ������� ��������. �������� ��� HID ���������� ����� USB
                ������������ PS2 ����������.
 * �onfiguration:
     MCU:             PIC18F2550
     Board:
     Oscillator:      HS+PLL, 48.000 MHz (12MHz Crystal)
     SW:              mikroC PRO for PIC
 */
#include <stdint.h>
#include "main.h"
#include "kb.h"

uint8_t readbuff[64] absolute 0x500;
uint8_t writebuff[64] absolute 0x540;
uint8_t modifier=0b00000000;                  //����������� ��� �������� �������������� ������� CtrlShiftAltWin
uint8_t reserved=0;                           //���������������� ���������� ��� �������� �������������
uint8_t keycode[6];                           //���������� �������� �� 6 ����� �������
uint8_t progPass[17] = {0};                   //���������� �������� ����� ������ ���������������� ��� �������� ������
uint8_t kybCnt = KYBCNT_DELAY;                //���������� ������� ������� ������������ ������ ����������

struct UFLG{                                  //����� ��� ������ � USB
   unsigned upBtn: 1;                         //���� ������������ ��� ������ ��������
   unsigned if_conf: 1;                       //���� ������������ ��� USB ���������. ����� ��� ����������� ����������� �� USB.
                                              //��� ��� � ���������� �� ������������� ������� ��������� ��������� USB ���������
                                              //������� �������. �� ��������.
} USBFlags at ADRESH;                         //��������� � �������� ADRESH

struct FLG{                                         //��������� ������, ����������� ������������� ��������� � ����� kb.c
   unsigned if_pc: 1;                               //0 = ��������� 1 = �����
   unsigned if_func: 1;
   unsigned if_up: 1;
   unsigned kb_mode: 1;                            //0 = ����������� ����������, 1 = �������
   unsigned kb_rw: 1;
   unsigned kb_parity: 1;
} sysFlags at CVRCON;                               //����� ����������� � �������� CVRCON �������� ����������� ������� �� ������������

void interrupt(){
     USB_Interrupt_Proc();                          // USB servicing is done inside the interrupt
     PS2_interrupt();                               //���������� �� INT1 ��� ����������� ������ � PS2
     if(SUSPND_bit) USBFlags.if_conf = 0;           //� ������ �������� USB � ����� SUSPEND(��������) ������������ ���� ������������ USB
}
void interrupt_low(){
     PS2_Timeout_Interrupt();     //���������� �� timer0 ����� 1�� � ������ ��������� ������ �� PS2
}

//==============================================================================
//    ������� ������� �������������
//==============================================================================
void Led_Indicate(unsigned char blink){
  unsigned char i;
  for(i=0; i<=blink; i++){
     LED_PIN = ~LED_PIN;
     delay_ms(100);
  }
  LED_PIN = 0;
}
//==============================================================================
//    ������� ��������� ������� ����. ��������
//==============================================================================
unsigned char ArrCmp(unsigned char * arr1, unsigned char * arr2, unsigned char pos, unsigned char ln){
   unsigned char i;
   for (i=0; i<ln; i++){
      if(arr1[i+pos] != arr2[i]) return 0;
   }
   return 1;
}
//==============================================================================
//    ���� �������� ���������
//==============================================================================
void main(){
        INTCON = 0;     //����������� ��� ����������
        //Initialize ports
        ADCON1 = 0x0F;  // Configure all PORT pins as digital
        /////////////////////��������� ������///////////////////////////////////
        TRISA= 0b00010000;
        TRISB= 0b00000011;
        TRISC= 0b10111000;
        PORTA= 0;
        PORTB= 0;
        PORTC= 0;
        //////////////////��������� ���������///////////////////////////////////
        ADRESH = 0;                            //����� �������� � ������� ��������� ����� USB(USBFlags)
        INTCON2.RBPU = 0;                      //�������� ��������
        init_kb();                             //������������� ���������� PS2
        HID_Enable(readbuff,writebuff);        //������������� USB � ������ HID ����������
        UART1_Init(9600);                      //������������� UART �� �������� 9600 bps
        sysFlags.kb_mode = EEPROM_Read(0x00);  //������ ����� ������������ ������ ����������
        Led_Indicate(2);                       //��������� ����������
        PWR12 = 1;                             //��������� ������� 12� �� �����
        INTCON |= (1<<GIE)|(1<<PEIE);          //���������� ���������� ����������
        while(!PS2_Send(0xFF));                //����� PS2 ����������
        //Main cycle
  while(1) {
        /////////////////////////////////////////////////////////////
        //////������������ � �� �� ����� � ��������� �����///////////
       if(button(&PORTC, RC7, 200, 0)){      //���� ��������� ���������
           LED_PIN = 1;                       //�������� ���������
           PWR5 = 1;                          //�������� 5� ������� �����
           VIDEO_PIN = 1;                     //����������� ������� �� �����
           sysFlags.if_pc = 1;                //���������� ��� �� �� �����
           USBFlags.if_conf = 0;              //���������� ���� ���������� �������� ������ � ��
           while(!PS2_Send(0xED));            //����� ������� ���������� �� ����������
           delay_ms(10);
           while(!PS2_Send(0x00));
           delay_ms(250);                     //��������
           LED_PIN = 0;                       //����� ���������
        }
        /////////////////////////////////////////////////////////////////////////////////
        ///��������� OUT �������� �� ����� (���������� ������������ ����������)//////////
        if(HID_Read()){
           USBFlags.if_conf = 1;                          //���� �� �������� ������ �� USB ������ �� ���������. ������������� ��������������� ����
           while(!PS2_Send(0xED));                        //����� �������� ������ � ����� � ����������
           delay_ms(10);
           while(!PS2_Send((readbuff[0] & 0x03) << 1));
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
                             EEPROM_Write(0,1);                            //������ � EEPROM ��������� 1 - ����� �������
                             sysFlags.kb_mode = 1;                         //���������� ���� ������ �������
                             kybCnt = KYBCNT_DELAY;                        //����� �������� �������� ������������ ����� �������� � �����������
                             uart_write(RDR_PRG_END);                      //������ �������� ������
                           }
                         } break;
           case KEY_NUM_ENTR : if(sysFlags.kb_mode == 1){                       //��������� ������������ �� ����������
                                 if(--kybCnt == 0){
                                    EEPROM_Write(0,0);                          //������ � EEPROM ��������� 1 - ����� ����������
                                    sysFlags.kb_mode = 0;                       //���������� ���� ������ ����������
                                    kybCnt = KYBCNT_DELAY;                      //����� �������� �������� ������������ ����� �������� � �����������
                                    uart_write(RDR_PRG_END);                    //������ �������� ������
                                 }
                               } break;
           default : kybCnt = KYBCNT_DELAY; break;                       //����� �������� ���� ������ �������� ��� ������ ������ ������
        }
        
        ///�������� ����� ����� ���������������� ������
        if(ArrCmp(&progPass, &progStr, 0, 16)){
           switch(progPass[16]){
              case KEY_1: UART1_Write(RDR_PRG_CH1); break;   //����������������1 - ���������
              case KEY_2: UART1_Write(RDR_PRG_CH2); break;   //����������������2 - �������
              case KEY_3: UART1_Write(RDR_PRG_CH3); break;   //����������������3 - �����
              case KEY_4: UART1_Write(RDR_PRG_CH4); break;   //����������������4 - �����
              case KEY_0: EEPROM_Write(0xFF,0xFF);           //������� � ����� ���������
                          HID_Disable();                     //���������� HID ����������
                          delay_ms(10);                      //�������� ��� ��, ����� ����� ���������
                          asm RESET; break;                  //����� ��
              default: break;
           }
           progPass[0] = 0;                         //����� ����� �����
        }
        ///�������� ����� ����� �������� ������
        else if(ArrCmp(&progPass, &delStr, 8, 8)){
           switch(progPass[16]){
              case KEY_1: UART1_Write(RDR_CLR_CH1); break;   //��������1 - ���������
              case KEY_2: UART1_Write(RDR_CLR_CH2); break;   //��������2 - �������
              case KEY_3: UART1_Write(RDR_CLR_CH3); break;   //��������3 - �����
              case KEY_4: UART1_Write(RDR_CLR_CH4); break;   //��������4 - �����
              case KEY_5: UART1_Write(RDR_CLR_ALL); break;   //��������5 - ���� ������
              default: break;
           }
           progPass[8] = 0;                         //����� �����
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
               writebuff[0]=modifier;                 //��������� �������� ������
               writebuff[1]=reserved;
               writebuff[2]=keycode[0];
               writebuff[3]=keycode[1];
               writebuff[4]=keycode[2];
               writebuff[5]=keycode[3];
               writebuff[6]=keycode[4];
               writebuff[7]=keycode[5];
               while(!HID_Write(writebuff,8));       //��������������� ���� ��������
               if(keycode[0] == 0)                   //���� ��� �� ����� ������� ������
                  USBFlags.upBtn == 1;               //������������� ���� ���������� ������
             }
           }
         delay_ms(30);
     }
  }
HID_Disable();
}