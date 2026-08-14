-- 110-ch23-vector.sql — Chapter 23's work product.
--
-- Unlike every other migration, this one is PRE-APPLIED at State(23) rather than
-- applied "one chapter early": its companion seed (seed-kb.sql) embeds 200
-- precomputed vectors that cannot be a printed listing, so the chapter's DDL
-- listings use IF NOT EXISTS and the prose explains why (see Ch23 §2).
--
-- Verified ONLY against the pgvector/pgvector:pg18 container — the native install
-- on the authoring machine has no pgvector. CLAUDE.md documents the container gate.

CREATE EXTENSION IF NOT EXISTS vector;

-- The knowledge base: resolved-ticket wisdom, searchable two ways.
--   embedding        — the semantic fingerprint (Ch23 §2). 768 dims: a common
--                      sentence-embedding width; the number is the model's, not
--                      PostgreSQL's, and vector(n) simply pins it.
--   embedding_model  — store the model's identity NEXT TO the vector (§4 proTip).
--                      Re-embedding under a new model means rewriting this column
--                      and the vectors together; without it you cannot tell which
--                      rows are stale. The book's fixtures are model-free and
--                      deterministic, labelled 'book-fixture-det-v1' honestly.
--   search_tsv       — the Chapter 12 lexical index, so one table answers both
--                      "these exact words" (FTS) and "this meaning" (vectors),
--                      which §7 fuses.
CREATE TABLE IF NOT EXISTS lumina.kb_article (
    id               bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_id        bigint,
    title            text NOT NULL,
    body             text NOT NULL,
    embedding        vector(768) NOT NULL,
    embedding_model  text NOT NULL,
    -- Chapter 11's jsonb, sitting beside Chapter 23's vector in ONE row: the
    -- article is relational (ticket_id), documentary (metadata), lexical
    -- (search_tsv) and semantic (embedding) at the same time. This is the
    -- column Ch11's crossRef promised, and §5's filtered-ANN query needs it.
    metadata         jsonb NOT NULL DEFAULT '{}',
    search_tsv       tsvector
        GENERATED ALWAYS AS (
            setweight(to_tsvector('english', title), 'A') ||
            setweight(to_tsvector('english', body),  'B')
        ) STORED,
    created_at       timestamptz NOT NULL
);

-- HNSW for approximate nearest-neighbor by cosine distance (Ch23 §4). The
-- operator class must match the distance operator the queries use: cosine here,
-- so vector_cosine_ops and <=>. m / ef_construction are left at pgvector's
-- defaults (16 / 64); the chapter tunes ef_search at query time instead.
CREATE INDEX IF NOT EXISTS kb_article_embedding_hnsw
    ON lumina.kb_article USING hnsw (embedding vector_cosine_ops);

-- The lexical half of hybrid search (Ch12's GIN, on the generated column).
CREATE INDEX IF NOT EXISTS kb_article_search_idx
    ON lumina.kb_article USING gin (search_tsv);

-- Chapter 11's containment operator stays indexable here too, so a metadata
-- filter composes with an ANN order-by without turning into a full scan.
CREATE INDEX IF NOT EXISTS kb_article_metadata_gin
    ON lumina.kb_article USING gin (metadata);
