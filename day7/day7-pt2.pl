#!/usr/bin/env -S perl -wl

use strict;
use List::Util qw(sum min);
use Data::Dumper qw(Dumper);

open INFILE, "./input.dat" || die "INFILE:$!\n";

my @input;
my (%files,%dirs);
my $curr_dir="";

{
local $/="cd ";
@input=<INFILE>;
}

close INFILE;

foreach (1 .. @input-1) {
    &make_struct($input[$_]);
}


my %filesize=();

map {
    $filesize{$_}=&filesize($_);      
} keys %dirs;


my $space_needed = 30_000_000-(70_000_000 - ($filesize{'//'}));

my @candidates = min grep {
    $_ > $space_needed;
} values %filesize;

print Dumper @candidates;


sub make_struct {
    my ($string) = @_;
 
    my @string=split(/\n/,$string);
    
    my $dirname=$curr_dir;
 
    if ($string[0] =~ /\.\./) {
        my @curr_dir=split(/\//,$curr_dir);
        pop @curr_dir;
        $curr_dir = join("/",@curr_dir);
        return;
    } 
    
    
    if ($string[0] ne '..') {
        $dirname=$dirname.'/'.$string[0];
        $curr_dir = $dirname;
        $files{ $dirname } = [];
        $dirs{ $dirname } = [];
    
    
        for my $i (@string) {
            ($i =~ /^dir\s+(.+)$/) && (push @{ $dirs{ $dirname} }, $dirname.'/'.$1 );
            ($i =~ /^(\d+)/) && (push @{ $files{ $dirname} },$1 );
        }
    }  
}

sub filesize {
    my ($dirname) = @_;
    
    my $filesize = sum @{ $files{$dirname} };

    for my $i (@{ $dirs{$dirname} }) {
        $filesize += &filesize($i);
    }
    $filesize;
}
