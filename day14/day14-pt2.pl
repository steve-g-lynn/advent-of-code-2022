#!/usr/bin/env -S perl -wl

use strict;
use List::Util qw(max);

(open my $fh_infile, "<", "./input.dat") || (die "$!\n");

my (%rock, %sand);

#-- read data; populate hash of rock positions
while (<$fh_infile>) {
    chomp;
    my $line=$_;
    my @line=map {[split(/,/,$_)]} split(/\s->\s/,$line);
    for my $i (1 .. $#line) {
        if ( ($line[$i]->[0]==$line[$i-1]->[0]) &&
            ($line[$i]->[1] != $line[$i-1]->[1]) ) {
                my ($min, $max) = sort {$a <=> $b} ($line[$i-1]->[1], $line[$i]->[1]);
                map {$rock{$line[$i]->[0].",". $_ }++} ($min .. $max);
            } 
            elsif ( ($line[$i]->[0] != $line[$i-1]->[0]) &&
            ($line[$i]->[1] == $line[$i-1]->[1]) ) {
               my ($min, $max) = sort {$a <=> $b} ($line[$i-1]->[0], $line[$i]->[0]);
               map {$rock{$_ .",". $line[$i]->[1]}++} ($min .. $max);            
            }
            else {
                die "Something wrong in input";
            }    
    }
}

close $fh_infile;

#-- find the floor (2 steps below bottom rock)
my $floor=&floor();

#-- fill the rock hash with a wide enough section of floor
map { $rock{$_ . "," .$floor}++ } (-10_000 .. 10_000);

#-- simulate sand and return number of sand grains
#-- sand positions are stored in a hash
&sim_sand;
print scalar(keys(%sand));


#-- sand simulation
sub sim_sand {
    #is just below blocked?
    local *check_below = sub {
        my ($x,$y) = @_;
        ( ($rock{($x).",".($y+1)}) || 
        ($sand{($x).",".($y+1)}) );
    };

    #is below left blocked?
    local *check_below_left = sub {
        my ($x,$y) = @_;
        (($rock{($x-1) . "," . ($y+1)} || $sand{($x-1) ."," .($y+1)}));         
    };

    #is below right blocked?
    local *check_below_right = sub {
        my ($x,$y) = @_;
        (($rock{($x+1).",".($y+1)} || $sand{($x+1).",".($y+1)}));         
    };
    
    #simulate one step (return down, below left, below right or stop)
    local *sim_one_step = sub {
        my ($pos) = @_; 
        my ($x,$y) = (&xx($_[0]),&yy($_[0]));
        
        if (&check_below($x,$y)) {#-- below is blocked
            if (&check_below_left($x,$y)) { #-- below-left blocked
                if (&check_below_right($x,$y)) { #-- below-right blocked             
                    $sand{$pos}+=1;
                    ($pos eq '500,0') && (return 'FULL');
                    return 'END';
                } 
                else { #-- fall_below_right
                    return ($x+1) ."," .($y+1);   
                }                
            }
            else { #-- fall below-left
                return ($x-1) .",". ($y+1);
            }
        }
        else {#-- fall straight down
            return $x . "," . ($y+1);
        }
    };
    
    #-- simulate one grain of sand falling
    local *sim_one_grain = sub {
        my ($pos)='500,0';
        until ( ($pos eq 'END') || ($pos eq 'FULL') ) {
            $pos = &sim_one_step($pos);
        }
        return $pos;
    };
    
    #-- simulate grains falling till cave is full
    my $pos='';
    until ($pos eq 'FULL') {
        $pos = &sim_one_grain;
    }    

}

#-- floor: two steps below bottom rock
sub floor {
    max ( map {&yy($_)} (keys %rock) ) + 2;
}

#-- get y coordinate from 'x,y' string (keys for rock,sand hashes)
sub yy {
    (split(/,/,$_[0]))[1];
}

#-- get x coordinate from 'x,y' string 
sub xx {
    (split(/,/,$_[0]))[0];
}
