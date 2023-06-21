

### Проверка текущего значения параметра

```s
SHOW SETTINGS ILIKE 'max_insert_block_size'
```

### Изминение значений в текущем сеансе

```s
SET max_insert_block_size = 1048440
SHOW CHANGED SETTINGS ILIKE 'max_insert_block_size' 
```

Если пусто то значит стоят знаения по умолчанию и не менялись

Для постоянных настроек нужны правки в конфиг config.xml

## Конфигурационные параметры сервера - это настройки в файле config.xml

https://clickhouse.com/docs/ru/operations/server-configuration-parameters/settings

Настройки:
https://clickhouse.com/docs/ru/operations/settings/settings