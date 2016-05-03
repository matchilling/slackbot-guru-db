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