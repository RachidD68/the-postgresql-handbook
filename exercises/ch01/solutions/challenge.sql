-- Solution to Exercise 1.3 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 1
-- (Docker-reader exercise; the shell commands run outside psql.)

-- 1. Stop the database out from under yourself:
--      docker compose stop
--    A query now fails at the client with:
--      connection to server at "localhost", port 5432 failed:
--      Connection refused
--    ("the database is down" is a CLIENT error - psql never reached a server.)

-- 2. Bring it back and confirm the world survived:
--      docker compose start
--      psql -h localhost -U postgres -d lumina
SELECT current_database();
--   \l still lists lumina: stop/start never touches the data volume.

-- 3. The full disaster drill:
--      docker compose down -v      (-v deletes the named data volume)
--      docker compose up -d
--      .\scripts\reset-to-chapter.ps1 -Chapter 1
--    Without -v, even `down` keeps the volume, and the data with it.
--    The -v flag is why backups exist (Chapter 18).
