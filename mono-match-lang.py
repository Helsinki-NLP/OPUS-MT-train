#!/usr/bin/env python3
#-*-python-*-


import pycld2 as cld2
import argparse
import sys


parser = argparse.ArgumentParser(description='language filter')
parser.add_argument('-l','--lang','--language', type=str, default='en',
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
                # print("ACCEPT")
                # print(details)
                return True
            # else:
            #     print("REJECT - not reliable", file=sys.stderr)
            #     print(details, file=sys.stderr)
            #     print(line, file=sys.stderr)
        # else:
        #     print("REJECT", file=sys.stderr)
        #     print(details, file=sys.stderr)
        #     print(line, file=sys.stderr)
    else:
        if details[0][1] != 'un':
            if details[0][1] != reject:
                # print("ACCEPT")
                # print(details)
                return True
            # else:
            #     print("REJECT", file=sys.stderr)
            #     print(details, file=sys.stderr)
            #     print(line, file=sys.stderr)
        # else:
        #     print("REJECT", file=sys.stderr)
        #     print(details, file=sys.stderr)
        #     print(line, file=sys.stderr)



if not supported_language(args.lang):
    # print(args.lang + " is not supported")
    reject = 'en'
    accept = ''
else:
    accept = args.lang
    reject = ''


for line in sys.stdin:
    text = line.rstrip()
    if is_accepted(text,accept,reject):
        print(text)

