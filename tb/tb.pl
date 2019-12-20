#!/usr/bin/perl
##########################################################
# ICF3-Z Project https://icf3z.idletime.tokyo/
# Naoki Hirayama 2019/5/23
##########################################################

##### Optiopn #####
$spm16 = "";
$int = "";
##########################################################

$pass = 0;
$fail = 0;

foreach( @ARGV ) {
    if(/^spm16$/) { $spm16 = "_spm16"; }
    if(/^int$/) { $store = "_int"; }
}

$MAKE = "make icarus$int$spm16 >& /dev/null";
$EXE = "./simz |";

foreach( @ARGV ) {
    if(/^xsim$/) {
        $MAKE = "make xsim$int$spm16 >& /dev/null";
        $EXE = "xsim -R simsim |";
    }
}

sub dotest {
    if($tname eq '' || $check eq '') { die; }

    system("./isimz a $tname.asmz");
    system("rm -rf pmem.bin");
    system("mv $tname.bin pmem.bin");
    system($MAKE);
    open(IN,$EXE);

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

#################
# add
#################
$tname = "add";
$check = "result:fd";
&dotest;

##########################################################
@list = qw/77 2c 8c/;
for( $i = 1 ; $i<=3 ; $i++ ) {
    $tname = "mul$i";
    $check = shift( @list );
    $check = "result:".$check;
    &dotest;
}

##########################################################
@list = qw/b9 0f 2c/;
for( $i = 1 ; $i<=3 ; $i++ ) {
    $tname = "div$i";
    $check = shift( @list );
    $check = "result:".$check;
    &dotest;
}

#################
# logic
#################
$tname = "logic";
$check = "result:2a";
&dotest;

##########################################################
@list = qw/33 33 77 77 77/;
for( $i = 1 ; $i<=5 ; $i++ ) {
    $tname = "jump$i";
    $check = shift( @list );
    $check = "result:".$check;
    &dotest;
}

##########################################################
@list = qw/33 33 85 02/;
for( $i = 1 ; $i<=4 ; $i++ ) {
    $tname = "call$i";
    $check = shift( @list );
    $check = "result:".$check;
    &dotest;
}

##########################################################
@list = qw/5e 5e 5e/;
for( $i = 1 ; $i<=3 ; $i++ ) {
    $tname = "loadstore$i";
    $check = shift( @list );
    $check = "result:".$check;
    &dotest;
}

#################
# loop
#################
$tname = "loop";
$check = "result:0a";
&dotest;

#################
# mov
#################
$tname = "mov";
$check = "result:4c";
&dotest;

#################
# xorcf
#################
$tname = "xorcf";
$check = "result:03";
&dotest;

#################
# input
#################
$tname = "input";
$check = "result:bc";
&dotest;

#################
# input2
#################
$tname = "input2";
$check = "result:05";
&dotest;

#################
# regbank
#################
$tname = "regbank";
$check = "result:25";
&dotest;

#################
# compress1
#################
$tname = "compress1";
$check = "result:ff";
&dotest;

#################
# compress2
#################
$tname = "compress2";
$check = "result:0a";
&dotest;

#################
# vm
#################
$tname = "vm";
$check = "result:0b";
&dotest;


##################################################
if($int =~ /int/ ) {
##################################################
#################
# debugger1
#################
$tname = "debugger1";
$check = "result:44";
&dotest;

##################################################
} else { # $int
##################################################
#################
# interrupt1
#################
$tname = "interrupt1";
$check = "result:83";
&dotest;

#################
# interrupt2
#################
$tname = "interrupt2";
$check = "result:47";
&dotest;

#################
# interrupt3
#################
$tname = "interrupt3";
$check = "result:1a";

system("./isimz a $tname.asmz");
system("rm -rf pmem.bin");
system("mv $tname.bin pmem.bin");

if($EXE =~ /^xsim/) {
    system("make xsim_interrupt3 >& /dev/null");
    open(IN,"xsim -R simsim |");
} else {
    system("make interrupt3 >& /dev/null");
    open(IN,"./simz |");
}

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

#################
# intloop1
#################
$tname = "intloop1";
$check = "result:03";
&dotest;

##################################################
} # $int
##################################################


$total = $pass + $fail;
print "pass=$pass , fail=$fail , total=$total\n";
