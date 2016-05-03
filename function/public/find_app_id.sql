CREATE OR REPLACE FUNCTION find_app_id(
    slug SLUG
) RETURNS SLUGID AS $$

    SELECT app_id FROM app WHERE slug = find_app_id.slug;

$$ LANGUAGE sql;

COMMENT ON FUNCTION find_app_id(SLUG) IS 'Find app id by a given slug.';