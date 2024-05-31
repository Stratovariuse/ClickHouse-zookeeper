# Конфигурация ClickHouse кластера

```
<remote_servers incl="clickhouse_remote_servers">
<include_from>/etc/clickhouse-server/cluster.xml</include_from>
```
remote_servers - — основное место, где описывается структура кластера.  
include_from - — путь к конфигурационному файлу с подстановками.  

## Полная конфигурация cluster.xml выглядит следующим образом

```
<?xml version="1.0"?>
<clickhouse>
    <clickhouse_remote_servers>
        <mycluster> // Название кластера
            
            <shard>
                <replica>
                    <host>167.99.142.32</host> // первая нода в нашем кластере
                    
                    <port>9000</port>
                </replica>
            </shard>
            <shard>
                <replica>
                    <host>159.65.123.161</host> // вторая нода в нашем кластере
                    
                    <port>9000</port>
                </replica>
            </shard>
        </mycluster>
    </clickhouse_remote_servers>
</clickhouse>
```
### Тестирование кластера ClickHouse
Перезапустим сервис для применения конфига и посмотрим логи, нас интересует строка Including configuration file '/etc/clickhouse-server/cluster.xml'.. Если в логах есть это сообщение, а в логах ошибок ClickHouse нет замечаний — идем дальше

### Создание таблиц в кластере

Они должны находиться на всех нодах и называться одинаково

```
CREATE TABLE ch_local
(
 id Int64,
 title String,
 description String,
 content String,
 date Date
 )
ENGINE = MergeTree()
PARTITION BY date
ORDER BY id;
```

### Создание Distributed таблиц

Distributed (распределенная) таблица не хранит никаких данных и по сути является виртуальной, как мы выяснили выше. Её основная задача — распределение запросов на все локальные таблицы в узлах кластера.

```
CREATE TABLE ch_distributed
(
 id Int64,
 title String,
 description String,
 content String,
 date Date
 )
 ENGINE = Distributed('local', 'default', 'ch_local', rand());
```

В параметрах движка таблицы мы указываем:

* имя кластера,
* база данных с таблицей,
* имя таблицы,
* ключ шардирования.

### Способы вставки данных в кластер

Мы можем вставлять данные либо в конкретный шард, либо используя distributed таблицу

В дистр
```
 INSERT INTO ch_distributed (*) values
 (1,'yy','2222','str','2019-01-01'),
 (1,'yy','2222','str','2019-01-01'),
 (1,'yy','2222','str','2019-01-01'),
 (1,'yy','2222','str','2019-01-01'),
 (1,'yy','2222','str','2019-01-01'),
 (1,'yy','2222','str','2019-01-01'),
 (1,'yy','2222','str','2019-01-01'),
 (1,'yy','2222','str','2019-01-01'),
 (1,'yy','2222','str','2019-01-01'),
 (1,'yy','2222','str','2019-01-01');
```

```
SELECT *
FROM ch_distributed

Query id: 946e602f-886a-4676-9b12-217452a60486

   ┌─id─┬─title─┬─description─┬─content─┬───────date─┐
1. │  1 │ yy    │ 2222        │ str     │ 2019-01-01 │
2. │  1 │ yy    │ 2222        │ str     │ 2019-01-01 │
3. │  1 │ yy    │ 2222        │ str     │ 2019-01-01 │
4. │  1 │ yy    │ 2222        │ str     │ 2019-01-01 │
5. │  1 │ yy    │ 2222        │ str     │ 2019-01-01 │
6. │  1 │ yy    │ 2222        │ str     │ 2019-01-01 │
   └────┴───────┴─────────────┴─────────┴────────────┘
    ┌─id─┬─title─┬─description─┬─content─┬───────date─┐
 7. │  1 │ yy    │ 2222        │ str     │ 2019-01-01 │
 8. │  1 │ yy    │ 2222        │ str     │ 2019-01-01 │
 9. │  1 │ yy    │ 2222        │ str     │ 2019-01-01 │
10. │  1 │ yy    │ 2222        │ str     │ 2019-01-01 │
    └────┴───────┴─────────────┴─────────┴────────────┘

10 rows in set. Elapsed: 0.012 sec.
```
 В обычную

 ```
clickhouse-client --query "INSERT INTO ch_local FORMAT CSV" < ch_local.csv
```

Если мы обратимся к локальной таблице на одном сервере а потом на втором, на втором не окажется данных, т.к. они записаны локально
Но если обратимся с запросом в дистр таблицу - там будут все данные.
