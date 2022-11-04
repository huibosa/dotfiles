#!/usr/bin/env python3
# -*- encoding: utf8 -*-

import pyperclip
import time
import re


def delete_newline(str):
    str = str.replace("\r\n", " ")
    str = str.replace("\2", "")
    return str


def delete_whitespace(str):
    return re.sub(r"\s+", "", str)


def translate_punc(str):
    punc_ch = "！？｡＂＃＄％＆＇（）＊＋，－／：；＜＝＞＠［＼］＾＿｀｛｜｝～｢｣､、〃《》「」『』【】〔〕〖〗〘〙〚〛〜〝〞“”."
    punc_en = '!?."#$%&\'()*+,-/:;<=>@[\\]^_`{|}~[],,"<>[][][][][][][]~"""".'
    table = {en: ch for en, ch in zip(punc_en, punc_ch)}
    return str.translate(table)


def is_chinese(str):
    # return re.compile(ur'[\u4e00-\u9fa5]').search(str)
    return re.search(r"[\u4e00-\u9fff]+", str)


if __name__ == "__main__":
    content = pyperclip.paste()

    while True:
        try:
            content_tmp = pyperclip.paste()

            if content_tmp != content:
                content = content_tmp

                content = delete_newline(content)
                if is_chinese(content):
                    content = delete_whitespace(content)
                    content = translate_punc(content)

                pyperclip.copy(content)
                print("Clipboard has been updated")

        except UnicodeDecodeError:
            print("Error: UnicodeDecodeError, try running in windows")
            pyperclip.copy("")
