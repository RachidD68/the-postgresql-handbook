-- Listing 23.4 — The PostgreSQL Handbook
-- Generated from Book/chapters/Ch23/render.js — DO NOT EDIT BY HAND
-- Requires: scripts/reset-to-chapter.ps1 -Chapter 23
SELECT '[0.25, -0.5, 0.25]'::vector AS three_dims,
       vector_dims('[0.25, -0.5, 0.25]'::vector) AS dims;
