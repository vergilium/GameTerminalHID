#ifndef USB_H
#define USB_H

struct UFLG{
   unsigned upBtn: 1;                         //Флаг определяющий что кнопка отпущена
   unsigned if_conf: 1;                       //Флаг определяющий что USB подключен. Нужен для определения подключения по USB.
   unsigned hid_rec: 1;                       //Флаг получения данных от USB
} USBFlags at ADRESL;                         //Размещены в регистре ADRESH

void USB_StateInit (void);
void USB_ReceiveBuffSet (void);
void SendNoKeys (void);
void SendKey (uint8_t, uint8_t);
uint8_t SendKeys (uint8_t *, uint8_t);
uint8_t USB_GetLEDs (void);

#endif // USB_H