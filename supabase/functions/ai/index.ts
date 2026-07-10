// =====================================================================
// Edge Function `ai` — funciones de IA (Gemini/OpenAI/Anthropic) para
// app_gestion.
//
// Desplegar: supabase functions deploy ai
//
// Acciones (POST JSON { action, ... }):
//   mapColumns : { targetType, headers, sampleRows } -- FASE 20 (importación)
//   chat       : { messages, context }                -- FASE 21 (asistente)
//
// Las API keys se leen de la tabla `ia_api_keys` (editable desde admin_panel,
// ver 0004_ia_api_keys.sql) — puede haber varias, de distintos proveedores.
// Se prueban en orden (`orden` asc, solo `activo = true`); si una falla
// (p. ej. 429 de cuota agotada), se prueba la siguiente. Si la tabla está
// vacía, usa GEMINI_API_KEY (variable de entorno) como respaldo.
//
// Respuesta: { ok: boolean, ...datos específicos de la acción, error?: string }
// =====================================================================

import { createClient } from "jsr:@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

const GEMINI_MODELO_DEFECTO = "gemini-2.0-flash";

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

type ApiKeyConfig = { proveedor: string; apiKey: string; modelo: string };

type Contenido = { role: string; parts: { text: string }[] };

type GenerarParams = { systemInstruction?: string; contents: Contenido[] };

type GenerarResultado = { texto: string } | { error: string };

/// Keys activas (en orden de prioridad). Si no hay ninguna configurada en
/// `ia_api_keys`, usa `GEMINI_API_KEY` (variable de entorno) como respaldo.
async function obtenerApiKeysActivas(): Promise<ApiKeyConfig[]> {
  const { data } = await supabase
    .from("ia_api_keys")
    .select("proveedor, api_key, modelo")
    .eq("activo", true)
    .order("orden", { ascending: true });

  const keys: ApiKeyConfig[] = (data ?? []).map((fila) => ({
    proveedor: fila.proveedor as string,
    apiKey: fila.api_key as string,
    modelo: fila.modelo as string,
  }));

  if (keys.length === 0) {
    const envKey = Deno.env.get("GEMINI_API_KEY");
    if (envKey) {
      keys.push({
        proveedor: "gemini",
        apiKey: envKey,
        modelo: GEMINI_MODELO_DEFECTO,
      });
    }
  }

  return keys;
}

async function generarConGemini(
  apiKey: string,
  modelo: string,
  params: GenerarParams,
): Promise<GenerarResultado> {
  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/${modelo}:generateContent?key=${apiKey}`;

  const body: Record<string, unknown> = { contents: params.contents };
  if (params.systemInstruction) {
    body.systemInstruction = {
      parts: [{ text: params.systemInstruction }],
    };
  }

  const respuesta = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });

  if (!respuesta.ok) {
    return { error: `Gemini respondió ${respuesta.status}` };
  }

  const data = await respuesta.json();
  const texto = data?.candidates?.[0]?.content?.parts?.[0]?.text as
    | string
    | undefined;
  if (!texto) return { error: "Respuesta de Gemini sin contenido." };
  return { texto };
}

async function generarConOpenAI(
  apiKey: string,
  modelo: string,
  params: GenerarParams,
): Promise<GenerarResultado> {
  const messages: { role: string; content: string }[] = [];
  if (params.systemInstruction) {
    messages.push({ role: "system", content: params.systemInstruction });
  }
  for (const contenido of params.contents) {
    messages.push({
      role: contenido.role === "model" ? "assistant" : "user",
      content: contenido.parts.map((p) => p.text).join("\n"),
    });
  }

  const respuesta = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${apiKey}`,
    },
    body: JSON.stringify({ model: modelo, messages }),
  });

  if (!respuesta.ok) {
    return { error: `OpenAI respondió ${respuesta.status}` };
  }

  const data = await respuesta.json();
  const texto = data?.choices?.[0]?.message?.content as string | undefined;
  if (!texto) return { error: "Respuesta de OpenAI sin contenido." };
  return { texto };
}

