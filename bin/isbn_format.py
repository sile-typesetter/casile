#!/usr/bin/env python

import sys
import os
import ruamel.yaml as yaml
import isbnlib

metafile = sys.argv[1]
metadata = open(metafile, 'r').read()
yamldata = yaml.safe_load(metadata)

identifier = {}

if "identifier" in yamldata:
    for id in yamldata["identifier"]:
        if "key" in id:
            isbnlike = isbnlib.get_isbnlike(str(id["text"]))[0]
            if isbnlib.is_isbn13(isbnlike):
                identifier[id["key"]] = isbnlib.EAN13(isbnlike)

isbn = identifier[sys.argv[2]] if sys.argv[2] in identifier else "9786056644504"

if len(sys.argv) >= 4 and sys.argv[3] == "mask":
    print(isbnlib.mask(isbn))
else:
    print(isbn)
