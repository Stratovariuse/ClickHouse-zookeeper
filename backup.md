Наглядный пример с фризом партиций
https://it-lux.ru/clickhouse-backup-and-recovery/

Нужен скрипт

Команда для attach all detach part

```
clickhouse-client --format=TSVRaw -q"select 'ALTER TABLE ' || database || '.' || table || ' ATTACH PARTITION ID \'' || partition_id || '\';\n' from system.detached_parts group by database, table, partition_id order by database, table, partition_id;" | clickhouse-client -mn
```

Ничего менять не нужно, возьмет все парты из системной таблицы (в которой уже есть инфа о названиях БД и таблиц и ID партов)

```
#!/bin/bash

table_1="test"
echo $table_1
myvariable=$(clickhouse-client --format=TSVRaw -q"SHOW CREATE TABLE $table_1;")
clickhouse-client --format=TSVRaw -q"drop table $table_1;"
clickhouse-client --format=TSVRaw -q"$myvariable;"
echo $myvariable
```
Скрипт от Олега

```
function rsynctab()
{
  tab_name=$1
  destdb=$2
  backup_num=cat /var/lib/clickhouse/shadow/increment.txt
  echo $backup_num
  sourcedir=$sourcerootdir/shadow/$backup_num/
  dest=$destrootdir/$server_name/$dateslot/data/$destdb/$tab_name/detached
#  source=$sourcerootdir/shadow/$backup_num/data/$sourcedb/$tab_name/
  if [ -d $sourcerootdir/shadow/$backup_num/data ]; then
    # /var/lib/clickhouse/shadow/6811/data/wifi_db/wifi_stat_attendance
    source=$sourcerootdir/shadow/$backup_num/data/$sourcedb/$tab_name/
    echo "rsync from "$source" to "$destip":"$dest
    time rsync --rsync-path="mkdir -p $dest && rsync" --bwlimit=$bwlim -avpP -e "ssh -p $destport" $source $destip:/$dest

  else
    # /var/lib/clickhouse/shadow/6810/store/e91/e9101028-40c9-46fe-98fc-c4c2cfb24f4a
#    find $(pwd) -mindepth 3 -maxdepth 3 -type d
    for stdir in $(find "$sourcedir" -mindepth 3 -maxdepth 3 -type d); do
      source="$stdir"/
      echo "rsync from "$source" to "$destip":"$dest
      time rsync --rsync-path="mkdir -p $dest && rsync" --bwlimit=$bwlim -avpP -e "ssh -p $destport" $source $destip:/$dest
    done;
  fi
  if [ $rmshadow = 1 ]; then
    echo "rm -Rf $sourcedir"
    rm -Rf $sourcedir
  fi
}
```

Самотест (удаление, пересоздание таблицы, восстановление данных из детач)
 ```
 #!/bin/bash

readonly JOB_ID=$(/bin/date +%Y%m%d%H)
LOG_DIR="/var/log/sh"
LOG="$LOG_DIR/${JOB_ID}_$(hostname)_backup.log"
tab_name="test"
destdb="default"
sourcedir="/var/lib/clickhouse"
dest="$sourcedir/data/$destdb/$tab_name/detached"
shadowdir="/var/lib/clickhouse/shadow"
## Initiate Log file
echo "$(date +%F-%H:%M:%S) $JOB_ID SSH  Starting full backup process, job id $JOB_ID" >> "$LOG"

clickhouse-client --format=TSVRaw -q"ALTER TABLE $destdb.$tab_name freeze;"
myvariable=$(clickhouse-client --format=TSVRaw -q"SHOW CREATE TABLE $destdb.$tab_name;")
clickhouse-client --format=TSVRaw -q"drop table $destdb.$tab_name;"
clickhouse-client --format=TSVRaw -q"$myvariable;"

backup_num=$(cat $shadowdir/increment.txt)

    for stdir in $(find "$shadowdir" -mindepth 4 -maxdepth 4 -type d); do
      source="$stdir"
      echo "Директория $source" > "$LOG"
      cp -r $source/* $dest
      chown -R clickhouse $dest
    done;

clickhouse-client --format=TSVRaw -q"select 'ALTER TABLE ' || database || '.' || table || ' ATTACH PARTITION ID \'' || partition_id || '\';\n' from system.detached_parts group by database, table, partition_id order by database, table, partition_id;" | clickhouse-client -mn
```
