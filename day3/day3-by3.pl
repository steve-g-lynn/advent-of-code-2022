#!/usr/bin/env perl

open INFILE, "./input.dat" || die "INFILE:$!\n";

my %score;
for my $i (1 .. 26) {$score{ ('a' .. 'z') [$i-1] } = $i;};  
for my $i (27 .. 52) {$score{ ('A' .. 'Z') [$i-27] } = $i;};

my $score=0;
my @input=();

INFILE: while (<INFILE>) {
    chomp;
    push @input, $_;
    next INFILE if scalar(@input) < 3;
    
    OUTER: for my $i (split //, $input[0]) {
        MIDDLE: for my $j (split //, $input[1]) {
            INNER: for my $k (split //, $input[2]) {
                if ( ($i eq $j) && ($j eq $k)) {
                    $score += $score{$i};
                    @input=();
                    last OUTER;
                }
            }
        }
    }
} 
close INFILE;


print $score,"\n";
