#!/usr/bin/env python
"""
Pandoc filter to convert svg files to pdf as suggested at:
https://github.com/jgm/pandoc/issues/265#issuecomment-27317316
Modified to use make at build time
"""

import mimetypes
import subprocess
import os
import sys
from pandocfilters import toJSONFilter, Image

fmt_to_option = {
    "sile": "pdf",
    "docx": "png",
}


def svg_to_any(key, value, fmt, meta):
    if key == "Image":
        if len(value) == 2:
            # before pandoc 1.16
            alt, [src, title] = value
            attrs = None
        else:
            attrs, alt, [src, title] = value
        mimet, _ = mimetypes.guess_type(src)
        targetfmt = fmt_to_option.get(fmt)
        if mimet == "image/svg+xml" and targetfmt:
            base_name, _ = os.path.splitext(src)
            eps_name = base_name + "." + targetfmt
            cmd_line = ["make", eps_name]
            sys.stderr.write("Running %s\n" % " ".join(cmd_line))
            subprocess.call(cmd_line, stdout=sys.stderr.fileno())
            if attrs:
                return Image(attrs, alt, [eps_name, title])
            else:
                return Image(alt, [eps_name, title])


if __name__ == "__main__":
    toJSONFilter(svg_to_any)
