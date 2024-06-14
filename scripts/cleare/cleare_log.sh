#!/bin/bash

tb=$(clickhouse-client -n --format=TSVRaw  -d system -q "show tables like 'query_log%';") # |grep -vE "query_thread_log_[0|1]$")
for t in $tb;do
        echo $t
        clickhouse-client -d system -q "select count(*) from $t"
        clickhouse-client -d system -q "drop table $t"
done