CREATE OR REPLACE FUNCTION find_category_id(
    slug SLUG
) RETURNS INTEGER AS $$

    SELECT category_id FROM category WHERE slug = find_category_id.slug;

$$ LANGUAGE sql;

COMMENT ON FUNCTION find_category_id(SLUG) IS 'Find category id by a given slug.';