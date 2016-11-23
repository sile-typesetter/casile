#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';

my @names;

my $name = '\p{Lu}\p{Ll}(\p{L}|-\p{Lu}\p{L})*';
my $nameOrInitial = '('.$name.'|\p{Lu}\.)';

print STDERR "NAME: $name\n";
print STDERR "ORIN: $nameOrInitial\n";

# while (<>) {
while (my $par = <>) {
  chomp($par);

  # Skip footnotes
  next if $par =~ m/^\[/;

  # Skip chapter and section headers (title cased)
  next if $par =~ m/^#/;

  # Find anything that even smells like a proper name
  while ($par =~ m/\b(($nameOrInitial\s?)+$name)\b/g) {
    push @names, $1."\n";
  }

}

print @names;
