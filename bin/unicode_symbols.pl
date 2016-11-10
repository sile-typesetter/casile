#!/usr/bin/env perl

# Convert ASCII to correct Unicode quotes based on context
while (<>) {
  s#(?<!-)---(?!-)#—#g;
  s#(?<!-)--(?!-)#–#g;
  s#\.\.\.#…#g;
  print;
}
