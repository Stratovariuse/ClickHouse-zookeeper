Вывод названий таблиц и их суммарное кол-во

```
#!/bin/bash
echo "Database"
read database
tb=$(clickhouse-client -n --format=TSVRaw -d ${database} -q "show tables")
for t in $tb; do
    echo $t
    clickhouse-client -d ${database} -nmq "SET check_query_single_value_result = 1;check table $t"
done
```
