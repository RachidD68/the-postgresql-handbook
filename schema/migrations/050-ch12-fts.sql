-- 050-ch12-fts.sql — Chapter 12's work product, applied from Chapter 13 onward.
-- Mirrors listing 12-15 exactly (the book's listings ARE the source; this file
-- replays them so State(N >= 13) matches a reader who followed Ch12).

ALTER TABLE lumina.ticket
    ADD COLUMN search_tsv tsvector
        GENERATED ALWAYS AS (
            setweight(to_tsvector('english', subject), 'A') ||
            setweight(to_tsvector('english', body),    'B')
        ) STORED;

CREATE INDEX ticket_search_idx ON lumina.ticket USING gin (search_tsv);
