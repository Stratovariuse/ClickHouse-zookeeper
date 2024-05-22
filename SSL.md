# DOC

https://clickhouse.com/docs/en/guides/sre/configuring-ssl

## INSTALL OpenSSL/Settings

Генерация сертификата и ключа

```
openssl req -subj "/CN=localhost" -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout /etc/clickhouse-server/server.key -out /etc/clickhouse-server/server.crt
```

Главное задать common name равным адресу сервера, к которому мы будем подключаться. Мы указали CN=localhost при создании - то есть клиент будет проверять имя сервера к которому он подключился, сравнивая его с common name равное localhost.

Дополнительно мы будем использовать параметры Диффи-Хеллмана (dhParamsFile), которые генерируются следующей командой

```
openssl dhparam -out /etc/clickhouse-server/dhparam.pem 4096
```

Данная операция будет выполняться некоторое время, но запустить ее нужно только один раз.

## Config Clickhouse

```
<clickhouse>
    <https_port>8443</https_port>
    <tcp_port_secure>9440</tcp_port_secure>
    <!--
    <http_port>8123</http_port>
    <tcp_port>9000</tcp_port>
    -->
</clickhouse>
```

```
<clickhouse>
  <openSSL>
    <server>
      <certificateFile>/etc/clickhouse-server/server.crt</certificateFile
      <privateKeyFile>/etc/clickhouse-server/server.key</privateKeyFile>
      <dhParamsFile>/etc/clickhouse-server/dhparam.pem</dhParamsFile>
      <verificationMode>none</verificationMode>
      <loadDefaultCAFile>true</loadDefaultCAFile>
      <cacheSessions>true</cacheSessions> 
      <disableProtocols>sslv2,sslv3</disableProtocols> 
      <preferServerCiphers>true</preferServerCiphers>
    </server>
    <client>
      <loadDefaultCAFile>false</loadDefaultCAFile>
      <caConfig>/etc/clickhouse-server/certs/marsnet_ca.crt</caConfig>
      <cacheSessions>true</cacheSessions>
      <disableProtocols>sslv2,sslv3</disableProtocols>
      <preferServerCiphers>true</preferServerCiphers>
      <verificationMode>relaxed</verificationMode>
      <invalidCertificateHandler>
          <name>RejectCertificateHandler</name>
      </invalidCertificateHandler>
    </client>
</openSSL>
</clickhouse>
```

Также следует позаботиться, чтобы ClickHouse имел права на доступ ко всем 3-м файлам

privateKeyFile
Путь к файлу с приватным ключом сертификата. Файл может содержать и ключ, и сертификат одновременно.  

certificateFile
Путь к файлу с сертификатом Х509, может не указываться, если privateKeyFile уже содержит сертификат.  

dhParamsFile
Путь к файлу с параметрами Диффи-Хеллмана. Этот параметр не обязателен и может быть закомментирован, хотя делать этого настоятельно не рекомендуется.  

verificationMode
Параметр, который отвечает за способ проверки сертификата. Допустимые значения — none, relaxed, strict, once. Рассмотрим, чем они отличаются:  

none — не запрашивает сертификат для проверки;  
relaxed — запрашивает сертификат для проверки, если при процессе верификации произошла ошибка, то TLS/SSL соединение разрывается с сообщением об ошибке;  
strict — метод очень похож на relaxed, но если сертификат не возвращается, то соединение также разрывается и будет показано сообщение об ошибке;  
once — сертификат на проверку запрашивается и верифицируется один раз при подключении. При переподключении сертификат дополнительно не запрашивается.  
loadDefaultCAFile
Определяет, будут ли использоваться встроенные CA-сертификаты для OpenSSL. Допустимые значения — true, false.  

cacheSessions
Определяет, будет ли включено кеширование TLS сессии. Допустимые значения — true, false.  

disableProtocols
В этом параметре перечислены протоколы, которые не будут использоваться.  

preferServerCiphers
Предпочтение серверных шифров на клиенте. Допустимые значения — true, false.  

### Ошибка

Если при подключении clickhouse-client --secure
Code: 210. DB::NetException: SSL Exception: error:1000007d:SSL routines:OPENSSL_internal:CERTIFICATE_VERIFY_FAILED (localhost:9440)

Исправить это можно двумя путями - либо подложить клиенту в /etc/clickhouse-client/config.xml CA сертификат, который подписал сертификат сервера. Или же в том же файле можно отключить проверку сертификта на клиенте:

```
<verificationMode>none</verificationMode>
```
