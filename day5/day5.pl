#!/usr/bin/env -S perl -wl

use Data::Dumper qw(Dumper);

open INFILE, "./input.dat" || die "INFILE:$!\n";

my @in_arry = ([],[],[],[],[],[],[],[],[]);
my $line_ctr=0;

while (<INFILE>) {
    chomp;
        
    my $str_pos = 1;
    for my $col_ctr (0 .. 8) {
        my $testchar = substr($_, $str_pos, 1);
        ($testchar =~ /[A-Z]/) && (push @{ $in_arry[$col_ctr] }, 
            $testchar);
        $str_pos += 4;  
    }
    
    $ctr++;
    $ctr==8 && last;
}

while (<INFILE>){
    /^move/ && &move($_);
}
close INFILE;


print Dumper(@in_arry);

sub move {
    my ($instruction)=@_;
    
    my ($tmp,$num,$from,$to) = split(/move\s+|from\s+|to\s+|\n/,$instruction); 

    map { s/\s+$// } ($num,$from,$to); #--trim
    
    map { 
        ($tmp) = shift @{ $in_arry[$from-1] };
        unshift @{ $in_arry[$to-1] }, $tmp;
    
    } (1 .. $num);
    return; 
}



