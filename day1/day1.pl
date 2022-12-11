#!/usr/bin/env perl

open INFILE, "./input.dat";

my $max=0;
my $candidate=0;

while(<INFILE>) {
    if (/^\n$/) {
        ($candidate > $max) && ($max = $candidate);
        $candidate = 0;
        next;
    }
    $candidate += $_;    
}
close INFILE;

print "$max\n";

