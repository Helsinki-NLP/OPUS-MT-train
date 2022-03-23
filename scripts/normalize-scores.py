#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# taken from https://github.com/browsermt/students

from __future__ import print_function, unicode_literals, division

import sys
import argparse
import math


def main():
    args = parse_user_args()

    for line in sys.stdin:
        fields = line.strip().split("\t")
        trg = fields[-1]
        try:
            score = float(fields[0])
        except:
            score = 0.00

        if not args.no_normalize:
            length = len(trg.split())
            score = score / float(length + 1)
        if args.exp:
            score = math.exp(score)

        sys.stdout.write("{:.6f}\t{}".format(score, line))


def parse_user_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-n", "--no-normalize", action="store_true")
    parser.add_argument("-e", "--exp", action="store_true")
    return parser.parse_args()


if __name__ == "__main__":
    main()
