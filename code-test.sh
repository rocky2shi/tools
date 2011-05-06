#!/bin/bash
# Rocky 2011-05-06 17:35:41
# 文件编码检测
#

# 支技的编码列表（也可以分析iconv -l的输出，暂不做）
list()
{
    cat <<eof
    utf-8 
    gb2312
    gbk 
    gb18030
eof
}

Usage()
{
    cat <<eof
 Usage: code-test.sh filename
eof
    exit 2
}

[[ $* == "" ]] && Usage

list | while read code;
do
    iconv -f $code "$*" >/dev/null 2>&1
    if [[ $? == 0 ]];
    then
        printf "%10s -- %s\n" $code "$*"
        exit 0
    fi
done

