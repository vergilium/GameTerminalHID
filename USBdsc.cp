#line 1 "C:/Users/Vergilium/Desktop/GameTerminal/GameTerminalHID/USBdsc.c"
#line 1 "c:/program files (x86)/mikroc pro for pic/include/stdint.h"




typedef signed char int8_t;
typedef signed int int16_t;
typedef signed long int int32_t;


typedef unsigned char uint8_t;
typedef unsigned int uint16_t;
typedef unsigned long int uint32_t;


typedef signed char int_least8_t;
typedef signed int int_least16_t;
typedef signed long int int_least32_t;


typedef unsigned char uint_least8_t;
typedef unsigned int uint_least16_t;
typedef unsigned long int uint_least32_t;



typedef signed char int_fast8_t;
typedef signed int int_fast16_t;
typedef signed long int int_fast32_t;


typedef unsigned char uint_fast8_t;
typedef unsigned int uint_fast16_t;
typedef unsigned long int uint_fast32_t;


typedef signed int intptr_t;
typedef unsigned int uintptr_t;


typedef signed long int intmax_t;
typedef unsigned long int uintmax_t;
#line 3 "C:/Users/Vergilium/Desktop/GameTerminal/GameTerminalHID/USBdsc.c"
const uint8_t _USB_HID_MANUFACTURER_STRING[] = "Vergilium_Electronics";
const uint8_t _USB_HID_PRODUCT_STRING[] = "GameTerminalHID";
const uint8_t _USB_HID_SERIALNUMBER_STRING[] = "0x00000001";
const uint8_t _USB_HID_CONFIGURATION_STRING[] = "HID Config desc string";
const uint8_t _USB_HID_INTERFACE_STRING[] = "HID Interface desc string";


const uint8_t _USB_HID_CONFIG_DESC_SIZ = 34+7;
const uint8_t _USB_HID_DESC_SIZ = 9;
const uint8_t _USB_HID_REPORT_DESC_SIZE = 63;
const uint8_t _USB_HID_DESCRIPTOR_TYPE = 0x21;


const uint8_t _USB_HID_IN_PACKET = 64;
const uint8_t _USB_HID_OUT_PACKET = 64;


const uint8_t _USB_HID_IN_EP = 0x81;
const uint8_t _USB_HID_OUT_EP = 0x01;


const uint8_t USB_HID_LangIDDesc[0x04] = {
 0x04,
 _USB_DEV_DESCRIPTOR_TYPE_STRING,
 0x409 & 0xFF,
 0x409 >> 8,
};



const uint8_t USB_HID_device_descriptor[] = {
 0x12,
 0x01,
 0x00,
 0x02,
 0x00,
 0x00,
 0x00,
 0x08,
 0x09, 0x12,
 0x00, 0x03,
 0x00,
 0x01,
 0x01,
 0x02,
 0x00,
 0x01

};



const uint8_t USB_HID_cfg_descriptor[_USB_HID_CONFIG_DESC_SIZ] = {

 0x09,
 _USB_DEV_DESCRIPTOR_TYPE_CONFIGURATION,
 _USB_HID_CONFIG_DESC_SIZ & 0xFF,
 _USB_HID_CONFIG_DESC_SIZ >> 8,
 0x01,
 0x01,
 0x00,
 0x00,
 0x00,


 0x09,
 0x04,
 0x00,
 0x00,
 0x02,
 0x03,
 0x01,
 0x01,
 0,


 0x09,
 _USB_HID_DESCRIPTOR_TYPE,
 0x01,
 0x01,
 0x00,
 0x01,
 0x22,
 _USB_HID_REPORT_DESC_SIZE,
 0x00,


 0x07,
 _USB_DEV_DESCRIPTOR_TYPE_ENDPOINT,
 _USB_HID_IN_EP,
 0x03,
 _USB_HID_IN_PACKET,
 0x00,
 0x0A,


 0x07,
 _USB_DEV_DESCRIPTOR_TYPE_ENDPOINT,
 _USB_HID_OUT_EP,
 0x03,
 _USB_HID_IN_PACKET,
 0x00,
 0x0A

};


const uint8_t USB_HID_ReportDesc[_USB_HID_REPORT_DESC_SIZE] ={
 0x05, 0x01,
 0x09, 0x06,
 0xa1, 0x01,
 0x05, 0x07,
 0x19, 0xe0,
 0x29, 0xe7,
 0x15, 0x00,
 0x25, 0x01,
 0x75, 0x01,
 0x95, 0x08,
 0x81, 0x02,
 0x95, 0x01,
 0x75, 0x08,
 0x81, 0x01,
 0x95, 0x05,
 0x75, 0x01,
 0x05, 0x08,
 0x19, 0x01,
 0x29, 0x05,
 0x91, 0x02,
 0x95, 0x01,
 0x75, 0x03,
 0x91, 0x01,
 0x95, 0x06,
 0x75, 0x08,
 0x15, 0x00,
 0x25, 0x65,
 0x05, 0x07,
 0x19, 0x00,
 0x29, 0x65,
 0x81, 0x00,
 0xc0
};
