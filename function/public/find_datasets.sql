CREATE OR REPLACE FUNCTION find_datasets(
    category_id INTEGER,
    start_date  DATE,
    end_date    DATE
) RETURNS JSON AS $$

    WITH
        rankings AS (
            SELECT DISTINCT app_id, name FROM rank JOIN app USING(app_id) WHERE category_id = find_datasets.category_id
        )
    SELECT
        JSON_AGG(
            JSON_BUILD_OBJECT(
                'label' , r.name,
                'data'  ,  find_rankings(
                    r.app_id,
                    find_datasets.category_id,
                    find_datasets.start_date,
                    find_datasets.end_date
                )
            )
        )
    FROM
        rankings AS r;

$$ LANGUAGE sql;