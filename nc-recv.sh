#!/bin/bash
#Rocky 2011-05-13 17:44:27

Usage()
{
    cat <<eof
 Usage: nc-recv.sh filename [port]
eof
    exit 2
}

[[ "x$1" == "x" ]] && Usage;

if [[ "x$2" != "x" ]]; then
    port=$2
else
    port=15234 
fi


nc -l $port -vv >> "$1" 
bell.sh

