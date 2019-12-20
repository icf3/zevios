/* ICF3-Z assembler & simulator
   ICF3-Z Project https://icf3z.idletime.tokyo/
   Naoki Hirayama
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <errno.h>
#include "isimz.h"

#define LINE_SIZE     (2048)
#define NEM_SIZE (32)
#define WORD_SIZE (32)
#define MAX_LBL     (1024)
#define MAX_DEF     (256)

uint32_t PCODE[PLEN];
uint32_t PDEBUG[PLEN];

static char lbl[MAX_LBL][NEM_SIZE];
static uint32_t lbl_adr[MAX_LBL];
static int lbl_ptr;

static char def[MAX_DEF][WORD_SIZE];
static unsigned short def_num[MAX_DEF];
static int def_ptr;

char cmd[32][NEM_SIZE];
int vcmd;

static int s_line;
static int err_line;
char buf[LINE_SIZE];

void exit_msg(char* msg) {
    fprintf(fp,"%s\n",msg);
    exit(-1);
}

void exit_msg_s(char* msg,char *s) {
    fprintf(fp,"%s %s\n",msg,s);
    exit(-1);
}

#define EXIT_SYNTAX_ERROR() exit_syntax_error(__LINE__)

void exit_syntax_error(int n) {
    fprintf(fp,"ERROR: syntax error(%d) in %d\n%s\n",n,err_line,buf);
    exit(-1);
}

void exit_range_over() {
    fprintf(fp,"ERROR: range over in %d\n%s\n",err_line,buf);
    exit(-1);
}

void delete_space(char *p) {
    int i,j;
	for(i=j=0; i<LINE_SIZE && p[i]!='\0' ; i++)
		if(p[i] != ' ' && p[i] != '\n') p[j++] = p[i];
	if(i == LINE_SIZE) {
        fprintf(fp,"delete_space() buffer over\n");
		exit(-1);
    }
	p[j] = '\0';
}

int is_lbl(char *p,unsigned long adr) {
	int i;
	for(i=0 ; i<LINE_SIZE && p[i]!=':' && p[i]!='\0' ; i++)
	    lbl[lbl_ptr][i] = p[i];
    if(p[i]==':') {
		lbl_adr[lbl_ptr] = adr;
		lbl[lbl_ptr++][i] = '\0';
        if(lbl_ptr>=MAX_LBL) exit_msg("too many lbls");
        return 0;
	}
	return 1;
}

int skip_adr(int adr) {
    return ((adr+3)/8)*8+4;
}

int StrCmp(char *p,const char *q) {
	int i;
    for(i=0 ; i<NEM_SIZE && p[i]!='\0' ; i++)
		if(p[i]!=q[i] && q[i]!='?') return 0;
	if(i==NEM_SIZE) exit_msg("StrCmp Error");
	if(q[i] != '\0') return 0;
	vcmd = 1;
	return 1;
}

int StrMch(char *p,const char *q) {
	int i;
    for(i=0 ; i<NEM_SIZE && q[i] != '\0' ; i++)
		if(p[i] != q[i] && q[i]!='?') return 0;
	if(i==NEM_SIZE) exit_msg("StrMch Error");
	vcmd = 1;
	return 1;
}

void resource_check(uint32_t c) {
    static uint32_t chk = 0;
    if(c==0) chk=0;
    if(chk & c) {
        fprintf(fp,"ERROR: mnemonic conflict in %d\n",s_line);
        fprintf(fp,"%08X %08X\n",c,chk);
        fprintf(fp,"%s\n",buf);
    }
	chk |= c;
}    

void CODE(uint32_t* code, uint32_t nem, uint32_t chk) {
    if(chk!=0) resource_check(nem);
    *code |= nem;
}

void CODE_OP(uint32_t* code,int op) {
    resource_check(0x3e000000);
    *code |= op<<25;
}

void CODE_BC(uint32_t* code, int s) {
    int c = ((*code)>>20)&0xF;
    if((s&0xF)!=s) exit_msg("Internal Error CODE_BC()");

    switch (c) {
    case 0:
        *code |= s<<20;
        return;
    case 1:
        if(s==4) *code |= 5<<20;
        if(s==8) *code |= 9<<20;
        if(s==12) *code |= 13<<20;
        if(s==4 || s==8 || s==12) return;
         break;
    case 2:
        if(s==4) *code |= 6<<20;
        if(s==8) *code |= 10<<20;
        if(s==4 || s==8) return;
        break;
    case 3:
        if(s==4) *code |= 7<<20;
        if(s==12) *code |= 15<<20;
        if(s==4 || s==12) return;
        break;
    case 4:
        if(s==1) *code |= 5<<20;
        if(s==2) *code |= 6<<20;
        if(s==3) *code |= 7<<20;
        if(s==1 || s==2 || s==3) return;
        break;
    case 8:
        if(s==1) *code |= 9<<20;
        if(s==2) *code |= 10<<20;
        if(s==1 || s==2) return;
        break;
    case 12:
        if(s==1) *code |= 13<<20;
        if(s==3) *code |= 15<<20;
        if(s==1 || s==3) return;
    }
    exit_msg("Invalid B, C combination");
}

void CODE_JUMP(uint32_t *code,int op,int copr,char *adr) {
	char l[NEM_SIZE];
	int i,j,count;
	unsigned long jmp;
    resource_check(0x7e00ffff);

	for(i=0,j=0 ; adr[i]!='\0' && adr[i] !=')' ; i++) l[j++] = adr[i];
	l[j] = '\0';
    count = 0;
	for(i=0 ; i<lbl_ptr ; i++) {
        if(StrCmp(l,lbl[i])) {
              jmp = lbl_adr[i];
			  count++;
		}
	}
	if(count > 1) exit_msg("lbl conflict.");
	if(count == 0) {
		fprintf(fp,"lbl not found. %s\n",l);
		exit(-1);
	}
	if(jmp > PLEN) exit_msg("lbl out of range.");
    *code |= (op<<25) | (copr<<30) | jmp;
}


void CODE_LOOP(uint32_t *code,int op,int copr,char *adr,int pc) {
	char l[NEM_SIZE];
	int i,j,count;
	int jmp,n;
    resource_check(0x7e00ffff);

	for(i=0,j=0 ; adr[i]!='\0' && adr[i] !=')' ; i++) l[j++] = adr[i];
	l[j] = '\0';
    count = 0;
	for(i=0 ; i<lbl_ptr ; i++) {
        if(StrCmp(l,lbl[i])) {
              jmp = lbl_adr[i];
			  count++;
		}
	}
	if(count > 1) exit_msg("lbl conflict.");
	if(count == 0) {
		fprintf(fp,"lbl not found. %s\n",l);
		exit(-1);
	}
    n = jmp - pc+2;
	if(n>255 || n<0) exit_msg("loop range error");
    *code |= (op<<25) | (copr<<30) | (n&0xff);
}


void CODE_COMPRESS(uint32_t *code,char *p) {
    char w0[NEM_SIZE];
    char w1[NEM_SIZE];
    char w2[NEM_SIZE];
    char w3[NEM_SIZE];
	int i,j,count;
	unsigned long jmp1,jmp2,copr1,copr2;
    resource_check(0xffffffff);

	for(i=0,j=0 ; p[i]!='\0' && p[i] !=','  && j<NEM_SIZE ; i++) w0[j++] = p[i];
    w0[j] = '\0';
    if(p[i]=='\0' || j==NEM_SIZE) exit_msg("16bit compress error1");
	for(i++,j=0 ; p[i]!='\0' && p[i] !=','  && j<NEM_SIZE ; i++) w1[j++] = p[i];
    w1[j] = '\0';
    if(p[i]=='\0' || j==NEM_SIZE) exit_msg("16bit compress error2");
	for(i++,j=0 ; p[i]!='\0' && p[i] !=','  && j<NEM_SIZE ; i++) w2[j++] = p[i];
    w2[j] = '\0';
    if(p[i]=='\0' || j==NEM_SIZE) exit_msg("16bit compress error3");
	for(i++,j=0 ; p[i]!='\0' && p[i] !=','  && j<NEM_SIZE ; i++) w3[j++] = p[i];
    w3[j] = '\0';
    if(j==NEM_SIZE) exit_msg("16bit compress error4");

    count = 0;
	for(i=0 ; i<lbl_ptr ; i++) {
        if(StrCmp(w0,lbl[i])) {
              jmp1 = lbl_adr[i];
			  count++;
		}
	}
	if(count > 1) exit_msg("lbl conflict.");
	if(count == 0) exit_msg_s("lbl not found. ",w0);
	if(jmp1 > 1027) {
		fprintf(fp,"lbl too large.\n");
		exit(-1);
	}
    copr1 = strtoul(w1,NULL,0);
    if(copr1>0xFF) exit_msg("copr1 error");
    count = 0;
	for(i=0 ; i<lbl_ptr ; i++) {
        if(StrCmp(w2,lbl[i])) {
              jmp2 = lbl_adr[i];
			  count++;
		}
	}
	if(count > 1) exit_msg("lbl conflict.");
	if(count == 0) exit_msg_s("lbl not found.",w2);
	if(jmp2 > 1027) exit_msg("lbl too large.");
    copr2 = strtoul(w3,NULL,0);
    if(copr2>0xFF) exit_msg("copr2 error");
    if(jmp1%8!=4) exit_msg("compress address error1");
    jmp1 = (jmp1-4)/8;
    if(jmp2%8!=4) exit_msg("compress address error2");
    jmp2 = (jmp2-4)/8;
    *code = 0x80008000 | (jmp1<<24) | (copr1<<16) | (jmp2<<8) | copr2;
}

unsigned short get_value(char *w) {
    unsigned long num;
    char *endptr;

    if(*w=='$') {
        int i;
        int count = 0;
        num = 0xffffffff;
        for(i=0 ; i<def_ptr ; i++) {
            if(strncmp(w,def[i],WORD_SIZE)==0) {
                num = def_num[i];
                count++;
            }
        }
        if(count>1) exit_msg_s("double define.",w);
        if(num>0xff) exit_range_over();
        return num;
    }
    errno = 0;
    endptr = w;
   if(*w=='\0') EXIT_SYNTAX_ERROR();
    num = strtoul(w,&endptr,0);
   if(w==endptr) EXIT_SYNTAX_ERROR();
   if(*endptr!='\0') EXIT_SYNTAX_ERROR();
   if(errno) EXIT_SYNTAX_ERROR();
   if(num > 0xff) exit_range_over();

   return (unsigned short)num;
}


void icf_asm(const char* asmfile) {
    int i,j,c,cp,num;
    FILE *fasm;
	unsigned long adr,debug;
    uint32_t code;

    /* PASS1 */
    
    if((fasm=fopen(asmfile,"r"))==NULL) exit_msg("Can't open file");
	adr = lbl_ptr = err_line = 0;
    while(fgets(buf,LINE_SIZE,fasm)) {
        err_line++;
        if(buf[0]=='#') continue;
        if(buf[0]=='$') {
            char *p = buf;
            char *q = def[def_ptr];
            char *endptr;
            unsigned long num;

            while(*p!=' ' && *p!='\t' && *p!='\r' && *p!='\n' && *p!='\0') *q++ = *p++;
            if(*p=='\r' || *p=='\n' || *p=='\0') continue;
            *q = '\0';
            while(*p==' ' || *p=='\t') p++;

            errno = 0;
            endptr = p;
            num = strtol(p,&endptr,0);
            if(p==endptr || errno) {
                fprintf(fp,"ERROR: invalid define in %d\n",err_line);
                fprintf(fp,buf);
                exit(-1);
            }
            if(*endptr!='\0' && *endptr!='\n' && *endptr!='\r' && *endptr!=' ' && *endptr!='\t') {
                fprintf(fp,"ERROR: invalid define in %d\n",err_line);
                fprintf(fp,buf);
                exit(-1);
            }
            def_num[def_ptr++] = num;
            continue;
        }

		delete_space(buf);
        if(buf[0]=='%') adr = skip_adr(adr);
		adr += is_lbl(buf,adr);
    }
    fclose(fasm);
	
    /* PASS 2 */
    if((fasm=fopen(asmfile,"r"))==NULL) {
		fprintf(fp,"Can't open file\n");
		exit(-1);
	}
    adr = s_line = err_line = 0;
    while( !feof(fasm) ) {
        err_line++;
	    c = 0;
        i = 0;
		do {
		    c=fgetc(fasm);
			if(c==EOF) break;
			if(c!='\r' && c!='\n') {
			    buf[i++]=c;
			} else {
			    if(i>0) break;
			}
		} while(!feof(fasm) && i<LINE_SIZE);
        		
		if(i == LINE_SIZE) {
			fprintf(fp,"line buffer over\n");
			exit(-1);
		}
		s_line++;
        resource_check(0);
		buf[i] = '\0';
        if(buf[0] == -1) continue;
		if(buf[0]=='#') continue;
		if(buf[0]=='$') continue;
        if(buf[0]=='%') adr = skip_adr(adr);
		c=0;
		for(i=0 ; buf[i] != '\0' ; i++) if(buf[i] == ':') c=1;
        if(c == 1) {
            if(mode&M_STDOUT) fprintf(fp,"%s\n",buf);
            continue;
        }
		delete_space(buf);
		code = debug = 0;
        cp = 0;
		for(i=0,j=0 ; buf[i] != '\0' ; i++) {
			if(buf[i] == '/' && buf[i+1] == '/') break;	
			if(buf[i] == ';') {
				cmd[cp++][j] = '\0';
				j = 0;
			} else {
				cmd[cp][j++] = buf[i];
				if(j>NEM_SIZE-2) {
					fprintf(fp,"mnemonic too long.\n");
                    exit(-1);
				}
			}
		}
		cmd[cp++][j] = '\0';
        for(i=0 ; i<cp ; i++) {
			vcmd = 0;
            if(StrCmp(cmd[i],""))           {}
            if(cmd[i][0]=='_') CODE_COMPRESS(&code,&cmd[i][1]);
			if(StrCmp(cmd[i],"COPR")) CODE(&code,0x40000000,0);
            if(StrCmp(cmd[i],"NOP"))        {}
			if(StrCmp(cmd[i],"I=X"))      CODE_OP(&code,1);
            if(StrMch(cmd[i],"B("))       CODE_JUMP(&code,2,0,&cmd[i][2]);
            if(StrMch(cmd[i],"JB("))      CODE_JUMP(&code,2,1,&cmd[i][3]);
			if(StrMch(cmd[i],"BCF0("))    CODE_JUMP(&code,3,0,&cmd[i][5]);
			if(StrMch(cmd[i],"BCF1("))    CODE_JUMP(&code,3,1,&cmd[i][5]);
			if(StrMch(cmd[i],"BZF0("))    CODE_JUMP(&code,4,0,&cmd[i][5]);
			if(StrMch(cmd[i],"BZF1("))    CODE_JUMP(&code,4,1,&cmd[i][5]);
			if(StrMch(cmd[i],"BC0("))     CODE_JUMP(&code,5,0,&cmd[i][4]);
			if(StrMch(cmd[i],"BC1("))     CODE_JUMP(&code,5,1,&cmd[i][4]);
			if(StrMch(cmd[i],"CALL("))    CODE_JUMP(&code,6,0,&cmd[i][5]);
			if(StrMch(cmd[i],"JCALL("))   CODE_JUMP(&code,6,1,&cmd[i][6]);
			if(StrMch(cmd[i],"CALL0("))   CODE_JUMP(&code,7,0,&cmd[i][6]);
			if(StrMch(cmd[i],"CALL1("))   CODE_JUMP(&code,7,1,&cmd[i][6]);
			if(StrCmp(cmd[i],"RETURN"))   CODE_OP(&code,8);
			if(StrCmp(cmd[i],"JRETURN"))  CODE_OP(&code,9);
			if(StrCmp(cmd[i],"RETURN0"))  CODE_OP(&code,10);
			if(StrCmp(cmd[i],"RETURN1"))  CODE_OP(&code,11);
			if(StrMch(cmd[i],"LOOP("))    CODE_LOOP(&code,12,0,&cmd[i][5],adr);
			if(StrCmp(cmd[i],"WAIT"))     CODE_OP(&code,13);
			if(StrCmp(cmd[i],"ADD"))      CODE_OP(&code,16);
			if(StrCmp(cmd[i],"AND"))      CODE_OP(&code,17);
			if(StrCmp(cmd[i],"XOR"))      CODE_OP(&code,18);
			if(StrCmp(cmd[i],"OR"))       CODE_OP(&code,19);
			if(StrCmp(cmd[i],"MOV"))      CODE_OP(&code,20);
			if(StrCmp(cmd[i],"REGBANK"))  CODE_OP(&code,21);
			if(StrCmp(cmd[i],"ENABLE"))   CODE_OP(&code,22);
			if(StrCmp(cmd[i],"DISABLE"))  CODE_OP(&code,23);
			if(StrCmp(cmd[i],"RETURNI"))  CODE_OP(&code,24);
			if(StrCmp(cmd[i],"POPSP"))    CODE_OP(&code,25);
			if(StrCmp(cmd[i],"IOSTROBE")) CODE_OP(&code,26);
			if(StrCmp(cmd[i],"OUTPUTK"))  CODE_OP(&code,27);
			if(StrCmp(cmd[i],"INPUTOUTPUT")) CODE_OP(&code,28);
			if(StrCmp(cmd[i],"INPUT"))    CODE_OP(&code,29);
			if(StrCmp(cmd[i],"OUTPUT"))   CODE_OP(&code,30);
			if(StrMch(cmd[i],"EXIT(")) {
				CODE_OP(&code,31);
				resource_check(0x0000ffff);
                code |= (0xffff & strtoul(cmd[i]+5,NULL,0));
            }
			if(StrCmp(cmd[i],"A=ANS"))    CODE(&code,0x01000000,0);
			if(StrCmp(cmd[i],"B=ANS"))    CODE_BC(&code,4);
			if(StrCmp(cmd[i],"B=LSH"))    CODE_BC(&code,8);
			if(StrCmp(cmd[i],"B=RSH"))    CODE_BC(&code,12);
			if(StrCmp(cmd[i],"B=REG"))    CODE_BC(&code,11);
			if(StrCmp(cmd[i],"C=ANS"))    CODE_BC(&code,1);
			if(StrCmp(cmd[i],"C=LSH"))    CODE_BC(&code,2);
			if(StrCmp(cmd[i],"C=RSH"))    CODE_BC(&code,3);
			if(StrCmp(cmd[i],"C=REG"))    CODE_BC(&code,14);
			if(StrCmp(cmd[i],"D=ANS"))    CODE(&code,0x00080000,0);
			if(StrCmp(cmd[i],"D=REG"))    CODE_OP(&code,14),CODE(&code,0x00080000,0);  
			if(StrCmp(cmd[i],"STORE"))    CODE(&code,0x00040000,0);
			if(StrCmp(cmd[i],"R(N)"))       CODE(&code,0x00010000,0x00030000);
			if(StrCmp(cmd[i],"R(ADDR)"))    CODE(&code,0x00020000,0x00030000);
			if(StrCmp(cmd[i],"R(REGADDR)")) CODE(&code,0x00030000,0x00030000);
			if(StrCmp(cmd[i],"ONE"))      CODE(&code,0x00008000,0);
			if(StrCmp(cmd[i],"NOT"))      CODE(&code,0x00004000,0);
			if(StrCmp(cmd[i],"ADDR=B"))   CODE(&code,0x00001000,0x00003000);
			if(StrCmp(cmd[i],"ADDR=C"))   CODE(&code,0x00002000,0x00003000);
			if(StrCmp(cmd[i],"ADDR=D"))   CODE(&code,0x00003000,0x00003000);
			if(StrCmp(cmd[i],"ADDL=A"))   CODE(&code,0x00000400,0x00000C00);
			if(StrCmp(cmd[i],"ADDL=DIVA"))CODE(&code,0x00000800,0x00000C00);
			if(StrCmp(cmd[i],"ADDL=N"))   CODE(&code,0x00000C00,0x00000C00);
			if(StrCmp(cmd[i],"CF"))       CODE(&code,0x00000200,0);
			if(StrCmp(cmd[i],"MUL"))      CODE(&code,0x00000100,0);
/*
			if(StrCmp(cmd[i],"X=?"))      CODE(&code,(cmd[i][2]-'0')<<4,0x000000f0);
			if(StrCmp(cmd[i],"X=1?"))     CODE(&code,(cmd[i][3]-'0'+10)<<4,0x000000f0);
			if(StrCmp(cmd[i],"Z=?"))      CODE(&code,cmd[i][2]-'0',0x0000000f);
			if(StrCmp(cmd[i],"Z=1?"))     CODE(&code,cmd[i][3]-'0'+10,0x0000000f);
*/
			if(StrMch(cmd[i],"X="))      {
                int val;
                resource_check(0x000000f0);
                val = get_value(cmd[i]+2);
                if(val>15) exit_range_over();
                code |= val<<4;
            }
			if(StrMch(cmd[i],"Z="))      {
                int val;
                resource_check(0x0000000f);
                val = get_value(cmd[i]+2);
                if(val>15) exit_range_over();
                code |= val;
            }
 			if(StrMch(cmd[i],"N=")) {
                resource_check(0x000000ff);
                code |= get_value(cmd[i]+2);
            }
            if(StrCmp(cmd[i],"@R0"))      debug |=0x00000001;
            if(StrCmp(cmd[i],"@R1"))      debug |=0x00000002;
            if(StrCmp(cmd[i],"@R2"))      debug |=0x00000004;
            if(StrCmp(cmd[i],"@R3"))      debug |=0x00000008;
            if(StrCmp(cmd[i],"@R4"))      debug |=0x00000010;
            if(StrCmp(cmd[i],"@R5"))      debug |=0x00000020;
            if(StrCmp(cmd[i],"@R6"))      debug |=0x00000040;
            if(StrCmp(cmd[i],"@R7"))      debug |=0x00000080;
            if(StrCmp(cmd[i],"@R8"))      debug |=0x00000100;
            if(StrCmp(cmd[i],"@R9"))      debug |=0x00000200;
            if(StrCmp(cmd[i],"@R10"))     debug |=0x00000400;
            if(StrCmp(cmd[i],"@R11"))     debug |=0x00000800;
            if(StrCmp(cmd[i],"@R12"))     debug |=0x00001000;
            if(StrCmp(cmd[i],"@R13"))     debug |=0x00002000;
            if(StrCmp(cmd[i],"@R14"))     debug |=0x00004000;
            if(StrCmp(cmd[i],"@R15"))     debug |=0x00008000;
            if(StrCmp(cmd[i],"@A"))       debug |=0x00010000;
            if(StrCmp(cmd[i],"@B"))       debug |=0x00020000;
            if(StrCmp(cmd[i],"@C"))       debug |=0x00040000;
            if(StrCmp(cmd[i],"@D"))       debug |=0x00080000;
            if(StrCmp(cmd[i],"@CF"))      debug |=0x00100000;
            if(StrCmp(cmd[i],"@ZF"))      debug |=0x00200000;
            if(StrCmp(cmd[i],"@I"))       debug |=0x00400000;
            if(StrCmp(cmd[i],"@PC"))      debug |=0x00800000;
            if(StrCmp(cmd[i],"@SP"))      debug |=0x01000000;
            if(StrCmp(cmd[i],"@ALL"))     debug |=0xffffffff;
     		if(vcmd == 0) {
	    		fprintf(fp,"Undefine NM : #%s#\n",cmd[i]);
		    	exit(-1);
			}
		}
       if(mode&M_STDOUT) fprintf(fp,"%04X %08X %s\n",adr,code,buf);
        PCODE[adr] = code;
        PDEBUG[adr++] = debug;
    }

    if(mode&M_BIN) for(i=0 ; i<PLEN ; i++) fprintf(fp,"%08X\n",PCODE[i]);
}
