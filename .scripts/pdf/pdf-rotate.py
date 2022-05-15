#!/usr/bin/env python3


from PyPDF2 import PdfFileReader, PdfFileWriter
import sys


def rotate_pages(pdf_path):
    pdf_writer = PdfFileWriter()
    pdf_reader = PdfFileReader(pdf_path)

    # Rotate page 180 degrees to the right
    for page in range(pdf_reader.getNumPages()):
        page_1 = pdf_reader.getPage(page).rotateClockwise(180)
        pdf_writer.addPage(page_1)

    with open(pdf_path, "wb") as fh:
        pdf_writer.write(fh)


if __name__ == "__main__":
    for path in sys.argv[1:]:
        rotate_pages(path)
