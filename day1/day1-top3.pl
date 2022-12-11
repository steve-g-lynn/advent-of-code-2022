#!/usr/bin/env perl

use List::Util qw(sum);

open INFILE, "./input.dat";

my @max=(0,0,0);
my $candidate=0;

INFILE: while(<INFILE>) {
    if (/^\n$/) {
        sort {$b <=> $a} @max;
        for my $i (0 .. @max-1) {
            if ($candidate > $max[$i]) {
                ($i+2 <= @max-1) && ($max[i+2]=$max[i+1]);
                ($i+1 <= @max-1) && ($max[i+1]=$max[i]);
                $max[$i] = $candidate;                 
                $candidate=0;
                next INFILE;
            }
        }
        $candidate = 0;
        next;
    }
    $candidate += $_;    
}
close INFILE;


print "@max\n";
my $max=sum @max;
print "$max\n";

