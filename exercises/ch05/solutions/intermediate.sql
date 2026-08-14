-- Solution to Exercise 5.2 — The PostgreSQL Handbook, Appendix D.
-- Run against: scripts/reset-to-chapter.ps1 -Chapter 5

CREATE TABLE payment (
    id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id    bigint NOT NULL,           -- FK-to-be; Chapter 6's job
    amount         numeric(12,2) NOT NULL,    -- exact arithmetic, never float
    currency       text NOT NULL,             -- amount + currency: two columns
    captured_at    timestamptz,               -- NULL while pending
    processor_ref  text NOT NULL UNIQUE,      -- external ids are text
    state          text NOT NULL
        CHECK (state IN ('pending', 'captured', 'refunded'))
);

-- Type defenses, one sentence each:
--   amount numeric(12,2): money is exact decimal arithmetic; float drifts
--     and the money type is a trap (locale-bound formatting, one currency).
--   currency text: the money trap's second lesson — currency is data, not
--     formatting, and it rides in its own column.
--   captured_at timestamptz: an instant, so timestamptz; nullable because
--     a pending payment has not happened yet.
--   processor_ref text: external references are opaque strings — never
--     integers you do arithmetic on.
--   state guarded by CHECK, not enum: the refund flow ('disputed'?
--     'partially_refunded'?) says this set is not settled, and a CHECK is
--     one ALTER to widen while an enum value is forever.

DROP TABLE payment;
