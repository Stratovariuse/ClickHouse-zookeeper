
### DB::Exception: Too many parts (600). Merges are processing significantly slower than inserts

Означает что в клик идет много запросов INSERT, они должны идти один-два в секунду (потому что задумана вставка пачками а они большим кол-м OLTP запросов)

*[Ссылка](https://clickhouse.com/docs/ru/introduction/performance#:~:text=%D0%9F%D1%80%D0%BE%D0%BF%D1%83%D1%81%D0%BA%D0%BD%D0%B0%D1%8F%20%D1%81%D0%BF%D0%BE%D1%81%D0%BE%D0%B1%D0%BD%D0%BE%D1%81%D1%82%D1%8C%20%D0%BF%D1%80%D0%B8%20%D0%BE%D0%B1%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%BA%D0%B5%20%D0%BC%D0%BD%D0%BE%D0%B3%D0%BE%D1%87%D0%B8%D1%81%D0%BB%D0%B5%D0%BD%D0%BD%D1%8B%D1%85,%D0%B2%20%D1%81%D0%B5%D0%BA%D1%83%D0%BD%D0%B4%D1%83%20%D0%BD%D0%B0%20%D0%BE%D0%B4%D0%BD%D0%BE%D0%BC%20%D1%81%D0%B5%D1%80%D0%B2%D0%B5%D1%80%D0%B5.)

### Application: DB::Exception: Duplicate interserver IO endpoint: DataPartsExchange:/clickhouse
/tables/events/events2/replicas/ch_2

*[Ссылка](https://clickhouse.com/docs/en/engines/table-engines/mergetree-family/replication#recovery-after-failures)