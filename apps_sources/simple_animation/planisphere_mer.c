
#include "stdio.h"
#include "string.h"
#include "stdlib.h"
#include "stdint.h"
#include "unistd.h"
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/time.h>
#include "../mask.h"
#include "../color.h"

#define NUM_LINES 49
#define NUM_COLS 100

// Image displayed by the demonstrator
unsigned int image[NUM_COLS][NUM_LINES] = {
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,R,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,R,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,R,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,R,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,R,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,R,R,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,R,R,R,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,R,R,R,R,R,R,R,B,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,R,R,R,R,R,R,R,R,R,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,R,R,R,R,R,R,R,R,R,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,R,R,R,R,R,R,R,R,R,R,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,R,R,R,R,R,R,R,R,R,R,R,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,R,R,R,R,R,R,R,R,R,R,R,R,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,R,R,R,R,R,R,R,R,R,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,R,B,B,B,R,R,R,B,B,R,R,R,R,R,R,R,R,B,B,B,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,R,R,B,B,R,B,R,B,B,B,R,R,R,R,R,R,R,R,B,B,B,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,R,R,R,R,B,R,B,B,B,B,B,B,R,R,R,R,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,R,R,R,B,B,R,B,B,B,R,R,R,R,R,R,R,R,B,B,B,B,B,B,B,B,B,Y,Y,Y,Y,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,R,R,B,B,B,B,R,R,B,R,R,R,R,R,R,R,B,B,B,B,B,B,B,B,Y,Y,Y,Y,Y,Y,Y,B,B,B,B,B,Y,Y,Y,B,B,B,B,B},
	{B,B,B,B,B,R,R,B,B,B,B,R,R,R,B,R,R,R,R,R,B,B,B,B,B,B,B,B,B,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,B,B,B,B,B},
	{B,B,B,B,B,B,B,R,R,B,B,B,R,B,B,R,R,R,B,B,B,B,B,B,B,B,B,B,B,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,R,R,R,B,B,B,B,B,B,B,B,R,B,B,B,B,B,B,B,B,B,B,B,B,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,R,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,Y,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,R,R,R,R,R,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,Y,Y,Y,Y,Y,Y,Y,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,R,R,R,R,R,R,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,Y,Y,Y,Y,Y,Y,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,R,R,R,R,R,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,Y,Y,Y,Y,Y,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,R,R,R,R,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,Y,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,R,R,R,R,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,R,R,R,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,R,R,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,R,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,P,P,P,P,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,P,P,P,P,P,P,P,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,P,P,P,P,P,P,P,P,P,P,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,P,P,P,B,P,P,P,P,P,P,P,P,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,P,P,P,B,B,P,P,P,P,P,P,P,P,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,P,B,B,P,P,P,B,B,P,P,P,P,P,P,P,P,P,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,P,P,P,P,B,P,P,P,B,B,B,P,P,P,P,P,P,P,P,P,P,P,P,P,P,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,P,P,P,B,B,B,P,P,P,B,B,B,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,P,P,B,B,B,P,P,P,P,P,B,B,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,P,P,P,P,P,P,P,P,P,B,B,B,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,P,P,P,P,P,P,P,P,B,G,G,B,B,P,P,P,P,P,P,P,P,P,P,P,P,P,P,P,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,P,P,P,P,P,P,B,B,G,G,G,G,B,P,P,P,P,P,P,P,P,P,P,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,G,G,G,G,G,G,G,G,G,G,G,G,G,G,B,P,P,P,P,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,B,P,P,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,G,G,G,G,G,G,G,B,B,B,G,G,B,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,G,G,G,G,G,G,G,G,G,G,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,G,G,G,G,G,G,G,G,G,G,G,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,G,G,G,G,G,G,G,G,G,G,G,B,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,P,P,P,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,G,G,G,G,G,G,G,G,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,P,P,P,P,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,G,G,G,G,G,G,G,G,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,P,P,P,P,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,G,G,G,G,G,G,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,P,P,P,P,P,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,G,G,G,G,G,B,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,P,P,P,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,G,G,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,P,P,P,P,P,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,G,G,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,P,P,P,P,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,G,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,G,G,G,B,B,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,G,G,G,B,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,G,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,G,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,G,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,G,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B},
	{B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B,B}
};


/*
This demonstrator displays the image on the globe and makes it rotate slowly
*/

int main(int argc, char *argv[])
{
	// Variables used
    int fd, fc, fs;
	int i, j, k = 0;
	int tt = 0;
    unsigned int *fb;
    char cntrl[1];	
	char speed[1];
	
	// 35 is a good speed for the globe
	if (argc == 1) {
		speed[0] = 35;
	} else {
		speed[0] = atoi(argv[1]);
	}
	
	// Opening and sending speed to the driver
	fs = open("/dev/speed",O_RDWR);
	write(fs, &speed, 1);
	
	// Opening the memory
    fd = open ("/dev/mem", O_RDWR);
    if (fd < 1) {
        perror("erreur ouverture /dev/mem\n");
        return -1;
    }

	// Mapping the frame buffer
    fb = mmap(NULL, FB_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, FB_ADDR);
    if  (fb == NULL) {
        printf("Error while mapping framebuffer\n");
        return -1;
    }
    	
	// Opening the control driver
    fc = open("/dev/cntrl", O_RDWR);
    if (fc < 1) {
        perror("erreur ouverture /dev/mem\n");
        return -1;
    }

	// Loop until the image has been shifted 300 times
	while(1)
	{
		// Pause during the step time
		for(tt = 0; tt < 10000000;tt++);
		
		// Sending the image to the frame buffer
		for(i = 0;i < NUM_COLS;i++) 
		{
			for(j = 0;j < NUM_LINES;j++)
			{
				// Write the shifted image
				*(fb + (i*NUM_LINES + j)) = image[(i+k) % NUM_COLS][NUM_LINES - 1 -j];
			}
		}
		
		// Switch the read frame buffer and the written frame buffer
		cntrl[0] = 1;
		write(fc, &cntrl, 1);
		cntrl[0] = 0;
		write(fc, &cntrl, 1);
		
		k++;
	}
	
	
	// Put the control signals back to zero
    cntrl[0] = 0;
    write(fc, &cntrl, 1); 

	// Unmapping the frame buffer
    munmap(fb, FB_SIZE);
	
	// Closing the drivers
    close(fc);
    close(fd);
	close(fs);

    return 0;
}
