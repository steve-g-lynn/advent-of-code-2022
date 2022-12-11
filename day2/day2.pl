#!/usr/bin/env perl

open INFILE, "./input.dat" || die "INFILE:$!\n";

my $score=0;
while( <INFILE> ) {
    (/A X/) && ($score += 4); #1 + 3
    (/A Y/) && ($score += 8); #2 + 6
    (/A Z/) && ($score += 3); #3 + 0 
#
    (/B X/) && ($score += 1); #1 + 0
    (/B Y/) && ($score += 5); #2 + 3
    (/B Z/) && ($score += 9); #3 + 6
#
    (/C X/) && ($score += 7); #1 + 6
    (/C Y/) && ($score += 2); #2 + 0
    (/C Z/) && ($score += 6); #3 + 3    
}
close INFILE;

print "$score\n";