async function generarConAnthropic(
  apiKey: string,
  modelo: string,
  params: GenerarParams,
): Promise<GenerarResultado> {
  const messages = params.contents.map((contenido) => ({
    role: contenido.role === "model" ? "assistant" : "user",
    content: contenido.parts.map((p) => p.text).join("\n"),
  }));

  const body: Record<string, unknown> = {
    model: modelo,
    max_tokens: 4096,
    messages,
  };
  if (params.systemInstruction) body.system = params.systemInstruction;

  const respuesta = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": apiKey,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify(body),
  });

  if (!respuesta.ok) {
    return { error: `Anthropic respondió ${respuesta.status}` };
  }

  const data = await respuesta.json();
  const texto = data?.content?.[0]?.text as string | undefined;
  if (!texto) return { error: "Respuesta de Anthropic sin contenido." };
  return { texto };
}

const ADAPTADORES_PROVEEDOR: Record<
  string,
  (apiKey: string, modelo: string, params: GenerarParams) => Promise<GenerarResultado>
> = {
  gemini: generarConGemini,
  openai: generarConOpenAI,
  anthropic: generarConAnthropic,
};

/// Prueba cada key activa en orden hasta obtener una respuesta válida.
/// Si todas fallan (p. ej. 429 de cuota agotada), devuelve el error de la
/// última. Permite combinar proveedores y rotar entre varias API keys.
async function generarConIA(
  keys: ApiKeyConfig[],
  params: GenerarParams,
): Promise<GenerarResultado> {
  if (keys.length === 0) return { error: "IA no configurada todavía." };

  let ultimoError = "";
  for (const key of keys) {
    const adaptador = ADAPTADORES_PROVEEDOR[key.proveedor];
    if (!adaptador) {
      ultimoError = `Proveedor "${key.proveedor}" no soportado.`;
      continue;
    }
    const resultado = await adaptador(key.apiKey, key.modelo, params);
    if ("texto" in resultado) return resultado;
    ultimoError = resultado.error;
  }
  return { error: ultimoError };
}

// =====================================================================
// mapColumns (FASE 20): sugiere el mapeo de columnas de un Excel hacia los
// campos que la app espera, según el tipo de dato destino.
// =====================================================================

const ESQUEMAS_DESTINO: Record<string, string> = {
  productos:
    "nombre (texto, requerido), categoria (texto libre), unidad (texto: unidad/libra/caja/paquete...), " +
    "precioCompra (dinero), precioVenta (dinero), stockActual (numero), stockMinimo (numero), activo (si/no)",
  gastos:
    "categoria (texto libre), concepto (texto), fecha (fecha), monto (dinero)",
  empleados:
    "tipo (enum: ventas o delivery), nombre (texto, requerido), cedula (texto), direccion (texto), " +
    "telefono (texto), fechaIngreso (fecha), salario (dinero), frecuenciaPago (texto), activo (si/no)",
  compras:
    "proveedor (texto, nombre del proveedor), producto (texto, nombre del producto), cantidad (numero), " +
    "costoUnitario (dinero), numeroFactura (texto opcional), fecha (fecha)",
  ventas:
    "producto (texto, nombre del producto), cantidad (numero), precioUnitario (dinero), " +
    "costoUnitario (dinero), fecha (fecha)",
};

const TRANSFORMS_VALIDOS = ["texto", "numero", "dinero", "fecha", "enum", "si_no"];

