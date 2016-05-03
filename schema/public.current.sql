CREATE SCHEMA IF NOT EXISTS public;

-------------
--- TYPES ---
-------------

CREATE DOMAIN slug   AS VARCHAR CHECK (VALUE ~ '^[a-zA-Z0-9-]{1,255}$');
CREATE DOMAIN slugid AS VARCHAR CHECK (VALUE ~ '^[a-zA-Z0-9_-]{8}$');

--------------------
--- TABLES - APP ---
--------------------

CREATE TABLE IF NOT EXISTS app (
    app_id            SLUGID PRIMARY KEY,
    created_at        TIMESTAMP WITH TIME ZONE,
    description_long  TEXT,
    description_short VARCHAR,
    image_url         VARCHAR(2000),
    name              VARCHAR UNIQUE,
    slug              SLUG UNIQUE,
    source_ref        VARCHAR,
    updated_at        TIMESTAMP WITH TIME ZONE
);

CREATE TRIGGER trig_app_insert_set_created BEFORE INSERT ON app FOR EACH ROW EXECUTE PROCEDURE util.set_created_at();
CREATE TRIGGER trig_app_insert_set_id      BEFORE INSERT ON app FOR EACH ROW EXECUTE PROCEDURE util.set_app_id();
CREATE TRIGGER trig_app_update BEFORE      UPDATE ON app FOR EACH ROW EXECUTE PROCEDURE util.set_updated_at();

COMMENT ON COLUMN app.app_id            IS 'URL-safe Base64-encoded UUID for an app.';
COMMENT ON COLUMN app.created_at        IS 'Timestamp when the app was inserted.';
COMMENT ON COLUMN app.description_long  IS 'A long description of the app.';
COMMENT ON COLUMN app.description_short IS 'A short plain text description of the app.';
COMMENT ON COLUMN app.image_url         IS 'A url to the app image.';
COMMENT ON COLUMN app.name              IS 'The name of the application.';
COMMENT ON COLUMN app.slug              IS 'Unique SEO-friendly string representation of the apps name for use in URLs.';
COMMENT ON COLUMN app.source_ref        IS 'Unique identifier of the application on slack.';
COMMENT ON COLUMN app.updated_at        IS 'Timestamp when the app was updated.';

-------------------------
--- TABLES - CATEGORY ---
-------------------------

CREATE TABLE IF NOT EXISTS category (
    category_id SERIAL   PRIMARY KEY,
    name        VARCHAR,
    slug        SLUG,
    source_ref  VARCHAR
);

COMMENT ON COLUMN category.name       IS 'The name of the category.';
COMMENT ON COLUMN category.slug       IS 'Unique SEO-friendly string representation of the category for use in URLs.';
COMMENT ON COLUMN category.source_ref IS 'Unique identifier of the category on slack.';

---------------------
--- TABLES - RANK ---
---------------------

CREATE TABLE IF NOT EXISTS rank (
    app_id      SLUGID  REFERENCES app ON DELETE CASCADE,
    category_id INTEGER REFERENCES category ON DELETE CASCADE,
    created_at  TIMESTAMP WITH TIME ZONE,
    position    INTEGER NOT NULL,
    rank_id     SERIAL PRIMARY KEY
);

CREATE TRIGGER trig_rank_insert BEFORE INSERT ON rank FOR EACH ROW EXECUTE PROCEDURE util.set_created_at();