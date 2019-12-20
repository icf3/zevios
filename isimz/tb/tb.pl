#!/usr/bin/perl
##########################################################
# ICF3-Z Project https://icf3z.idletime.tokyo/
# Naoki Hirayama 2019/4/21
##########################################################

$pass = 0;
$fail = 0;

sub dotest {
    if($tname eq '' || $check eq '') { die; }

    open(IN,"./isimz S $tname.asmz |");
    $flag = 0;
    while(<IN>) {
        if( /$check/ ) {$flag = 1;}
    }
    close(IN);
    if( $flag==1 ) {
        print "$tname ok!\n";
        $pass++;
    } else {
        print "$tname *** error ***\n";
        $fail++;
    }
}

##########################################################
$tname = "add";
$check = "D=FD";
&dotest;

##########################################################
@list = qw/D=77 D=2C D=8C/;
for( $i = 1 ; $i<=3 ; $i++ ) {
    $tname = "mul$i";
    $check = shift( @list );
    &dotest;
}

##########################################################
@list = qw/D=B9 D=0F D=2C/;
for( $i = 1 ; $i<=3 ; $i++ ) {
    $tname = "div$i";
    $check = shift( @list );
    &dotest;
}

##########################################################
$tname = "logic";
$check = "D=2A";
&dotest;

##########################################################
@list = qw/D=33 D=33 D=77 D=77 D=77/;
for( $i = 1 ; $i<=5 ; $i++ ) {
    $tname = "jump$i";
    $check = shift( @list );
    &dotest;
}

##########################################################
@list = qw/D=33 D=33 D=85 D=02/;
for( $i = 1 ; $i<=4 ; $i++ ) {
    $tname = "call$i";
    $check = shift( @list );
    &dotest;
}

##########################################################
@list = qw/D=5E D=5E D=5E/;
for( $i = 1 ; $i<=3 ; $i++ ) {
    $tname = "loadstore$i";
    $check = shift( @list );
    &dotest;
}

##########################################################
$tname = "loop";
$check = "D=0A";
&dotest;

##########################################################
$tname = "mov";
$check = "D=4C";
&dotest;

##########################################################
$tname = "xorcf";
$check = "D=03";
&dotest;

##########################################################
$tname = "input";
$check = "D=BC";
&dotest;

##########################################################
$tname = "input2";
$check = "D=05";
&dotest;

##########################################################
$tname = "compress1";
$check = "D=FF";
&dotest;

##########################################################
$tname = "compress2";
$check = "D=0A";
&dotest;

##########################################################
$tname = "vm";
$check = "D=0B";
&dotest;

$total = $pass + $fail;
print "pass=$pass , fail=$fail , total=$total\n";


