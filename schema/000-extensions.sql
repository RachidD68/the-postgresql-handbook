-- The PostgreSQL Handbook — extensions
--
-- Everything here ships with a stock PostgreSQL 18 install; no compilation needed.
-- The pgvector extension is NOT created here — it arrives with Chapter 23's
-- migration (110-ch23-vector.sql), because it is the one extension that requires
-- the pgvector/pgvector:pg18 image (or a separately installed extension) and the
-- first 22 chapters must run clean on any PostgreSQL 18.

CREATE EXTENSION IF NOT EXISTS citext;      -- case-insensitive text (emails, Ch5)
CREATE EXTENSION IF NOT EXISTS pg_trgm;     -- trigram similarity (typo-tolerant search, Ch12)
CREATE EXTENSION IF NOT EXISTS btree_gin;   -- composite GIN indexes (Ch15)
