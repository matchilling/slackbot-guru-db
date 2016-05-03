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