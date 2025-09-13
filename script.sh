
echo Running clickhouse

/entrypoint.sh >/dev/null 2>/dev/null &

until clickhouse client --query "SELECT 'loaded'"
do
	echo not yet started, waiting...
	sleep 1s
done

echo

cd /data

echo Loading schema
clickhouse client --queries-file schema.sql

echo Loading data
n=10
total=$(wc -l <data.tsv)

#while read -r row; do
for ((i=1; i<=$total; i+=$n)); do
	end_line=$((i + n - 1))
	echo "Processing rows $i to $end_line of $total"
	sed -n "${i},${end_line}p" data.tsv |
		clickhouse client --query 'INSERT INTO q FORMAT TabSeparated'
done
#done <data.tsv

echo Check data
clickhouse client --query "SELECT count() FROM q"

echo "Normal qeury, should work"
clickhouse client --queries-file query.sql \
	--external --file - --name _params --structure 'arg0 Tuple(id UUID, ver Int32), arg1 Tuple(id UUID, ver Int32)' <<<"('2e5d8c78-4e4e-488f-84c5-31222482eaa6',2)	('3c2b5a64-d7a9-42d4-9f1c-974d489559ae',1)"

echo "Query with different argument, expected to receive value: 0"
clickhouse client --queries-file query.sql \
	--external --file - --name _params --structure 'arg0 Tuple(id UUID, ver Int32), arg1 Tuple(id UUID, ver Int32)' <<<"('2e5d8c78-4e4e-488f-84c5-31222482e000',2)	('3c2b5a64-d7a9-42d4-9f1c-974d489559ae',1)"

echo "The same normal qeury again, doesn't work"
clickhouse client --queries-file query.sql \
	--external --file - --name _params --structure 'arg0 Tuple(id UUID, ver Int32), arg1 Tuple(id UUID, ver Int32)' <<<"('2e5d8c78-4e4e-488f-84c5-31222482eaa6',2)	('3c2b5a64-d7a9-42d4-9f1c-974d489559ae',1)"

echo "The same normal qeury again with condition cache disabled, works again"
clickhouse client --queries-file query.sql --use_query_condition_cache=0 \
	--external --file - --name _params --structure 'arg0 Tuple(id UUID, ver Int32), arg1 Tuple(id UUID, ver Int32)' <<<"('2e5d8c78-4e4e-488f-84c5-31222482eaa6',2)	('3c2b5a64-d7a9-42d4-9f1c-974d489559ae',1)"
