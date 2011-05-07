#!/bin/bash


tmp=/tmp/.XDFGSD25u123498234

[[ "$1" == "-h" ]] && echo " Usage: $(basename $0) filename" && exit

if [[ "$1" == "" ]]; then
    iconv -f gb18030 -t utf8
else    
    iconv -f gb18030 -t utf8 $1 > $tmp && /bin/cp -f $tmp $1
    /bin/rm -f $tmp
fi

