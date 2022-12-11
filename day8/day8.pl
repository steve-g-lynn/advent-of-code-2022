#!/usr/bin/env -S perl -wl

use strict;

use PDL;
use PDL::NiceSlice;
use PDL::AutoLoader;
{
my $input=pdl;

open INFILE, "input.dat" || die "INFILE:$!\n";

my @input;
while (<INFILE>) {
    chomp;
    push @input, split(//,$_);
}    

close INFILE;

$input = (pdl @input)->reshape(sqrt(@input),sqrt(@input));

my $dims = $input->shape; #-- pdl for pdl ops
my @dims = $input->dims; #-- perl list for looping

my $retval = zeros($input->dims); 
#-- return value boolean matrix

#-- populate the perimeter (1 for visible on boundary)

$retval(0) += 1;
$retval($dims(0)-1) +=1;
$retval(,0)->where($retval(,0)==0) += 1;
$retval(,$dims(1)-1)->where($retval(,$dims(1)-1)==0) += 1;


#-- loop left and right 


for my $i (1 .. $dims[1]-2) {

    $retval($i, 1:($dims[1]-2)) +=  ($input($i,1:($dims[1]-2)) >    ($input(0:$i-1,1:($dims[1]-2))->maxover->transpose));

    $retval($i, 1:($dims[1]-2)) +=  ($input($i,1:($dims[1]-2)) > ($input($i+1:$dims[0]-1,1:($dims[1]-2))->maxover->transpose));

}


#-- loop up and down

for my $i (1 .. $dims[0]-2) {

    $retval(1:$dims[0]-2,$i) += ($input(1:$dims[0]-2,$i) > ( ($input(1:$dims[0]-2,0:$i-1)->transpose->maxover) )) ;

    $retval(1:$dims[0]-2,$i) += ($input(1:$dims[0]-2,$i) > ( ($input(1:$dims[0]-2,$i+1:$dims[1]-1)->transpose->maxover) )) ;

}

$retval = ($retval >= 1);


print $retval->sum;


}


