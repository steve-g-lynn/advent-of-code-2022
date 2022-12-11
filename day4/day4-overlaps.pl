#!/usr/bin/env perl

use strict;

open INFILE, "./input.dat" || die "INFILE:$!\n";

my $count=0;
while (<INFILE>) {
    /^\n$/ && next;

    chomp;
    
    my ($first,$second)=split(/,/,$_);
    
    my @first=split('-',$first);
    my @second=split('-',$second);
 
    $count++ unless ( ($first[0] > $second[1]) || 
        ($second[0] > $first[1]) ); 
}
close INFILE;


print $count,"\n";
