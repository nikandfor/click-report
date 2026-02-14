version=${1:-25.12.5-alpine} # 25.10.6-alpine words

echo using clickhouse version $version
echo

docker run --rm -v `pwd`:/data:ro --entrypoint bash clickhouse/clickhouse-server:$version /data/script.sh
