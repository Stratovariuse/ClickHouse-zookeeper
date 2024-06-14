#!/bin/bash

# Create sql file with query CREATE TABLE
# FREEZE table parts

FILE="/var/lib/clickhouse/create.sql"
tab_name="test"
destdb="default"

clickhouse-client --format=TSVRaw -q"ALTER TABLE $destdb.$tab_name freeze;"
myvariable=$(clickhouse-client --format=TSVRaw -q"SHOW CREATE TABLE $destdb.$tab_name;")
echo $myvariable >> $FILE

if [ -f "$FILE" ]; then
                echo "Freeze succes and create.sql file created"
else
                echo "sql file don't created"
fi