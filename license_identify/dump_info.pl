#!/usr/bin/perl
use File::Copy;
use Storable;
use Data::Dumper;

$serialized_file = '/home/xji/Source_Code_Audit/serizlized_rpm_to_srcrpm.lorui';

my $retrieved_rpm_mapping = retrieve($serialized_file);
print Dumper($retrieved_rpm_mapping);
