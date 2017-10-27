#ifndef USB_H
#define USB_H

struct UFLG{
   unsigned upBtn: 1;                         //���� ������������ ��� ������ ��������
   unsigned if_conf: 1;                       //���� ������������ ��� USB ���������. ����� ��� ����������� ����������� �� USB.
   unsigned hid_rec: 1;                       //���� ��������� ������ �� USB
} USBFlags at ADRESL;                         //��������� � �������� ADRESH

void USB_StateInit (void);
void USB_ReceiveBuffSet (void);
void SendNoKeys (void);
void SendKey (uint8_t, uint8_t);
uint8_t SendKeys (uint8_t *, uint8_t);
uint8_t USB_GetLEDs (void);

#endif // USB_H