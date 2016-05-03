CREATE OR REPLACE FUNCTION insert_app(
    app JSON
) RETURNS JSON AS $$

    INSERT INTO app (
        app_id,
        description_long,
        description_short,
        image_url,
        name,
        slug,
        source_ref
    ) VALUES (
        insert_app.app->>'appId',
        insert_app.app->>'descriptionLong',
        insert_app.app->>'descriptionShort',
        insert_app.app->>'imageUrl',
        insert_app.app->>'name',
        util.slugify(insert_app.app->>'name'),
        insert_app.app->>'sourceRef'
    ) RETURNING get_app (app_id);

$$ LANGUAGE sql;

COMMENT ON FUNCTION insert_app(json) IS 'Insert an app item by a given json string.';
