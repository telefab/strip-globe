
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>


/*
This demonstrator shows how to use the speed driver
*/

int main(int args, char *argv[])
{
	// Variables used
	int fs;
	char speed[1];
	
	// Opening the speed driver
	fs = open("/dev/speed",O_RDWR);
	
	if(args == 1) // No extra arguments, reading the last speed value sent
	{
		read(fs,&speed,1);
		printf("********** speed=%d ************\n",speed[0]);
	}
	else if(args == 2) // Speed given in the extra argument, sending it to the speed driver
	{
		speed[0] = (char) (atoi (argv[1]));
		write(fs,&speed,1);
	}
	
	// Closing the speed driver
	close(fs);
	return 0;
}
