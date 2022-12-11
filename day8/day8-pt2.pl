#!/usr/bin/env -S perl -wl

use strict;

use PDL;
use PDL::NiceSlice;
use PDL::AutoLoader;

my $input=pdl;

open INFILE, "input.dat" || die "INFILE:$!\n";

my @input;
while (<INFILE>) {
    chomp;
    push @input, split(//,$_);
}

close INFILE;

$input = (pdl @input)->reshape(sqrt(@input),sqrt(@input));

my @dims = $input->dims; #-- perl list for looping
my ($ncol,$nrow)=@dims;

print &best_score($ncol,$nrow);

sub best_score {
    my ($ncol, $nrow) = @_;
    my $best=0;
    
    for my $i (1 .. $ncol-2) {
        for my $j (1 .. $nrow-2) {
            my $test=&scenic_score($i,$j);
            ($test > $best) && ($best = $test);
        }
    }
    return $best;
}


sub scenic_score {
    my ($col,$row)=@_;
 
    my $view_left=0;
    my $view_right=0;
    my $view_up=0;
    my $view_down=0;
    
    LEFT: for my $i (1 .. $col) { 
        ($view_left++);
        last LEFT if $input($col-$i,$row) >= $input($col,$row);
    }
    
    RIGHT: for my $i ($col+1 .. $dims[0]-1) { 
        ($view_right++);
        last RIGHT if $input($i,$row) >= $input($col,$row);
    }

    UP: for my $i (1 .. $row) { 
        ($view_up++);
        last UP if $input($col,$row-$i) >= $input($col,$row);
    }
    
    DOWN: for my $i ($row+1 .. $dims[1]-1) { 
        ($view_down++);
        last if $input($col,$i) >= $input($col,$row);
    }
    
    return $view_left*$view_right*$view_up*$view_down;
}




