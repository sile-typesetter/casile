#!/usr/bin/env perl

# Convert hyphens between numbers to figure dashes
while (<>) {
  s#(?<=\d)-\s*(?=\d)#--#g;
  print;
}
