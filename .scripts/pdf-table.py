#!/usr/bin/env python3

# This scripts extract table from pdf and write them to separate sheets
import pdfplumber
import pandas as pd
import sys


def extract_table(pdf_path):
    count = 1  ## for sheet name
    with pdfplumber.open(pdf_path) as pdf:
        with pd.ExcelWriter("tables.xlsx") as writer:
            for page in pdf.pages:
                for table in page.extract_tables():
                    data = pd.DataFrame(table[1:], columns=table[0])
                    data.to_excel(writer, sheet_name=f"sheet{count}")
                    count += 1


if __name__ == "__main__":
    pdf_path = sys.argv[1]
    extract_table(pdf_path)
