#include <stdint.h>

const uint8_t _USB_HID_MANUFACTURER_STRING[]  = "Vergilium_Electronics";
const uint8_t _USB_HID_PRODUCT_STRING[]       = "GameTerminalHID";
const uint8_t _USB_HID_SERIALNUMBER_STRING[]  = "0x00000001";
const uint8_t _USB_HID_CONFIGURATION_STRING[] = "HID Config desc string";
const uint8_t _USB_HID_INTERFACE_STRING[]     = "HID Interface desc string";

// Sizes of various descriptors
const uint8_t _USB_HID_CONFIG_DESC_SIZ   = 34+7;
const uint8_t _USB_HID_DESC_SIZ          = 9;
const uint8_t _USB_HID_REPORT_DESC_SIZE  = 63;
const uint8_t _USB_HID_DESCRIPTOR_TYPE   = 0x21;

// Endpoint max packte size
const uint8_t _USB_HID_IN_PACKET  = 64;
const uint8_t _USB_HID_OUT_PACKET = 64;

// Endpoint address
const uint8_t _USB_HID_IN_EP      = 0x81;
const uint8_t _USB_HID_OUT_EP     = 0x01;

//String Descriptor Zero, Specifying Languages Supported by the Device
const uint8_t USB_HID_LangIDDesc[0x04] = {
  0x04,
  _USB_DEV_DESCRIPTOR_TYPE_STRING,
  0x409 & 0xFF,
  0x409 >> 8,
};


// device descriptor
const uint8_t USB_HID_device_descriptor[] = {
  0x12,       // bLength
  0x01,       // bDescriptorType
  0x00,       // bcdUSB
  0x02,
  0x00,       // bDeviceClass
  0x00,       // bDeviceSubClass
  0x00,       // bDeviceProtocol
  0x08,       // bMaxPacketSize0
  0x09, 0x12, // idVendor
  0x00, 0x03, // idProduct
  0x00,       // bcdDevice
  0x01,
  0x01,       // iManufacturer
  0x02,       // iProduct
  0x00,       // iSerialNumber
  0x01        // bNumConfigurations

};

//contain configuration descriptor, all interface descriptors, and endpoint
//descriptors for all of the interfaces
const uint8_t USB_HID_cfg_descriptor[_USB_HID_CONFIG_DESC_SIZ] = {
  // Configuration descriptor
  0x09,                                   // bLength: Configuration Descriptor size
  _USB_DEV_DESCRIPTOR_TYPE_CONFIGURATION, // bDescriptorType: Configuration
  _USB_HID_CONFIG_DESC_SIZ & 0xFF,        // wTotalLength: Bytes returned
  _USB_HID_CONFIG_DESC_SIZ >> 8,          // wTotalLength: Bytes returned
  0x01,                                   // bNumInterfaces: 1 interface
  0x01,                                   // bConfigurationValue: Configuration value
  0x00,                                   // /4 iConfiguration: Index of string descriptor describing  the configuration
  0x00,                                   // bmAttributes: self powered and Support Remote Wake-up
  0x00,                                   // MaxPower 100 mA: this current is used for detecting Vbus

  // Interface Descriptor
  0x09,                                   // bLength: Interface Descriptor size
  0x04,                                   // bDescriptorType: Interface descriptor type
  0x00,                                   // bInterfaceNumber: Number of Interface
  0x00,                                   // bAlternateSetting: Alternate setting
  0x02,                                   // bNumEndpoints
  0x03,                                   // bInterfaceClass: HID
  0x01,                                   // bInterfaceSubClass : 1=BOOT, 0=no boot
  0x01,                                   // nInterfaceProtocol : 0=none, 1=keyboard, 2=mouse
  0,                                      // iInterface: Index of string descriptor

  // HID Descriptor
  0x09,                                   // bLength: HID Descriptor size
  _USB_HID_DESCRIPTOR_TYPE,               // bDescriptorType: HID
  0x01,                                   // bcdHID: HID Class Spec release number
  0x01,
  0x00,                                   // bCountryCode: Hardware target country
  0x01,                                   // bNumDescriptors: Number of HID class descriptors to follow
  0x22,                                   // bDescriptorType
  _USB_HID_REPORT_DESC_SIZE,              // wItemLength: Total length of Report descriptor
  0x00,

  // Endpoint descriptor
  0x07,                                   // bLength: Endpoint Descriptor size
  _USB_DEV_DESCRIPTOR_TYPE_ENDPOINT,      // bDescriptorType:
  _USB_HID_IN_EP,                         // bEndpointAddress: Endpoint Address (IN)
  0x03,                                   // bmAttributes: Interrupt endpoint
  _USB_HID_IN_PACKET,                     // wMaxPacketSize
  0x00,
  0x0A,                                   // bInterval: Polling Interval (10 ms)

  // Endpoint descriptor
  0x07,                                   // bLength: Endpoint Descriptor size
  _USB_DEV_DESCRIPTOR_TYPE_ENDPOINT,      // bDescriptorType:
  _USB_HID_OUT_EP,                        // bEndpointAddress: Endpoint Address (IN)
  0x03,                                   // bmAttributes: Interrupt endpoint
  _USB_HID_IN_PACKET,                     // wMaxPacketSize
  0x00,
  0x0A                                    // bInterval: Polling Interval (10 ms)

};

