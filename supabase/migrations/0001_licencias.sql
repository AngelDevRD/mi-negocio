-- =====================================================================
-- FASE 3 — Sistema de licencias (lado nube)
-- Aplicar con: supabase db push   (o pegar en el SQL Editor del dashboard)
--
-- Modelo de acceso:
--   * La app de negocio NUNCA toca estas tablas directamente: solo llama a
--     la edge function `licencias` (service role). RLS niega todo a anon.
--   * El propietario del sistema (panel F4) entra autenticado y debe existir
--     en `propietarios`.
-- =====================================================================

-- Negocios registrados (se crean al solicitar licencia)
create table if not exists negocios (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  telefono text,
  email_admin text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Propietarios del sistema (tu usuario del panel F4)
create table if not exists propietarios (
  user_id uuid primary key references auth.users (id) on delete cascade,
  nombre text,
  created_at timestamptz not null default now()
);

-- Licencias
create table if not exists licencias (
  id uuid primary key default gen_random_uuid(),
  clave text not null unique,
  tipo text not null check (tipo in ('demo', 'local', 'nube')),
  estado text not null default 'pendiente'
    check (estado in ('pendiente', 'activa', 'suspendida', 'vencida', 'transferida', 'rechazada')),
  negocio_id uuid not null references negocios (id),
  email_admin text not null,
  device_id_principal text,
  fecha_activacion timestamptz,
  fecha_vencimiento timestamptz,
  motivo_suspension text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_licencias_clave on licencias (clave);
create index if not exists idx_licencias_negocio on licencias (negocio_id);
create index if not exists idx_licencias_estado on licencias (estado);

-- Solicitudes (licencia nueva o transferencia de dispositivo)
create table if not exists solicitudes_licencia (
  id uuid primary key default gen_random_uuid(),
  tipo_solicitud text not null check (tipo_solicitud in ('nueva', 'transferencia', 'renovacion')),
  negocio_id uuid references negocios (id),
  licencia_id uuid references licencias (id),
  nombre_negocio text,
  telefono text,
  email_admin text,
  device_id text not null,
  tipo_licencia_deseada text check (tipo_licencia_deseada in ('local', 'nube')),
  estado text not null default 'pendiente'
    check (estado in ('pendiente', 'aprobada', 'rechazada')),
  nota text,
  created_at timestamptz not null default now(),
  resuelta_at timestamptz
);

create index if not exists idx_solicitudes_estado on solicitudes_licencia (estado);

-- Historial de cambios de licencia (auditoría del lado nube)
create table if not exists historial_licencias (
  id uuid primary key default gen_random_uuid(),
  licencia_id uuid not null references licencias (id),
  accion text not null, -- aprobada | activada | suspendida | reactivada | renovada | transferida | rechazada
  detalle jsonb,
  actor text not null default 'sistema', -- 'sistema' (edge function) o user_id del propietario
  created_at timestamptz not null default now()
);

-- Pagos de suscripción (los registra el propietario desde el panel — F4/F18)
create table if not exists pagos_licencia (
  id uuid primary key default gen_random_uuid(),
  licencia_id uuid not null references licencias (id),
  monto_centavos bigint not null,
  moneda text not null default 'DOP',
  metodo text, -- efectivo | transferencia | otro
  periodo_meses int not null default 1,
  nota text,
  registrado_por uuid references propietarios (user_id),
  created_at timestamptz not null default now()
);

-- =====================================================================
-- RLS: denegar todo por defecto; solo propietarios autenticados leen/escriben.
-- Las edge functions usan service role y no pasan por RLS.
-- =====================================================================

alter table negocios enable row level security;
alter table propietarios enable row level security;
alter table licencias enable row level security;
alter table solicitudes_licencia enable row level security;
alter table historial_licencias enable row level security;
alter table pagos_licencia enable row level security;

create or replace function es_propietario() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from propietarios where user_id = auth.uid());
$$;

-- Un propietario puede verse a sí mismo
create policy propietarios_self on propietarios
  for select using (user_id = auth.uid());

-- Propietarios: acceso total a la gestión
create policy owner_negocios on negocios
  for all using (es_propietario()) with check (es_propietario());
create policy owner_licencias on licencias
  for all using (es_propietario()) with check (es_propietario());
create policy owner_solicitudes on solicitudes_licencia
  for all using (es_propietario()) with check (es_propietario());
create policy owner_historial on historial_licencias
  for all using (es_propietario()) with check (es_propietario());
create policy owner_pagos on pagos_licencia
  for all using (es_propietario()) with check (es_propietario());

-- updated_at automático
create or replace function touch_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger trg_touch_negocios before update on negocios
  for each row execute function touch_updated_at();
create trigger trg_touch_licencias before update on licencias
  for each row execute function touch_updated_at();
