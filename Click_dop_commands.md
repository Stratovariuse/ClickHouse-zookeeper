# Команды не для администрирования

## Users

```s
CREATE USER test IDENTIFIED WITH plaintext_password by 'qwerty'
CREATE USER test IDENTIFIED BY 'password'  (сразу шифрует пароль в scram-sha, аналог IDENTIFIED WITH sha256_password BY 'qwerty')
```

Посмотреть привилегии для пользователя

```s
SHOW GRANTS FOR test
```

### ON CLUSTER

```s
CREATE USER test_cl ON CLUSTER test IDENTIFIED BY 'password'
GRANT ON CLUSTER test SELECT on default.test TO test_cl
```

### GRANT

```s
GRANT ON CLUSTER test SELECT ON events.* TO test_cl (дать права на селект для всех таблиц БД events)
GRANT ON CLUSTER test ALL ON events.* TO test_cl (дать все права на базу)
GRANT ON CLUSTER test ALL ON *.* TO test_cl (дать все права на всё)
CREATE ROLE role2 ON CLUSTER test (создать группу ролей на кластер)
GRANT ON CLUSTER test role2 TO test_cl (включить пользователя test_cl в роль role2)
```

Рабочий пример

```a
GRANT ON CLUSTER test SELECT, INSERT, UPDATE, CREATE, ALTER ON events.* TO test_cl
```

## INSERT

```s
INSERT INTO events.test VALUES('1', '2', '3', '4') (вносится автоматом не реплику, если таблица была создана с replicatedMergeTree)
```

### ALTER

Пример создания индекса на существующую таблицу

```s
ALTER TABLE events.test ON CLUSTER test ADD INDEX PhoneNumberIdx PhoneNumber TYPE set(100) GRANULARITY 2;
```