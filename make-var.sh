#!/bin/bash
# Rocky 2011-05-03 16:51:54
#
# 查看Makefile中变量值
#

[[ $1 == "" ]] && { echo "Usage make-var.sh [d-]make_var"; exit 1;}

make -f Makefile -f ~/tools/other/var.mk $1

