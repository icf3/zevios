#!/usr/bin/perl
##########################################################
# ICF3-Z Project https://icf3z.idletime.tokyo/
# Naoki Hirayama 2020/01/14
# Naoki Hirayama 2020/02/04
##########################################################
open(CHK1,"icf3z.v") || die "'make copy' ";
close(CHK1);
open(CHK2,"isimz") || die "./isimz not found.";
close(CHK2);

$MAKE = "make icarus 2>&1 /dev/null";
$EXE = "./simz |";

foreach( @ARGV ) {
    if(/^xsim$/) {
        $MAKE = "make xsim 2>&1 /dev/null";
        $EXE = "xsim -R simsim |";
    }
}

$loop=0;
do {
    $R1 = int(rand 256);
    $R2 = int(rand 256);
    $R3 = int(rand 256);
    $R4 = int(rand 256);
    $R5 = 0;
    $R6 = 1 + int(rand 255);

    $x = $R1;
    $x = $x * 256;
    $x = $x + $R2;
    $x = $x * 256;
    $x = $x + $R3;
    $x = $x * 256;
    $x = $x + $R4;

    $y = $R5;
    $y = $y * 256;
    $y = $y + $R6;

    $z = int($x/$y);

    $exp = sprintf("%08x",$z);

    open(RND,"> tmp.asmz");
    printf RND "    A=ANS;ADDL=N;N=0x%02X\n",$R1;
    printf RND "    STORE;Z=1\n";
    printf RND "    A=ANS;ADDL=N;N=0x%02X\n",$R2;
    printf RND "    STORE;Z=2\n";
    printf RND "    A=ANS;ADDL=N;N=0x%02X\n",$R3;
    printf RND "    STORE;Z=3\n";
    printf RND "    A=ANS;ADDL=N;N=0x%02X\n",$R4;
    printf RND "    STORE;Z=4\n";
    printf RND "    A=ANS;ADDL=N;N=0x%02X\n",$R5;
    printf RND "    STORE;Z=5\n";
    printf RND "    A=ANS;ADDL=N;N=0x%02X\n",$R6;
    printf RND "    STORE;Z=6\n";

    open(IN,"pmem.asmz");
    $flag = 0;
    while(<IN>) {
        if($flag == 1) {print RND;}
        if(/^#START#####/) {$flag = 1;}
    }
    close(IN);
    close(RND);

    system("./isimz a tmp.asmz");
    system("rm -rf pmem.bin");
    system("mv tmp.bin pmem.bin");
    `$MAKE`;
    open(IN,$EXE);
    $success=0;
    $res = "null";
    while(<IN>) {
        if(/result:([0-9,a-f]+)/) {$res = $1}
        if(/result:$exp/) {$success=1}
    }
    close(IN);

    if($success==0) {
        printf("loop = $loop\n");
        printf("%02X %02X %02X %02X / %02X %02X\n",$R1,$R2,$R3,$R4,$R5,$R6);
        printf("exp: $exp\n");
        print("res: $res\n");
    }

    $loop = $loop + 1;
    if($loop % 100 == 0) {printf ("loop = $loop\n");}
} while($success==1);

