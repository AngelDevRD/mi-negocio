-- =====================================================================
-- FASE 20.0 (fix) — Múltiples API keys de IA con rotación y soporte para
-- varios proveedores (Gemini, OpenAI, Anthropic).
--
-- Sustituye a `configuracion_ia` (fila única, solo Gemini): la edge function
-- `ai` ahora prueba las keys activas en orden hasta obtener una respuesta
-- válida, lo que evita quedar bloqueada por un 429 de cuota agotada.
-- =====================================================================

create table if not exists ia_api_keys (
  id uuid primary key default gen_random_uuid(),
  proveedor text not null check (proveedor in ('gemini', 'openai', 'anthropic')),
  etiqueta text not null default '',
  api_key text not null,
  modelo text not null,
  activo boolean not null default true,
  orden integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

insert into ia_api_keys (proveedor, etiqueta, api_key, modelo, activo, orden)
select 'gemini', 'Gemini (migrado)', gemini_api_key, modelo, true, 0
from configuracion_ia
where gemini_api_key is not null and gemini_api_key <> '';

drop table configuracion_ia;

alter table ia_api_keys enable row level security;

create policy owner_ia_api_keys on ia_api_keys
  for all using (es_propietario()) with check (es_propietario());

create trigger trg_touch_ia_api_keys before update on ia_api_keys
  for each row execute function touch_updated_at();
