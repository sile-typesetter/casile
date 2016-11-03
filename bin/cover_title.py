#!/usr/bin/env python

import sys
import os
import yaml
import re

file = sys.argv[1]
metafile = re.sub("-.*$", ".yml", file)
project = os.environ["PROJECT"]
metadata = open(metafile, 'r').read()
yamldata = yaml.load(metadata)

if "title" in yamldata:
    title = yamldata["title"]
else:
    title = "ERROR: No meta Data"

words = title.split(" ")

max = 0
for word in words:
    len = word.__len__()
    if len > max:
        max = len

lines = [ "" ]

for word in words:
    if lines[-1].__len__() == 0:
        lines[-1] = word
    elif lines[-1].__len__() + word.__len__() <= max + 2:
        lines[-1] += " " + word
    else:
        lines.append(word)

for line in lines:
    print(line)

