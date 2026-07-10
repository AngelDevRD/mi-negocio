import 'package:pdf/widgets.dart' as pw;

/// Tema común de los PDF exportados (RF-EXP-01). Las fuentes base de `pdf`
/// (Helvetica, WinAnsi) cubren los acentos y la ñ del español.
Future<pw.ThemeData> exportPdfTheme() async => pw.ThemeData.base();
