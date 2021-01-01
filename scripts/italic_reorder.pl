#!/usr/bin/env perl

use utf8;
use open ':std', ':encoding(UTF-8)';

while (<>) {
  s/ \(([^\)]+)\)\*/* (*\1*)/g;
  print;
}
