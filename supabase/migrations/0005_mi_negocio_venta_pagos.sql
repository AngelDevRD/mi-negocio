-- =====================================================================
-- 0005 — Método de pago de las ventas (tabla mi_negocio_venta_pagos).
--
-- NO se aplica automáticamente: la ejecuta el propietario del proyecto de
-- Supabase cuando decida (por ejemplo desde el SQL Editor). Hasta entonces,
-- las filas de `venta_pagos` esperan en la `sync_queue` de cada dispositivo y
-- se reintentan sin afectar a la sincronización de las demás tablas (el
-- motor aísla los fallos por fila).
--
-- Es una tabla NUEVA: no modifica `mi_negocio_ventas` ni ninguna otra. Es
-- idempotente (se puede ejecutar más de una vez).
-- =====================================================================

create table if not exists public.mi_negocio_venta_pagos (
  id text primary key,
  user_id uuid not null default auth.uid(),
  venta_id text not null,
  metodo text not null,
  monto bigint not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz null
);

alter table public.mi_negocio_venta_pagos enable row level security;

drop policy if exists venta_pagos_select_own on public.mi_negocio_venta_pagos;
create policy venta_pagos_select_own on public.mi_negocio_venta_pagos
  for select to authenticated
  using (user_id = auth.uid());

drop policy if exists venta_pagos_insert_own on public.mi_negocio_venta_pagos;
create policy venta_pagos_insert_own on public.mi_negocio_venta_pagos
  for insert to authenticated
  with check (user_id = auth.uid());

drop policy if exists venta_pagos_update_own on public.mi_negocio_venta_pagos;
create policy venta_pagos_update_own on public.mi_negocio_venta_pagos
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

drop policy if exists venta_pagos_delete_own on public.mi_negocio_venta_pagos;
create policy venta_pagos_delete_own on public.mi_negocio_venta_pagos
  for delete to authenticated
  using (user_id = auth.uid());

grant select, insert, update, delete
  on public.mi_negocio_venta_pagos to authenticated;
