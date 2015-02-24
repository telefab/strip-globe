
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>



int main(int args, char *argv[])
{
	int fs;
	char speed[1];
	
	fs = open("/dev/speed",O_RDWR);
	
	if(args == 1)
	{
		read(fs,&speed,1);
		printf("********** speed=%d ************\n",speed[0]);
	}
	else if(args == 2)
	{
		write(fs,argv[1],1);
	}
	
	close(fs);
	return 0;
}