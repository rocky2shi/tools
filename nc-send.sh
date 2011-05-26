#!/bin/bash
#Rocky 2011-05-13 17:44:27

Usage()
{
    cat <<eof
 Usage: nc-send.sh filename [ip] [port]
eof
    exit 2
}

[[ "x$1" == "x" ]] && Usage;

# ipÉèÖÃ
if [[ "x$2" != "x" ]]; then
    ip=$2
else
    ip=192.168.16.2
fi

# ¶Ë¿ÚÉèÖÃ
if [[ "x$3" != "x" ]]; then
    port=$3
else
    port=15234
fi





nc $ip $port -vv < "$1" 
bell.sh

