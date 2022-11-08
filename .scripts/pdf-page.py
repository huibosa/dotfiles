#!/usr/bin/env python3

import sys
from PyPDF2 import PdfFileReader, PdfFileWriter

fname = sys.argv[1]
dst = sys.argv[2]
pages = []
start = 0
end = 0

ifstrm = PdfFileReader(fname)
ofstrm = PdfFileWriter()

if "," in dst:
    pages = [int(x) for x in dst.split(",")]
elif dst.count("-") == 1:
    start = int(dst.split("-")[0])
    end = int(dst.split("-")[1])
    pages = list(range(start, end + 1, 1))
else:
    pages = [int(dst)]

for p in pages:
    ofstrm.addPage(ifstrm.getPage(int(p) - 1))

with open(f"page-{dst}.pdf", "wb") as f:
    ofstrm.write(f)
