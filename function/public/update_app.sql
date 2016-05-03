CREATE OR REPLACE FUNCTION update_app(
    app    JSON,
    app_id SLUGID DEFAULT NULL
) RETURNS json AS $$

    UPDATE
        app
    SET
        description_long  = update_app.app->>'descriptionLong',
        description_short = update_app.app->>'descriptionShort',
        name              = update_app.app->>'name',
        slug              = util.slugify(update_app.app->>'name'),
        source_ref        = update_app.app->>'sourceRef'
    WHERE
        CASE
            WHEN update_app.app_id IS NOT NULL
            THEN app_id = update_app.app_id
            ELSE app_id = (update_app.app->>'appId')::slugid
        END
    RETURNING
        get_app(app_id);

$$ LANGUAGE sql;

COMMENT ON FUNCTION update_app(JSON, SLUGID) IS 'Modify an app by a given json string.';
