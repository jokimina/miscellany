#!/bin/bash

#Get InnoDB Row Lock Details and InnoDB Transcation Lock Memory
#mysql> SELECT SUM(trx_rows_locked) AS rows_locked, SUM(trx_rows_modified) AS rows_modified, SUM(trx_lock_memory_bytes) AS lock_memory FROM information_schema.INNODB_TRX;
#+-------------+---------------+-------------+
#| rows_locked | rows_modified | lock_memory |
#+-------------+---------------+-------------+
#|        NULL |          NULL |        NULL |
#+-------------+---------------+-------------+
#1 row in set (0.00 sec)

#+-------------+---------------+-------------+
#| rows_locked | rows_modified | lock_memory |
#+-------------+---------------+-------------+
#|           0 |             0 |         376 |
#+-------------+---------------+-------------+

#Get InnoDB Compression Time
#mysql> SELECT SUM(compress_time) AS compress_time, SUM(uncompress_time) AS uncompress_time FROM information_schema.INNODB_CMP;
#+---------------+-----------------+
#| compress_time | uncompress_time |
#+---------------+-----------------+
#|             0 |               0 |
#+---------------+-----------------+
#1 row in set (0.00 sec)


#Get InnoDB Transaction states

#TRX_STATE	Transaction execution state. One of RUNNING, LOCK WAIT, ROLLING BACK or COMMITTING.

#mysql> SELECT LOWER(REPLACE(trx_state, " ", "_")) AS state, count(*) AS cnt from information_schema.INNODB_TRX GROUP BY state;
#+---------+-----+
#| state   | cnt |
#+---------+-----+
#| running |   1 |
#+---------+-----+
#1 row in set (0.00 sec)





innodb_metric=$1

case $innodb_metric in
   Innodb_rows_locked)
                      value=$(echo "SELECT SUM(trx_rows_locked) AS rows_locked, SUM(trx_rows_modified) AS rows_modified, SUM(trx_lock_memory_bytes) AS lock_memory FROM information_schema.INNODB_TRX;"|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N| awk '{print $1}')
                      if [ "$value" == "NULL" ];then
                         echo 0
                      else
                         echo $value
                      fi
                    ;;
   Innodb_rows_modified)
                      value=$(echo "SELECT SUM(trx_rows_locked) AS rows_locked, SUM(trx_rows_modified) AS rows_modified, SUM(trx_lock_memory_bytes) AS lock_memory FROM information_schema.INNODB_TRX;"|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N| awk '{print $2}')
                      if [ "$value" == "NULL" ];then
                         echo 0
                      else
                         echo $value
                      fi
                    ;;
   Innodb_trx_lock_memory)
                      value=$(echo "SELECT SUM(trx_rows_locked) AS rows_locked, SUM(trx_rows_modified) AS rows_modified, SUM(trx_lock_memory_bytes) AS lock_memory FROM information_schema.INNODB_TRX;"|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N| awk '{print $3}')
                      if [ "$value" == "NULL" ];then
                         echo 0
                      else
                         echo $value
                      fi
                    ;;
      Innodb_compress_time)
                      value=$(echo "SELECT SUM(compress_time) AS compress_time, SUM(uncompress_time) AS uncompress_time FROM information_schema.INNODB_CMP;"|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N|awk '{print $1}')
                      echo $value
                      ;;
       
     Innodb_uncompress_time)
                      value=$(echo "SELECT SUM(compress_time) AS compress_time, SUM(uncompress_time) AS uncompress_time FROM information_schema.INNODB_CMP;"|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N|awk '{print $2}')
                      echo $value
                      ;;   
         Innodb_trx_running)
                         value=$(echo 'SELECT LOWER(REPLACE(trx_state, " ", "_")) AS state, count(*) AS cnt from information_schema.INNODB_TRX GROUP BY state;'|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N|grep running|awk '{print $2}')
                         if [ "$value" == "" ];then
                            echo 0
                         else
                            echo $value
                         fi
                        ;;
       Innodb_trx_lock_wait)
                         value=$(echo 'SELECT LOWER(REPLACE(trx_state, " ", "_")) AS state, count(*) AS cnt from information_schema.INNODB_TRX GROUP BY state;'|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N|grep lock_wait|awk '{print $2}')
                         if [ "$value" == "" ];then
                            echo 0
                         else
                            echo $value
                         fi
                        ;;
    Innodb_trx_rolling_back)
                         value=$(echo 'SELECT LOWER(REPLACE(trx_state, " ", "_")) AS state, count(*) AS cnt from information_schema.INNODB_TRX GROUP BY state;'|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N|grep rolling_back|awk '{print $2}')
                         if [ "$value" == "" ];then
                            echo 0
                         else
                            echo $value
                         fi
                        ;;
    Innodb_trx_committing)
                         value=$(echo 'SELECT LOWER(REPLACE(trx_state, " ", "_")) AS state, count(*) AS cnt from information_schema.INNODB_TRX GROUP BY state;'|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N|grep committing|awk '{print $2}')
                         if [ "$value" == "" ];then
                            echo 0
                         else
                            echo $value
                         fi
                        ;;
 Innodb_trx_history_list_length)
                         echo 'show engine innodb status\G'|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N|grep "History list length"|awk '{print $4}'
                        ;;
    Innodb_last_checkpoint_at)
                         echo 'show engine innodb status\G'|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N|grep "Last checkpoint at"|awk '{print $4}'
                        ;;

   Innodb_log_sequence_number)
                         echo 'show engine innodb status\G'|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N|grep "Log sequence number"|awk '{print $4}'
                        ;;
    Innodb_log_flushed_up_to)
                         echo 'show engine innodb status\G'|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N|grep "Log flushed up to"|awk '{print $5}'
                        ;;
   Innodb_open_read_views_inside_innodb)
                         echo 'show engine innodb status\G'|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N|grep "read views open inside InnoDB"|awk '{print $1}'
                        ;;
        Innodb_queries_inside_innodb)
                        echo 'show engine innodb status\G'|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N|grep "queries inside InnoDB"|awk '{print $1}'
                        ;;
        Innodb_queries_in_queue)
                        echo 'show engine innodb status\G'|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N|grep "queries in queue"|awk '{print $5}'
                        ;;
        Innodb_hash_seaches)
                        echo 'show engine innodb status\G'|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N|grep "hash searches"|awk '{print $1}'
                        ;;
       Innodb_non_hash_searches)
                        echo 'show engine innodb status\G'|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N|grep "non-hash searches/s"|awk '{print $4}'
                        ;;
       Innodb_node_heap_buffers)
                        echo 'show engine innodb status\G'|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N|grep "node heap"|awk '{print $8}'
                       ;;
       Innodb_mutex_os_waits)
                        echo 'show engine innodb status\G'|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N|grep "Mutex spin waits"|awk '{print $9}'
                       ;;
       Innodb_mutex_spin_rounds)
                        echo 'show engine innodb status\G'|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N|grep "Mutex spin waits"|awk '{print $6}'|tr -d ','
                       ;;
       Innodb_mutex_spin_waits)
                        echo 'show engine innodb status\G'|mysql --defaults-file=/usr/local/zabbix/etc/.my.cnf -N|grep "Mutex spin waits"|awk '{print $4}'|tr -d ','
                       ;; 

                   *)
                    echo "wrong parameter"
                    ;;

esac
