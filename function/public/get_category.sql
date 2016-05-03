CREATE OR REPLACE FUNCTION get_category(
    category_id INTEGER
) RETURNS json AS $$

    SELECT
        JSON_BUILD_OBJECT (
            'categoryId', category_id,
            'name',       name,
            'slug',       slug,
            'sourceRef',  source_ref
        ) as category
    FROM
        category
    WHERE
        category_id = get_category.category_id;

$$ LANGUAGE sql;

COMMENT ON FUNCTION get_category(INTEGER) IS 'Get a category a given catgeory id.';