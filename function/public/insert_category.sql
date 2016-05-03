CREATE OR REPLACE FUNCTION insert_category(
    category JSON
) RETURNS JSON AS $$

    INSERT INTO category (
        name,
        slug,
        source_ref
    ) VALUES (
        insert_category.category->>'name',
        insert_category.category->>'slug',
        insert_category.category->>'sourceRef'
    ) RETURNING get_category (category_id);

$$ LANGUAGE sql;

COMMENT ON FUNCTION insert_app(json) IS 'Insert a category by a given json string.';
