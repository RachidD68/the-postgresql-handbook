-- Solution to Exercise 8.1 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 8

SELECT channel,
       count(*) AS tickets,
       count(satisfaction) AS scored,
       round(avg(satisfaction), 2) AS avg_satisfaction
FROM ticket
GROUP BY channel
ORDER BY tickets DESC;

--  channel | tickets | scored | avg_satisfaction
--  email   |      19 |     10 |             4.40
--  web     |      13 |      5 |             4.00
--  chat    |       6 |      4 |             4.50
--  phone   |       2 |      2 |             1.50
--
-- Least trustworthy: phone. Its alarming 1.50 rests on exactly two scored
-- tickets — the gap between count(*) and count(satisfaction) is the
-- section-one lesson that an average without its denominator is a rumor.
