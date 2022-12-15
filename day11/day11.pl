#!/usr/bin/env -S perl -wl

use strict;

open my $fh_infile, "<", "input.dat" || die "INFILE:$!\n";

my (@input, @monkeys);
{
    local $/="\n\n";
    
    @input=(<$fh_infile>);
}

close $fh_infile;

for my $i (0 .. @input-1) {
    my @monkey_data = split("\n",$input[$i]);
    
    $monkeys[$i] = {};
    
    ($monkey_data[0] =~ /Monkey\s+(\d+):/) &&
        ($monkeys[$i]->{'id'}=$1);

    ($monkey_data[1] =~ /Starting\s+items:\s+(.+)/) &&
        ($monkeys[$i]->{'items'} = [split(/,\s*/,$1)]);

    ($monkey_data[2] =~ /Operation:\s+(.+)/) &&
        ($monkeys[$i]->{'operation'} = &parse_ops($1));

    ($monkey_data[3] =~ /Test:\s+divisible\s+by\s+(\d+)/) &&
        ($monkeys[$i]->{'test'} = $1);
        
    ($monkey_data[4] =~ /If\s+true:\s+throw\s+to\s+monkey\s+(\d+)/) &&
        ($monkeys[$i]->{'ifTrue'} = $1);
    
    ($monkey_data[5] =~ /If\s+false:\s+throw\s+to\s+monkey\s+(\d+)/) &&
        ($monkeys[$i]->{'ifFalse'} = $1);
        
    $monkeys[$i]->{'ctr'}=0; # counter for inspections
    
}

#-- sort by id just in case input is not sorted
@monkeys = sort { $a->{'id'} <=> $b->{'id'} } @monkeys;

for (1 .. 20) {
    for my $i (0 .. @monkeys-1) {
        &monkey_each_cycle($i);
    }
}

my @ctr;
for my $i (0 .. @monkeys-1) {
    push @ctr, $monkeys[$i]->{'ctr'};
}

@ctr = sort {$b <=> $a} @ctr;

print $ctr[0]*$ctr[1];

#-- monkey methods
sub monkey_each_cycle {
    my ($id) = @_;
    
    #make copy of items to loop through
    my @items = $monkeys[$id]->{'items'}->@*;
    
    for my $item (@items) {
        
        #inspect & increment ctr
        $monkeys[$id]->{'ctr'} += 1;
        
        #apply operation
        $item = $monkeys[$id]->{'operation'}->($item);    
        
        #monkey gets bored divide by 3 and round down
        $item=int($item/3);
        
        #test
        my $test = ( ($item % ($monkeys[$id]->{'test'}))  == 0);
        
        #throw
        $test ? 
            &throw_item($item, $id,
                $monkeys[$id]->{'ifTrue'}) :
            &throw_item($item, $id,
                $monkeys[$id]->{'ifFalse'});        
    } 
}




sub throw_item {
    my ($item, $id_from, $id_to) = @_; #id of monkey to throw to
    
    shift $monkeys[$id_from]->{'items'}->@*;
    
    push ( @{ $monkeys[$id_to]->{'items'} }, $item );
    
}

sub parse_ops {
    my ($opstring)=@_;
    $opstring =~ s/new/\$new/g;
    $opstring =~ s/old/\$old/g;
    return sub { my ($old) = @_;
        my $new;        
        eval $opstring;
        return $new;
        }
}
