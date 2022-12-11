#!/usr/bin/env -S perl -wl

open INFILE, "./input.dat" || die "INFILE:$!\n";

my $input=<INFILE>;

close INFILE;

my $retval=0;
FOR: for my $ctr (0 .. length($input) ) {
    if ( &uniq (substr($input,$ctr,14) ) ) {
        $retval=$ctr+14;
        last FOR;
    }
}

print $retval;

sub uniq {
    my ($string)=@_;
    
    my @string=split(//,$string);
    
    my %string;
    
    map {
        $string{$_}++;
    } @string;   
    
    ( scalar(keys %string) == length($string) ) && return 1;
    
    return 0;
}
