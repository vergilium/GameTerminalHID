#ifndef PASSWORD_H
#define PASSWORD_H

#define PASS_START_ADDR                 0x01

void SendPassword (uint8_t);
void EEPROM_SavePassword (uint8_t *, uint8_t, uint8_t);
void EEPROM_ClearPassword (uint8_t, uint8_t);
//void GetPassword (uint8_t *);

#endif // PASSWORD_H