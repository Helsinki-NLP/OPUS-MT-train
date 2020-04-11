#!/usr/bin/env python3
#-*-python-*-


import pycld2 as cld2
import argparse
import sys


parser = argparse.ArgumentParser(description='language filter')
parser.add_argument('-l','--lang','--language', type=str, default='en',
                   help='accepted language')
parser.add_argument('-s','--supported','--supported-languages', action='store_true',
                   help='list all supported languages')
parser.add_argument('-c','--checklang','--check-language-support', action='store_true',
                   help='show whether languages are supported')
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
        if details[0][1] != reject:
            # print("ACCEPT")
            # print(details)
            return True
        # else:
        #     print("REJECT", file=sys.stderr)
        #     print(details, file=sys.stderr)
        #     print(line, file=sys.stderr)



if args.supported:
    print(cld2.LANGUAGES)
    quit()


if args.checklang:
    if args.lang:
        if supported_language(args.lang):
            print(args.lang + " is supported")
        else:
            print(args.lang + " is not supported")
    quit()


if not supported_language(args.lang):
    # print(args.lang + " is not supported")
    reject = 'en'
    accept = ''
else:
    accept = args.lang
    reject = ''


for line in sys.stdin:
    text = line.rstrip()
    if text:
        if is_accepted(text,accept,reject):
            print(text)
    else:
        print("")
