user="user"
pass="password"
table="database.table"
hosts="host1 host2"

function rec_count() {
  clickhouse-client -h$1 --user $user --password $pass -q "select count(*) from $table"
}

function get_counts() {
table=$1
echo "$table:"
for host in ${hosts}; do
  echo "$host: "$(rec_count $host)
done
}
free -h
echo
df -h / /var /var/lib/clickhouse
echo
du -hd1 /var/lib/clickhouse/data/database/
echo
get_counts $table
get_counts "database.daily_resource_records"
get_counts "database.resource_records"