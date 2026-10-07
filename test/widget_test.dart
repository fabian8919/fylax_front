// Smoke test de Fylax: la app arranca y muestra la pantalla de login.

import 'package:fylax_front/app/app.dart';
import 'package:fylax_front/app/di/injection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('La app arranca en la pantalla de login', (tester) async {
    await configureDependencies();
    await tester.pumpWidget(const FylaxApp());
    // Deja correr las animaciones de entrada escalonadas (timers).
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Fylax'), findsOneWidget);
    expect(find.text('Continuar con Google'), findsOneWidget);

    // Drena cualquier timer residual antes de cerrar el árbol de widgets.
    await tester.pump(const Duration(seconds: 2));
  });
}
