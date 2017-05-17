#!/usr/bin/env perl

use utf8;
use open ':std', ':encoding(UTF-8)';

while (<>) {
  # Place footnote markers after any trailing punctuation.
  s/(?<!^)(\[\^\d+\])([\p{P}]+)/\2\1/g;
  # Move trailing punction inside double quotes
  s/”([,\.?!])/\1”/g;
  # Use thin space between proper name initials
  s/(?<=\p{Lu}\.) (\p{Lu}\.) (?=\p{Lu})/ \1 /g;
  print;
}
