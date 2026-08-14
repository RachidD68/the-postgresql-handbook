-- Listing 23.8 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch23/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 23
-- The model's response arrives as 768 floats; borrow a stored fixture
-- vector so this runs without an API key:
SELECT embedding AS qv
FROM kb_article
WHERE title LIKE 'Document feeder%'
ORDER BY id LIMIT 1 \gset

INSERT INTO kb_article (ticket_id, title, body, embedding, embedding_model, created_at)
VALUES (42, 'Scanner grabs two pages at a time',
        'Clean the separation pad and fan the stack before loading.',
        :'qv'::vector, 'book-fixture-det-v1', '2026-01-15 09:00:00+00')
RETURNING id, title, vector_dims(embedding) AS dims;
