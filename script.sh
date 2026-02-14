
echo Running clickhouse

/entrypoint.sh >/dev/null 2>/dev/null &

until clickhouse client --query "SELECT 'loaded'"
do
	echo not yet started, waiting...
	sleep 1s
done

echo
echo "Tuple element by index"
clickhouse client --query "SELECT x.1 FROM _data" \
	--external --file - --structure 'x Tuple(a UUID, b Int32)' <<<"('2e5d8c78-4e4e-488f-84c5-31222482eaa6',2)"

echo
echo "Tuple element by name"
clickhouse client --query "SELECT x.a FROM _data" \
	--external --file - --structure 'x Tuple(a UUID, b Int32)' <<<"('2e5d8c78-4e4e-488f-84c5-31222482eaa6',2)"
