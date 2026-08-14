-- Listing 2.1 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch02/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 2
-- Lumina's spreadsheet, faithfully reproduced as one wide table.
-- (Even the INSERT is sloppy — no column list. It fits the exhibit.)
CREATE TABLE helpdesk_sheet (
    ticket_ref     text,
    subject        text,
    customer_name  text,
    customer_email text,
    agent_name     text,
    agent_team     text
);

INSERT INTO helpdesk_sheet VALUES
    ('LUM-1003', 'Invoice shows wrong VAT number',
     'Fiona O''Brien', 'fiona@harboranalytics.example', 'Sofia Ramos', 'Billing'),
    ('LUM-1015', 'Updating card details fails with 402',
     'Fiona O''Brien', 'fiona@harboranalytics.example', 'Sofia Ramos', 'Billing'),
    ('LUM-1027', 'Printer-friendly view cuts off table',
     'Fiona O''Brien', 'fiona@harboranalytics.example', 'Marcus Webb', 'Technical Support');
