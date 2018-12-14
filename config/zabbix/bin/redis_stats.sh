#!/bin/bash
METRIC="$1"
HOSTNAME=127.0.0.1
PORT="${2:-6379}"
CACHE_FILE="/tmp/redis_$PORT.cache"

    (echo -en "INFO\r\n"; sleep 1;) | nc $HOSTNAME $PORT > $CACHE_FILE 2>/dev/null || exit 1

grep "^$METRIC:" $CACHE_FILE |awk -F':' '{print $2}'
