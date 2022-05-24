#!/usr/bin/env python3

# use word to generate a pdf first, save the file as 'watermark.pdf'

from PyPDF2 import PdfFileWriter, PdfFileReader
from copy import copy
import sys

fname = "a.pdf"
target = "fileWithWaterMark.pdf"

ifstrm_wm = PdfFileReader("waterMark.pdf")
waterMark = ifstrm_wm.getPage(0)

ifstrm = PdfFileReader(fname)
ofstrm = PdfFileWriter()

for i in range(ifstrm.getNumPages()):
    pageToAddWM = ifstrm.getPage(i)
    newPage = copy(waterMark)
    newPage.merge(pageToAddWM)  ## the text is on top of watermark
    ofstrm.addPage(newPage)

with open(target, "wb") as f:
    ofstrm.write(f)


# TODO:
if __name__ == "__main__":
    fnames = [sys.argv[1], sys.argv[2]]
