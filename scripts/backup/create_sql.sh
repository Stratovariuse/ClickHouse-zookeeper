#!/bin/bash
# RUN sql command for CREATE TABLE 

database="default"
FILE="/var/lib/clickhouse/create.sql"

clickhouse-client --database $database --queries-file $FILE
