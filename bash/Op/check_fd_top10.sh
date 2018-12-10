lsof |& sed '1,3d' | awk '{num[$2]++} END{for(pid in num)print pid,"-->",num[pid]}' | sort -nr -k 3 | head
