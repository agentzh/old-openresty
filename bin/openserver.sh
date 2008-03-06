#!/bin/bash

OPENRESTY_BACKEND=PgFarm
OPENRESTY_COMMAND=fastcgi
OPENRESTY_URL_PREFIX=openapi
OPENRESTY_CACHE=mmap
OPENRESTY_COLUMN_LIMIT=100
OPENRESTY_RECORD_LIMIT=10000

export OPENRESTY_BACKEND OPENRESTY_COMMAND

BASEDIR=`dirname $0`

OPENRESTY="${BASEDIR}/openapi.pl"


case "$1" in
 start)
        echo "OpenAPI server starting..."
        $OPENRESTY start &
        disown
        ;;
 stop)
        echo "OpenAPI server stoping..."
        pid=`ps axuww|grep [o]penapi |awk '{print $2}'`
        if [ 'x$pid' != 'x' ]; then
                sudo kill -9 $pid
        else
                echo "no openapi pid found!"
        fi
        ;;
 *)
        echo $"Usage: $0 {start|stop}"
        exit 1
        ;;
esac

