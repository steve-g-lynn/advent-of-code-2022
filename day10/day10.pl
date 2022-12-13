#!/usr/bin/env -S perl -wl

use strict;
use Switch;

open my $fh_infile, "<", "./input.dat" || die "INFILE:$!\n";

my $cycle_ctr=0;
my $X=1;
my $retval=0;

while (<$fh_infile>) {
    chomp;
    my ($command, $param) = split;
    (!$param) && ($param=0); #-- to comply with use strict
    eval("&$command($param)");
}

print $retval;

sub addx {
    my ($param)=@_;
    &next_cycle;
    &next_cycle;
    $X += $param;
}

sub noop {
    &next_cycle;
}

sub next_cycle {
    $cycle_ctr++;
    
    switch ($cycle_ctr) {
        case 20 { &update_score }
        case 60 { &update_score }
        case 100 { &update_score }
        case 140 { &update_score }
        case 180 { &update_score }
        case 220 { &update_score }    
        else {return}
    }
}

sub update_score {
    $retval += $cycle_ctr*$X;
}
