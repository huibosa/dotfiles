#!/usr/bin/env python3

# This script calculates

import os
from difflib import SequenceMatcher


def similar(str1, str2):
    return SequenceMatcher(None, str1, str2).ratio()


files = os.listdir("./")
pairs = []

for i, u in enumerate(files):
    for j, v in enumerate(files):
        if i == j:
            continue

        ratio = similar(u, v)
        if ratio > 0.5:  # NOTE: Change the ratio here
            pairs.append((u, v))
            print(u)
            print(v)
