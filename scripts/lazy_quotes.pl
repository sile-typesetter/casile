#!/usr/bin/env perl

# WARNING: This can screw up valid Markdown if there are code snippets. Only
# run on prose that is actually broken and check the results.

use utf8;
use open ':std', ':encoding(UTF-8)';

# Convert lazy double quote entry styles to something sane
while (<>) {
  s#(?<!\s)['‘’`]{3}#'"#g;
  s#['‘’`]{3}(?!\s)#"'#g;
  s#['‘’`]{2}#"#g;
  print;
}
