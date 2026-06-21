#include <stdlib.h>
#include <unistd.h>

int main(void) {
    char command[1024];
    ssize_t n;

    write(1, "sh> ", 4);
    n = read(0, command, sizeof(command) - 1);
    if (n > 0) {
        command[n - 1] = '\0';
        system(command);
    }
    return 0;
}
