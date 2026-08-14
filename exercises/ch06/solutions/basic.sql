-- Solution to Exercise 6.1 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 6

-- Named, so violations report something greppable:
ALTER TABLE attachment
    ADD CONSTRAINT attachment_byte_size_check CHECK (byte_size > 0);
-- Succeeds instantly — adding a plain CHECK validates existing rows, and
-- all six seed attachments pass.

-- The violation attempt:
INSERT INTO attachment (ticket_id, filename, content_kind, byte_size, uploaded_at)
VALUES (1, 'empty.log', 'text/plain', 0, '2026-01-15 09:00:00+00');
-- ERROR:  new row for relation "attachment" violates check constraint
--         "attachment_byte_size_check"        (SQLSTATE 23514)
-- The error carries OUR name — the reason the Pro Tip says name every
-- constraint you add.
