CREATE OR REPLACE FUNCTION find_rankings(
    app_id      SLUGID,
    category_id INTEGER,
    start_date  DATE,
    end_date    DATE
) RETURNS JSON AS $$

    WITH
        rankings AS (
            SELECT * FROM rank WHERE find_rankings.app_id = app_id AND find_rankings.category_id = category_id
        ),
        interval AS (
            SELECT generate_series(find_rankings.start_date, find_rankings.end_date, '24 hours')::date AS date
        )
    SELECT
        JSON_AGG(
            NULLIF(r.position, null)
        )
    FROM
        interval AS i
    LEFT JOIN
        rankings AS r ON r.created_at::date = i.date;

$$ LANGUAGE sql;