#ifndef KB_H
#define KB_H

    #define KEYB_DATA          PORTA.RA4   //Пин приема данных с клавматуры
    #define KEYB_CLOCK         PORTB.RB1   //Строб от клавиатуры
    
    #define KEYB_MODE_NOTCONFIGURE     0
    #define KEYB_MODE_CONFIGURED       1
    #define KEYB_MODE_ERROR            2
    
    #define KEYB_SEND_FALSE            0
    #define KEYB_SEND_OK               1
    #define KEYB_GET_FALSE             2
    #define KEYB_GET_OK                3
    
    #define KYB_FLAG_NORESPONSE        0
    #define KYB_FLAG_CMPSUCCES         1
    #define KYB_FLAG_ACKNOWLEDGE       2
    #define KYB_FLAG_RESEND            3
    #define KYB_FLAG_FAILURE           4
    
    #define KEYB_BREAK_CODE            0xF0
    #define KEYB_FUNC_CODE             0xE0
    #define KEYB_ACKNOWLEDGE           0xFA
    #define KEYB_RESEND                0xFE
    #define KEYB_FAILURE               0xFC
    #define KEYB_COMPLETE_SUCCESS      0xAA
    #define SET_KEYB_INDICATORS        0xED
    #define KEYB_RESET                 0xFF
                                                   //HID
    #define SET_CAPS_LED               0x04        //2
    #define SET_NUM_LED                0x02        //1
    #define SET_SCRL_LED               0x01        //4
    #define SET_OFF_LED                0x00

    #define BT_STOP1          PORTA.RA0   //1
    #define BT_STOP2          PORTA.RA1   //2
    #define BT_STOP3          PORTA.RA2   //3
    #define BT_STOP4          PORTA.RA3   //4
    #define BT_STOP5          PORTA.RA5   //5
    #define BT_BET            PORTB.RB5   //7
    #define BT_LINE           PORTB.RB6   //8
    #define BT_START          PORTB.RB4   //enter
    #define BT_INFO           PORTC.RC0   //9
    #define BT_MENU           PORTC.RC1   //0
    
    #define LED_PIN           PORTC.RC2
    #define VIDEO_PIN         PORTB.RB7
    #define SW_ON             PORTC.RC7
    #define PWR5              PORTB.RB2
    #define PWR12             PORTB.RB3
    

    #define KEY_A             0x04
    #define KEY_B             0x05
    #define KEY_C             0x06
    #define KEY_D             0x07
    #define KEY_E             0x08
    #define KEY_F             0x09
    #define KEY_G             0x0A
    #define KEY_H             0x0B
    #define KEY_I             0x0C
    #define KEY_J             0x0D
    #define KEY_K             0x0E
    #define KEY_L             0x0F
    #define KEY_M             0x10
    #define KEY_N             0x12
    #define KEY_O             0x12
    #define KEY_P             0x13
    #define KEY_Q             0x14
    #define KEY_R             0x15
    #define KEY_S             0x16
    #define KEY_T             0x17
    #define KEY_U             0x18
    #define KEY_V             0x19
    #define KEY_W             0x1A
    #define KEY_X             0x1B
    #define KEY_Y             0x1C
    #define KEY_Z             0x1D
    #define KEY_1             0x1E
    #define KEY_2             0x1F
    #define KEY_3             0x20
    #define KEY_4             0x21
    #define KEY_5             0x22
    #define KEY_6             0x23
    #define KEY_7             0x24
    #define KEY_8             0x25
    #define KEY_9             0x26
    #define KEY_0             0x27
    #define KEY_ENTER         0x28
    #define KEY_ESC           0x29
    #define KEY_BCSP          0x2A
    #define KEY_TAB           0x2B
    #define KEY_SPACE         0x2C
    #define KEY_CAPLCK        0x39
    #define KEY_F1            0x3A
    #define KEY_F2            0x3B
    #define KEY_F3            0x3C
    #define KEY_F4            0x3D
    #define KEY_F5            0x3E
    #define KEY_F6            0x3F
    #define KEY_F7            0x40
    #define KEY_F8            0x41
    #define KEY_F9            0x42
    #define KEY_F10           0x43
    #define KEY_F11           0x44
    #define KEY_F12           0x45
    #define KEY_PRTSCRN       0x46
    #define KEY_SCRLCK        0x47
    #define KEY_INSERT        0x49
    #define KEY_HOME          0x4A
    #define KEY_PGUP          0x4B
    #define KEY_DEL           0x4C
    #define KEY_END           0x4D
    #define KEY_PGDWN         0x4E
    #define KEY_RIGHT         0x4F
    #define KEY_LEFT          0x50
    #define KEY_DOWN          0x51
    #define KEY_UP            0x52
    #define KEY_NUMLCK        0x53
    #define KEY_NUM_MUL       0x55            //*
    #define KEY_NUM_MINUS     0x56            //-
    #define KEY_NUM_PLUS      0x57            //+
    #define KEY_NUM_ENTR      0x58
    #define KEY_NUM_1         0x59
    #define KEY_NUM_2         0x5A
    #define KEY_NUM_3         0x5B
    #define KEY_NUM_4         0x5C
    #define KEY_NUM_5         0x5D
    #define KEY_NUM_6         0x5E
    #define KEY_NUM_7         0x5F
    #define KEY_NUM_8         0x60
    #define KEY_NUM_9         0x61
    #define KEY_NUM_0         0x62
    #define KEY_NUM_DEL       0x63
    #define KEY_L_CTRL        0xE0
    #define KEY_L_SHIFT       0xE1
    #define KEY_L_ALT         0xE2
    #define KEY_L_WIN         0xE3
    #define KEY_R_CTRL        0xE4
    #define KEY_R_SHIFT       0xE5
    #define KEY_R_ALT         0xE6
    #define KEY_R_WIN         0xE7
    
    #define PASS_BUFF_SIZE    32
    
    void Init_PS2(void);
    unsigned char Reset_PS2(void);
    unsigned char GetState_PS2(void);
    void KeyDecode(unsigned char);
    void PS2_interrupt(void);
    void PS2_Timeout_Interrupt(void);
    unsigned char PS2_Send(unsigned char);
    
#endif // KB_H