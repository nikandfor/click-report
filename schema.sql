CREATE TABLE q
(
    `ts` DateTime64(9, 'UTC'),
    `id` Tuple(
        UUID,
        Int32),
    `name` String,
    `value` Dynamic
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS index_granularity = 8192
;
