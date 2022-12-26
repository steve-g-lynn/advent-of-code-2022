#!/usr/bin/env -S perl -wl 

#-- this is an over-engineered solution
#-- it works for my input, so I haven't changed it
#-- it assumes (incorrectlly in general, but true for my input) 
#-- that there are no gaps between the intervals traced
#-- out by different sensors in row # 2_000_000

use strict;
use Hash::MultiKey; #-- allow arrayrefs as hash indices
use List::Util qw(min max);

(open my $fh_infile, '<', './input.dat') || (die "INFILE:$!\n");

my (%S);
tie %S, 'Hash::MultiKey';

while(<$fh_infile>) {
    chomp;
    m/([-0-9]+)[^-0-9]+([-0-9]+)[^-0-9]+([-0-9]+)[^-0-9]+([-0-9]+).*/;
    $S{[$1,$2]}=[$3,$4]; #-- store coordinates of nearest beacon
}
close $fh_infile;

my @candidate_keys;

for my $key (keys %S) {
    if (&diamond_intersects_row($key, 2_000_000)) { #10 for test_input
        push @candidate_keys, ([$key->[0], $key->[1]]);
    }
}

my ($left_edge,$right_edge)=(10_000_000_000, -10_000_000_000);

for my $key (@candidate_keys) {
    my ($left, $right) = &diamond_row_edges( $key, 2_000_000); #10 for test_input
    ($left < $left_edge) && ($left_edge = $left);
    ($right > $right_edge) && ($right_edge = $right);
}


print $right_edge-$left_edge;

END {
untie %S;
}

#-- subroutines
#-- note this is column-first x is column, y is row

sub manhattan { #-- manhattan distance
    my ($Sx, $Sy, $Bx, $By) = @_;
    abs($Sx-$Bx)+abs($Sy-$By);
}

sub distance_to_nearest_beacon {
    my ($S_key)=@_; #-- an arrayref
    my ($Sx, $Sy)=($S_key->[0], $S_key->[1]);
    my ($Bx, $By) = ($S{[ $Sx, $Sy ]}->[0], $S{[ $Sx, $Sy]}->[1]);
    &manhattan($Sx, $Sy, $Bx, $By);
}

sub diamond {
    my ($S_key)=@_; #-- an arrayref
    my ($Sx, $Sy) = ($S_key->[0], $S_key->[1]);
    
    my $nearest_beacon = &distance_to_nearest_beacon($S_key);
    my ($north, $south, $east, $west); #-- arrayrefs

    $west = [$Sx-$nearest_beacon, $Sy];
    $east = [$Sx+$nearest_beacon, $Sy];
    $south  = [$Sx, $Sy+9];
    $north = [$Sx, $Sy-9];
    return ($north, $south, $east, $west);
}

sub diamond_intersects_row {
    my ($S_key, $y) = @_; #arrayref, row 
    my $extent=&distance_to_nearest_beacon($S_key);
    ($y <= ( ($S_key->[1])+$extent)) && ($y >= (($S_key->[1])-$extent));
}

sub diamond_row_edges { 
#--left and right x's where diamond intersects row
    my ($S_key, $y) = @_;
    (!(&diamond_intersects_row)) && die "Row $y out of range";   
    my $offset=&distance_to_nearest_beacon($S_key)-abs(($S_key->[1])-$y);
    ( ($S_key->[0])-$offset, ($S_key->[0])+$offset);      
}
