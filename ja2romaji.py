# coding: utf-8
from pykakasi import kakasi
import sys
import re
import os
import codecs
import ntpath
import subprocess


def to_hiragana(line, kakasi, s_base, fw):
    # Mode to convert kanji and katakana into hiragana.
    kakasi.setMode("K", "H")
    kakasi.setMode("J", "H")

    conv = kakasi.getConverter()

    # print(conv.do(line))
    fw.write(conv.do(line + "\n"))


if __name__ == "__main__":
    args = sys.argv
    s = args[1]
    s = os.path.abspath(s)
    s_base = ntpath.basename(s)
    # print(s_base)

    kakasi = kakasi()
    f = codecs.open(s, "r", "utf-8")
    hiragana_text_f = "hiragana_" + s_base
    fw = codecs.open(hiragana_text_f, "a", "utf-8")
    for line in f:
        line = line.strip()
        responce = to_hiragana(line, kakasi, s_base, fw)

    f.close()
    fw.close()

    cmd_hiragana2katakana = "hiragana2katakana.pl" + " " + hiragana_text_f
    subprocess.call(cmd_hiragana2katakana, shell=True, timeout=None)

    katakana_hiragana_text_f = "Katakana_" + hiragana_text_f
    cmd_katakana2romaji = "katakana2Romaji.pl" + " " + katakana_hiragana_text_f
    subprocess.call(cmd_katakana2romaji, shell=True, timeout=None)
    
    os.remove(hiragana_text_f)
    os.remove(katakana_hiragana_text_f)

    print("Done!")
