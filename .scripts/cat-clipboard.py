#!/usr/bin/env python3

import pyperclip

str = ""
urls = []

while True:
    tmp = pyperclip.paste()

    if str != tmp:
        str = tmp
        urls.append(str)
        print(str)
