#!/usr/bin/env python3

from PyPDF2 import PdfFileReader, PdfFileWriter
import sys

fname = sys.argv[1]

ifstrm = PdfFileReader(fname)
ofstrm = PdfFileWriter()
for i in range(ifstrm.getNumPages()):
    if i & 0x1:
        ofstrm.addPage(ifstrm.getPage(i))

with open("oddPage.pdf", "wb") as f:
    ofstrm.write(f)
