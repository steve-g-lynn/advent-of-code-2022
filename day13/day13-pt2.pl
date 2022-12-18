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

my @eval_input;
for my $i (0 .. @input-1) {    
    my ($left,$right)=split("\n",$input[$i]);
    push @eval_input, (eval($left),eval($right));  
}
my $two=[[2]];
my $six=[[6]];

push @eval_input, ($two,$six);

@eval_input=sort {&compare_packets($a,$b)} @eval_input;

my $decoder_key=1;
for my $i (0 .. @eval_input-1) {
     (($eval_input[$i] == $two) || ($eval_input[$i] == $six)) &&
        ($decoder_key *= ($i+1));
}

print $decoder_key;

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


