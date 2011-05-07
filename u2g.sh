#!/bin/bash


tmp=/tmp/.XDFGSD25u123498234

[[ "$1" == "-h" ]] && echo " Usage: $(basename $0) filename" && exit

if [[ "$1" == "" ]]; then
    iconv -f utf8 -t gb18030 
else
    iconv -f utf8 -t gb18030 $1 > $tmp && /bin/cp -f $tmp $1
    /bin/rm -f $tmp
fi

