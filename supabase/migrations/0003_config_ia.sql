-- =====================================================================
-- FASE 20.0 — Configuración de IA (Gemini) para las edge functions de IA
-- (importación asistida y asistente de negocio).
--
-- Modelo de acceso:
--   * La edge function `ai` lee esta tabla con service role (bypassa RLS).
--   * Solo el propietario del sistema (panel admin_panel, ver 0001) puede
--     leer/editar la API key desde la app — los negocios cliente (app_gestion)
--     nunca acceden a esta tabla.
-- =====================================================================

create table if not exists configuracion_ia (
  id boolean primary key default true check (id),
  gemini_api_key text,
  modelo text not null default 'gemini-2.0-flash',
  updated_at timestamptz not null default now()
);

insert into configuracion_ia (id) values (true)
  on conflict (id) do nothing;

alter table configuracion_ia enable row level security;

create policy owner_config_ia on configuracion_ia
  for all using (es_propietario()) with check (es_propietario());

create trigger trg_touch_configuracion_ia before update on configuracion_ia
  for each row execute function touch_updated_at();
