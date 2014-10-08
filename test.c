#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#define RXPIPE	0
#define TXPIPE	1

int main(int argc,char *argv[])
{
	int pipefds[2];
	pid_t pid;
	if(pipe(pipefds)< 0)
	{
		switch(errno)
		{
			case EMFILE:
				fprintf(stderr,"ERROR: EMFILE Too many file descriptors are in use by the process");
				break;
			case ENFILE:
				fprintf(stderr,"ERROR: ENFILE The system file table is full. ");
				break;
			default:
				fprintf(stderr,"ERROR: %d Cannot allocate wakeup pipe",errno);
				break;
		}
		return -1;
	}
	pid = fork();
	if(pid==-1)
	{
		switch(errno)
		{
			case EAGAIN:
				fprintf(stderr,"ERROR: The system-imposed limit on the total number of processes under execution would be exceeded or the system-imposed limit MAXUPRC (<sys/param.h>) on the total number of processes under execution by a single user would be exceeded");
				break;
			case ENOMEM:
				fprintf(stderr,"ERROR: There is insufficient swap space for the new process");
				break;
			default:
				fprintf(stderr,"ERROR: %d Cannot allocate wakeup pipe",errno);
				break;
		}
		return -2;
	}
	if(pid==0)
	{
		/* child process */
		printf("I am Luke and I will call uname now\n");
		dup2(pipefds[TXPIPE], STDOUT_FILENO);
		close(pipefds[RXPIPE]);
		
		char * const cmd[] = { "uname", "-a",NULL };
		if (execvp(cmd[0], cmd) == -1)
		{
			printf("I am Luke and I have an error\n");
			exit(-1);
		}
		printf("I am Luke and I'm done\n");
	}
	else
	{		 
		printf("I am Darth Vader, waiting for process %d to complete\n",(int)pid);

		int returnStatus=0;
		waitpid(pid, &returnStatus, 0);
		printf("I am Darth Vader, process has completed with status %d\n",returnStatus);
		close(pipefds[TXPIPE]);

		FILE *fromChild = fdopen(pipefds[RXPIPE], "r");
		int found=0;
		char *line=NULL;
		size_t linecap=255;
		int linelen;
		while ((linelen = getline(&line, &linecap, fromChild)) > 0)
		{
			printf("I am Darth Vader. Luke tells me %s\n",line);
			if(feof(fromChild))
			{
				break;
			}
		}
		printf("Darth Wader is done\n");
	}
}
