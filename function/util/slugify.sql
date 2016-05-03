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