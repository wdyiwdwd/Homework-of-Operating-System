#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/wait.h>

#define LEN 128
#define SHOR 16

// ??????
void merge(char *s){
    char *p=s;
    while(*s!='\0')
    {
        while(*s==' ' &&*(s+1)==' '){s++;}
        *p=*s;s++;p++;
    }
    *p='\0';
}

// ???????? ???result? ?????length
void splitCommand(char* str, char* seps, char** result, int* length) {
    char *token;
    int count = 0;
    token = strtok(str, seps);
    while( token != NULL )
    {
        result[count] = token;
        token = strtok( NULL, seps );
        count++;
    }
    *length = count;
}

//???????
void execute(char **cmds)
{
    int error;
    char path[64] = "/bin/\0";
    strcat (path, cmds[0]);
    error = execv(path, cmds);
    if (error==-1)  printf("Wrong Command!\n");
    _exit(1);
}

// ?????????
int fatherCommand(char** cmds) {
    if (strcmp(cmds[0], "exit\0") == 0) {
        _exit(1);
    }
    else if (strcmp(cmds[0], "cd\0") == 0) {
        char buf[LEN];
        if (chdir(cmds[1])>=0)
        {
            getcwd(buf,sizeof(buf));
            printf("Dir is:%s\n",buf);
        }
        else
        {
            printf("Error path!\n");
        }
        return 1;
    }
    else if (strcmp(cmds[0], "pwd\0") == 0) {
        char buf[LEN];
        getcwd(buf, sizeof(buf));
        printf("Dir is:%s\n", buf);
        return 1;
    }
    return 0;
}

// ???????
void excutePipe(char** cmds1, char** cmds2)
{
    int fd[2];
    pipe(fd);
    if (fork() == 0) {
        dup2(fd[1], 1);
        close(fd[0]);
        close(fd[1]);
        execute(cmds1);
    }
    dup2(fd[0], 0);
    close(fd[0]);
    close(fd[1]);
    execute(cmds2);
}


int main() {
    pid_t pid;
    char str[LEN];
    while (1) {
        gets(str);
        merge(str);
        int isPipe = 0;
        int pipeCount = 2;
        char* pipiChar = "|";
        char* pipiStr[2] = {NULL, NULL};
        splitCommand(str, pipiChar, pipiStr, &pipeCount);
        char* seps = " ";
        char* cmds[SHOR];
        char* cmds2[SHOR];
        for (int i = 0; i < SHOR; i++) {
            cmds[i] = NULL;
            cmds2[i] = NULL;
        }
        int count = 0;
        splitCommand(pipiStr[0], seps, cmds, &count);
        if (pipiStr[1] != NULL) {
            isPipe = 1;
            splitCommand(pipiStr[1], seps, cmds2, &count);
        }
        if (fatherCommand(cmds) == 0) {
            pid = fork();
            if (pid == 0) {
                if (isPipe) excutePipe(cmds, cmds2);
                else execute(cmds);
                _exit(1);
            }
        }
        wait(NULL);
    }
    return 0;
}
