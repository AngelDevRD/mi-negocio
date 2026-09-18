import 'package:app_gestion/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'diaActualProvider programa un único Timer hasta la próxima medianoche '
    'y lo cancela al hacer dispose (sin timers pendientes)',
    () {
      FakeAsync().run((async) {
        final container = ProviderContainer();

        container.read(diaActualProvider);
        expect(async.pendingTimers, hasLength(1));

        container.dispose();
        expect(async.pendingTimers, isEmpty);
      });
    },
  );

  test(
    'diaActualProvider se reprograma con un único Timer nuevo al cruzar la '
    'medianoche (sin timers duplicados ni huérfanos)',
    () {
      FakeAsync().run((async) {
        final container = ProviderContainer();
        final sub = container.listen(diaActualProvider, (_, _) {});

        expect(async.pendingTimers, hasLength(1));

        async.elapse(const Duration(hours: 25));

        // El Timer original se disparó e invalidó el provider; con un
        // listener activo se reconstruye de inmediato y programa un único
        // Timer nuevo para la siguiente medianoche (no queda en cero ni se
        // acumulan varios).
        expect(async.pendingTimers, hasLength(1));

        sub.close();
        container.dispose();
        expect(async.pendingTimers, isEmpty);
      });
    },
  );
}
