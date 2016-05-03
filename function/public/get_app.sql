CREATE OR REPLACE FUNCTION get_app(
    app_id SLUGID
) RETURNS json AS $$

    SELECT
        JSON_BUILD_OBJECT (
            'appId',             app.app_id,
            'createdAt',         app.created_at,
            'descriptionLong',   app.description_long,
            'descriptionShort',  app.description_short,
            'imageUrl',          app.image_url,
            'name',              name,
            'rankings',          (
                SELECT JSON_AGG(get_rank(rank.rank_id))
            ),
            'slug',              app.slug,
            'sourceRef',         app.source_ref,
            'updatedAt',         app.updated_at
        ) as app
    FROM
        app
    LEFT JOIN
        rank USING (app_id)
    WHERE
        app_id = get_app.app_id
    GROUP BY
        app.app_id;

$$ LANGUAGE sql;

COMMENT ON FUNCTION get_app(SLUGID) IS 'Get an app by a given app id.';