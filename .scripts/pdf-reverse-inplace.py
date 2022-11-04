#!/usr/bin/env python3


import sys
from PyPDF2 import PdfFileReader, PdfFileWriter


def reverse_pages(pdf_path):
    pdf_writer = PdfFileWriter()
    pdf_reader = PdfFileReader(pdf_path)

    for page in reversed(pdf_reader.pages):
        pdf_writer.addPage(page)

    with open(pdf_path, "wb") as fh:
        pdf_writer.write(fh)


if __name__ == "__main__":
    for path in sys.argv[1:]:
        reverse_pages(path)
