#ifndef SCANCODES_H
#define SCANCODES_H

////////////////////////////////////////////////////////////////////
//         Соответствия символов ps2 HID
////////////////////////////////////////////////////////////////////
const code unsigned char scanCode[] = {     //Таблица обычных кнопок
//HID          func           PS2
0x01,          //Err          00
0x42,          //F9           01
0x00,          //Err          02
0x3E,          //F5           03
0x3C,          //F3           04
0x3A,          //F1           05
0x3B,          //F2           06
0x45,          //F12          07
0x00,          //Err          08
0x43,          //F10          09
0x41,          //F8           0A
0x3F,          //F6           0B
0x3D,          //F4           0C
0x2B,          //Tab          0D
0x35,          //`~           0E
0x67,          //Num =        0F
0x00,          //Err          10
0xE2,          //Left Alt     11
0xE1,          //Left Shift   12
0x00,          //Err          13
0xE0,          //Left Ctrl    14
0x14,          //Q q          15
0x1E,          //1 !          16
0x00,          //Err          17
0x00,          //Err          18
0x00,          //Err          19
0x1D,          //Z z          1A
0x16,          //S s          1B
0x04,          //A a          1C
0x1A,          //W w          1D
0x1F,          //2 @          1E
0x00,          //Err          1F
0x00,          //Err          20
0x06,          //C c          21
0x1B,          //X x          22
0x07,          //D d          23
0x08,          //E e          24
0x21,          //4 $          25
0x20,          //3 #          26
0x00,          //Err          27
0x00,          //Err          28
0x2C,          //Spase        29
0x19,          //V v          2A
0x09,          //F f          2B
0x17,          //T t          2C
0x15,          //R r          2D
0x22,          //5 %          2E
0x00,          //Err          2F
0x00,          //Err          30
0x11,          //N n          31
0x05,          //B b          32
0x0B,          //H h          33
0x0A,          //G g          34
0x1C,          //Y y          35
0x23,          //6 ^          36
0x00,          //Err          37
0x00,          //Err          38
0x00,          //Err          39
0x10,          //M m          3A
0x0D,          //J j          3B
0x18,          //U u          3C
0x24,          //7 &          3D
0x25,          //8 *          3E
0x00,          //Err          3F
0x00,          //Err          40
0x36,          //< ,          41
0x0E,          //K k          42
0x0C,          //I i          43
0x12,          //O o          44
0x27,          //0 )          45
0x26,          //9 (          46
0x00,          //Err          47
0x00,          //Err          48
0x37,          //> .          49
0x38,          //? /          4A
0x0F,          //L l          4B
0x33,          //; :          4C
0x13,          //P p          4D
0x2D,          //- _          4E
0x00,          //Err          4F
0x00,          //Err          50
0x00,          //Err          51
0x34,          //' "          52
0x00,          //Err          53
0x2F,          //[ {          54
0x2E,          //= +          55
0x00,          //Err          56
0x00,          //Err          57
0x39,          //CapsLock     58
0xE5,          //RightShift   59
0x28,          //Enter        5A
0x30,          //] }          5B
0x00,          //Err          5C
0x31,          //\ |          5D
0x00,          //Err          5E
0x00,          //Err          5F
0x00,          //Err          60
0x00,          //Err          61
0x00,          //Err          62
0x00,          //Err          63
0x00,          //Err          64
0x00,          //Err          65
0x2A,          //BackSpace    66
0x00,          //Err          67
0x00,          //Err          68
0x59,          //Num 1 End    69
0x00,          //Err          6A
0x5C,          //Num 4 Left   6B
0x5F,          //Num 7 Home   6C
0x85,          //Num          6D
0x00,          //Err          6E
0x00,          //Err          6F
0x62,          //Num 0 Insert 70
0x63,          //Num Del      71
0x5A,          //Num 2 Down   72
0x5D,          //Num 5        73
0x5E,          //Num 6 Right  74
0x60,          //Num 8 Up     75
0x29,          //Esc          76
0x53,          //Num Lock     77
0x44,          //F11          78
0x57,          //Num +        79
0x5B,          //Num PgDown   7A
0x56,          //Num -        7B
0x55,          //Num *        7C
0x61,          //Num 9 PgUp   7D
0x47,          //ScrolLock    7E
0x00,          //Err          7F
0x00,          //Err          80
0x00,          //Err          81
0x00,          //Err          82
0x40           //F7           83
};

////////////////////////////////////////////////////////////////////
//         Соответствия функциональных клавишь ps2 HID
////////////////////////////////////////////////////////////////////
const code unsigned char funCode[][2] = {      //Таблица функциональных кнопок
//AT   HID
{0x5A, 0x58},     //Num Enter
{0x69, 0x4D},     //End
{0x6C, 0x4A},     //Home
{0x70, 0x49},     //Insert
{0x71, 0x4C},     //Del
{0x72, 0x51},     //Down
{0x74, 0x4F},     //Right
{0x75, 0x52},     //Up
{0x7A, 0x4E},     //PgDown
{0x7C, 0x46},     //PrintScreen
{0x7D, 0x4B},     //PgUp
{0x7E, 0x48},     //Break
{0x14, 0xE4},     //Right Ctrl
{0x11, 0xE6},     //Right Alt
{0x27, 0xE7},     //Right WIN
{0x1F, 0xE3},     //Left WIN
{0x6B, 0x50},     //Left
{0x4A, 0x54}      //Num /
};

const code unsigned char dvFlags[] = {          //Флаги модификатора
0x01,                                      //DV_LEFT_CRTL
0x02,                                      //DV_LEFT_SHIFT
0x04,                                      //DV_LEFT_ALT
0x08,                                      //DV_LEFT_GUI
0x10,                                      //DV_RIGHT_CTRL
0x20,                                      //DV_RIGHT_SHIFT
0x40,                                      //DV_RIGHT_ALT
0x80,                                      //DV_RIGHT_GUI
};

////////////////////////////////////////////////////////////////////
//         Соответствия кнопок консоли для ПК
////////////////////////////////////////////////////////////////////
const code unsigned char kbRemark[] = {
KEY_H,                 //Info/help                KEY_F1
KEY_G,                 //Menu                     KEY_F2
KEY_P,                 //Collect/escape to PC     KEY_F3
KEY_F,                 //AutoPlay                 KEY_F4
KEY_1,                 //H1                       KEY_F5
KEY_2,                 //H2                       KEY_F6
KEY_3,                 //H3                       KEY_F7
KEY_4,                 //H4                       KEY_F8
KEY_5,                 //H5                       KEY_F9
KEY_M,                 //MaxBet                   KEY_F10
KEY_B,                 //Bet                      KEY_F11
KEY_SPACE              //Start                    KEY_F12
};

#endif // SCANCODES_H