async function mapColumns(body: Record<string, unknown>): Promise<Response> {
  const { targetType, headers, sampleRows } = body as {
    targetType?: string;
    headers?: string[];
    sampleRows?: unknown[][];
  };

  if (!targetType || !ESQUEMAS_DESTINO[targetType] || !Array.isArray(headers)) {
    return json({ ok: false, error: "Datos de mapeo incompletos." }, 400);
  }

  const keys = await obtenerApiKeysActivas();
  if (keys.length === 0) return json({ ok: false, error: "IA no configurada todavía." }, 503);

  const prompt = `Vas a ayudar a mapear columnas de un archivo Excel a los campos de una app de gestión de negocios.

Campos esperados para "${targetType}":
${ESQUEMAS_DESTINO[targetType]}

Encabezados del Excel (en el orden que aparecen):
${JSON.stringify(headers)}

Filas de ejemplo (para entender el formato de los datos):
${JSON.stringify(sampleRows ?? [])}

Responde SOLO un JSON (sin texto adicional, sin markdown) con esta forma exacta:
{
  "mapping": {
    "<campoApp>": { "columna": "<encabezado exacto del excel o null si no aplica>", "transform": "<una de: ${TRANSFORMS_VALIDOS.join(", ")}>", "enumValores"?: { "<valor del excel>": "<valor app>" } }
  },
  "advertencias": ["<texto>", ...]
}

Incluye una entrada en "mapping" por cada campo esperado. Si una columna del excel no corresponde a ningún campo, ignórala. Si un campo no tiene columna correspondiente, usa "columna": null. Para campos enum (como "tipo" de empleados), incluye "enumValores" mapeando los valores que veas en las filas de ejemplo a los valores esperados.`;

  const resultado = await generarConIA(keys, {
    contents: [{ role: "user", parts: [{ text: prompt }] }],
  });
  if ("error" in resultado) return json({ ok: false, error: resultado.error }, 502);

  try {
    const limpio = resultado.texto.trim().replace(/^```json\s*|```$/g, "");
    const parsed = JSON.parse(limpio);
    return json({ ok: true, mapping: parsed.mapping ?? {}, advertencias: parsed.advertencias ?? [] });
  } catch {
    return json({ ok: false, error: "No se pudo interpretar la respuesta de la IA." }, 502);
  }
}

// =====================================================================
// chat (FASE 21): asistente de IA del negocio.
// =====================================================================

async function chat(body: Record<string, unknown>): Promise<Response> {
  const { messages, context } = body as {
    messages?: { role: string; texto: string }[];
    context?: Record<string, unknown>;
  };

  if (!Array.isArray(messages) || messages.length === 0) {
    return json({ ok: false, error: "Falta el mensaje." }, 400);
  }

  const keys = await obtenerApiKeysActivas();
  if (keys.length === 0) return json({ ok: false, error: "IA no configurada todavía." }, 503);

  const nombreNegocio = (context?.negocio as Record<string, unknown> | undefined)
    ?.nombre as string | undefined;

  const systemInstruction =
    `Eres un asistente para el negocio "${nombreNegocio ?? "del usuario"}". ` +
    `Responde ÚNICAMENTE preguntas relacionadas con este negocio (finanzas, inventario, ventas, compras, ` +
    `gastos, empleados, recomendaciones de gestión), usando este contexto del negocio en formato JSON:\n` +
    `${JSON.stringify(context ?? {})}\n` +
    `Si la pregunta no tiene relación con el negocio, responde amablemente que solo puedes ayudar con ` +
    `temas del negocio. Responde siempre en español, de forma breve y clara.`;

  const contents = messages.map((m) => ({
    role: m.role === "asistente" ? "model" : "user",
    parts: [{ text: m.texto }],
  }));

  const resultado = await generarConIA(keys, { systemInstruction, contents });
  if ("error" in resultado) return json({ ok: false, error: resultado.error }, 502);

  return json({ ok: true, respuesta: resultado.texto });
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return json({ ok: false, error: "Método no soportado." }, 405);
  }
  try {
    const body = await req.json();
    switch (body.action) {
      case "mapColumns":
        return await mapColumns(body);
      case "chat":
        return await chat(body);
      default:
        return json({ ok: false, error: "Acción desconocida." }, 400);
    }
  } catch (e) {
    console.error("ai edge function:", e);
    return json({ ok: false, error: "Error interno." }, 500);
  }
});
