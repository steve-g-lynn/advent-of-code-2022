#!/usr/bin/env -S perl -wl

use strict;
use Switch;
use Data::Dumper qw(Dumper);

open my $fh_infile, "<", "input.dat" || die "INPUT:$!\n";

#-- start position
my @kpos=('0:0','0:0','0:0','0:0','0:0','0:0','0:0','0:0','0:0','0:0');

#-- array of hashes to store visited positions;

my @kvisited=({},{},{},{},{},{},{},{},{},{});


#-- initialize by storing start position
for my $i (0 .. 9) {
    $kvisited[$i]->{'0:0'} += 1;
}


#-- loop through infile
while (<$fh_infile>) {
    chomp;
    &hmove($_);
}

print scalar(keys %{$kvisited[9]});

#-- head moves
sub hmove {
    my ($string)=@_;
    
    ($string =~ /^([LRUD])\s+(\d+)$/) || (return "Invalid input");
    
    my ($direction,$distance) = ($1,$2);
    
    my ($x,$y) = &get_pos($kpos[0]);
    
    my $hmove;
    
    switch( $direction ) {
        case 'L'    {$hmove='$x--'};
        case 'R'    {$hmove='$x++'};
        case 'U'    {$hmove='$y++'}; 
        case 'D'    {$hmove='$y--'};
    }

    for (1 .. $distance) {
        eval($hmove);
        $kpos[0]=store_pos($x,$y);
        $kvisited[0]->{$kpos[0]} += 1;
        for my $i (1 .. 9) {
            &tmove($i);            
        }
    }

    return 0;
}

#-- tail moves
sub tmove { 

    my ($pos)=@_;
    
    my ($hx,$hy) = &get_pos($kpos[$pos-1]);
    my ($tx,$ty) = &get_pos($kpos[$pos]);

#h in same row or column
    ( ($hx==$tx) && ($hy == ($ty+2)) ) && ($ty++);
    ( ($hx==$tx) && ($hy == ($ty-2)) ) && ($ty--);
    ( ($hy==$ty) && ($hx == ($tx+2)) ) && ($tx++);
    ( ($hy==$ty) && ($hx == ($tx-2)) ) && ($tx--); 

#move down diagonally left
    ( ($hx==($tx+2)) && ($hy==($ty-1)) ) && eval('$tx++;$ty--');
    ( ($hx==($tx+1)) && ($hy==($ty-2)) ) && eval('$tx++;$ty--');
    ( ($hx==($tx+2)) && ($hy==($ty-2)) ) && eval('$tx++;$ty--');
    
#move up diagonally right
    ( ($hx==($tx+2)) && ($hy==($ty+1)) ) && eval('$tx++;$ty++');
    ( ($hx==($tx+1)) && ($hy==($ty+2)) ) && eval('$tx++;$ty++');
    ( ($hx==($tx+2)) && ($hy==($ty+2)) ) && eval('$tx++;$ty++');
    
#move down diagonally left
    ( ($hx==($tx-2)) && ($hy==($ty-1)) ) && eval('$tx--;$ty--');
    ( ($hx==($tx-1)) && ($hy==($ty-2)) ) && eval('$tx--;$ty--');
    ( ($hx==($tx-2)) && ($hy==($ty-2)) ) && eval('$tx--;$ty--');

#move up diagonally left
    ( ($hx==($tx-2)) && ($hy==($ty+1)) ) && eval('$tx--;$ty++');
    ( ($hx==($tx-1)) && ($hy==($ty+2)) ) && eval('$tx--;$ty++');
    ( ($hx==($tx-2)) && ($hy==($ty+2)) ) && eval('$tx--;$ty++');


    ($kpos[$pos]) = &store_pos($tx,$ty);
    ($kvisited[$pos]->{$kpos[$pos]}) += 1;
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
