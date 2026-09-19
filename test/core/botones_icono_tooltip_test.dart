import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Los botones de solo ícono se anuncian por su `tooltip` (lector de pantalla
/// y pulsación larga). Esta prueba recorre `lib/` y falla si aparece uno sin él.
void main() {
  test('todo IconButton y PopupMenuButton declara un tooltip', () {
    final patron = RegExp(r'(IconButton(\.\w+)?|PopupMenuButton<[^>]*>)\(');
    final sinTooltip = <String>[];

    for (final entidad in Directory('lib').listSync(recursive: true)) {
      if (entidad is! File ||
          !entidad.path.endsWith('.dart') ||
          entidad.path.endsWith('.g.dart') ||
          entidad.path.endsWith('.freezed.dart')) {
        continue;
      }
      final texto = entidad.readAsStringSync();
      for (final m in patron.allMatches(texto)) {
        var i = m.end;
        var nivel = 1;
        while (i < texto.length && nivel > 0) {
          if (texto[i] == '(') nivel++;
          if (texto[i] == ')') nivel--;
          i++;
        }
        if (!texto.substring(m.end, i).contains('tooltip:')) {
          final linea = texto.substring(0, m.start).split('\n').length;
          sinTooltip.add('${entidad.path}:$linea');
        }
      }
    }

    expect(sinTooltip, isEmpty, reason: 'Botones sin tooltip: $sinTooltip');
  });
}
