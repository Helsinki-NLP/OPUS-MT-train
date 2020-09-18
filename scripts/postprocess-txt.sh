#!/bin/bash
#
# USAGE postprocess.sh < input > output
#

perl -C -pe 's/\p{C}/ /g;'
