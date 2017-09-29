#line 1 "C:/Users/Vergilium/Desktop/GameTerminal/GameTerminalHID/USB_DSC.c"
const unsigned int USB_VENDOR_ID = 0x4406;
const unsigned int USB_PRODUCT_ID = 0x0006;
const char USB_SELF_POWER = 0xC0;
const char USB_MAX_POWER = 50;
const char HID_INPUT_REPORT_BYTES = 64;
const char HID_OUTPUT_REPORT_BYTES = 64;
const char USB_TRANSFER_TYPE = 0x03;
const char EP_IN_INTERVAL = 10;
const char EP_OUT_INTERVAL = 10;

const char USB_INTERRUPT = 1;
const char USB_HID_EP = 1;
const char USB_HID_RPT_SIZE = 63;


const struct {
 char bLength;
 char bDescriptorType;
 unsigned int bcdUSB;
 char bDeviceClass;
 char bDeviceSubClass;
 char bDeviceProtocol;
 char bMaxPacketSize0;
 unsigned int idVendor;
 unsigned int idProduct;
 unsigned int bcdDevice;
 char iManufacturer;
 char iProduct;
 char iSerialNumber;
 char bNumConfigurations;
} device_dsc = {
 0x12,
 0x01,
 0x0200,
 0x00,
 0x00,
 0x00,
 8,
 USB_VENDOR_ID,
 USB_PRODUCT_ID,
 0x0001,
 0x01,
 0x02,
 0x00,
 0x01
 };


const char configDescriptor1[]= {

 0x09,
 0x02,
 0x29,0x00,
 1,
 1,
 0,
 USB_SELF_POWER,
 USB_MAX_POWER,


 0x09,
 0x04,
 0,
 0,
 2,
 0x03,
 1,
 1,
 0,


 0x09,
 0x21,
 0x01,0x01,
 0x00,
 1,
 0x22,
 USB_HID_RPT_SIZE,0x00,


 0x07,
 0x05,
 USB_HID_EP | 0x80,
 USB_TRANSFER_TYPE,
 0x40,0x00,
 EP_IN_INTERVAL,


 0x07,
 0x05,
 USB_HID_EP,
 USB_TRANSFER_TYPE,
 0x40,0x00,
 EP_OUT_INTERVAL
};

const struct {
 char report[];
}hid_rpt_desc =
 {
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


const struct {
 char bLength;
 char bDscType;
 unsigned int string[1];
 } strd1 = {
 4,
 0x03,
 {0x0409}
 };



const struct{
 char bLength;
 char bDscType;
 unsigned int string[10];
 }strd2={
 22,
 0x03,
 {'T','U',' ','G','a','b','r','o','v','o'}
 };


const struct{
 char bLength;
 char bDscType;
 unsigned int string[15];
}strd3={
 32,
 0x03,
 {'U','S','B',' ','M','a','n','i','p','u','l','a','t','o','r'}
 };


const char* USB_config_dsc_ptr[1];


const char* USB_string_dsc_ptr[3];

void USB_Init_Desc(){
 USB_config_dsc_ptr[0] = &configDescriptor1;
 USB_string_dsc_ptr[0] = (const char*)&strd1;
 USB_string_dsc_ptr[1] = (const char*)&strd2;
 USB_string_dsc_ptr[2] = (const char*)&strd3;
}
