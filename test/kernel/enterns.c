#define _GNU_SOURCE  
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sched.h>

int main(int argc , char* argv[])
{
    int fd = open(argv[1], O_RDONLY);
    setns(fd, 0);
    execvp(argv[2], &argv[2]);
    return 0;
}