#ifndef WSS_EMU_H
#define WSS_EMU_H

#include <stdint.h>
#include <stdbool.h>
#include "PLATFORM.H"
#include "AD1848.H"

void WSS_Reset(void);
uint8_t WSS_ReadPort(uint16_t port);
void WSS_WritePort(uint16_t port, uint8_t value);
int WSS_GetDMA(void);
int WSS_GetIRQ(void);
bool WSS_IRQFree(void);
uint32_t WSS_Port(uint32_t port, uint32_t val, uint32_t out);

#endif // WSS_EMU_H
