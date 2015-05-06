
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>


/*
This demonstrator reads the real value of the rotating speed
*/

int main(int args, char *argv[])
{
	// Variables used
	int fs;
	int round;
	char speed[3];
	
	// Opening the round sensor driver
	fs = open("/dev/rnd",O_RDWR);
	
	// Reading the value of the round counters' registers
	read(fs,&speed,3);
	
	round = (int) speed[0];
	round += ((int) speed[1]) << 8;
	round += ((int) speed[2]) << 16;
	
	printf("********** speed=%d %d %d ************\n",speed[0],speed[1], speed[2]);
	printf("speed int : %d \n", round);	

	// Closing the round sensor driver
	close(fs);
	return 0;
}
