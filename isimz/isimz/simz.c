/* ICF3-Z assembler & simulator
   ICF3-Z Project https://icf3z.idletime.tokyo/
   Naoki Hirayama
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "isimz.h"

extern unsigned int PCODE[PLEN];
extern unsigned int PDEBUG[PLEN];


unsigned long long time;
unsigned char A,B,C,D;
int CF,ZF,I,PC;
unsigned char *R;
int STACK[MAX_SP];
int SP,HL;
unsigned char COPR;

#define COPRbit   P[30]
#define STOREbit  P[18]
#define ONEbit   P[15]
#define NOTbit   P[14]
#define CFbit    P[9]
#define MULbit   P[8]

void print_register(unsigned int debug) {
    if(fp==NULL) return;
    if(debug & 0x00000001) fprintf(fp,"R0=%02X ",R[0]);
    if(debug & 0x00000002) fprintf(fp,"R1=%02X ",R[1]);
    if(debug & 0x00000004) fprintf(fp,"R2=%02X ",R[2]);
    if(debug & 0x00000008) fprintf(fp,"R3=%02X ",R[3]);
	if(debug & 0x00000010) fprintf(fp,"R4=%02X ",R[4]);
	if(debug & 0x00000020) fprintf(fp,"R5=%02X ",R[5]);
	if(debug & 0x00000040) fprintf(fp,"R6=%02X ",R[6]);
	if(debug & 0x00000080) fprintf(fp,"R7=%02X ",R[7]);
    if(debug & 0x00000100) fprintf(fp,"R8=%02X ",R[8]);
    if(debug & 0x00000200) fprintf(fp,"R9=%02X ",R[9]);
    if(debug & 0x00000400) fprintf(fp,"R10=%02X ",R[10]);
    if(debug & 0x00000800) fprintf(fp,"R11=%02X ",R[11]);
	if(debug & 0x00001000) fprintf(fp,"R12=%02X ",R[12]);
	if(debug & 0x00002000) fprintf(fp,"R13=%02X ",R[13]);
	if(debug & 0x00004000) fprintf(fp,"R14=%02X ",R[14]);
	if(debug & 0x00008000) fprintf(fp,"R15=%02X ",R[15]);
	if(debug & 0x00010000) fprintf(fp,"A=%02X ",A);
	if(debug & 0x00020000) fprintf(fp,"B=%02X ",B);
	if(debug & 0x00040000) fprintf(fp,"C=%02X ",C);
	if(debug & 0x00080000) fprintf(fp,"D=%02X ",D);
    if(debug & 0x00100000) fprintf(fp,"CF=%d ",CF);
    if(debug & 0x00200000) fprintf(fp,"ZF=%d ",ZF);
    if(debug & 0x00400000) fprintf(fp,"I=%d ",I);
    if(debug & 0x00800000) fprintf(fp,"PC=%3X (%d) ",PC,PC);
    if(debug & 0x01000000) fprintf(fp,"SP=%5d ",SP);
    printf("\n");
}

void not_support(char* cmd) {
    fprintf(fp,"ERROR: not support %s\n",cmd);
    exit(-1);
}

int icf_sim() {
    unsigned char ADDL,ADDR,ANS,PA;
    unsigned short ADD;
    int X,Z,PC0,i;
    int P[32];
    int opcode;
    int cancel; 
    int loop;
    int wait;
    unsigned int code_adr;
    unsigned int debug = 0;
    unsigned int code = 0;
    int CY = 0;
    int Q = 0;
    unsigned char REG = 0;

    time = 0;
    PC  = 1;
    PC0 = CF = ZF = SP = HL = cancel = wait = 0;
    R = calloc(MAX_SRAM,sizeof(unsigned char));
    if(R==NULL) exit_error("Out of Memory");

    loop = -1;
    while(1) {
        time ++;
//      printf("*** time = %d PC = %08X PC0 = %08X\n",time,PC,PC0);
        if(wait==0) {
            code = PCODE[PC0];
            debug = PDEBUG[PC0];
        }
        if(cancel) {
            code &= 0x000000ff;
            cancel = 0;
        }
        code_adr = code;
        if(wait) wait = 0;
        else PC0 = PC++;
        if(loop>=0) {
            PC -= loop +1;
            loop = -1;
        }
        if(code&0x80000000) {
            if(SP+1>=MAX_SP) {
                fprintf(fp,"ERROR: Stack Overflow PC=%04X\n",PC);
                exit(-1);
            }
            if(HL) {
                STACK[SP++] =PC-1;
                HL = 0;
				PC0 = ((code & 0x7f00)>>8)*8+4;
                PC  = PC0 +1;
                COPR = code&0xff;
                REG = R[(code>>20)&0x0f];
            } else {
                STACK[SP++] =PC-2;
                HL = 1;
				PC0 = ((code & 0x7f000000)>>24)*8+4;
                PC  = PC0 +1;
                COPR = (code>>16)&0xff;
                REG = R[(code>>4)&0x0f];
            }
            time++;
            continue;
        }

        opcode = (code>>25)&0x1f;
        PA = A;

        for(i=0 ; i<32 ; i++) P[i]=0x1 & (code >>i);
        if(COPRbit) code = (code&0xffffff00)| COPR;

        X = 0xf & (code>>4);
        Z = 0xf & code;

        switch (opcode) {
        case 0: /* NOP */
            break;
        case 1: /* I=X */
		    I=(code>>4) & 0xf;
            break;
        case 2: /* B/JB */
            PC = code_adr & 0xffff;
            cancel = (code >> 30)&1;
            break;
        case 3: /* BCF0/BCF1 */
			if(CF==COPRbit) PC = code_adr & 0xffff;
            break;
        case 4: /* BZF0/BZF1 */
			if(ZF==COPRbit) PC = code_adr & 0xffff;
            break;
        case 5: /* BC0/BC1 */
            if((C&1)==COPRbit) PC = code_adr & 0xffff;
            break;
        case 6: /* CALL/JCALL */
            if(SP+1>=MAX_SP) {
                fprintf(fp,"ERROR: Stack Overflow PC=%04X\n",PC);
                exit(-1);
            }
            if((code >> 30)&1) STACK[SP++] =PC-1;
            else STACK[SP++] =PC;
            PC = code_adr & 0xffff;
            cancel = (code >> 30)&1;
            break;
        case 7: /* CALL0/CALL1 */
			if(ZF!=COPRbit) break;
            if(SP+1>=MAX_SP) {
                fprintf(fp,"ERROR: Stack Overflow PC=%04X\n",PC);
                exit(-1);
            }
            STACK[SP++] =PC;
            PC = code_adr & 0xffff;
            break;
        case 8: /* RETURN */
        case 9: /* JRETURN */
            if(SP==0) {
                fprintf(fp,"ERROR: Stack Overflow PC=%04X\n",PC);
                exit(-1);
            }
            PC = STACK[--SP];
            cancel = opcode&1;
            break;
        case 10: /* RETURN0 */
        case 11: /* RETURN1 */
			if(ZF != (opcode&1)) break;
            if(SP==0) {
                fprintf(fp,"ERROR: Stack Overflow PC=%04X\n",PC);
                exit(-1);
            }
            PC = STACK[--SP];
            if(opcode&1) cancel = (code >> 30)&1;
            break;

        case 12: /* LOOP */
            if((I--)!=0) loop = code & 0xff;
            if(I<-1 || I>16) {
                fprintf(fp,"ERROR: Out of Range : I=%d PC=%04X\n",I,PC);
                exit (-1);
            }
            break;

        case 13: /* WAIT */
            if((I--)!=0) wait = 1;
            if(I<-1 || I>16) {
                fprintf(fp,"ERROR: Out of Range : I=%d PC=%04X\n",I,PC);
                exit (-1);
            }
            break;
        case 14: /* D=REG */
            break;
        case 16: /* ADD */
        case 17: /* AND */
        case 18: /* XOR */
        case 19: /* OR  */
        case 20: /* MOV */
            break;
        case 21: /* REGBANK  */ not_support("REGBANK");
        case 22: /* ENABLE   */ not_support("ENABLE");
        case 23: /* DISABLE  */ not_support("DISABLE");
        case 24: /* RETURNI  */ not_support("RETURNI");
        case 25: /* POPSP    */ not_support("POPSP");
        case 26: /* IOSTROBE */
        case 27: /* OUTPUTK  */
        case 28: /* INPUTOUTPUT  */
        case 29: /* INPUT  */
        case 30: /* OUTPUT  */
            break;
        case 31: /* EXIT */
            if(debug) print_register(debug);
            return (code&0xffff);
		default:
		    fprintf(fp,"ERROR: Unknown opcode %08X\n",code);
			exit(-1);
        }

        ADDL = 0;
        if(P[11]==0 && P[10]==1) ADDL = A;
        if(P[11]==1 && P[10]==0) ADDL = A<<1|B>>7;
        if(P[11]==1 && P[10]==1) ADDL = code & 0xff;
        if(MULbit && (C&1)==0) ADDL=0;

         ADDR = 0;
        if(P[13]==0 && P[12]==1) ADDR = B;
        if(P[13]==1 && P[12]==0) ADDR = C;
        if(P[13]==1 && P[12]==1) ADDR = D;
        if(NOTbit) ADDR = ~ADDR;

        if(opcode>=17 && opcode<=19) {
            if(opcode==17) ANS = ADDL & ADDR;
            if(opcode==18) ANS = ADDL ^ ADDR;
            if(opcode==19) ANS = ADDL | ADDR;
            if(P[9]) ZF = ANS ? 0 : ZF;
            else ZF = ANS ? 0 : 1;
        } else {
            if( (opcode>>1)==14 ) {
                ANS=0x5e; // dummy data
                if(Z==1) ANS=STACK[SP-1]&0xff;   // RADR low
                if(Z==2) ANS = (STACK[SP-1])>>8; // RADR high
                if(Z==3) ANS=  0x34;             // IADR low
                if(Z==4) ANS = 0x12;             // IADR high
            } else {
                ADD = (unsigned short)ADDL + (unsigned short)ADDR + (unsigned short)((CF&CFbit)|ONEbit);
                ANS = (unsigned char)ADD;
                CY = ADD>>8;
    		    Q = A>>7 | CY;
            }
        }

