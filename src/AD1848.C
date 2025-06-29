#include <string.h>
#include "AD1848.H"

void AD1848_Reset(AD1848 *ad)
{
    memset(ad, 0, sizeof(*ad));
    ad->status = 0xcc;
    ad->mce = 0x40;
    ad->regs[0] = 0x00;
    ad->regs[1] = 0x00;
    ad->regs[2] = 0x80;
    ad->regs[3] = 0x80;
    ad->regs[4] = 0x80;
    ad->regs[5] = 0x80;
    ad->regs[6] = 0x80;
    ad->regs[7] = 0x80;
    ad->regs[8] = 0x00;
    ad->regs[9] = 0x08;
    ad->regs[10] = 0x00;
    ad->regs[11] = 0x00;
    ad->regs[12] = 0x0a;
    ad->regs[13] = 0x00;
    ad->regs[14] = 0x00;
    ad->regs[15] = 0x00;
}

uint8_t AD1848_Read(AD1848 *ad, uint16_t port)
{
    switch(port & 3)
    {
        case 0:
            return ad->index | ad->trd | ad->mce;
        case 1:
            return ad->regs[ad->index & 0x1F];
        case 2:
            return ad->status;
    }
    return 0xFF;
}

void AD1848_Write(AD1848 *ad, uint16_t port, uint8_t val)
{
    switch(port & 3)
    {
        case 0:
            ad->index = val & 0x1F;
            ad->trd   = val & 0x20;
            ad->mce   = val & 0x40;
            break;
        case 1:
            ad->regs[ad->index & 0x1F] = val;
            break;
        case 2:
            ad->status &= ~0x01; /* acknowledge interrupt */
            break;
    }
}

void AD1848_SetDMA(AD1848 *ad, int dma)
{
    ad->dma = dma;
}

void AD1848_SetIRQ(AD1848 *ad, int irq)
{
    ad->irq = irq;
}
