#!/usr/bin/env python3

import pdfplumber
import sys

fname = sys.argv[1]

with pdfplumber.open(fname) as pdf:
    for page in pdf.pages:
        text = page.extract_text()
        file = open(fname.replace(".pdf", ".txt"), mode="a")
        file.write(text)
