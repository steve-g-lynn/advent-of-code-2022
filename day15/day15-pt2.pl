#!/usr/bin/env -S perl -wl 

#-- Slow. Ran in around 20 minutes
#-- correct answer is between row # 3.3 and 3.4 million
#-- for my input data

use strict;
use Hash::MultiKey; #-- allow arrayrefs as hash indices
use List::Util qw(min max);

use constant {MINDIM => 0, MAXDIM => 4_000_000};

(open my $fh_infile, '<', './input.dat') || (die "INFILE:$!\n");

my (%S);
tie %S, 'Hash::MultiKey';

while(<$fh_infile>) {
    chomp;
    m/([-0-9]+)[^-0-9]+([-0-9]+)[^-0-9]+([-0-9]+)[^-0-9]+([-0-9]+).*/;
    $S{[$1,$2]}=[$3,$4]; #-- store coordinates of nearest beacon
}
close $fh_infile;

ROWS: for my $row (MINDIM .. MAXDIM) {
    ($row % 100_000) || (print $row);
    my @check = &my_slide(
    &sort_intervals(
    &get_intervals_row( $row)));
    
    if (scalar(@check) == 2) {
        my $cell = [($check[0]->[1])+1, $row];
        print (4_000_000 * ($cell -> [0]) + $cell -> [1]);
        last ROWS; 
    }  
}

END {
untie %S;
$fh_infile && (close $fh_infile);
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
    [ ($S_key->[0])-$offset, ($S_key->[0])+$offset ];      
}

sub get_intervals_row {
    my ($row)=@_;

    my @candidate_keys;

    for my $key (keys %S) {
        if (&diamond_intersects_row($key, $row)) {
            push @candidate_keys, ([$key->[0], $key->[1]]);
        }
    }
    
    my @retval;
    for my $key (@candidate_keys) {
        my $diamond_row_edges = &diamond_row_edges($key,$row);
        (($diamond_row_edges->[1]) < MINDIM) && next;
        (($diamond_row_edges->[0]) > MAXDIM) && next;
        push @retval, $diamond_row_edges;
    }
    @retval;
}

sub sort_intervals {
    my @intervals = @_;
    my @retval;

    (@intervals == 1) && (return @intervals);
    
    sort { 
        ($a->[0] <=> $b->[0]) || 
        ($a->[1] <=> $b->[1])
    } @intervals;
}

sub merge_2_presorted_intervals {
    my ($interval1, $interval2) = @_;

    ($interval2) || (return $interval1);
    
    if ( ($interval2->[0]) <= ($interval1->[1]) ) {
        if ( ($interval2->[1]) <= ($interval1->[1]) ) {
            return ($interval1);
        }
        else {
            return ([$interval1->[0], $interval2->[1]]);
        }
    }     
    
    return ($interval1, $interval2);
}

sub my_slide {
    my @sorted_intervals=@_;
    
    (@sorted_intervals <= 1) && (return @sorted_intervals);
    @sorted_intervals = (@sorted_intervals, [10_000_001, 10_000_001]);
    
    my $check_length=@sorted_intervals;
    my $ctr=0;


    SLIDE: while (1) {
        last if ($sorted_intervals[$ctr]->[0] == 10_000_001);
        my @merge = &merge_2_presorted_intervals(
            @sorted_intervals[$ctr, $ctr+1]); 
           
            if (@merge==1) {
                splice(@sorted_intervals,
                    $ctr,
                    2,
                    @merge);
                $check_length = @sorted_intervals;
                next SLIDE;            
            }
            elsif (@merge==2) {
                $ctr+=1;
                ($ctr < ($check_length - 2) ) && (next SLIDE);
            }
            else {
                die "Something wrong.";
            }
        
  
        ($ctr==$check_length-2) && (last); 
    }
    pop @sorted_intervals;
    (scalar(@sorted_intervals) > 2) && (die "Something wrong");
    @sorted_intervals;    
}

