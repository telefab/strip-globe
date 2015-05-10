#ifndef MASK_H
#define MASK_H

// Masks of the control signals
#define WR0 0x1
#define WR1 0x2
#define RAM_ENABLE 0x4
#define PS_CONTROL 0x8
#define RAM_READ 0x10
#define COPY 0x20
#define CHAR_ENABLE 0x40
#define ROT_ENABLE 0x80

// Address and size of the frame buffer 
#define FB_ADDR 0x43C30000
#define FB_SIZE 91200



#endif
