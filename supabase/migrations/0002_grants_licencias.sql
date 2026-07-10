-- =====================================================================
-- FASE 3 (fix) — Otorga privilegios de tabla a los roles estándar.
-- RLS (0001_licencias.sql) sigue limitando el acceso real de anon/authenticated;
-- este GRANT solo evita "permission denied for table" antes de evaluar RLS,
-- y es lo que necesita service_role (usado por la edge function `licencias`).
-- =====================================================================

grant usage on schema public to anon, authenticated, service_role;

grant all on all tables in schema public to anon, authenticated, service_role;
grant all on all sequences in schema public to anon, authenticated, service_role;

alter default privileges in schema public
  grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public
  grant all on sequences to anon, authenticated, service_role;
