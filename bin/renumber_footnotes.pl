#!/usr/bin/env perl

use utf8;
use open ':std', ':encoding(UTF-8)';

my $offset = 0;
my $last = 0;

sub calculate_offset {
	my ($i) = @_;
	if ($1 == 1) {
		$offset += $last;
	}
	$last = $i;
}

sub add_offset {
	my ($i) = @_;
	my $j = $i + $offset;
	return "[^$j]";
}

for my $line (<>) {
	if ($line =~ m/(?<!^)\[\^(\d+)\]/) {
		calculate_offset($1);
	}
	$line =~ s/\[\^(\d+)\]/add_offset($1)/ge;
	print $line;
}
