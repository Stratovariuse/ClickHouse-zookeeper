Наглядный пример с фризом партиций
https://it-lux.ru/clickhouse-backup-and-recovery/

Нужен скрипт

Команда для attach all detach part

```
clickhouse-client --format=TSVRaw -q"select 'ALTER TABLE ' || database || '.' || table || ' ATTACH PARTITION ID \'' || partition_id || '\';\n' from system.detached_parts group by database, table, partition_id order by database, table, partition_id;" | clickhouse-client -mn
```

Ничего менять не нужно, возьмет все парты из системной таблицы (в которой уже есть инфа о названиях БД и таблиц и ID партов)

