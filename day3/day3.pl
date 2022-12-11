#!/usr/bin/env perl

open INFILE, "./input.dat" || die "INFILE:$!\n";

my %score;
for my $i (1 .. 26) {$score{ ('a' .. 'z') [$i-1] } = $i;};  
for my $i (27 .. 52) {$score{ ('A' .. 'Z') [$i-27] } = $i;};

my $score=0;
while (<INFILE>) {
    chomp;
    my $len=length($_)/2;
    my $b1=substr($_,0,$len);
    my $b2=substr($_,$len);

    OUTER: for my $i (split(//,$b1)) {
        INNER: for my $j (split(//,$b2)) {
            if ($i eq $j) {
                $score += $score{$i};
                last OUTER;
            }   
        }        
    }
}
close INFILE;

print $score,"\n";
