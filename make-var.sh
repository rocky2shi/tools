#!/bin/bash
# Rocky 2011-05-03 16:51:54
#
# �鿴Makefile�б���ֵ
#

[[ $1 == "" ]] && { echo "Usage make-var.sh [d-]make_var"; exit 1;}

make -f Makefile -f ~/tools/other/var.mk $1

