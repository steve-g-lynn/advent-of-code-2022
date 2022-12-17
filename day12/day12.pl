#!/usr/bin/env -S perl -wl

use strict;

#-- read in the data
(open my $fh_infile, '<', './input.dat') || (die "INFILE:$!\n");

my $input=[];
my $ctr;

while (<$fh_infile>) {
    chomp;
    $input->[$ctr++] = [ split(//,$_) ];
}


close $fh_infile;

#-- find start and end position

my ($start,$end);
OUTER: for my $i (0 .. scalar(@$input)-1) {
    INNER: for my $j (0 .. scalar(@{$input->[$i]})-1) {
        if ($input->[$i]->[$j] eq 'E') {  
            $end=[$i,$j];
            $input->[$i]->[$j] = 'z';
        }
        if ($input->[$i]->[$j] eq 'S') {
            $start=[$i,$j];
            $input->[$i]->[$j] = 'a';
        }
    }
}


#--  breadth-first search
#-- h/t hyper-neutrino https://www.youtube.com/watch?v=xhe79JubaZI

my (%seen);

$ctr=0; #-- declared earlier, reuse

my $queue=[$ctr,$end];

QUEUE: while ($queue->@*) {
    my $ctr=shift $queue->@*;
    my $next=shift $queue->@*;
    my $chr_next=&cell($next);
    
    POS: for my $pos (
        [$next->[0]+1, $next->[1]],
        [$next->[0]-1, $next->[1]],
        [$next->[0], $next->[1]-1],
        [$next->[0], $next->[1]+1]
    ) {
        $seen{$pos->[0].':'.$pos->[1]} && (next POS);
        
        &out_of_bounds($pos) && (next POS);
        
        my $chr_pos=&cell($pos);        
        
        ((ord($chr_pos) - ord($chr_next)) < -1) && next POS; 

        if (($pos->[0] eq $start->[0])
            && ($pos->[1] eq $start->[1])) {
            print "FINAL ANSWER: ",$ctr+1;
            last QUEUE;
        }
        
        $seen{$pos->[0].':'.$pos->[1]}++;
        push @$queue, ($ctr+1, $pos);      
        }
}

sub cell {
    $input->[$_[0]->[0]]->[$_[0]->[1]];    
}

sub out_of_bounds {
    ($_[0]->[0] < 0) || ($_[0]->[0] > (scalar($input->@*)-1)) ||
    ($_[0]->[1] < 0) || ($_[0]->[1] > (scalar($input->[0]->@*)-1)); 
}
