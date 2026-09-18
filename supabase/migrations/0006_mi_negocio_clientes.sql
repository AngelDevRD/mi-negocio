-- =====================================================================
-- 0006 — Fiado: clientes y libro de cuenta del cliente
--        (mi_negocio_clientes y mi_negocio_movimientos_cliente).
--
-- NO se aplica automáticamente: la ejecuta el propietario del proyecto de
-- Supabase cuando decida (por ejemplo desde el SQL Editor). Hasta entonces,
-- las filas de `clientes` y `movimientos_cliente` esperan en la `sync_queue`
-- de cada dispositivo (con espera creciente entre reintentos) sin afectar a
-- la sincronización de las demás tablas: el motor aísla los fallos por fila.
--
-- Son tablas NUEVAS: no modifican ninguna tabla existente. Es idempotente
-- (se puede ejecutar más de una vez). El saldo del cliente NO se guarda: se
-- calcula sumando `monto` de sus movimientos.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Clientes
-- ---------------------------------------------------------------------
create table if not exists public.mi_negocio_clientes (
  id text primary key,
  user_id uuid not null default auth.uid(),
  nombre text not null,
  telefono text null,
  nota text null,
  limite_credito bigint null,
  activo boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz null
);

alter table public.mi_negocio_clientes enable row level security;

drop policy if exists clientes_select_own on public.mi_negocio_clientes;
create policy clientes_select_own on public.mi_negocio_clientes
  for select to authenticated
  using (user_id = auth.uid());

drop policy if exists clientes_insert_own on public.mi_negocio_clientes;
create policy clientes_insert_own on public.mi_negocio_clientes
  for insert to authenticated
  with check (user_id = auth.uid());

drop policy if exists clientes_update_own on public.mi_negocio_clientes;
create policy clientes_update_own on public.mi_negocio_clientes
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

drop policy if exists clientes_delete_own on public.mi_negocio_clientes;
create policy clientes_delete_own on public.mi_negocio_clientes
  for delete to authenticated
  using (user_id = auth.uid());

grant select, insert, update, delete
  on public.mi_negocio_clientes to authenticated;

-- ---------------------------------------------------------------------
-- Movimientos del cliente (libro mayor: cargo +, abono/anulación -)
-- ---------------------------------------------------------------------
create table if not exists public.mi_negocio_movimientos_cliente (
  id text primary key,
  user_id uuid not null default auth.uid(),
  cliente_id text not null,
  tipo text not null,
  monto bigint not null,
  venta_id text null,
  metodo_pago text null,
  caja_sesion_id text null,
  usuario_id text not null,
  nota text null,
  fecha timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz null
);

alter table public.mi_negocio_movimientos_cliente enable row level security;

drop policy if exists movimientos_cliente_select_own
  on public.mi_negocio_movimientos_cliente;
create policy movimientos_cliente_select_own
  on public.mi_negocio_movimientos_cliente
  for select to authenticated
  using (user_id = auth.uid());

drop policy if exists movimientos_cliente_insert_own
  on public.mi_negocio_movimientos_cliente;
create policy movimientos_cliente_insert_own
  on public.mi_negocio_movimientos_cliente
  for insert to authenticated
  with check (user_id = auth.uid());

drop policy if exists movimientos_cliente_update_own
  on public.mi_negocio_movimientos_cliente;
create policy movimientos_cliente_update_own
  on public.mi_negocio_movimientos_cliente
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

drop policy if exists movimientos_cliente_delete_own
  on public.mi_negocio_movimientos_cliente;
create policy movimientos_cliente_delete_own
  on public.mi_negocio_movimientos_cliente
  for delete to authenticated
  using (user_id = auth.uid());

grant select, insert, update, delete
  on public.mi_negocio_movimientos_cliente to authenticated;
