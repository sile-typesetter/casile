#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';

my @names;

my $name = '\p{Lu}\p{Ll}(\p{L}|-\p{Lu}\p{L})*';
my $postfix = ',?\s([IV]{1,3}|[JS]r|MD|Bey|Paşa|Hanım|Efendi|Başkanı)\.?';
my $nameOrInitial = '('.$name.'|\p{Lu}\.)\s*';

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
  while ($par =~ m/\b(($nameOrInitial)+($name)($postfix)?)\b/gs) {
    push @names, $1."\n";
  }

}

print @names;
