/* ICF3-Z assembler & simulator
   ICF3-Z Project https://icf3z.idletime.tokyo/
   Naoki Hirayama
 */
#define MAX_SP  16    /* Stack */
#define MAX_SRAM 0x10000
#define PLEN    1024

#define M_STDOUT 0x00000001
#define M_BIN    0x00000002
#define M_VLOG   0x00000004

extern unsigned int mode;
extern FILE *fp; /* output */

void icf_asm(const char* asmfile);
int icf_sim();
