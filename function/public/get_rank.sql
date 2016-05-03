CREATE OR REPLACE FUNCTION get_rank(
    rank_id INTEGER
) RETURNS json AS $$

    SELECT
        JSON_BUILD_OBJECT (
            'appId',      app_id,
            'categoryId', category_id,
            'createdAt',  created_at,
            'position',   position,
            'rankId',     rank_id
        ) as rank
    FROM
        rank
    WHERE
        rank_id = get_rank.rank_id

$$ LANGUAGE sql;

COMMENT ON FUNCTION get_rank(INTEGER) IS 'Get a rank by a given rank id.';