// HID report descriptor
const uint8_t USB_HID_ReportDesc[_USB_HID_REPORT_DESC_SIZE] ={
    0x05, 0x01,                    // USAGE_PAGE (Generic Desktop)
    0x09, 0x06,                    // USAGE (Keyboard)
    0xa1, 0x01,                    // COLLECTION (Application)
    0x05, 0x07,                    //   USAGE_PAGE (Keyboard)
    0x19, 0xe0,                    //   USAGE_MINIMUM 224(Keyboard LeftControl)
    0x29, 0xe7,                    //   USAGE_MAXIMUM 231(Keyboard Right GUI)    (left and right: alt, shift, ctrl and win)
    0x15, 0x00,                    //   LOGICAL_MINIMUM (0)
    0x25, 0x01,                    //   LOGICAL_MAXIMUM (1)
    0x75, 0x01,                    //   REPORT_SIZE (1)
    0x95, 0x08,                    //   REPORT_COUNT (8)
    0x81, 0x02,                    //   INPUT (Data,Var,Abs)
    0x95, 0x01,                    //   REPORT_COUNT (1)
    0x75, 0x08,                    //   REPORT_SIZE (8)
    0x81, 0x01,                     //   INPUT (Constant)
    0x95, 0x05,                    //   REPORT_COUNT (5)
    0x75, 0x01,                    //   REPORT_SIZE (1)
    0x05, 0x08,                    //   USAGE_PAGE (LEDs)
    0x19, 0x01,                    //   USAGE_MINIMUM (Num Lock)
    0x29, 0x05,                    //   USAGE_MAXIMUM (Kana)
    0x91, 0x02,                    //   OUTPUT (Data,Var,Abs)
    0x95, 0x01,                    //   REPORT_COUNT (1)
    0x75, 0x03,                    //   REPORT_SIZE (3)
    0x91, 0x01,                    //   OUTPUT (Cnst)
    0x95, 0x06,                    //   REPORT_COUNT (6)
    0x75, 0x08,                    //   REPORT_SIZE (8)
    0x15, 0x00,                    //   LOGICAL_MINIMUM (0)
    0x25, 0x65,                    //   LOGICAL_MAXIMUM (101)
    0x05, 0x07,                    //   USAGE_PAGE (Keyboard)
    0x19, 0x00,                    //   USAGE_MINIMUM (Reserved (no event indicated))
    0x29, 0x65,                    //   USAGE_MAXIMUM (Keyboard Application)
    0x81, 0x00,                    //   INPUT (Data,Ary,Abs)
    0xc0                           // END_COLLECTION                   // End Collection
};