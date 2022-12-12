#!/usr/bin/env -S perl -wl

use strict;
use Switch;

open my $fh_infile, "<", "input.dat" || die "INPUT:$!\n";

#-- start position
my $hpos='0:0';
my $tpos='0:0';

#-- hashes to store visited positions;

my (%hvisited,%tvisited);

#-- initialize by storing start position
$hvisited{$hpos}++;
$tvisited{$tpos}++;

#-- loop through infile
while (<$fh_infile>) {
    chomp;
    &hmove($_);
}

print scalar(keys %tvisited);

#-- head moves
sub hmove {
    my ($string)=@_;
    
    ($string =~ /^([LRUD])\s+(\d+)$/) || (return "Invalid input");
    
    my ($direction,$distance) = ($1,$2);
    
    my ($x,$y) = &get_pos($hpos);
    
    my $hmove;
    
    switch( $direction ) {
        case 'L'    {$hmove='$x--'};
        case 'R'    {$hmove='$x++'};
        case 'U'    {$hmove='$y++'}; 
        case 'D'    {$hmove='$y--'};
    }

    for (1 .. $distance) {
        eval($hmove);
        $hpos=store_pos($x,$y);
        $hvisited{$hpos}++;
        &tmove;
    }

    return 0;
}

#-- tail moves
sub tmove { 
    #-- no arguments, depends only on current hpos and tpos
    my ($hx,$hy)=get_pos($hpos);
    my ($tx,$ty)=get_pos($tpos);

#--h in same row or column
    ( ($hx==$tx) && ($hy == ($ty+2)) ) && ($ty++);
    ( ($hx==$tx) && ($hy == ($ty-2)) ) && ($ty--);
    ( ($hy==$ty) && ($hx == ($tx+2)) ) && ($tx++);
    ( ($hy==$ty) && ($hx == ($tx-2)) ) && ($tx--); 

#move down diagonally right
    ( ($hx==($tx+2)) && ($hy==($ty-1)) ) && eval('$tx++;$ty--');
    ( ($hx==($tx+1)) && ($hy==($ty-2)) ) && eval('$tx++;$ty--');
    
#move up diagonally right
    ( ($hx==($tx+2)) && ($hy==($ty+1)) ) && eval('$tx++;$ty++');
    ( ($hx==($tx+1)) && ($hy==($ty+2)) ) && eval('$tx++;$ty++');
    
#move down diagonally left
    ( ($hx==($tx-2)) && ($hy==($ty-1)) ) && eval('$tx--;$ty--');
    ( ($hx==($tx-1)) && ($hy==($ty-2)) ) && eval('$tx--;$ty--');

#move up diagonally left
    ( ($hx==($tx-2)) && ($hy==($ty+1)) ) && eval('$tx--;$ty++');
    ( ($hx==($tx-1)) && ($hy==($ty+2)) ) && eval('$tx--;$ty++');

    $tpos=store_pos($tx,$ty);
    $tvisited{$tpos}++;
}

sub get_pos {
    my ($string)=@_;
    ($string =~ /^([\-0-9]+):([\-0-9]+)$/) || (return "Invalid input");
    return (split(/:/,$string));
}

sub store_pos {
    (@_ == 2) || (return "Invalid input"); 
    return join(':',@_);
}
