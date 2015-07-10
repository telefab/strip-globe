/**
 * Read a configuration file live
 * and display it on the globe
 */
#include "stdio.h"
#include "string.h"
#include "stdlib.h"
#include "stdint.h"
#include "unistd.h"
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/time.h>
#include "../mask.h"

#define NUM_LINES 49
#define NUM_COLS 100

typedef struct globe_t {
	uint8_t columns;
	uint8_t lines;
	uint8_t image[NUM_COLS][NUM_LINES][3];
	uint8_t rotation_speed;
} globe_t;

int main(int argc, char *argv[])
{
	// Variables used
    int fd, fc, fs;
	int i, j, rot, x, y = 0;
	int tt = 0;
    unsigned int *fb;
    char cntrl[1];	
	char speed[1];
	FILE * image_file;
	globe_t globe;
	uint32_t color;
	
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
	
	while(1)
	{
		// Pause during the step time
		for(tt = 0; tt < 10000000;tt++);

		// read configuration in the file
		image_file = fopen("sphere.colors", "rb");
		fread(&globe, sizeof(globe_t), 1, image_file);
		fclose(image_file);
		if (globe.lines != NUM_LINES || globe.columns != NUM_COLS) {
			printf("Error: wrong GUI configuration: %dx%d\n", globe.lines, globe.columns);
			return -1;
		}

		// Rotate the image
		if (globe.rotation_speed > 0)
			rot = (rot + 1) % 100;
		
		// Sending the image to the frame buffer
		for(i = 0;i < NUM_COLS;i++) 
		{
			for(j = 0;j < NUM_LINES;j++)
			{
				// Write the shifted image
				x = (i+rot) % NUM_COLS;
				y = NUM_LINES -1 -j;
				color = globe.image[x][y][2];
				color = color << 8;
				color+= globe.image[x][y][0];
				color = color << 8;
				color+= globe.image[x][y][1];
				*(fb + (i*NUM_LINES + j)) = color;
			}
		}
		
		// Switch the read frame buffer and the written frame buffer
		cntrl[0] = 1;
		write(fc, &cntrl, 1);
		cntrl[0] = 0;
		write(fc, &cntrl, 1);
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
