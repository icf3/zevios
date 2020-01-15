#!/usr/bin/perl
##########################################################
# ICF3-Z Project https://icf3z.idletime.tokyo/
# Naoki Hirayama 2020/01/14
##########################################################
open(CHK,"isimz") || die "./isimz not found.";
close(CHK);

$loop=0;
$avr=0;
do {
    $R1 = int(rand 256);
    $R2 = int(rand 256);
    $R3 = int(rand 256);
    $R4 = int(rand 256);
    $R5 = 0;
    $R6 = 1+int(rand 255);

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

    $exp = sprintf("%08X",$z);
    $exp =~ /([0-9,A-Z][0-9,A-Z])([0-9,A-Z][0-9,A-Z])([0-9,A-Z][0-9,A-Z])([0-9,A-Z][0-9,A-Z])/;
    $e1 = $1;
    $e2 = $2;
    $e3 = $3;
    $e4 = $4;

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

    open(IN,"./isimz S tmp.asmz |") || die "./isimz file not found";
    $success=0;
    $res = "null";
    $r1 ="";
    $r2 ="";
    $r3 ="";
    $r4 ="";
    while(<IN>) {
        if(/^R7=([0-9,A-F][0-9,A-F]) R8=([0-9,A-F][0-9,A-F]) R9=([0-9,A-F][0-9,A-F]) R10=([0-9,A-F][0-9,A-F])/) {
            $r1 = $1;
            $r2 = $2;
            $r3 = $3;
            $r4 = $4;
        }
        $cyc = 0;
        if(/cyc = ([0-9]+)/) {$cyc = $1;}
        if($e1 eq $r1 && $e2 eq $r2 && $e3 eq $r3 && $e4 eq $r4) {$success=1}
    }
    close(IN);

   if($success==0) {
        printf("loop = $loop\n");
        printf("%02X %02X %02X %02X / %02X %02X\n",$R1,$R2,$R3,$R4,$R5,$R6);
        printf("exp: $e1 $e2 $e3 $e4\n");
        printf("res: $r1 $r2 $r3 $r4\n");
    }
    if($cyc == 0) {
        die "cyc error\n";
    }
    $avr = $avr + $cyc - 5;

    $loop = $loop + 1;
    if($loop % 100 == 0) {
        printf ("loop = %d %d\n",$loop,$avr/100);
        $avr = 0;
    }
} while($success==1);

