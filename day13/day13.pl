#!/usr/bin/env -S perl -wl

use strict;

my @input;

#-- slurp in data
{
open my $fh_infile, "<", "input.dat" || (die "INFILE: $!\n");
local $/="\n\n";
@input=<$fh_infile>;
close $fh_infile;
}

#-- loop thru' data
my $ctr=0;
for my $i (1 .. @input) {
    my ($left,$right)=split("\n",$input[$i-1]);
    $left=eval($left); $right=eval($right);
    
    (&compare_packets( $left,$right ) < 1) && ($ctr += $i);   
}

print $ctr;

#-- sub to compare packets
sub compare_packets {
    my ($left, $right)=@_;
    
    #-- not an array
    (!ref($left) && !ref($right)) && (return ($left <=> $right));
    ((ref($left) =~ 'ARRAY') && (!ref($right))) && ($right=[$right]);
    ((ref($right) =~ 'ARRAY') && (!ref($left))) && ($left=[$left]);   
   
    #-- both are arrayrefs, loop and recurse   
    for my $i (0 .. $#$right) {
        last if ($i > $#$left);
        my $retval = &compare_packets($left->[$i], $right->[$i]);
        return $retval if $retval;          
    }
    
    #-- if not exited yet, compare length of left vs right
    return (@$left <=> @$right);
}


