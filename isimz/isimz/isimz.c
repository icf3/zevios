/* ICF3-Z assembler & simulator
   Ver0.0 2019/4/23
   Ver0.1 2019/5/22
   ICF3-Z Project https://icf3z.idletime.tokyo/
   Naoki Hirayama
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "isimz.h"

static char ver[] = "0.1";
extern uint64_t time;

unsigned int mode;
FILE *fp;

void exit_error(char* msg) {
    perror(msg);
    exit(-1);
}

int main(int argc,char *argv[]) {
    int exit_code;
    int len;
    char* filename;

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
}
