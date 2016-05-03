CREATE SCHEMA IF NOT EXISTS util;

-----------------
--- EXTENSION ---
-----------------

CREATE EXTENSION IF NOT EXISTS "pgcrypto" SCHEMA util;

-------------------------
--- TRIGGER FUNCTIONS ---
-------------------------

CREATE OR REPLACE FUNCTION util.set_created_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.created_at = now()::timestamp;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION util.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now()::timestamp;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION util.set_timestamps()
RETURNS TRIGGER AS $$
BEGIN
    NEW.created_at = now()::timestamp;
    NEW.updated_at = now()::timestamp;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION util.set_app_id()
RETURNS TRIGGER AS $$
DECLARE
  slug_id VARCHAR;
  found   VARCHAR;
BEGIN

  LOOP
  
    slug_id := encode(util.gen_random_bytes(6), 'base64');
    slug_id := replace(slug_id, '/', '_');
    slug_id := replace(slug_id, '+', '-');

    EXECUTE 'SELECT app_id FROM app WHERE app_id = ' || quote_literal(slug_id) INTO found;
    IF found IS NULL THEN EXIT; END IF;

  END LOOP;
  
  NEW.app_id = slug_id;
  RETURN NEW;
  
END;
$$ language 'plpgsql';

