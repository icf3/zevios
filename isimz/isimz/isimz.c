/* ICF3-Z assembler & simulator
   Ver0.0 2019/04/23
   Ver0.1 2019/05/22
   Ver0.2 2020/01/13
   Ver0.3 2020/02/21
   ICF3-Z Project https://icf3z.idletime.tokyo/
   Naoki Hirayama
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "isimz.h"

static char ver[] = "0.3";
extern unsigned long long time;

unsigned int mode;
FILE *fp;

void exit_error(char* msg) {
    perror(msg);
    exit(-1);
}

int main(int argc,char *argv[]) {
    int exit_code = 0;
    int len;
    char* filename = NULL;

    if(sizeof(long long)!=8)
        printf("long long is no 8byte\n"),exit(-1);
    if(sizeof(int)!=4)
        printf("int is no 4byte\n"),exit(-1);
    if(sizeof(short)!=2)
        printf("short is no 2byte\n"),exit(-1);

    fp = stdout;
    mode = 0;
	
	if(argc == 1) {
        printf("isimz version %s\n",ver);
        printf("Usage: isimz <a,A,s,S> [<filename>]\n");
        printf("    a -  assemble > filename.bin\n");
        printf("    A -  assemble > stdout\n");
        printf("    s -  simulation > filename.res\n");
        printf("    S -  simulation > stdout\n");
        return -1;
    }
    if(argc == 2) {
        icf_asm("infile");
        icf_sim();
    }
	if(argv[1][0]=='a' || argv[1][0]=='s') {
        len = strlen(argv[2]);
        filename = (char*)malloc(len+5);
        if(filename==NULL) exit_error("malloc()");
        strcpy(filename,argv[2]);
        if(filename[len-4]!='a' || filename[len-3]!='s' || filename[len-2]!='m' || filename[len-1]!='z') {
            printf("file extention is not asm\n");
            return -1;
        }
        filename[len-5] = '\0';
    }
	if(argc==3 && argv[1][0]=='a') {
        mode |= M_BIN;
        strcat(filename,".bin");
        fp = fopen(filename,"w");
        free(filename);
        if(fp==NULL) exit_error("fopen()");
        icf_asm(argv[2]);
        fclose(fp);
		return 0;
    }
	if(argc==3 && argv[1][0]=='A') {
        mode |= M_STDOUT;
        icf_asm(argv[2]);
		return 0;
    }
	if(argc==3 && argv[1][0]=='s') {
        strcat(filename,".res");
        fp = fopen(filename,"w");
        free(filename);
        if(fp==NULL) exit_error("fopen()");
        icf_asm(argv[2]);
        exit_code = icf_sim();
    }
	if(argc==3 && argv[1][0]=='S') {
        icf_asm(argv[2]);
        exit_code = icf_sim();
    }
    printf("Sim end. end code = %d cyc = %llu\n",exit_code,time);
	if(fp!=stdout) fprintf(fp,"#Sim end. end code = %d cyc = %llu\n",exit_code,time);
	fclose(fp);
    return 0;
}