/*
        printf("ADD=%03X A=%02X B=%02X C=%02X D=%02X ADDL=%02X ADDR=%02X CY=%d ANS=%02X Q=%d\n",
                ADD,A,B,C,D,ADDL,ADDR,CY,ANS,Q);
*/

        /* A input select */
        if(P[24]) {
            if(P[11]==1 && P[10]==0)  {
                if(MULbit) A = A<<1|B>>7;
				else A = (A>>7|CY) ? ANS : (A<<1|B>>7);
            } else {
                A = ANS;
            }
        }

        /* B,C input select */
        switch((code>>20)&0xf) {
        case  1: C = ANS; break;
        case  2: C = C<<1; C|= (P[11]==1&&P[10]==0) ? Q : (CF|CY); break;
        case  3: C = (C>>1)|(ANS<<7); break;
        case  4: B = ANS; break;
        case  5: B = ANS; C = ANS; break;
        case  6: B = ANS; C = C<<1; C|= (P[11]==1&&P[10]==0) ? Q : (CF|CY); break;
        case  7: B = ANS; C = (C>>1)|(ANS<<7); break;
        case  8: B = (B<<1)|(C>>7); break;
        case  9: B = (B<<1)|(C>>7); C = ANS; break;
        case 10: B = (B<<1)|(C>>7); C = C<<1; C|= (P[11]==1&&P[10]==0) ? Q : (CF|CY); break;
        case 11: B = REG; break;
        case 12: B = (ANS>>1)|(CY<<7); break;
        case 13: B = (ANS>>1)|(CY<<7); C = ANS; break;
        case 14: C = REG; break;
        case 15: B = (ANS>>1)|(CY<<7); C = (C>>1)|(ANS<<7);
        }

        /* D input select */
        if(P[19]) D = (opcode==14) ? REG : ANS;

        if(opcode==16) CF = CY;

        if(STOREbit && P[17]==0 && P[16]==0) R[Z] = opcode==20 ? REG : PA;
        if(STOREbit && P[17]==1 && P[16]==0) R[ADDR] = opcode==20 ? REG : PA;
        if(STOREbit && P[17]==0 && P[16]==1) R[code&0xff] = opcode==20 ? REG : PA;
        if(STOREbit && P[17]==0 && P[16]==1) {
            unsigned short int sram_adr = REG;
            sram_adr <<= 8;
            sram_adr |= ADDR;
            R[sram_adr] = opcode==20 ? REG : PA;
        }

        REG = R[X];
        if(P[17]==1 && P[16]==0) REG = R[ADDR];
        if(P[17]==0 && P[16]==1) REG = R[code&0xff];
        if(debug) print_register(debug);
    }
    free(R);
	return 0x3f;
}
