#!/bin/bash

## COPY parts from shadow dir to table dir and DETACH parts

tab_name="test"
destdb="default"
sourcedir="/var/lib/clickhouse"
dest="$sourcedir/data/$destdb/$tab_name/detached"
shadowdir="/var/lib/clickhouse/shadow"

backup_num=$(cat $shadowdir/increment.txt)

   for stdir in $(find "$shadowdir" -mindepth 4 -maxdepth 4 -type d); do
     source="$stdir"
     echo "Директория $source"
     cp -r $source/* $dest
     chown -R clickhouse $dest
   done;

clickhouse-client --format=TSVRaw -q"select 'ALTER TABLE ' || database || '.' || table || ' ATTACH PARTITION ID \'' || partition_id || '\';\n' from system.detached_parts group by database, table, partition_id order by database, table, partition_id;" | clickhouse-client -mn
