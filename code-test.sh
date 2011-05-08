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

Test()
{
    local file
    file=$1
    # 测试每种编码
    list | while read code;
    do
        iconv -f $code "$file" >/dev/null 2>&1
        if [[ $? == 0 ]];
        then
            echo "$code"
            return 0
        fi
    done
}


[[ "$*" == "" ]] && Usage


export ok=0

# 取出每个文件名
echo "$*" | tr ' ' '\n' | while read file;
do
    # 测试每种编码
    code=$(Test "$file")
    if [[ "$code" != "" ]]; then
        printf "%10s -- %s\n" $code "$file"
    else
        printf "%10s -- %s\n" "unknown" "$file"
    fi
done

