CREATE TABLE q
(
    `id` Tuple(
        UUID,
        Int32),
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS index_granularity = 8192
;

