#!/usr/bin/env -S perl -w

use strict;

open my $fh_infile, "<", "./input.dat" || die "INFILE:$!\n";

my $cycle_ctr=0;
my $X=1;

while (<$fh_infile>) {
    chomp;
    my ($command, $param) = split;
    (!$param) && ($param=0); #-- to comply with use strict
    eval("&$command($param)");
}

sub addx {
    my ($param)=@_;
    &paint;
    &next_cycle;
    &paint;
    &next_cycle;
    $X += $param;
}

sub noop {
    &paint;
    &next_cycle;
}

sub paint {
    my $xpos=$cycle_ctr % 40;
    ( ($xpos == $X) || ($xpos == $X-1) || ($xpos == $X+1) ) ? (print '#') : (print '.');
    ( ($xpos==39) && ($cycle_ctr > 0) ) && (print "\n");
}

sub next_cycle {
    $cycle_ctr++;    
}


