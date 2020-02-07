#!/usr/bin/env python3
#-*-python-*-


import pycld2 as cld2
import sys
import argparse

parser = argparse.ArgumentParser(description='language filter')
parser.add_argument('-s','--srclang','--source-language', type=str, default='en',
                   help='accepted language')
parser.add_argument('-t','--trglang','--target-language', type=str, default='de',
                   help='accepted language')
args = parser.parse_args()


def supported_language(lang):
    supported = False
    for l in cld2.LANGUAGES:
        if l[1] == lang:
            return True
    return False


def is_accepted(line,accept,reject):
    # isReliable, textBytesFound, details = cld2.detect(line, hintLanguage=args.lang)
    isReliable, textBytesFound, details = cld2.detect(line, bestEffort=True)
    if accept:
        if details[0][1] == accept:
            if isReliable:
                return True
    else:
        if details[0][1] != 'un':
            if details[0][1] != reject:
                return True



if not supported_language(args.srclang):
    # print(args.srclang + " is not supported")
    srcreject = 'en'
    srcaccept = ''
else:
    srcaccept = args.srclang
    srcreject = ''

if not supported_language(args.trglang):
    # print(args.trglang + " is not supported")
    trgreject = 'en'
    trgaccept = ''
else:
    trgaccept = args.trglang
    trgreject = ''



for line in sys.stdin:
    text = line.rstrip().split("\t")
    if len(text) > 1:
        if text[0] and text[1]:
            if is_accepted(text[0],srcaccept,srcreject):
                if is_accepted(text[1],trgaccept,trgreject):
                    print(text[0] + "\t" + text[1])

