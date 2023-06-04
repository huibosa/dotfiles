#!/usr/bin/env python3

import sys
from PyPDF2 import PdfFileReader, PdfFileWriter, PdfWriter


class MyPdf:
    # NOTE: Should the output be a list?
    def __init__(self, inputs, outputs) -> None:
        self.infiles = inputs
        self.outfiles = outputs

        self.readers = self.__open_ifstrm()
        self.writers = self.__open_ofstrm()

    def __open_ifstrm(self):
        ifstrms = []
        for fname in self.infiles:
            ifstrms.append(PdfFileReader(fname))
        return ifstrms

    def __open_ofstrm(self):
        ofstrms = []
        for fname in self.outfiles:
            with open(fname, "wb") as out:
                ofstrms.append(PdfFileWriter(out))
        return ofstrms

    def __write(self):

    def cat(self):
        if self.outfiles == None:
            self.outfiles = "cat-file.pdf"

        for ifstrm in self.readers:
            n = ifstrm.getNumPages()

            for i in range(n):
                self.ofstrm.addPage(ifstrm.pages[i])

        self.__write()

    def split(self):
        cnt = 1

        for fname in self.infiles:
            ifstrm = PdfFileReader(fname)
            n = ifstrm.getNumPages()

            for i in range(n):
                self.ofstrm.addPage(ifstrm.pages[i])

                self.outfiles = f"{self.outfiles}_{cnt}"
                self.__write()

                self.ofstrm.clean_page(ifstrm.pages[i])

                cnt = cnt + 1


def oddPages(fname):
    ifstrm = PdfFileReader(fname)
    ofstrm = PdfFileWriter()
    for i in range(ifstrm.getNumPages()):
        if i & 0x1:
            ofstrm.addPage(ifstrm.getPage(i))

    with open("oddPage.pdf", "wb") as f:
        ofstrm.write(f)


def reverse_pages(pdf_path):
    pdf_writer = PdfFileWriter()
    pdf_reader = PdfFileReader(pdf_path)

    for page in reversed(pdf_reader.pages):
        pdf_writer.addPage(page)

    with open(pdf_path, "wb") as fh:
        pdf_writer.write(fh)


def rotate_pages(pdf_path):
    pdf_writer = PdfFileWriter()
    pdf_reader = PdfFileReader(pdf_path)

    # Rotate page 180 degrees to the right
    for page in range(pdf_reader.getNumPages()):
        page_1 = pdf_reader.getPage(page).rotateClockwise(180)
        pdf_writer.addPage(page_1)

    with open(pdf_path, "wb") as fh:
        pdf_writer.write(fh)


def page(path):
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


def interleave(fnames, output):
    pdfWriter = PdfFileWriter()
    input1 = PdfFileReader(fnames[0])
    input2 = PdfFileReader(fnames[1])

    # pdf1 and pdf2 should have equal page numbers
    max = input1.getNumPages()
    cnt1 = 0
    cnt2 = 0

    while cnt1 < max or cnt2 < max:
        if cnt1 <= cnt2:
            pdfWriter.addPage(input1.pages[cnt1])
            cnt1 = cnt1 + 1
        else:
            pdfWriter.addPage(input2.pages[cnt2])
            cnt2 = cnt2 + 1

    # Write out the merged PDF
    with open(output, "wb") as out:
        pdfWriter.write(out)
