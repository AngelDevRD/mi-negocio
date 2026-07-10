// =====================================================================
// Edge Function `licencias` — única puerta de la app de negocio hacia las
// tablas de licencias (usa service role; RLS niega acceso directo a anon).
//
// Desplegar: supabase functions deploy licencias
//
// Acciones (POST JSON { action, ... }):
//   solicitar : { nombreNegocio, telefono, deviceId, tipoDeseado }
//   activar   : { clave, deviceId }
//   validar   : { clave, deviceId }
//   renovar   : { clave, deviceId }
// Respuesta: { ok: boolean, licencia?: {...}, error?: string, mensaje?: string }
// =====================================================================

import { createClient } from "jsr:@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

type LicenciaDto = {
  clave: string;
  tipo: string;
  estado: string;
  fechaActivacion: string | null;
  fechaVencimiento: string | null;
  motivoSuspension: string | null;
};

function dto(l: Record<string, unknown>): LicenciaDto {
  return {
    clave: l.clave as string,
    tipo: l.tipo as string,
    estado: l.estado as string,
    fechaActivacion: (l.fecha_activacion as string) ?? null,
    fechaVencimiento: (l.fecha_vencimiento as string) ?? null,
    motivoSuspension: (l.motivo_suspension as string) ?? null,
  };
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

async function registrarHistorial(
  licenciaId: string,
  accion: string,
  detalle: Record<string, unknown>,
) {
  await supabase.from("historial_licencias").insert({
    licencia_id: licenciaId,
    accion,
    detalle,
    actor: "sistema",
  });
}

async function solicitar(body: Record<string, unknown>): Promise<Response> {
  const { nombreNegocio, telefono, deviceId, tipoDeseado } = body;
  if (!nombreNegocio || !deviceId) {
    return json({ ok: false, error: "Faltan datos de la solicitud." }, 400);
  }
  const { error } = await supabase.from("solicitudes_licencia").insert({
    tipo_solicitud: "nueva",
    nombre_negocio: nombreNegocio,
    telefono: telefono ?? null,
    device_id: deviceId,
    tipo_licencia_deseada: tipoDeseado ?? "local",
  });
  if (error) return json({ ok: false, error: error.message }, 500);
  return json({
    ok: true,
    mensaje:
      "Solicitud enviada. Recibirás tu clave de licencia cuando sea aprobada.",
  });
}

async function buscarLicencia(clave: string) {
  const { data } = await supabase
    .from("licencias")
    .select("*")
    .eq("clave", clave)
    .maybeSingle();
  return data;
}

async function activar(body: Record<string, unknown>): Promise<Response> {
  const { clave, deviceId } = body;
  if (!clave || !deviceId) {
    return json({ ok: false, error: "Clave y dispositivo requeridos." }, 400);
  }
  const lic = await buscarLicencia(clave as string);
  if (!lic) return json({ ok: false, error: "Clave de licencia inválida." }, 404);

  if (lic.estado === "suspendida") {
    return json({ ok: false, error: "Licencia suspendida.", licencia: dto(lic) });
  }
  if (lic.estado === "rechazada" || lic.estado === "vencida") {
    return json({ ok: false, error: `Licencia ${lic.estado}.`, licencia: dto(lic) });
  }
  // Ya activada en otro dispositivo → requiere transferencia aprobada (RN-18)
  if (lic.device_id_principal && lic.device_id_principal !== deviceId) {
    return json({
      ok: false,
      error:
        "La licencia está activa en otro dispositivo. Solicita una transferencia.",
    });
  }

  const { data, error } = await supabase
    .from("licencias")
    .update({
      estado: "activa",
      device_id_principal: deviceId,
      fecha_activacion: lic.fecha_activacion ?? new Date().toISOString(),
    })
    .eq("id", lic.id)
    .select()
    .single();
  if (error) return json({ ok: false, error: error.message }, 500);

  await registrarHistorial(lic.id, "activada", { deviceId });
  return json({ ok: true, licencia: dto(data) });
}

async function validar(body: Record<string, unknown>): Promise<Response> {
  const { clave, deviceId } = body;
  if (!clave || !deviceId) {
    return json({ ok: false, error: "Clave y dispositivo requeridos." }, 400);
  }
  const lic = await buscarLicencia(clave as string);
  if (!lic) return json({ ok: false, error: "Clave de licencia inválida." }, 404);

  if (lic.device_id_principal && lic.device_id_principal !== deviceId) {
    return json({
      ok: false,
      error: "La licencia pertenece a otro dispositivo.",
    });
  }

  // Vencimiento efectivo al validar
  if (
    lic.estado === "activa" &&
    lic.fecha_vencimiento &&
    new Date(lic.fecha_vencimiento) < new Date()
  ) {
    const { data } = await supabase
      .from("licencias")
      .update({ estado: "vencida" })
      .eq("id", lic.id)
      .select()
      .single();
    await registrarHistorial(lic.id, "vencida", {});
    return json({ ok: true, licencia: dto(data) });
  }

  return json({ ok: true, licencia: dto(lic) });
}

async function renovar(body: Record<string, unknown>): Promise<Response> {
  const { clave, deviceId } = body;
  if (!clave || !deviceId) {
    return json({ ok: false, error: "Clave y dispositivo requeridos." }, 400);
  }
  const lic = await buscarLicencia(clave as string);
  if (!lic) return json({ ok: false, error: "Clave de licencia inválida." }, 404);

  if (lic.device_id_principal && lic.device_id_principal !== deviceId) {
    return json({
      ok: false,
      error: "La licencia pertenece a otro dispositivo.",
    });
  }

  const { error } = await supabase.from("solicitudes_licencia").insert({
    tipo_solicitud: "renovacion",
    negocio_id: lic.negocio_id,
    licencia_id: lic.id,
    device_id: deviceId,
    estado: "pendiente",
  });
  if (error) return json({ ok: false, error: error.message }, 500);

  await registrarHistorial(lic.id, "renovacion_solicitada", { deviceId });
  return json({
    ok: true,
    mensaje:
      "Solicitud de renovación enviada. Se reflejará al confirmarse el pago.",
  });
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ ok: false, error: "Método no soportado." }, 405);
  }
  try {
    const body = await req.json();
    switch (body.action) {
      case "solicitar":
        return await solicitar(body);
      case "activar":
        return await activar(body);
      case "validar":
        return await validar(body);
      case "renovar":
        return await renovar(body);
      default:
        return json({ ok: false, error: "Acción desconocida." }, 400);
    }
  } catch (e) {
    console.error("licencias edge function:", e);
    return json({ ok: false, error: "Error interno." }, 500);
  }
});
