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
 
    ( (($first[0] >= $second[0]) && ($first[1] <= $second[1])) ||
    (($second[0] >= $first[0]) && ($second[1] <= $first[1])) ) &&
    ($count++);    
}
close INFILE;

print $count,"\n";
