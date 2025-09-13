
echo Running clickhouse

/entrypoint.sh >/dev/null 2>/dev/null &

until clickhouse client --query "SELECT 'loaded'"
do
	echo not yet started, waiting...
	sleep 1s
done

cd /data

echo
echo Loading schema
clickhouse client --queries-file schema3.sql

echo
echo Loading data
clickhouse client --queries-file data3.sql

echo
echo Check data
clickhouse client --query "SELECT count() FROM q"

echo
echo "Normal qeury, should work"
clickhouse client --queries-file query.sql \
	--external --file - --name _params --structure 'arg0 Tuple(UUID, Int32)' <<<"('2e5d8c78-4e4e-488f-84c5-31222482eaa6',2)"

echo
echo "Query with different argument, expected to receive value: 0"
clickhouse client --queries-file query.sql \
	--external --file - --name _params --structure 'arg0 Tuple(UUID, Int32)' <<<"('00000000-0000-0000-0000-000000000000',2)"

echo
echo "The same normal qeury again, doesn't work"
clickhouse client --queries-file query.sql \
	--external --file - --name _params --structure 'arg0 Tuple(UUID, Int32)' <<<"('2e5d8c78-4e4e-488f-84c5-31222482eaa6',2)"

echo
echo "The same normal qeury again with condition cache disabled, works again"
clickhouse client --queries-file query.sql --use_query_condition_cache=0 \
	--external --file - --name _params --structure 'arg0 Tuple(UUID, Int32)' <<<"('2e5d8c78-4e4e-488f-84c5-31222482eaa6',2)"
