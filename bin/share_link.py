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

domain = "https://owncloud.alerque.com/"
prefix = ""
infix = ""

if "owncloudshare" in yamldata:
    prefix = "index.php/s/"
    infix = yamldata["owncloudshare"]
    infix += "/download?path=%2F&files="
else:
    prefix = "remote.php/webdav/viachristus/"
    infix = project + "/"

print (domain + prefix + infix + file)

