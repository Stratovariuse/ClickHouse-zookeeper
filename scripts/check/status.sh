#!/bin/bash

clickhouse-client -f PrettyCompact -q "select cluster,shard_num as Num,shard_weight as weight, replica_num as rep_num,host_name,is_local as local, errors_count as errors from system.clusters;"

clickhouse-client -f PrettyCompact -q "SELECT * FROM system.mutations WHERE is_done = 0"