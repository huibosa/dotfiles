#!/usr/bin/env python3


import sys
from PyPDF2 import PdfFileReader, PdfFileWriter


def catPdfs(fnames, output):
    pdfWriter = PdfFileWriter()

    for fname in fnames:
        input = PdfFileReader(fname)
        n = input.getNumPages()

        for i in range(n):
            pdfWriter.addPage(input.pages[i])

    with open(output, "wb") as out:
        pdfWriter.write(out)


if __name__ == "__main__":
    catPdfs(sys.argv[1:], output="catenated-pages.pdf")
