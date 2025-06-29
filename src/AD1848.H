#ifndef AD1848_EMU_H
#define AD1848_EMU_H

#include <stdint.h>
#include <stdbool.h>

typedef struct {
    uint8_t index;
    uint8_t trd;
    uint8_t mce;
    uint8_t status;
    int dma;
    int irq;
    uint8_t regs[32];
} AD1848;

void AD1848_Reset(AD1848 *ad);
uint8_t AD1848_Read(AD1848 *ad, uint16_t port);
void AD1848_Write(AD1848 *ad, uint16_t port, uint8_t val);
void AD1848_SetDMA(AD1848 *ad, int dma);
void AD1848_SetIRQ(AD1848 *ad, int irq);

#endif // AD1848_EMU_H
