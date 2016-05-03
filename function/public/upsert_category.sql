CREATE OR REPLACE FUNCTION upsert_category(
    category JSON
) RETURNS JSON AS $$

    DECLARE category    JSON;
    DECLARE category_id INTEGER;

    BEGIN
        category_id = find_category_id(
           upsert_category.category->>'slug'::slug
        );
        
        IF category_id IS NULL THEN
            category := insert_category(upsert_category.category);
        ELSE
            category := get_category(category_id);
        END IF;

        RETURN category;
    END;

$$ LANGUAGE 'plpgsql';

COMMENT ON FUNCTION upsert_category(json) IS 'Upsert a category by a given json string.';