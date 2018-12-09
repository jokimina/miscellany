ps -xH | awk '{a[$1]++}END{for (i in a){printf "%s  %s\n",i,a[i]}}' | sort -n  -k2.1 | tail
