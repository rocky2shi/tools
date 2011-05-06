#!/bin/bash
# Rocky 2011-05-06 17:35:41
# �ļ�������
#

# ֧���ı����б�Ҳ���Է���iconv -l��������ݲ�����
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

[[ $1 == "" ]] && Usage

list | while read code;
do
    iconv -f $code $1 >/dev/null 2>&1
    if [[ $? == 0 ]];
    then
        echo $code
        exit 1 
        exit 0
    fi
done

