/*���� ���������� ��� �������� ���������*/
#ifndef MAIN_H
#define MAIN_H

    #define KYBCNT_DELAY      50
    #define PASS_BUFF_SIZE    32
    
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
    
    const code unsigned char progStr[] = {
    0x0A,                    //�  g
    0x0B,                    //�  h
    0x0D,                    //�  j
    0x18,                    //�  u
    0x0B,                    //�  h
    0x09,                    //�  f
    0x19,                    //�  v
    0x19,                    //�  v
    0x05,                    //�  b
    0x0B,                    //�  h
    0x0D,                    //�  j
    0x07,                    //�  d
    0x09,                    //�  f
    0x1C,                    //�  y
    0x05,                    //�  b
    0x17                     //�  t
    };

    const code unsigned char delStr[] = {
    0x08,                    //�    e
    0x0F,                    //�    l
    0x09,                    //�    f
    0x0E,                    //�    k
    0x17,                    //�    t
    0x1C,                    //�    y
    0x05,                    //�    b
    0x17                     //�    t
    };
    
    /*const code unsigned char progStr[] = {
    0x17                     //�  t
    0x05,                    //�  b
    0x1C,                    //�  y
    0x09,                    //�  f
    0x07,                    //�  d
    0x0D,                    //�  j
    0x0B,                    //�  h
    0x05,                    //�  b
    0x19,                    //�  v
    0x19,                    //�  v
    0x09,                    //�  f
    0x0B,                    //�  h
    0x18,                    //�  u
    0x0D,                    //�  j
    0x0B,                    //�  h
    0x0A,                    //�  g

    };

    const code unsigned char delStr[] = {
    0x17                     //�    t
    0x05,                    //�    b
    0x1C,                    //�    y
    0x17,                    //�    t
    0x0E,                    //�    k
    0x09,                    //�    f
    0x0F,                    //�    l
    0x08,                    //�    e
    };*/
#endif // MAIN_H