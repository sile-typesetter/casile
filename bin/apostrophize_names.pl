#!/usr/bin/env perl

use utf8;
use open ':std', ':encoding(UTF-8)';
use File::Basename;

# Build a regex out of all the proper names we've set aside
my @names;
open(my $names_en, '<:encoding(UTF-8)', dirname($0)."/../names.en.txt");
while (my $name = <$names_en>) { chomp($name); push @names, $name; }
open(my $names_tr, '<:encoding(UTF-8)', dirname($0)."/../names.tr.txt");
while (my $name = <$names_tr>) { chomp($name); push @names, $name; }
my $names = "(".join('|', sort { length $b <=> length $a } @names).")";

# Except for -lar -lu and -sal suffixes, suffixes should get apostrophes
while (<>) {
  # Don't process stuff in footnotes or headers
  print and next if m{^(\[^|#)};

  s#$names(?=\p{Ll})(?!(l[ae]r|l[ıioöuü]|s[ae]l))#\1’#g;
  print;
}
