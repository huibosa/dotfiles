#!/usr/bin/env python3


from PyPDF2 import PdfFileReader, PdfFileWriter
import sys


def split(path):
    cnt = 1
    pdf = PdfFileReader(path)
    for page in range(pdf.getNumPages()):
        pdf_writer = PdfFileWriter()
        pdf_writer.addPage(pdf.getPage(page))

        output = "split.pdf"
        with open(f"{cnt}_{output}", "wb") as output_pdf:
            pdf_writer.write(output_pdf)
        cnt = cnt + 1


if __name__ == "__main__":
    path = sys.argv[1]
    split(path)
