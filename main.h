/*Файл заголовков для основной программы*/
#ifndef MAIN_H
#define MAIN_H

    #define KYBCNT_DELAY      50
    #define PASS_BUFF_SIZE    32
    //===========Коды пересылаемые считывателю==================================
    #define RDR_PRG_END       30
    #define RDR_PRG_CH1       201
    #define RDR_PRG_CH2       202
    #define RDR_PRG_CH3       203
    #define RDR_PRG_CH4       204
    #define RDR_CLR_CH1       205
    #define RDR_CLR_CH2       206
    #define RDR_CLR_CH3       207
    #define RDR_CLR_CH4       208
    #define RDR_CLR_ALL       209
    //==========================================================================
    #define SYS_CONF_ADDR     0          //Адрес в EEPROM для хранения конфигурации
    
    #define KBBTN_10          0
    #define KBBTN_11          1
    
    #define ON                1
    #define OFF               0
    
    const code unsigned char progStr[] = {
    0x0A,                    //п  g
    0x0B,                    //р  h
    0x0D,                    //о  j
    0x18,                    //г  u
    0x0B,                    //р  h
    0x09,                    //а  f
    0x19,                    //м  v
    0x19,                    //м  v
    0x05,                    //и  b
    0x0B,                    //р  h
    0x0D,                    //о  j
    0x07,                    //в  d
    0x09,                    //а  f
    0x1C,                    //н  y
    0x05,                    //и  b
    0x17                     //е  t
    };

    const code unsigned char delStr[] = {
    0x08,                    //у    e
    0x0F,                    //д    l
    0x09,                    //а    f
    0x0E,                    //л    k
    0x17,                    //е    t
    0x1C,                    //н    y
    0x05,                    //и    b
    0x17                     //е    t
    };

#endif // MAIN_H