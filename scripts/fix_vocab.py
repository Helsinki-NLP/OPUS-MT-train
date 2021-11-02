#!/usr/bin/env python3
#-*-python-*-

import yaml
import sys
from shutil import copyfile


filename = sys.argv[1]

try:
    input = open(filename, 'r')
    yaml.load(input)
except:
    print('YAML file is broken - try to fix it!')
    print(f'copy {filename} to {filename}.bak')
    copyfile(filename, f'{filename}.bak')

    vocab={}
    # for line in sys.stdin:
    with open(filename) as fh:
        for line in fh:
            parts = line.rstrip().split(': ')
            parts[0] = parts[0][1:-1]
            vocab[parts[0]] = int(parts[1])


    print(f'write a new version of {filename}')
    output = open(filename, 'w')
    yaml.dump(vocab, output, allow_unicode=True)
