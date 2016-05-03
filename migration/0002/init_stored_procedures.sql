START TRANSACTION;

    CREATE OR REPLACE FUNCTION util.slugify(
        string TEXT
    ) RETURNS SLUG AS $$
        BEGIN
             -- Remove punctuation EXCEPT hyphens and ampersands
             slugify.string = regexp_replace(slugify.string , '[^a-zA-Z0-9\-\&]', '', 'g');

             -- Replace multiple whitepaces by one hyphen
             slugify.string = regexp_replace(slugify.string, '\s+', '-');

             -- Replace multiple adjacent ampersand symbols with a dash
             slugify.string = regexp_replace(slugify.string, '\&+', '-');

             -- Replace multiple adjacent hyphens with only one hyphen
             slugify.string = regexp_replace(slugify.string, '\-+', '-');

             -- Remove all remaining illegal characters
             slugify.string = regexp_replace(slugify.string, '[^\w-]', '');

             RETURN substr(slugify.string, 0, 255);
        END;

    $$ LANGUAGE 'plpgsql';
    COMMENT ON FUNCTION util.slugify(TEXT) IS 'Convert a given string into a slug.';

    CREATE OR REPLACE FUNCTION find_app_id(
    slug SLUG
    ) RETURNS SLUGID AS $$

        SELECT app_id FROM app WHERE slug = find_app_id.slug;

    $$ LANGUAGE sql;
    COMMENT ON FUNCTION find_app_id(SLUG) IS 'Find app id by a given slug.';

    CREATE OR REPLACE FUNCTION find_category_id(
    slug SLUG
    ) RETURNS INTEGER AS $$

        SELECT category_id FROM category WHERE slug = find_category_id.slug;

    $$ LANGUAGE sql;

    COMMENT ON FUNCTION find_category_id(SLUG) IS 'Find category id by a given slug.';

    CREATE OR REPLACE FUNCTION get_rank(
    rank_id INTEGER
    ) RETURNS json AS $$

        SELECT
            JSON_BUILD_OBJECT (
                'appId',      app_id,
                'categoryId', category_id,
                'createdAt',  created_at,
                'position',   position,
                'rankId',     rank_id
            ) as rank
        FROM
            rank
        WHERE
            rank_id = get_rank.rank_id

    $$ LANGUAGE sql;

    COMMENT ON FUNCTION get_rank(INTEGER) IS 'Get a rank by a given rank id.';

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

    CREATE OR REPLACE FUNCTION upsert_app(
        app JSON
    ) RETURNS JSON AS $$

        DECLARE app_id      SLUGID;
                category    JSON;
                category_id INTEGER;
                ranking     JSON;

        BEGIN
            app_id = find_app_id(
               util.slugify(upsert_app.app->>'name')
            );

            IF app_id IS NULL THEN
                app_id = CAST(
                    (insert_app(upsert_app.app))->>'appId' AS SLUGID
                );
            ELSE
                PERFORM update_app(upsert_app.app, app_id);
            END IF;

            FOR ranking IN SELECT json_array_elements( CAST(upsert_app.app->>'rankings' AS json))
            LOOP
                category_id = find_category_id(
                    CAST (ranking->'category'->>'slug' AS slug)
                );

                IF category_id IS NULL THEN
                    category_id = CAST (
                        (insert_category((ranking->>'category')::json))->>'categoryId' AS INTEGER
                    );
                END IF;

                INSERT INTO rank(app_id, category_id, position) VALUES (app_id, category_id, CAST(ranking->>'popularity' AS INTEGER));
            END LOOP;

            RETURN get_app(app_id);
        END;

    $$ LANGUAGE plpgsql;

    COMMENT ON FUNCTION upsert_app(JSON) IS 'Upsert an application by a given json string.';
    
    CREATE OR REPLACE FUNCTION bulk_insert_apps(
        apps JSON
    ) RETURNS INTEGER AS $$

        DECLARE app   JSON;
                count INTEGER DEFAULT 0;

        BEGIN
            FOR app IN SELECT json_array_elements(bulk_insert_apps.apps)
            LOOP
                count := count + 1;
                PERFORM upsert_app(CAST(app AS json));
            END LOOP;

            RETURN count;
        END;

    $$ LANGUAGE plpgsql;

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

COMMIT TRANSACTION;